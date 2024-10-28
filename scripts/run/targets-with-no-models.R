###################################################################
## R script to figure out individuals without a valid model
## Input table contains 'subsets' output from qpadm run
## by R admixr package, after processed for p-values.
## columns of input table:
##  target pattern wt dof chisq tail <source %s> <source pval> <max_child_p> <min_parent_p>
###############
# INPUT ARGUMENTS 
# - input file with 'subsets' output table from admixr with p-values 
# - min value for tail prob
# OUTPUT:
# - list of individuals without a valid model printed to stdout
###################################################################

args         <- commandArgs(trailingOnly = TRUE) # TRUE
in_file      <- args[1]
minTail      <- as.numeric(args[2])

# check input and output files
if(!file.exists(in_file)) {
   cat(paste("Error: input file",in_file,"does not exist.\n"))
   quit(save="ask")
}


## read the input table file ##
inTable <-  read.table(in_file, stringsAsFactors = FALSE, comment.char = '#', header=TRUE)


## read the comments in the header and print to stdout
filehandler <- file(in_file, "r")
while ( TRUE ) {
   line <- readLines(filehandler, n = 1)
   if ( !grepl("^[[:space:]]*#", line) ) {
      break
   }
}

targets     <- unique(sort(inTable$target))
for(target in targets) {
   models <- inTable[which(inTable$target==target) , ]
   lines  <- which(models$feasible & models$pval >= minTail)
   if(length(lines)==0) {
      cat(target,"\n");
   }
}
