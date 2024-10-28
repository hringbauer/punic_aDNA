###################################################################
## R script for generating Fig S7 with all valid
## qpAdm models for non-Phoenician individuals from Sicily
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

# load setup and data tables
source(paste(script_dir,"/plot-settings.R",sep=""))
source(paste(script_dir,"/prepare-data-tables.R",sep=""))

# Relevant categories
category_dict  <- c("Sicily_IA_Polizzello" = "Polizzello",
                    "Sicily_IA_Sicani" = "Sicani",
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
		    "Roman_Lilybaeum_1" = "Lilybaeum",
                    "Roman_Lilybaeum_2" = "",
                    "Roman_Lilybaeum_3" = "",
                    "Roman_Lilybaeum_4" = "",
                    "Roman_Lilybaeum_5" = "",
                    "Roman_Lilybaeum_6" = "",
                    "Roman_Birgi_1" = "Birgi",
                    "Roman_Birgi_2" = "",
                    "Roman_Birgi_3" = "",
                    "Roman_Palermo" = "Palermo"
)

# show all models and don't filter by sample coverage
minCov <- 0
filterSelectModels <- FALSE

# generate plot for three sets of Sicilian samples
region <- "Sicily"
for(set in c("Sicily_IA","Punic","Roman")) {
   fig_file   <- paste(outDir,"/fig-S7-",set,".pdf",sep="");
   if(set == "Punic") { set <- "_Ph_" }
   categories <- names(category_dict)[grep(paste("^",set,sep=""),names(category_dict))]
   source(paste(script_dir,"/filter-models.R",sep=""))
   source(paste(script_dir,"/generate-one-qpadm-plot.R",sep=""))
}# end of for(region)

