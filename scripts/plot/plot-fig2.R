###################################################################
## R script for generating Fig 2 with summary of representative
## qpAdm models for Phoenician/Punic individuals
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

library(plotly)
###############################
# To export plotly to PDF one has to install the following on R:
# install.packages('reticulate')
# reticulate::install_miniconda()
# reticulate::conda_install('r-reticulate', 'python-kaleido')
# reticulate::conda_install('r-reticulate', 'plotly', channel = 'plotly')
# reticulate::use_miniconda('r-reticulate')
#
# Before plotting begins, one has to call the following command:
#   reticulate::py_run_string("import sys")
# After the plot is completed, one has to call the following command:
#   save_image(plot_object, out_file_name)
######################################
reticulate::py_run_string("import sys")

# load setup and data tables
source(paste(script_dir,"/plot-settings.R",sep=""))
source(paste(script_dir,"/prepare-data-tables.R",sep=""))

# Relevant categories
category_dict  <- c("_Ph_Akhziv" = "Akhziv",
                    "_Ph_Kerkouane" = "Kerkouane",
                    "_Ph_CapBon" = "Cap Bon",
                    "_Ph_Carthage" = "Carthage",
                    "_Ph_Tharros_Early" = "Tharros (E)",
                    "_Ph_Tharros_Late" = "(L)",
                    "_Ph_Tharros_Late_Roman" = "(L/R)",
                    "_Ph_Tharros_NoRC" = "(N)",
                    "_Ph_Villamar_Late" = "Villamar (L)",
                    "_Ph_MonteSirai_Early" = "M. Sirai (E)",
                    "_Ph_MonteSirai_NoRC" = "(N)",
                    "_Ph_Motya_Early" = "Motya (E)",
                    "_Ph_Motya_Late_Roman" = "(L/R)",
                    "_Ph_Birgi_Early" = "Birgi (E)",
                    "_Ph_Birgi_Late" = "(L)",
                    "_Ph_Birgi_Late_Roman" = "(L/R)",
                    "_Ph_Selinunte_Early" = "Sel. (E)",
                    "_Ph_Selinunte_Late" = "(L)",
                    "_Ph_Palermo_Late" = "Pal. (L)",
                    "_Ph_Lilybaeum_Late" = "Lil. (L)",
                    "_Ph_Lilybaeum_Late_Roman" = "(L/R)",
                    "_Ph_Cadiz_Early" = "Cadiz (E)",
                    "_Ph_Cadiz_Late" = "(L)",
                    "_Ph_Ibiza_Late" = "Ibiza (L)",
                    "_Ph_Ibiza_NoRC" = "(N)",
                    "_Ph_Malaga_Late" = "Malaga (L)",
                    "_Ph_Malaga_NoRC" = "(N)",
                    "_Ph_Villaricos_Late" = "Villaricos (L)",
                    "_Ph_Villaricos_fam" = "(F)",
                    "_Ph_Villaricos_NoRC" = "(N)")

# aggregate sources Greece+Sicily   / Iberia+Sardinia 
grouped_source_dict <- c("Greece_Sicily"          = "Greece/Sicily (BA)",
                         "Steppe_MLBA_source"     = "Steppe (BA)",		 
                         "Iberia_Sardinia"        = "Iberia/Sardinia (BA)",
                         "Levant_MLBA_source"     = "Levant (BA)",
                         "Iran_N_source"          = "Iran (N)",
                         "North_Africa_IA_source" = "North Afr. (IA)")

color_dict["Greece_Sicily"]   <- "#0f3b7dff" #color_dict["Greece_BA_Myc_source"]
color_dict["Iberia_Sardinia"] <- "#229222ff" #color_dict["Sardinia_LBA_source"]

modelTable$Greece_Sicily   <- modelTable$Greece_BA_Myc_source + modelTable$Sicily_EMBA_source
modelTable$Iberia_Sardinia <- modelTable$Sardinia_LBA_source  + modelTable$Iberia_EBA_source

# Create data table with select model per sample
# by filtering  lines based on coverage, region, and category
lines <- which( sampleTable$cov >= 100000 &
                sampleTable$region %in% names(regions_dict) &
                sampleTable$category   %in% names(category_dict))

# add one model per sample
samples <- sampleTable$sample[lines]
numrows <- nrow(modelTable)
modelTable[numrows+1:length(samples),1]<-samples
modelTable[numrows+1:length(samples),setdiff(1:numcols,c(1,3,numcols-1,numcols))]<-0.0
modelTable[numrows+1:length(samples),c(3,numcols-1,numcols)]<-FALSE

# sort models based on sample, then ancestry criteria, and p-val
# consider only feasible models (if exist)
# then, prioritize eastern models (positive Levant_MLBA ancestry)
# then, prioritize western models (high Central Med ancestry)
# finally, prioritize high P-value		  
modelTable <- modelTable[order(modelTable$target,
			       -modelTable$feasible,
			       -modelTable$Levant_MLBA_source,
			       -modelTable$Greece_Sicily,
			       -modelTable$pval),]

# minimum coverage for samples to show - 100K
minCov <- 100000
filterSelectModels <- TRUE

# get first line per sample
lines  <- c(1, 1+which( modelTable$target[2:nrow(modelTable)] != modelTable$target[2:nrow(modelTable)-1]))
modelTable <- modelTable[lines,]
if(length(setdiff(samples , modelTable$target)) > 0) {
   # just in case, check that all samples left in table have models
   cat("Samples without models:",setdiff(modelSelect$sample , modelTable$target),"\n")
   cat("Aborting\n")
} else {
   for(region in names(regions_dict)) {
      fig_file   <- paste(outDir,"/fig-2-",regions_dict[region],".pdf",sep="");
      categories <- names(category_dict)
      source(paste(script_dir,"/filter-models.R",sep=""))

      # plot figure for region
      numrows        <- nrow(modelSubset)
      labelPositions <- which(modelSubset$target != "")

      models_p <- plot_ly(type='bar',width=25*numrows+200)
      models_p <- layout(models_p,  barmode = 'stack',
                         yaxis       = list(title = 'Ancestry proportion'),
                         xaxis       = list(tickvals=labelPositions, ticktext=modelSubset$target[labelPositions],tickangle=45),
                         annotations = list(x=header_pos,y=1.08,text=headers,xanchor = 'left',align='left',showarrow=FALSE,font=list(size = 14)),
                         legend      = list(y=0))
      for(source in names(grouped_source_dict)) {
         models_p <- add_trace(models_p, x = 1:numrows, y =modelSubset[,source] , type = 'bar',
                           marker = list(color = color_dict[source]), name = grouped_source_dict[source])
      }
   
      # separate bar plot for p-values will be plotted above model bars
      pval_p <- plot_ly(type='bar',width=25*numrows)
      pval_p <- layout(pval_p, yaxis = list(title = 'P-value',tickvals=c(0.05,0.5)),xaxis=list(tickvals=c()))
      pval_p <- add_trace(pval_p, x = c(0.5, numrows), y = c(0.05,0.05), type = "scatter", mode = "lines", line = list(color = 'gray', dash = "dash", width=0.5 )
               , showlegend = FALSE)
      pval_p <- add_trace(pval_p,x = 1:numrows, y =modelSubset$pval,marker=list(color = "gray"), showlegend=FALSE)

      #combine model plot and p-val plot and save to file
      fig    <- subplot(pval_p,models_p,nrows=2,heights=c(0.2,0.8),shareX = TRUE, titleY= TRUE)
      save_image(fig, fig_file)

   }# end of for(region)
}
