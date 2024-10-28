########################################################
## R script to run qpadm using
## admixr package.
## Works on Linux or MacOs ONLY
########################################################

########################################################
# This script is called by:
# - launch-batch-qpadm-runs.sh
########################################################

####################
## Replace %ADMIXTOOLS_DIR% tag with path
## of dir that contains admixtools (qpAdm, qpWav, etc.)
## This is done by configureScripts.sh
####################
admixtoolsdir <- "%ADMIXTOOLS_DIR%"
old_path      <- Sys.getenv("PATH")
Sys.setenv(PATH = paste(admixtoolsdir, old_path, sep = ":"))
# export PATH=$admixtoolsdir:$PATH

library(admixr)
# library(tidyverse)
###############
##   SETUP   ##
###############
# INPUT ARGUMENTS. SEE COMMENTED EXAMPLE BELOW
args         <- commandArgs(trailingOnly = TRUE) # TRUE
dataset      <- args[1]
out_file     <- args[2]
right_pops   <- unlist(strsplit(args[3],"[[:space:]]"))
source_pops  <- unlist(strsplit(args[4],"[[:space:]]"))
targets      <- unlist(strsplit(args[5],"[[:space:]]"))

# args[1]      <- "dataDir"                      <-- prefix of data files (ind geno snp)
# args[2]      <- "qpadm-out.tsv"                <-- output file
# args[3]      <- "refPop1 refPop2 refPop3"      <-- reference pops
# args[4]      <- "sourcePop1 sourcePop2"        <-- source pops
# args[5]      <- "target1 target2 target3"      <-- target individuals/pops


cat("Loading data set . . .\n");
snps         <- eigenstrat(ind = paste0(dataset,".ind"), geno = paste0(dataset,".geno"), snp = paste0(dataset,".snp") )

####################################
###  apply qpAdm on all targets  ###
####################################
write(paste("# Dataset prefix:",dataset),file = out_file)
write(paste("# Reference pops:",toString(right_pops)),file = out_file, append=TRUE)
first_target <- TRUE;
for (target in targets){
    cat("Analyzing target",target,"\n")
    result <- qpAdm(
      target = target,
      sources = source_pops,
      outgroups = right_pops,
      data = snps,
      params = list(allsnps = "YES", summary = "YES", details = "YES")
    )

    ### add empty coment column if it does not exist
    if(!"comment" %in% colnames(result$subsets)) {
        result$subsets$comment <- "-"
    }
    ### write  subsets to file
    if(first_target) {
        suppressWarnings(write.table(result$subsets, file = out_file , sep = "\t",row.names=FALSE, col.names=TRUE, quote=FALSE,append=TRUE))
        first_target = FALSE;
    } else {
        write.table(result$subsets, file = out_file , sep = "\t",row.names=FALSE, col.names=FALSE, quote=FALSE,append=TRUE)
    }
  }
