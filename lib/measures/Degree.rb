module Degree
  def degree(node)
    @degree_cache ||= {}
    @degree_cache[node] ||= edges_from(node).values.inject(0) { |s,x| s += x }
    @highest_degree = [node, @degree_cache[node]] if @highest_degree.nil? or @degree_cache[node] > @highest_degree[1]
    
    return @degree_cache[node]
  end
  
  def reweight!
    new_edges = {}
    
    # Fill in degree cache for nodes
    progress = ProgressBar.new("reweighting",@edges.size + @edges.size**2) if @use_progressbar
    @edges.keys.each do |from| 
      degree(from)
      progress.inc if @use_progressbar
    end
    
    # Compute edge degrees
    @edges.each_pair do |from, list|
      new_edges[from] ||= {}
      list.each_pair do |to, weight|
        new_edges[from][to] = (degree(from) + degree(to))/2.0
        # Normalise against highest possible degree
        new_edges[from][to] /= @highest_degree[1]
        progress.inc if @use_progressbar
      end
    end
    progress.finish if @use_progressbar
    
    @edges = new_edges
  end
end