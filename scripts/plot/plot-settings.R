###################################################################
## R script for general settings used in all qpAdm plots
###################################################################

# assumes that variable script_dir is set by calling script
sample_file <- paste(script_dir,"/../sample-info.tsv",sep="/")

# %_OUTDIR% below should be replaced with output dir for pipeline (see configureScripts.sh)
dataDir      <- "%OUTDIR%"
model_file   <- paste(dataDir,"/qpAdm/combined-pars-models.tsv",sep="")
outDir       <- paste(dataDir,"/plots",sep="")

# check existence of input files and output dir
if(!file.exists(sample_file)) {
   cat(paste("Error: input file",sample_file,"does not exist.\n"))
   quit(save="ask")
}
if(!file.exists(model_file)) {
   cat(paste("Error: input file",model_file,"does not exist.\n"))
   quit(save="ask")
}
if(!dir.exists(dirname(outDir))) {
   cat(paste("Error: directory of output file",dirname(outDir),"does not exist.\n"))
   quit(save="ask")
}

# dictionary to map model type annotations
model_type_dict <- c("westernModels" = ""  ,
                     "easternModels" = "",
                     "broadModels"   = "B")

# dictionary to map regions in table to ones used in annotations
regions_dict <- c("Spain"    = "Iberia"  ,
		  "Sardinia" = "Sardinia",
		  "Sicily"   = "Sicily"  ,
		  "Tunisia"  = "North_Africa",
	     	  "Israel"   = "Akhziv")
# dictionary to map source populations to names used in annotations
source_dict <- c("Greece_BA_Myc_source"   = "Greece_BA_Myc",
                 "Sicily_EMBA_source"     = "Sicily_EMBA",
		 "Steppe_MLBA_source"     = "Steppe_MLBA",
		 "Sardinia_LBA_source"    = "Sardinia_LBA",
		 "Iberia_EBA_source"      = "Spain_EBA",
		 "Levant_MLBA_source"     = "Levant_MLBA",
		 "Iran_N_source"          = "Iran_N",
		 "North_Africa_IA_source" = "North_Africa_IA")
# dictionary to map source populations to colors used in bar plots
color_dict  <- c("Greece_BA_Myc_source"   = "#002255ff",
                 "Sicily_EMBA_source"     = "#325fa2ff",
                 "Steppe_MLBA_source"     = "#7e819aff",
                 "Sardinia_LBA_source"    = "#186818ff",
                 "Iberia_LBA_source"      = "#2bba2bff",
                 "Levant_MLBA_source"     = "#800000ff",
                 "Iran_N_source"          = "#c46969ff",
 		 "North_Africa_IA_source" = "#fac233ff")
