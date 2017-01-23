#!/usr/bin/env ruby

require 'find'
require 'optparse'

#################################################################################################
## FUNCTIONS
#################################################################################################
def parse_cols(col_string)
    cols = col_string.split(',').map{|col| col.to_i}
    return cols
end

def build_pattern(col_filter, keywords)
    pattern = {}
    if col_filter.nil? || keywords.nil?
    else
        keys_per_col = keywords.split('%')
        if keys_per_col.length != col_filter.length
            puts 'Number of keywords not equal to number of filtering columns'
            Process.exit
        end
        col_filter.each_with_index do |col, i|
            pattern[col] = keys_per_col[i].split('&')
        end
    end
    return pattern
end

def match(string, key, match_mode)
    match = FALSE
    if string.nil?
        match = FALSE
    elsif  match_mode == 'i'
        match = string.include?(key)
    elsif match_mode == 'c'
        if string == key
            match = TRUE
        end
    end
    return match
end

def filter(header, pattern, search_mode, match_mode, reverse = FALSE)
    filter = FALSE
    pattern.each do |col,keys|
        match = FALSE
        keys.each do |key|
            if match(header[col], key, match_mode)
                match =TRUE
            end
        end
        if match
            if search_mode == 's'
                filter = FALSE
                break
            end
        elsif !match && search_mode == 'c'
            filter = TRUE
            break
        elsif !match
            filter = TRUE
        end
    end
    if reverse
        filter = !filter
    end
    return filter
end

def check_file(file, names, options, pattern)
    if file == '-'
        input = STDIN
    else
        input = File.open(file)
    end
    relations = relations(options[:column])
	input.read.each_line do |line|
		line.chomp!
		header = line.split(options[:separator])
        if pattern.nil? || !filter(header, pattern, options[:search_mode], options[:match_mode], options[:reverse])
            options[:column].each do |col|
        		if !options[:check_uniq] || !names[relations[col]].include?(header[col]) 
        			names[relations[col]] << header[col]
        		end
            end
        end
	end
	return names
end

def relations(column)
    relations = {}
    column.each_with_index do |col,i|
        relations[col] = i
    end
    return relations
end

def report(names)
    n_col = names.length
    names.first.length.times do |y|
        n_col.times do |x|
		string = "#{names[x][y]}"
		if x < n_col-1
			string << "\t"
		end
            print string
        end
        puts
    end
end

#################################################################################################
## INPUT PARSING
#################################################################################################
options = {}

optparse = OptionParser.new do |opts|
        options[:table_file] = nil
        opts.on( '-t', '--table_file FILE', 'Input tabulated file' ) do |table_file|
            options[:table_file] = table_file
        end

        options[:column] = [0]
        opts.on( '-c', '--column STRING', 'Column/s to show. Format: x,y,z..' ) do |column|            
                options[:column] = parse_cols(column)
        end

        options[:col_filter] = nil
        opts.on( '-f', '--col_filter STRING', 'Select columns where search keywords. Format: x,y,z..' ) do |col_filter|
                options[:col_filter] =  parse_cols(col_filter)
        end      

        options[:keywords] = nil
        opts.on( '-k', '--keywords STRING', 'Keywords for select rows. Format: key1_col1&key2_col1%key1_col2&key2_col2' ) do |keywords|
                options[:keywords] = keywords
        end

        options[:search_mode] = 'c'
        opts.on( '-s', '--search STRING', 'c a match per column, s some match in some column. Default c' ) do |search_mode|
                options[:search_mode] = search_mode
        end

        options[:match_mode] = 'i'
        opts.on( '-m', '--match_mode STRING', 'i string must include the keyword, c for fullmatch. Default i') do |match_mode|
                options[:match_mode] = match_mode
        end

        options[:separator] = "\t"
        opts.on( '-p', '--separator STRING', 'Separator used in fields. Default i') do |separator|
                options[:separator] = separator
        end

        options[:reverse] = FALSE
        opts.on( '-r', '--reverse', 'Select not matching' ) do 
                options[:reverse] = TRUE
        end

        options[:uniq] = FALSE
        opts.on( '-u', '--uniq', 'Delete redundant items' ) do 
                options[:uniq] = TRUE
        end

        # Set a banner, displayed at the top of the help screen.
        opts.banner = "Usage: table_header.rb -t tabulated_file \n\n"

        # This displays the help screen
        opts.on( '-h', '--help', 'Display this screen' ) do
                puts opts
                exit
        end

end # End opts

# parse options and remove from ARGV
optparse.parse!

##################################################################################################
## MAIN
##################################################################################################
if options[:table_file].nil?
	puts 'Tabulated file not specified'
	Process.exit
end

pattern = build_pattern(options[:col_filter], options[:keywords])

names = []
options[:column].length.times do
    names << []
end
if options[:table_file].include?('*')
	Find.find(Dir.pwd) do |path|
		if FileTest.directory?(path)
			next
		else
           	if File.basename(path) =~ /#{options[:table_file]}/
				names = check_file(path, names, options, pattern) 
			end
		end
	end	
else
	names = check_file(options[:table_file], names, options, pattern)
end

report(names)
