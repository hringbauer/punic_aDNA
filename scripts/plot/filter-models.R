###################################################################
## R script to filter table qith qpAdm models based on region
## and categories
###################################################################

###########################################################
# This script shold be run with 'source' when 
# the following variables are already defined.
#  - category_dict : list of categories and labels to use in plot for them
#                    for them in plots
#  - modelTable:     table with all qpAdm models
#  - sampleTable:    table of samples analyzed
#  - region:         name of region to focus on
#  - categories      list of samples categories to consider
#  - filterSelectModels: TRUE iff extract representative model per sample
###########################################################


   modelSubset_all <- c()
   headers         <- c()
   header_pos      <- c()
   for(cat in categories) {
      # filter samples based on region time and coverage and then extract valid models for these samples
      samples <- sampleTable$sample[which(sampleTable$region == region & sampleTable$category == cat & sampleTable$cov >= minCov)]
      modelSubset <- modelTable[which(modelTable$target %in% samples & modelTable$feasible == "TRUE"),]
      numrows <- nrow(modelSubset)
      if(length(samples)==0) {next}

      # slightly different filtering when considering only select models or all models
      if(filterSelectModels==TRUE) {
	 # only continue if there are valid models
         if(numrows==0) {next}
         # sort feasible models based on North African ancestry and then by Greece+Sicily or Levant ancestry
         modelSubset <- modelSubset[order(!modelSubset$feasible,
					   modelSubset$North_Africa_IA_source,
					  -modelSubset$Levant_MLBA_source - modelSubset$Greece_Sicily),]
      } else {
         # get samples with valid models
         modeled_samples <- unique(modelSubset$target)
         # add spacer lines in model matrix
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
         modelSubset <- modelSubset[order(modelSubset$target,-modelSubset$pval),]
      }# end of if/else (filterSelectModels)

      # dupplicate last spacer line to signify change of category
      numrows <- nrow(modelSubset)+1
      modelSubset[numrows,"target"] <- ""
      modelSubset[numrows,setdiff(1:numcols,c(1,3,numcols))]<-0.0
      modelSubset[numrows,c(3,numcols)]<-FALSE
      modelSubset_all <- rbind(modelSubset_all,modelSubset)
      # set header for cateogry and location based on first bar
      headers <- c(headers,category_dict[cat])
      header_pos <- c(header_pos,nrow(modelSubset_all)-numrows+0.5)
   }# end of for(cat)
   modelSubset    <- modelSubset_all
