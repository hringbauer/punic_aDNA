###############################################################
## R script to process qpadm output table and compute nested p-values
## Input table contains 'subsets' output from qpadm run by R admixr package
## columns of input table:
##  target pattern wt dof chisq tail <source %s> comment
#######
## for each model, compute the nested p-values relative to all parent and children models
## also computes feasibility of models and changes "tail" to "pval"
## columns of output table:
##    target pattern wt dof chisq pval feasible <source %s> <source ps> <max child p> < min parent p>
## the 'max child p' column specifies the maximum p-value for any of the child models
## the 'min parent p' column specifies the minimum p-value for any of the parent models 
## a model is parsimonious if the significance threshold is larger than the max child p
## and smaller than the min parent p
#######
## ~~~~~~~~~~~~~~~
## Important note:
## ~~~~~~~~~~~~~~~
##  p-value for (parent,child) is assigned to both parent and child models
##  for parent model it is assigned with positive sign (standard p-value)
##  for child model it is assigned with negative sign (-) 
##  to indicate that this is the child model for this comparison
#######
# INPUT ARGUMENTS 
# - input file with simple 'subsets' output table from admixr 
# - output file - contains same results, with added p-value columns
args         <- commandArgs(trailingOnly = TRUE) # TRUE
in_file      <- args[1]
out_file     <- args[2]
###############################################################

# p-value used when parent model has negative %s in source (if negative, then compute p-value)
NEG_PER_PVAL <- 100

# check input and output files
if(!file.exists(in_file)) {
   cat(paste("Error: input file",in_file,"does not exist.\n"))
   quit(save="ask")
}
if(file.exists(out_file)) {
   cat(paste("Warning: output file",out_file,"will be overwritten.\n"))
   temp <- file.remove(out_file)
} else if(!dir.exists(dirname(out_file))) {
   cat(paste("Error: directory of output file",dirname(out_file),"does not exist.\n"))
   quit(save="ask")
}


## read the input table file ##
inTable <-  read.table(in_file, stringsAsFactors = FALSE, comment.char = '#', header=TRUE)

## read the comments in the header and print to output file
filehandler <- file(in_file, "r")
while ( TRUE ) {
   line <- readLines(filehandler, n = 1)
   if ( grepl("^[[:space:]]*#", line) ) {
      write(line,out_file,append=TRUE)
   } else {
      break
   }
}

## creating output table
# original columns: target pattern wt dof chisq tail <source %s> comment
# updated  columns: target pattern wt dof chisq pval feasible <source %s> <source ps>
# pval is simply the tail probability (tail)
# feasible is TRUE if all source pop %s are non-negative (should replace comment)
# p_<source> is the nexted p-value corresponding to this pop (main computation done by this script

numSources  <- ncol(inTable) - 7
source_pops <- colnames(inTable)[6+1:numSources]
new_columns <- c( colnames(inTable)[1:5] , "pval" , "feasible", source_pops, paste("p_",source_pops,sep='') , "max_child_p", "min_parent_p")
outTable    <- data.frame(matrix(ncol=length(new_columns),nrow=nrow(inTable), dimnames=list(NULL, new_columns)))
outTable[,1:6] <- inTable[,1:6]
outTable[,source_pops] <- inTable[,source_pops]
#compute feasibility of models
outTable[,"feasible"] <- ( rowMeans(outTable[,source_pops]>=0) == 1)

# compute pattern for model with no sources (non-existing)
noSrcPattern <- 0
for(i in 1:numSources) {
   noSrcPattern <- noSrcPattern*10 + 1
}

## go through models in table, line by line
cat("Computing p-values for",nrow(outTable),"models...\n")

for(i in 1:nrow(outTable)) {
   target <- outTable[i,"target"]
   code   <- outTable[i,"pattern"]

   # initialize the min/max p-values for parent/child models
   outTable[i,"max_child_p"] <- -1; 
   outTable[i,"min_parent_p"] <- NEG_PER_PVAL + 1; 


   # iterate through all child/parent models to compute p-value
   # digit flip is 1, 10, 100, ... according to source index
   digitFlip   <- 1
   # shiftedCode is version of code shifted to right
   shiftedCode <- code
   for(s in numSources:1) {
      pval_col <- paste("p_",source_pops[s],sep='')
      # if p-value already computed, nothing to do here
      if(is.na(outTable[i,pval_col])) {
         # determine participation of source based on right-digit
         if(shiftedCode%%10 == 0) {   # digit 0 - this source participates
            if(code + digitFlip == noSrcPattern) {
               next;
	    }
            child  <- which( outTable[,"target"]==target & outTable[,"pattern"]==code + digitFlip)
            parent <- i;
         } else {                     # digit 1 - does not participate
            parent <- which( outTable[,"target"]==target & outTable[,"pattern"]==code - digitFlip)
	    child  <- i;
	 }
         if(NEG_PER_PVAL > 0 && outTable[parent,source_pops[s]] < 0) {
            outTable[parent,pval_col] <- NEG_PER_PVAL
	 } else {
            outTable[parent,pval_col] <- 1 - pchisq( outTable[child,"chisq"] - outTable[parent,"chisq"] , outTable[child,"dof"] - outTable[parent,"dof"] )
	 }

	 # assign p-value to child with negative sign
	 outTable[child,pval_col] <- -outTable[parent,pval_col]
      }
      nested_p_value = abs(outTable[i,pval_col])
      # update min_parent_p or max_child_p if needed
      if(outTable[i,pval_col] < 0 && -outTable[i,pval_col] < outTable[i,"min_parent_p"]) {
         outTable[i,"min_parent_p"] = -outTable[i,pval_col];
      } else if(outTable[i,pval_col] > outTable[i,"max_child_p"]) {
         outTable[i,"max_child_p"] = outTable[i,pval_col];
      }

      # shift code right
      shiftedCode      <- floor(shiftedCode / 10)
      digitFlip <- digitFlip* 10
   } # end of for(s)
} # end of for(i)
cat("Done.\n")

suppressWarnings(write.table(outTable, file = out_file, sep="\t", row.names=FALSE, col.names=TRUE, quote=FALSE,append=TRUE))
