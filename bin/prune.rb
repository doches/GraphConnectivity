#!/usr/bin/env ruby
# Takes a .graph file and a choice of pruning method and outputs a pruned graph
#
# Usage: ruby #{$0} file.graph -m <mean, median> [options]

require 'lib/Wordmap'
require 'lib/Graph'
require 'optparse'

known_prunings = [:mean, :median]

# Default options
options = {:method => :none, :output => :dot, :threshold => -1.0}

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
  # Implement thresholding
  opts.on("-t THRESHOLD", 
          "--threshold THRESHOLD", 
          "Only output edges above a specified weight; disabled by default") do |t|
    options[:threshold] = t.to_f
  end

  # Specify the output format (dot, graph, human-readable graph)
  opts.on("-o FORMAT",
          "--output FORMAT",
          Graph.formats,
          "Output re-weighted graph as (#{Graph.formats.join(', ')}; defaults to #{options[:output]})") do |format|
    options[:output] = format
  end
end

parser.parse!

graph_f = ARGV.shift

graph = Graph.new(graph_f)
graph.threshold = options[:threshold]
wordmap = graph.wordmap

if options[:method] != :none
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
end

# Output in specified format
puts graph.format(options[:output])