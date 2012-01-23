#!/usr/bin/env ruby
# Takes a .graph and a .wordmap and outputs a reweighted version of the graph using 
# inverse shortest path
#
# Usage: ruby #{$0} file.graph [options] > file2.graph

require 'lib/Wordmap'
require 'lib/Graph'
require 'optparse'

graph_f = ARGV.shift
wordmap_f = graph_f.gsub(/graph$/,"wordmap")

wordmap = Wordmap.new(wordmap_f)
graph = Graph.new(graph_f, wordmap)

known_measures = [:shortest_path, :degree, :kpp]
known_formats = [:dot, :graph, :human_graph]

# Default options
options = {:measure => :none, :output => :dot, :minimal => false}

# Parse command-line options
OptionParser.new do |opts|
  opts.banner = "Takes a .graph and a .wordmap and outputs a reweighted version of the graph"
  opts.separator ""
  opts.separator "Usage: #{$0} file.graph file.wordmap [options] > file2.graph"
  opts.separator ""
  opts.separator "Options:"
  
  # Specify reweighting measure
  opts.on("-m MEASURE", 
          "--measure MEASURE", 
          known_measures, 
          "Use measure (#{known_measures.join(', ')}; defaults to #{options[:measure]})") do |m|
    options[:measure] = m
  end
  
  # Don't print redundant ( A -- B, B -- A ) edges
  opts.on("-t", "--trim", "Do not print redundant edges") { |v| options[:minimal] = true }
  
  # Specify the output format (dot, graph, human-readable graph)
  opts.on("-o FORMAT",
          "--output FORMAT",
          known_formats,
          "Output re-weighted graph as (#{known_formats.join(', ')}; defaults to #{options[:output]})") do |format|
    options[:output] = format
  end
end.parse!

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