###################################################################
## R script for generating Fig SI2 in the Supp Info with 
## broad ancestry models inferred using qpAdm for select individuals
###################################################################

library(tidyverse)
get_script_dir <- function(){
  commandArgs() %>%
     tibble::enframe(name=NULL) %>%
     tidyr::separate(col=value, into=c("key", "value"), sep="=", fill='right') %>%
     dplyr::filter(key == "--file") %>%
     dplyr::pull(value) %>%
     dirname()
}
script_dir <- get_script_dir()

# select samples sorted based on region
#            Akhziv    Akhziv   Kerkouene  Carthage   Motya    Birgi    Selinun   Tharros   Villamar  Eivissa   Malaga    Villaricos
samples <-c("I22252", "I22258", "I24031" , "I28504", "I4798", "I12666", "I21853", "I22096" ,"VIL006", "I27613", "I26931", "I18201")

# load setup and data tables
source(paste(script_dir,"/plot-settings.R",sep=""))
model_file   <- paste(dataDir,"/qpAdm/broadModelsSelect/broadModelsSelect-pars-models-with-p.tsv",sep="")
if(!file.exists(model_file)) {
   cat(paste("Error: input file",model_file,"does not exist.\n"))
   quit(save="ask")
}
source(paste(script_dir,"/prepare-data-tables.R",sep=""))

# compute subset of models to display
modelSubset <- modelTable[which(modelTable$target %in% samples & modelTable$feasible == "TRUE"),]
numrows <- nrow(modelSubset)

# get samples with valid models
modeled_samples <- unique(modelSubset$target)
# and add spacer lines in model matrix
modelSubset[numrows+1:length(samples),1]<-samples
modelSubset[numrows+1:length(samples),setdiff(1:numcols,c(1,3,numcols-1,numcols))]<-0.0
modelSubset[numrows+1:length(samples),c(3,numcols-1,numcols)]<-FALSE

# add an additional model for all non-modeled samples
numrows <- nrow(modelSubset)
non_modeled_samples <- setdiff(unique(modelSubset$target) , modeled_samples)
if(length(non_modeled_samples) > 0) {
  modelSubset[numrows+1:length(non_modeled_samples),1]<-non_modeled_samples
  modelSubset[numrows+1:length(non_modeled_samples),setdiff(1:numcols,c(1,3,numcols-1,numcols))]<-0.0
  modelSubset[numrows+1:length(non_modeled_samples),c(3,numcols-1,numcols)]<-FALSE
}
# sort models based on sample and decreasing p-val
modelSubset <- modelSubset[order(match(modelSubset$target,samples),-modelSubset$pval),]
modelSubset$type <- "easternModels" # to avoid printing model type label

# generate plot for select samples
header_pos<-c(0.5) # set empty headers
headers<-c(" ")
fig_file   <- paste(outDir,"/fig-SI_2.pdf",sep="");
source(paste(script_dir,"/generate-one-qpadm-plot.R",sep=""))

