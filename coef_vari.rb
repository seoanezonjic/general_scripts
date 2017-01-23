#! /usr/bin/env ruby

require 'optparse'
require 'descriptive_statistics'

#################################################################################################
## INPUT PARSING
#################################################################################################
options = {}

optparse = OptionParser.new do |opts|
        options[:table] = nil
        opts.on( '-t', '--table PATH', 'Input table') do |table|
                options[:table] = table
        end

        options[:max_coef_var] = 10
        opts.on( '-c', '--max_coef_var INTEGER', 'Maximum coefficient of variation (default 10)' ) do |max_coef_var|
                options[:max_coef_var] = max_coef_var.to_i
        end

        # Set a banner, displayed at the top of the help screen.
        opts.banner = "Usage: #{__FILE__} -f table_path -c max_coef_var \n\n"


        # This displays the help screen
        opts.on( '-h', '--help', 'Display this screen' ) do
                puts opts
                exit
        end

end # End opts

# parse options and remove from ARGV
optparse.parse!

#################################################################################################

if options[:table].nil?
        puts 'Input table not defined'
        Process.exit
end


array = []

File.open(options[:table]).each do |line|
		line.chomp!
		fields = line.split("\t")

		gene_name = fields.shift				

		fields.map!{|col| col.to_i}								
			coef_var = 100 * fields.standard_deviation / fields.mean
			if coef_var <= options[:max_coef_var]
				row_array = [gene_name, coef_var, fields.mean].concat(fields)		
				array << row_array				
			end
end

array.sort!{|ar1, ar2| ar1[1] <=> ar2[1] }		

array.each do |row|
	puts "#{row[0]}\t#{sprintf('%.2f',row[1])}\t#{sprintf('%.1f',row[2])}\t#{row[3..row.length-1].join("\t")}"  
end