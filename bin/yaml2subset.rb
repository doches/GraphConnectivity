#!/usr/bin/env ruby
# Takes a yamlized list of category:exemplars and extracts a subset of categories.
#
# Usage: ruby #{$0} file.yaml category1 category2 ...

Exemplars_Per_Category = 10

require 'rubygems'
require 'wordnet'
require 'highline/import'

console = HighLine.new(STDIN, STDERR)

yaml = ARGV.shift
gold = YAML.load_file(yaml)

categories = []
while not ARGV.empty?
  category = ARGV.shift
  if gold.keys.include?(category)
    categories.push category
  else
    console.say("Source clustering <%=color('#{yaml}', :yellow)%> doesn't include category <%=color('#{category}',:bold, :red)%>")
  end
end

subset = gold.reject { |category,exemplars| not categories.include?(category) }

subset.each_pair do |category, exemplars|
  subset[category] = exemplars.shuffle[0..Exemplars_Per_Category-1] if exemplars.size > Exemplars_Per_Category
end

puts subset.to_yaml