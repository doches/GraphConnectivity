module Degree
  def degree(node)
    @degree_cache ||= {}
    @degree_cache[node] ||= edges_from(node).values.inject(0) { |s,x| s += x }
    
    return @degree_cache[node]
  end
  
  def reweight!
    new_edges = {}
    progress = ProgressBar.new("reweighting",@edges.size**2) if @use_progressbar
    @edges.each_pair do |from, list|
      new_edges[from] ||= {}
      list.each_pair do |to, weight|
        new_edges[from][to] = (degree(from) + degree(to))/2.0
        progress.inc if @use_progressbar
      end
    end
    progress.finish if @use_progressbar
    @edges = new_edges
  end
end