#!/usr/bin/env ruby
# Takes a .graph file and a choice of pruning method and outputs a pruned graph
#
# Usage: ruby #{$0} file.graph -m <mean, median> [options]

require 'lib/Wordmap'
require 'lib/Graph'
require 'optparse'

graph_f = ARGV.shift
wordmap_f = graph_f.gsub(/graph$/,"wordmap")

wordmap = Wordmap.new(wordmap_f)
graph = Graph.new(graph_f, wordmap)

known_prunings = [:mean, :median]
known_formats = [:dot, :graph, :human_graph]

# Default options
options = {:method => :none, :output => :dot}

# Parse command-line options
parser = OptionParser.new do |opts|
  opts.banner = "Takes a .graph file and a choice of pruning method and outputs a pruned graph"
  opts.separator ""
  opts.separator "Usage: #{$0} file.graph -m <mean, median> [options]"
  opts.separator ""
  opts.separator "Options:"
  
  # Specify reweighting measure
  opts.on("-m METHOD", 
          "--method METHOD", 
          known_prunings, 
          "Use pruning method (#{known_prunings.join(', ')}; defaults to #{options[:method]})") do |m|
    options[:method] = m
  end

  # Specify the output format (dot, graph, human-readable graph)
  opts.on("-o FORMAT",
          "--output FORMAT",
          known_formats,
          "Output re-weighted graph as (#{known_formats.join(', ')}; defaults to #{options[:output]})") do |format|
    options[:output] = format
  end
end.parse!

if options[:method] == :none
  STDERR.puts "Pruning method required!\n"
  STDERR.puts parser
  exit(1)
end

# Build a module/file name from the prune method, and inject it into Graph
klass = options[:method].to_s.split("_").map { |x| x.capitalize }.join("")
file = File.join("lib","prunings",klass)
require(file)
mixin = <<RUB
class Graph
  include #{klass}
end
RUB
eval(mixin)

# Prune! 
graph.prune!

# Output in specified format
case options[:output]
  when :dot
    puts graph.to_dot
  when :human_graph
    puts graph.to_s(true)
  when :graph
    puts graph.to_s
  else
    STDERR.puts "Unknown graph output format \"#{options[:output]}\" specified."
end