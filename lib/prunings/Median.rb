module Median
  def prune!
    @edges.each_pair do |from, others|
      all = others.map { |to, weight| [to, weight] }.sort { |a,b| a[1] <=> b[1] }
      median = all[all.size/2]
      
      retained_edges = {}
      all[all.index(median)..(all.size-1)].each do |pair|
        retained_edges[pair[0]] = pair[1]
      end
      @edges[from] = retained_edges
    end
  end
end