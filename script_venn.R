#! /usr/bin/env Rscript


suppressPackageStartupMessages(library(VennDiagram))
suppressPackageStartupMessages(library("optparse"))

###########################################################################
## FUNCTIONS
###########################################################################

# get_vector_names <- function(all_data){  #all_data es una lista con data frames
#   for (i in c(1:length(all_data))){
#     all_data[[i]] <- row.names(all_data[[i]])
#   }
#   return(all_data)
# }


calculate_intersection <- function(all_package_results){
  x_all <- all_package_results[[1]]
  for (i in c(2:length(all_package_results))){
    x_all <- intersect(x_all, all_package_results[[i]])
  }
  return(x_all)
}



###############################################################################
## OPTPARSE
###############################################################################

option_list <- list(
	make_option(c("-f", "--file_list"), default="",
		help = "File list with format file_path1,file_path2,... [default \"%default\"]"),
	make_option(c("-o", "--output_path"), default=getwd(),
		help = "Output path for result files"),
 	make_option(c("-n", "--name_list"), default="",
		help="Titles for each list. Format name1,name2,... [default %default]")
)

opt <- parse_args(OptionParser(option_list=option_list))



#############################################################################
## MAIN
############################################################################


file_paths <- strsplit(opt$file_list, ',')[[1]]
titles_list <- c()
if(opt$name_list == ""){
	titles_list <- file_paths
}else{
	titles_list <- strsplit(opt$name_list, ',')[[1]]
}

all_colours <- c('red', 'green', 'yellow', 'blue', 'grey')

venn_colors <- c()
all_data <- list()
count <- 1
for (path in file_paths){
	all_data[[titles_list[[count]]]] <- row.names(read.table(path, row.names=1))
	venn_colors <- c(venn_colors, all_colours[[count]])
	count <- count + 1
}
pdf(file.path(opt$output_path, "venn.pdf"))
	body(venn.diagram)[[3]] <- substitute("") #Disables the logger system on venndiagram package
	body(venn.diagram)[[7]] <- substitute("") #Disables the logger system on venndiagram package
	venn_plot <- venn.diagram(all_data, fill=venn_colors, filename = NULL)
	grid.draw(venn_plot)
dev.off()


x_all <- calculate_intersection(all_data)
write(x_all, file.path(opt$output_path,"intersection.txt"))
   
