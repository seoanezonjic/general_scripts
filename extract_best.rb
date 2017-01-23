#!/usr/bin/env ruby

array = []
current_ort_hit = nil
final_array = []

File.open(ARGV[0]).each do |line|
	line.chomp!
	fields = line.split("\t")
	array << fields
end

array.sort!{|ar1, ar2| [ar1[2], ar2[1].to_f] <=> [ar2[2], ar1[1].to_f]}

array.each do |row|
	ort_hit = row[2]
	if ort_hit != current_ort_hit
		final_array << row
		current_ort_hit = ort_hit
	end
end


final_array.each do |row|
	puts "#{row[0]}\t#{row[2..row.length-1].join("\t")}"	
end