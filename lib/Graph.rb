class Graph
  begin
    require 'progressbar'
    @use_progressbar = true
  rescue LoadError
    STDERR.puts "Could not load progressbar gem"
    @use_progressbar = false
  end
  attr_accessor :minimal
  
  def initialize(path_to_graph, wordmap)
    @minimal = false
    @edges = {}
    @wordmap = wordmap
    IO.foreach(path_to_graph) do |line|
      from, to, weight = *(line.strip.split(/\s+/))
      from, to, weight = wordmap[from.to_i], wordmap[to.to_i], weight.to_f
      
      @edges[from] ||= {}
      @edges[to] ||= {}
      
      @edges[from][to] = weight
      @edges[to][from] = weight
    end
  end
  
  def edges_from(node)
    @edges[node]
  end
  
  def edge_between(a,b)
    return @edges[a.to_sym].nil? ? [] : @edges[a.to_sym][b.to_sym]
  end
  
  def to_s(human_readable=false)
    str = []
    seen = []
    progress = ProgressBar.new("Graph#to_s",@edges.keys.size**2) if @use_progressbar
    @edges.each_pair do |from, list|
      list.each_pair do |to, weight|
        if @minimal and not seen.include?([from, to])
          vertices = [from, to]
          vertices.map! { |x| @wordmap.reverse_lookup(x) } if not human_readable
          str.push(vertices + [weight])
          seen.push [to, from] if @minimal
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
        if decorate["penwidth"] <= 0
          decorate["penwidth"] = 1
          decorate["color"] = "grey90"
        end
        decorate = decorate.map { |k,v| "#{k}=#{v}" }.join(", ")
        str.push "\t#{@wordmap.reverse_lookup(from)} -- #{@wordmap.reverse_lookup(to)} [#{decorate}];"
        progress.inc if @use_progressbar
      end
    end
    progress.finish if @use_progressbar
    
    str = str.join("\n")
    
    return "graph {\n#{str}\n}"
  end
end