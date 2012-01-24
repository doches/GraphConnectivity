require 'lib/Wordmap'

class Graph
  attr_accessor :minimal, :wordmap, :threshold
  
  def initialize(path_to_graph, wordmap=nil)
    begin
      require 'progressbar'
      @use_progressbar = true
    rescue LoadError
      STDERR.puts "Could not load progressbar gem"
      @use_progressbar = false
    end
    # If we weren't given a wordmap, try to find one
    if wordmap.nil?
      # Try path_to_file.wordmap...
      if not load_wordmap_file(path_to_graph.gsub(/graph$/,"wordmap"))
        # break of path components until we find something
        path = File.basename(path_to_graph.gsub(/\.graph$/,"")).split(".")
        found = false
        while not path.empty? and not found
          path.pop
          wordmap_f = File.join(File.dirname(path_to_graph), "#{path.join('.')}.wordmap")
          found = load_wordmap_file(wordmap_f)
          STDERR.puts wordmap_f
        end
      end
      
      if @wordmap.nil?
        STDERR.puts "[Graph] Failed to find any reasonable wordmap; dying"
        exit(1)
      end
    end
      
    @minimal = true
    @threshold = -1.0
    @edges = {}
    @wordmap = wordmap if not wordmap.nil?
    IO.foreach(path_to_graph) do |line|
      from, to, weight = *(line.strip.split(/\s+/))
      from, to, weight = @wordmap[from.to_i], @wordmap[to.to_i], weight.to_f
      
      @edges[from] ||= {}
      @edges[to] ||= {}
      
      @edges[from][to] = weight
      @edges[to][from] = weight
    end
  end
  
  def load_wordmap_file(wordmap_f)
    if File.exists?(wordmap_f)
      begin
        @wordmap = Wordmap.new(wordmap_f)
        STDERR.puts "[Graph] Using #{wordmap_f}"
        return true
      rescue
        return false
      end
    end
    return false
  end
  
  def edges_from(node)
    @edges[node]
  end
  
  def edge_between(a,b)
    return @edges[a.to_sym].nil? ? [] : @edges[a.to_sym][b.to_sym]
  end
  
  def Graph.formats
    [:dot, 
     :human_graph, 
     :graph, 
     :pairs,
     :human_pairs]
  end
  
  def format(method)
    case method
      when :dot
        return self.to_dot
      when :human_graph
        return self.to_s(true)
      when :graph
        return self.to_s
      when :pairs
        return self.to_pairs
      when :human_pairs
        return self.to_pairs(true)
      else
        STDERR.puts "[Graph] Unknown graph output format \"#{method}\" specified."
        return nil
    end
  end
  
  def to_s(human_readable=false)
    str = []
    seen = {}
    progress = ProgressBar.new("Graph#to_s",@edges.keys.size**2) if @use_progressbar
    @edges.each_pair do |from, list|
      list.each_pair do |to, weight|
        tf = "#{to}_#{from}".to_sym
        ft = "#{from}_#{to}".to_sym
        if not @minimal or (@minimal and seen[ft].nil?)
          vertices = [from, to]
          vertices.map! { |x| @wordmap.reverse_lookup(x) } if not human_readable
          str.push(vertices + [weight]) if weight.to_f >= @threshold
          if @minimal
            seen[tf] = true
            seen[ft] = true
          end
        end
        progress.inc if @use_progressbar
      end
    end
    progress.finish if @use_progressbar
    return str.map { |x| x.join("\t") }.join("\n")
  end
  
  def to_dot
    str = []
    str.push "\tnode [color=grey, fontsize=12, fontname=Helvetica, fillcolor=white];"
    str.push "\tedge [penwidth=1, color=grey, fontcolor=red, fontname=Helvetica];"
    str.push "\tgraph [outputorder=edgesfirst];"
    
    str.push "\t"
    
    seen = []
    progress = ProgressBar.new("Graph#to_dot",@edges.keys.size**2) if @use_progressbar
    nodes = {}
    @edges.each_pair do |from, list|
      list.each_pair do |to, weight|
        if weight >= @threshold
          # Make sure we only print node info once per node
          [from, to].each do |label| 
            if nodes[label].nil?
              str.push "\t#{@wordmap.reverse_lookup(label)} [label=\"#{label}\"];"
              nodes[label] = true
            end
          end
          decorate = {}
          decorate["weight"] = weight
          decorate["penwidth"] = (weight*10).to_i
          if decorate["penwidth"] <= 0 and weight >= 0.05
            decorate["penwidth"] = 1
            decorate["color"] = "grey90"
          end
          decorate = decorate.map { |k,v| "#{k}=#{v}" }.join(", ")
          str.push "\t#{@wordmap.reverse_lookup(from)} -- #{@wordmap.reverse_lookup(to)} [#{decorate}];" if not seen.include?([from, to])
          seen.push [to, from]
          seen.push [from, to]
        end
        progress.inc if @use_progressbar
      end
    end
    progress.finish if @use_progressbar
    
    str = str.join("\n")
    
    return "graph {\n#{str}\n}"
  end
  
  def to_pairs(human=false)
    str = []
    @edges.each_pair do |from, others|
      others.each_pair do |to, weight|
        nodes = [from, to]
        nodes.map! { |x| @wordmap.reverse_lookup(x) } if not human
        str.push nodes.join("\t") if weight.to_f >= @threshold
      end
    end
    
    return str.join("\n")
  end
end