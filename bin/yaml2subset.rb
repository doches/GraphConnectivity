# Takes a yamlized list of category:exemplars and extracts a subset of categories.
#
# Usage: ruby #{$0} file.yaml category1 category2 ...

require 'rubygems'
require 'wordnet'

yaml = ARGV.shift
gold = YAML.load_file(yaml)

categories = []
while not ARGV.empty?
  categories.push ARGV.shift
end

subset = gold.reject { |category,exemplars| not categories.include?(category) }

puts subset.to_yaml