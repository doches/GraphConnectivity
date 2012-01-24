#!/usr/bin/env ruby
# Takes a .graph and a .wordmap and outputs a reweighted version of the graph using 
# inverse shortest path
#
# Usage: ruby #{$0} file.graph [options] > file2.graph

require 'lib/Wordmap'
require 'lib/Graph'
require 'optparse'

known_measures = [:shortest_path, :degree, :kpp]

# Default options
options = {:measure => :none, :output => :dot}

# Parse command-line options
parser = OptionParser.new do |opts|
  opts.banner = "Takes a .graph and outputs a reweighted version of the graph"
  opts.separator ""
  opts.separator "Usage: #{$0} file.graph [options] > file2.graph"
  opts.separator ""
  opts.separator "Options:"
  
  # Specify reweighting measure
  opts.on("-m MEASURE", 
          "--measure MEASURE", 
          known_measures, 
          "Use measure (#{known_measures.join(', ')}; defaults to #{options[:measure]})") do |m|
    options[:measure] = m
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

if ARGV.empty?
  puts parser
  exit(1)
end

graph_f = ARGV.shift

graph = Graph.new(graph_f)
wordmap = graph.wordmap

# Load requested reweighting function
case options[:measure]
  when :shortest_path
    require 'lib/measures/ShortestPath'
    class Graph
      include ShortestPath
    end
  when :degree
    require 'lib/measures/Degree'
    class Graph
      include Degree
    end
  when :kpp
    require 'lib/measures/KPP'
    class Graph
      include KPP
    end
  else
    # Do nothing!
    STDERR.puts "Reweight called without a specified measure; using old weights instead."
    class Graph
      def reweight!
      end
    end
end

# Actually do the reweighting
graph.reweight!

# Output in specified format
puts graph.format(options[:output])