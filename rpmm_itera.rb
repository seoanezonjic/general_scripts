#! /usr/bin/env ruby

rpmm_array = []
iterator = 0
total_reads = 0
final_array = []


File.open(ARGV[0]).each do |line|
	line.chomp!
	fields = line.split("\t")	
	rpmm_array << fields
end

rpmm_array.transpose.each do |row|
	if iterator == 0               					   
		final_array << row
	else											   
		row.map!{|col| col.to_i}
		row.each do |number|
			total_reads += number
		end
		million_reads = (total_reads*1.0/1000000)

		row.map!{|col| sprintf('%.0f', col/million_reads)}
		final_array << row
	end
	iterator = iterator + 1
	total_reads = 0
end

final_array.transpose.each do |row|
	puts "#{row[0..row.length-1].join("\t")}"   
end

