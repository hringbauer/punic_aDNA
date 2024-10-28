###############################################
# Simple bash script for configuring all other
# scripts before running qpAdm.
# Set the bash variables below according to
# specification
# Run script with -u to reset scripts to initial (unconfigured) form
#############################

###############################################
# Set binDir to the directory containing qpAdm
# executable
binDir=___SPECIFIY_BIN_DIR_HERE___!!!

###############################################
# Set dataDir to the path of a directory that
# contains data files:
# - ancient_genomes.v54.geno
# - ancient_genomes.v54.ind
# - ancient_genomes.v54.snp
dataDir=___SPECIFIY_DATA_DIR_HERE___!!!

###############################################
# Set outDir to the directory where you wish 
# all output files to be generated in
outDir=___SPECIFIY_OUTPUT_DIR_HERE___!!!

###############################################

# create subdirectories for qpAdm output and plots
mkdir -p $outDir/qpAdm $outDir/plots

scriptDir=`dirname $0`


script=run/run-qpadm-admixr.R
if [ "$1" != "-u" ]; then
   sed -r -i 's|%ADMIXTOOLS_DIR%|'$binDir'|g' $scriptDir/$script
else
   sed -r -i 's|'$binDir'|%ADMIXTOOLS_DIR%|g' $scriptDir/$script
fi

# scripts for running qpAdm
configuredScripts="\
prepare-qpadm-ind-file.sh \
run-analysis-broad-select.sh \
run-analysis-broad.sh \
run-analysis-eastern.sh \
run-analysis-western.sh \
combine-qpadm-models.sh \
"
for script in $configuredScripts; do
   if [ "$1" != "-u" ]; then
      sed -r -i 's|%DATADIR%|'$dataDir'|g'   $scriptDir/run/$script
      sed -r -i   's|%OUTDIR%|'$outDir'|g'   $scriptDir/run/$script
   else
      sed -r -i 's|'$dataDir'|%DATADIR%|g'   $scriptDir/run/$script
      sed -r -i   's|'$outDir'|%OUTDIR%|g'   $scriptDir/run/$script
   fi
done

# plotting script
script=plot/plot-settings.R
if [ "$1" != "-u" ]; then
   sed -r -i 's|%OUTDIR%|'$outDir'|g'   $scriptDir/$script
else
   sed -r -i 's|'$outDir'|%OUTDIR%|g'   $scriptDir/$script
fi

