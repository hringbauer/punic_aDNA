########################################################
# bash script for combining all types of qpAdm models
# in one large table
#
# The final output file  contatining all parsimonious models:
#    %OUTDIR%/qpAdm/combined-pars-models.tsv
########################################################

########################################################
# This script calls:
# - expand-sources.R
# - filter-parsimony-models.R
########################################################

##############################################
# %_OUTDIR% below should be set to the directory
# where all output files are placed
# this tag is replaced by configureScripts.sh
#################################################
outDir=%OUTDIR%/qpAdm
outFile=$outDir/combined-pars-models.tsv
scriptDir=`dirname $0`
# union of all proxy source populations
sources="Greece_BA_Myc_source Sicily_EMBA_source Steppe_MLBA_source Sardinia_LBA_source Iberia_EBA_source Levant_MLBA_source Iran_N_source North_Africa_IA_source"

#expand source set in each table
for modelType in easternModels westernModels broadModels; do
   #echo $modelType
   Rscript $scriptDir/expand-sources.R $outDir/$modelType/${modelType}-all-models-with-p.tsv "$sources" > $outDir/tempfile.tsv
   Rscript $scriptDir/filter-parsimony-models.R $outDir/tempfile.tsv 0.05 0.05 0.05 | \
      awk -v OFS="\t" -v type=$modelType '{if(NR<3){print;} else if(NR==3){print $0,"type";} else {print $0,type;}}' \
      > $outDir/tempfile-$modelType.tsv
   rm $outDir/tempfile.tsv
done

#copy header
head -n3  $outDir/tempfile-$modelType.tsv | tail -n1 > $outFile
#copy table contents
tail -qn+4 $outDir/tempfile-*.tsv |  sort -k1,1 -k2,2nr >> $outFile

rm $outDir/tempfile*.tsv

