module ShortestPath
  def shortest_path(from, to)
    @shortestpath_cache ||= {}
    ft = "#{from}_#{to}".to_sym
    if not @shortestpath_cache[ft].nil?
      return @shortestpath_cache[ft]
    end
    
    path = shortest_path_helper(from, to, [])
    if not path.nil? and not path.map { |x| x[0] }.include?(to) 
      last_stop = path[path.size-1][0]
      last_dist = self.edges_from(last_stop)[to]
      path = path + [[to, last_dist]]
    end
    if not path.nil?
      @shortestpath_cache[ft] = path
      @shortestpath_cache["#{to}_#{from}".to_sym] = path.reverse
    end
    return path
  end
  
  def shortest_path_helper(from, to, progress=nil)
    STDERR.puts progress.map { |x| x[0] }.join(" -> ")
    ft = "#{from}_#{to}".to_sym
    tf = "#{to}_#{from}".to_sym
    return @shortestpath_cache[ft] if not @shortestpath_cache[ft].nil?
    return @shortestpath_cache[tf] if not @shortestpath_cache[tf].nil?
    progress ||= []
    return progress if from == to
    all_edges_from = self.edges_from(from)
    return nil if all_edges_from.nil?
    steps = all_edges_from.map { |k,v| [k,v] } # e.g. [[:yacht, 0.29], ...]
    on_path = progress.map { |x| x[0] } + [from]
    steps.reject! { |x| on_path.include?(x[0]) }
    return nil if steps.empty?
    paths = steps.map { |pair| shortest_path_helper(pair[0], to, progress.dup + [[from, pair[1]]]) }.reject { |x| x.nil? }.map { |path| [path.inject(0) { |s,k| s += k[1] }, path] }
    paths.sort! { |a,b| a[0] <=> b[0] }
    return nil if paths.empty?
    return paths[0][1]
  end
  
  def path_to_edges(path)
    (0..path.size-2).map { |i| [path[i][0], path[i+1][0]] }
  end
  
  def all_shortest_paths
    hash = {}
    progress = ProgressBar.new("Computing paths",@wordmap.words.size**2) if @use_progressbar
    @wordmap.words.map do |a|
      (@wordmap.words - [a]).map do |b|
        hash[[a,b]] = self.shortest_path(a,b)
        progress.inc if @use_progressbar
      end
    end
    progress.finish if @use_progressbar
    return hash
  end
  
  def all_edges_on_shortest_paths
    edges = []
    self.all_shortest_paths.values.map { |x| self.path_to_edges(x) }.each { |x| edges.push x }
    return edges.flatten(1)
  end
  
  def reweight!
    counts = {}
    self.all_edges_on_shortest_paths.each do |edge|
      counts[edge] ||= 0
      counts[edge] += 1
    end
    
    counts.keys.each do |edge|
      @edges[edge[0]][edge[1]] = counts[edge]
      @edges[edge[1]][edge[0]] = counts[edge]
    end
  end
end