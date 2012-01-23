#!/usr/bin/env ruby
# Takes a graph file, looks for the corresponding wordmap, and prints a labeled .dot
#
# Usage: ruby #{$0} file.graph > file.dot

require 'lib/Graph'
require 'lib/Wordmap'

graph_f = ARGV.shift
wordmap_f = graph_f.gsub(/graph$/,"wordmap")

wordmap = Wordmap.new(wordmap_f)
graph = Graph.new(graph_f, wordmap)
puts graph.to_dot