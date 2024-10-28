##############################################
## R script to compute parsimonious models
## base on qpadm output table with p-values. 
## Input table contains 'subsets' output from qpadm run
## by R admixr package, after processed for p-values.
## columns of input table:
##  target pattern wt dof chisq tail <source %s> <source pval> <max_child_p> <min_parent_p>
#######
## filter models based on tail probability and source p-values
#######
# INPUT ARGUMENTS 
# - input file with 'subsets' output table from admixr with p-values 
# - min value for tail prob
# - max p-value for child model (for parsimonious model def)
# - min p-value for parent model (for parsimonious model def)
#######
# OUTPUT:
# - output is printed to stdout
# - lines are printed in order, with designation for parsimony
# - First line is the one with max tail prob
# - Other lines are parsimonious models based on input parameters
##############################################

args         <- commandArgs(trailingOnly = TRUE) # TRUE
in_file      <- args[1]
minTail      <- as.numeric(args[2])
maxPchild    <- as.numeric(args[3])
minPparent   <- as.numeric(args[4])


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
   if ( grepl("^[[:space:]]*#", line) ) {
      cat(line,"\n")
   } else {
      break
   }
}

## creating output table
# original columns: target pattern wt dof chisq tail <source %s> <source ps> <max_child_p> <min_parent_p>
# updated  columns: target pval feasible <source %s> <source ps> <parsimony>
# parsimony is set to TRUE iff model is feasible, pval >= minTail , max_child_p < maxPchild, and min_parent_p >= minParent

numSources  <- (ncol(inTable) - 9) / 2
source_pops <- colnames(inTable)[7+1:numSources]
old_columns <- colnames(inTable)[c(1,6,7,7+1:(2*numSources))]
new_columns <- c( old_columns , "parsimony")
outTable    <- data.frame(matrix(ncol=length(new_columns),nrow=0, dimnames=list(NULL, new_columns)))
invalidModel<- data.frame(matrix(ncol=length(new_columns),nrow=1, dimnames=list(NULL, new_columns)))
invalidModel[1,"feasible"]<-FALSE
invalidModel[1,"parsimony"]<-FALSE
targets     <- unique(sort(inTable$target))
for(target in targets) {
   models <- inTable[which(inTable$target==target) , ]
   models$parsimony <- models$feasible                 &
	               models$pval >= minTail          & 
		       models$max_child_p <  maxPchild & 
		       models$min_parent_p>= minPparent


   lines  <- which(models$parsimony)
   ##  print(target);   print(lines);   print(length(lines))
   if(length(lines)>0) {
      models <- models[lines,]
   } else {
      # check to see if there are any valid, but non-parsimonious models
      lines <- which(models$feasible & models$pval >= minTail)
      if(length(lines)>0) {
         models <- models[lines,]
      } else {
         models <- invalidModel  # invalid model to indicate no valid models
         models[1,"target"] <- target
      }
   }
   outTable <- rbind(outTable, models[order(models$pval,decreasing=TRUE),new_columns])
}
write.table(outTable, sep="\t", row.names=FALSE, col.names=TRUE, quote=FALSE)
