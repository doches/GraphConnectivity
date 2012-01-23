#!/usr/bin/env ruby
# Takes a .dot, renders it, and opens it
#
# Usage: ruby #{$0} file.dot

dot = ARGV.shift
out = dot.gsub(/dot$/,"png")
`fdp -Tpng #{dot} -o #{out} && open #{out}`
