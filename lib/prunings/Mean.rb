module Mean
  def prune!
    @edges.each_pair do |from, others|
      all = others.map { |to, weight| [to, weight] }.sort { |a,b| a[1] <=> b[1] }
      mean = all.inject(0) { |s,x| s += x[1] } / all.size
      
      retained_edges = {}
      all.each do |pair|
        retained_edges[pair[0]] = pair[1] if pair[1] >= mean
      end
      @edges[from] = retained_edges
    end
  end
end