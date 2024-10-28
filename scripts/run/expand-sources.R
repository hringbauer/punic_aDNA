###################################################################
## R script to expand a given qpAdm output file to a given 
## list of proxy source populations.
## Input table contains 'subsets' output from qpadm run
## by R admixr package, after processed for p-values.
## columns of input table:
##  target pattern wt dof chisq tail <source %s> <source pval> <max_child_p> <min_parent_p>
#######
## expand set of sources
#######
# INPUT ARGUMENTS 
# - input file with 'subsets' output table from admixr with p-values 
# - pop for which to extract valid model with min ancestry
# OUTPUT:
# - output is printed to stdout
###################################################################

args         <- commandArgs(trailingOnly = TRUE) # TRUE
in_file      <- args[1]
out_sources  <- unlist(strsplit(args[2],"[[:space:]]"))

# check input and output files
if(!file.exists(in_file)) {
   cat(paste("Error: input file",in_file,"does not exist.\n"))
   quit(save="ask")
}


## read the input table file ##
inTable <-  read.table(in_file, stringsAsFactors = FALSE, comment.char = '#', header=TRUE)
columns <- colnames(inTable)
if(columns[length(columns)] != "min_parent_p"){
   cat(paste("Error: last column of input table should be min_parent_p, but it is",columns[length(columns)],"\n"));
   quit()
}

## creating output table
numSources  <- (ncol(inTable) - 9) / 2
in_sources  <- colnames(inTable)[7+1:numSources]

# make sure that in_sources is included in out_sources
for(source in in_sources) {
  if(! source %in% out_sources) {
      cat(paste("Error: population",source," is specified in input file as source, but not in list of output source pops.\n"))
      quit(save="ask")
  }
}

## read the comments in the header and print to output file
filehandler <- file(in_file, "r")
while ( TRUE ) {
   line <- readLines(filehandler, n = 1)
   if ( grepl("^[[:space:]]*#", line) ) {
      cat(line)
      cat("\n")
   } else {
      break
   }
}

columns  <- c(columns[1:7],out_sources,paste("p",out_sources,sep="_"),columns[length(columns)-1:0])
outTable <- as.data.frame(matrix(NA, nrow=nrow(inTable),ncol=length(columns)))
colnames(outTable) <- columns;
outTable[,c(columns[1:7],columns[length(columns)-1:0])] <- inTable[,c(columns[1:7],columns[length(columns)-1:0])]
for(source in out_sources) {
  cols <- c(source,paste("p",source,sep="_"))
  if(source %in% in_sources) {
      outTable[,cols] <- inTable[,cols]
  } else {
      outTable[,cols[1]] <- 0
  }

}
write.table(outTable, sep="\t", row.names=FALSE, col.names=TRUE, quote=FALSE)
