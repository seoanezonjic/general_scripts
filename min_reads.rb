#! /usr/bin/env ruby
require 'optparse'

#################################################################################################
## INPUT PARSING
#################################################################################################
options = {}

optparse = OptionParser.new do |opts|
        options[:file] = nil
        opts.on( '-f', '--file PATH', 'Input reads file') do |file|
                options[:file] = file
        end

        options[:min_reads] = 10
        opts.on( '-m', '--min_reads INTEGER', 'Minimun reads per sequence (default 10)' ) do |min_reads|
                options[:min_reads] = min_reads.to_i
        end

        # Set a banner, displayed at the top of the help screen.
        opts.banner = "Usage: #{__FILE__} -f file_path -m min_reads \n\n"


        # This displays the help screen
        opts.on( '-h', '--help', 'Display this screen' ) do
                puts opts
                exit
        end

end # End opts

# parse options and remove from ARGV
optparse.parse!

#################################################################################################

if options[:file].nil?
        puts 'Reads file not defined'
        Process.exit
end


array = []

File.open(options[:file]).each do |line|							
		line.chomp!
		fields = line.split("\t")

		gene_name = fields.shift	

		fields.map!{|col| col.to_i}				
		
		if fields.select{|col| col >= options[:min_reads]}.count == fields.length	
				row_array = [gene_name].concat(fields)		
				array << row_array				
		end
end

array.each do |row|
	puts "#{row[0]}"					
end