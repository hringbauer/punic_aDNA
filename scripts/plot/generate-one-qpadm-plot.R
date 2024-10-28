###################################################################
## R script to generate a sinlge plot with qpAdm models for
## a collection of individuals identified by certain tags
###################################################################

library(plotly)
library(plyr)    # for mapvalues

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


###########################################################
# This script shold be run with 'source' when 
# the following variables are already defined.
# Dictionaries:
#  - source_dict:    list of source pops and names to use in legend
#  - color_dict:     list of source pops and colors to use for them in bar plots
#  - model_type_dict:list of model types (eastern/western/broad) and tags to use
#                    for them in plots
# Data tables:
#  - modelSubset:    table with all qpAdm models to plot
# Other variables:
#  - fig_file:       name of file to use for figure
###########################################################

   numrows        <- nrow(modelSubset)

   # set up fig
   labelPositions <- c(1,1+which(modelSubset$target[2:numrows] != modelSubset$target[1:(numrows-1)]))

   models_p <- plot_ly(type='bar',width=12*numrows + 300, height=300)
   models_p <- layout(models_p,  barmode = 'stack',
		      yaxis       = list(title = 'Ancestry proportion'), 
		      xaxis       = list(tickvals=labelPositions, ticktext=modelSubset$target[labelPositions],tickangle=45),
		      annotations = list(x=header_pos,y=1.25,text=headers,xanchor = 'left',showarrow=FALSE, font=list(size = 18)),
		      legend      = list(y=0))
   modelPositions <- which(modelSubset$feasible)
   modelLabels    <- model_type_dict[modelSubset$type[modelPositions]]
   models_p <- layout(models_p,annotations = list(x=modelPositions,y=1.05,text=modelLabels,xanchor = 'center',showarrow=FALSE,font=list(size=12)))
   for(source in names(source_dict)) {
      models_p <- add_trace(models_p, x = 1:numrows, y =modelSubset[,source] , type = 'bar', 
		        marker = list(color = color_dict[source]), name = source_dict[source])
   }

   # separate bar plot for p-values will be plotted above model bars
   pval_p <- plot_ly(type='bar',width=12*numrows)
   pval_p <- layout(pval_p, yaxis = list(title = 'P-value',tickvals=c(0.05,0.5)),xaxis=list(tickvals=c()))
   pval_p <- add_trace(pval_p, x = c(0.5, numrows), y = c(0.05,0.05), type = "scatter", mode = "lines", line = list(color = 'gray', dash = "dash", width=0.5 )
            , showlegend = FALSE)
   pval_p <- add_trace(pval_p,x = 1:numrows, y =modelSubset$pval,marker=list(color = "gray"), showlegend=FALSE)

   #combine model plot and p-val plot and save to file
   fig    <- subplot(pval_p,models_p,nrows=2,heights=c(0.2,0.6),shareX = TRUE, titleY= TRUE)
   save_image(fig, fig_file)
