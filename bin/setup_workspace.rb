# Symlink and chmod scripts in `bin/` into the current working directory
#
# Usage: ruby #{$0}

require 'highline/import'
require 'optparse'

options = {:clean => false, :verbose => true, :dry => false}
OptionParser.new do |opts|
  opts.banner = "Symlink and chmod scripts in `bin/` into the current working directory"
  opts.separator ""
  opts.separator "Usage: #{$0} [options]"
  opts.separator ""
  opts.separator "Options:"
  
  # Specify reweighting measure
  opts.on("-c", 
          "--clean",  
          "Remove existing symlinks only") do |c|
    options[:clean] = true
  end
  opts.on("-s", 
          "--silent",  
          "Don't print verbose log messages") do |v|
    options[:verbose] = false
  end
  opts.on("-d", 
          "--dry",  
          "Do a dry run; don't actually execute any commands") do |v|
    options[:dry] = true
  end
end.parse!

ignore = [$0]

Dir.glob("bin/*.rb").each do |script|
  if not ignore.include?(script)
    bin = File.basename(script).gsub('.rb','')
    if File.exists?(bin)
      say("<%= color('rm',:bold, :red) %> #{bin}") if options[:verbose]
      `rm #{bin}` if not options[:dry]
    end
    if not options[:clean]
      say("<%= color('chmod',:bold, :green) %> #{script}") if options[:verbose]
      `chmod +x #{script}` if not options[:dry]
      say("<%= color('ln',:bold, :green) %> #{script} #{bin}") if options[:verbose]
      `ln -s #{script} #{bin}` if not options[:dry]
      puts "" if options[:verbose]
    end
  else
    if options[:verbose]
      say("<%= color('ignore', :bold, :yellow) %> #{script}") if not options[:clean]
      puts ""
    end
  end
end