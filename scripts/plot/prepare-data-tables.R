###################################################################
## R script for preparing data tables before plotting
## qpAdm results
###################################################################

library(plyr)    # for mapvalues

###########################################################
# This script shold be run with 'source' when
# the following variables are already defined.
#  - model_file:     path to file with table including all qpAdm models
#  - sample_file:    path to file with table of information on samples
###########################################################

# read the input table files
modelTable <-  read.table(model_file, stringsAsFactors = FALSE, comment.char = '#', header=TRUE, na.strings = "NA")
sampleTable <- read.delim(sample_file, stringsAsFactors = FALSE, comment.char = '#', header=TRUE, na.strings = "NA")

# convert relevant columns to numeric and logicals
numcols     <- ncol(modelTable)
modelTable[,setdiff(1:numcols,c(1,3,numcols-1,numcols))] <- as.numeric(as.matrix(modelTable[,setdiff(1:numcols,c(1,3,numcols-1,numcols))]))
modelTable[,c(3,numcols-1)] <- as.logical(as.matrix(modelTable[,c(3,numcols-1)]))
sampleTable$cov <- as.numeric(sampleTable$cov)
# mark low coverage samples
sampleTable$target <- sampleTable$sample;
sampleTable$sample[ which(sampleTable$cov<100000) ] <- paste(sampleTable$sample[ which(sampleTable$cov<100000) ],"(*)")
#switch target labels with sample labels in model table
modelTable$target  <- mapvalues(modelTable$target,sampleTable$target,sampleTable$sample,warn_missing=FALSE)

