###################################################################
## R script for generating Fig S3 with all valid
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

# show all models and don't filter by sample coverage
minCov <- 0
filterSelectModels <- FALSE

# generate plot for every region
for(region in names(regions_dict)) {
   fig_file   <- paste(outDir,"/fig-S3-",regions_dict[region],".pdf",sep="");
   categories <- names(category_dict)
   source(paste(script_dir,"/filter-models.R",sep=""))
   source(paste(script_dir,"/generate-one-qpadm-plot.R",sep=""))
}# end of for(region)

