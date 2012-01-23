require 'lib/measures/ShortestPath'

module KPP
  include ShortestPath
  
  def kpp(node)
    @kpp_cache ||= {}
    return @kpp_cache[node] if not @kpp_cache[node].nil?
    
    numerator = (@wordmap.words - [node]).inject(0) { |sum, word| sum += 1.0/@paths[[node,word]].size }
    den = @wordmap.words.size - 1
    
    @kpp_cache[node] = numerator.to_f / den
    return @kpp_cache[node]
  end

  def reweight!
    @paths = self.all_shortest_paths
    new_edges = {}
    @edges.each_pair do |from, list|
      new_edges[from] ||= {}
      list.each_pair do |to, weight|
        new_edges[from][to] = (kpp(from) + kpp(to))/2.0
      end
    end
    @edges = new_edges
  end
end