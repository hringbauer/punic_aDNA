###################################################################
## R script for generating Fig S4 with 2D plot of
## North African ancestry estimates for Punic samples
###################################################################

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
source(paste(script_dir,"/plot-settings.R",sep=""))
source(paste(script_dir,"/prepare-data-tables.R",sep=""))

out_file     <- paste(outDir,"/fig-S4.pdf",sep="")

# dictionaries to map times in table to ones used in legend + colors
times_dict  <- c("Punic_Early" = "900-360 BCE", 
		 "Punic_Late"  = "450-170 BCE",
		 "Punic_Late2" = "400-50 BCE" ,
		 "Punic_NoRC"  = "No C14 date")
colors_dict <- c("Punic_Early" = "#ff0054ff",
		 "Punic_Late"  = "#ff8c00ff",
		 "Punic_Late2" = "#f0e68cff",
		 "Punic_NoRC"  = "#c0c0c0ff")

# dictionaries to map regions in table to ones used in legend + symbols
symbols_dict <- c("Spain"    = "diamond"  ,
		  "Sardinia" = "x",
		  "Sicily"   = "star"  ,
		  "Tunisia"  = "square",
	     	  "Israel"   = "hexagon2")


#pca.levant == TRUE for individuals that project near Levantine samples
sampleTable$pca.levant <- sampleTable$PC1 < -0.015 & sampleTable$PC2>-0.013

# Individuals plotted should be in one of the regions and time ranges
# specified in the dictionaries and they should be outside of the
# Levantine cluster in the PCA
outTable <- subset(sampleTable, region %in% names(regions_dict)
			      & time   %in% names(times_dict)
			      & !pca.levant)

# Compute PCA-based estimate of North African ancestry
# as a linear combination of the two PCs.
# This linear combination provides the location of the projection
# of the individual on the line connecting the Algerian IA sample
# and the main cluster of Sicilian/Greek BA samples in the PCA
# See illustration in Fig SI3 in Supplementary Information
outTable$pca.norAf <- pmax(0, -13.37 * outTable$PC2 - 16.02 * outTable$PC1 - 0.3261) 

# Compute qpAdm-based North African ancestry per sample
outTable$qpadm.norAf <- NA
outTable$qpadm.norAf.old <- NA
outTable$pca.norAf.old <- NA
for(target in outTable$sample) {
   # collect valid models per target individual
   models <- modelTable[which(modelTable$target==target) , ]
   lines  <- which(models$feasible & models$pval >= 0.05)

   if(length(lines)>0) {
      outTable$qpadm.norAf[which(outTable$sample==target)] <- min(models$North_Africa_IA_source[lines])
   }
}

# filter out samples without valid ancestry estimates
outTable <- subset(outTable, !is.na(pca.norAf) & !is.na(qpadm.norAf))


p <- plot_ly()
p <- layout(p, title = '', #North African ancestry in Phoenician samples',
	   xaxis = list(range = list(-0.03, 1.05), title = "PCA-based North African ancestry",showgrid = FALSE), 
           yaxis = list(range = list(-0.03, 1.05),title = 'qpAdm-based North African ancestry',showgrid = FALSE),
	   legend = list(x = 0.03, y = 1.05,pt.cex=1.5))
p <- add_trace(p, x = c(0, 1), y = c(0, 1), type = "scatter", mode = "lines", line = list(color = 'gray', dash = "dash", width=0.5 )
            , showlegend = FALSE)

for(reg in names(regions_dict)) {
   for(tim in names(times_dict)) {
      trace_data <- subset(outTable, region == reg & time == tim)
      if(nrow(trace_data) == 0) { next; }
      cat(paste("plotting",nrow(trace_data),"for",reg, tim,"\n"))
      p <- add_trace(p,  data=trace_data, x=trace_data$pca.norAf, y=trace_data$qpadm.norAf,
                      type = "scatter", mode="markers",
		      marker = list(symbol = symbols_dict[reg], color = colors_dict[tim], size = 10, opacity = 0.8),
		      name=paste(regions_dict[reg],", ",times_dict[tim]," (",nrow(trace_data),")",sep=""))
   }# end of for(tim)
}# end of for(reg)

save_image(p, out_file)
