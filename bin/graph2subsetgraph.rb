#!/usr/bin/env ruby
# Takes a .graph and a desired clustering (i.e. a Yamlised concept-exemplar map)
# and outputs a subset graph in `.graph` format.
#
# Usage: ruby #{$0} file.graph subset.yaml > file2.graph

require 'lib/Graph'
require 'lib/Wordmap'

graph_f = ARGV.shift
gold = YAML.load_file(ARGV.shift)
wordmap_f = graph_f.gsub(/graph$/,"wordmap")

wordmap = Wordmap.new(wordmap_f)
graph = Graph.new(graph_f, wordmap)
exemplars = gold.values.flatten.uniq

exemplars.each do |a|
  (exemplars - [a]).each do |b|
    edge = graph.edge_between(a,b)
    puts ([a,b].map { |x| wordmap.reverse_lookup(x.to_sym) } + [edge]).join("\t") if not edge.nil?
  end
end