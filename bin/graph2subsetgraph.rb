#!/usr/bin/env ruby
# Takes a .graph, a gold-standard clustering, and a list of category names and 
# outputs a subset of the graph containing only those elements
#
# Usage: ruby #{$0} file.graph gold.yaml catA catB ... > file2.graph

require 'lib/Graph'
require 'lib/Wordmap'

graph_f = ARGV.shift
gold = YAML.load_file(ARGV.shift)
wordmap_f = graph_f.gsub(/graph$/,"wordmap")
categories = ARGV

wordmap = Wordmap.new(wordmap_f)
graph = Graph.new(graph_f, wordmap)

exemplars = categories.map { |category| gold[category][0..4] }.flatten.uniq
p exemplars
exemplars.each do |a|
  (exemplars - [a]).each do |b|
    edge = graph.edge_between(a,b)
    puts ([a,b].map { |x| wordmap.reverse_lookup(x.to_sym) } + [edge]).join("\t") if not edge.nil?
  end
end