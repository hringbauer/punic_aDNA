#!/bin/bash
########################################################
# bash script for fitting Eastern models using qpAdm.
# analyses are run in parallel.
# set maxJobs variable to max number of jobs you
# would like to allow to run in parallel.
#
# Reference (right) and source proxy (left) pops
# are set according to the Eastern model approach
# The final output files are:
#    All models:
#    %_OUTDIR%/qpAdm/easternModels/easternModels-all-models-with-p.tsv
#    Parsimonious models:
#    %_OUTDIR%/qpAdm/easternModels/easternModels-pars-models-with-p.tsv
########################################################

########################################################
# This script calls:
# - launch-batch-qpadm-runs.sh
# - group-out-tables.sh
# - filter-parsimony-models.R
########################################################

#######################################################
#                SETTINGS AND VARIABLES               #
#######################################################

# SET maxJobs TO THE MAX NUM OF QPADM JOBS YOU'D LIKE TO RUN IN PARALLEL
maxJobs=1

modelType=easternModels
##############################################
# %_DATADIR% in two paths below should be set
# to path of directory cotnaining the data files
# (including the ind file modified for qpAdm)
###
# %_OUTDIR% below should be set to the director
# where all output files are placed
# these two tags are replaced by configureScripts.sh
#################################################
# SET THIS TO THE PATH YOU'D LIKE OUTPUT FILES TO BE PLACED IN
outDir=%OUTDIR%/qpAdm/$modelType
dataset=%DATADIR%/ancient_genomes.v54
ind_file=%DATADIR%/ancient_genomes.v54.qpadm.ind


# scriptDir should contain the path to all utility scripts for running qpAdm analysis
scriptDir=`dirname $0`
sampleFile=$scriptDir/../sample-info.tsv
local_dataset=$outDir/data

pvalThres=0.05
# reference (right) pops: 14 base pops + 5 Western proxy sources
references="ElMiron_back Mota_back Ust_Ishim_back Kostenki14_back GoyetQ116_back Vestonice16_back Villabruna_back WHG_back EHG_back CHG_back MA1_back Natufian_back Levant_N_back Tunisia_N_back Greece_BA_Myc_source Sicily_EMBA_source Steppe_MLBA_source Sardinia_LBA_source Iberia_EBA_source"
# source (left) pops:
sources="Iran_N_source Levant_MLBA_source North_Africa_IA_source"
# list for all targets
targets=`tail -n+2 $sampleFile | cut -f1`


#######################################################
#                  COPY DATA FILES                    #
#######################################################

# copy data files
mkdir -p $outDir
ln -s  $dataset.snp  $local_dataset.snp
ln -s  $dataset.geno $local_dataset.geno
ln -rs $ind_file     $local_dataset.ind

#######################################################
#              CREATE DOCUMENTATION                   #
#######################################################
echo "     dataset = $dataset"    >> $outDir/README
echo "  references = $references" >> $outDir/README
echo "     sources = $sources"    >> $outDir/README
echo "     targets = "            >> $outDir/README
echo $targets                     >> $outDir/README


#######################################################
#              Base round - all sources               #
#######################################################
mkdir $outDir/log
mkdir $outDir/tsv
jobid=1
allSources=$sources
source $scriptDir/launch-batch-qpadm-runs.sh


#######################################################
#           Round 2 - all but Iran                    #
#######################################################
sources="Levant_MLBA_source North_Africa_IA_source"
source $scriptDir/launch-batch-qpadm-runs.sh

#######################################################
#           Round 3 - all but North Africa            #
#######################################################
sources="Iran_N_source Levant_MLBA_source"
source $scriptDir/launch-batch-qpadm-runs.sh

#######################################################
#           Round 4 - all but Levant                  #
#######################################################
sources="Iran_N_source North_Africa_IA_source"
source $scriptDir/launch-batch-qpadm-runs.sh

bash $scriptDir/group-out-tables.sh `ls $outDir/jobs*-with-p.tsv` > $outDir/$modelType-all-models-with-p.tsv
Rscript $scriptDir/filter-parsimony-models.R $outDir/$modelType-all-models-with-p.tsv $pvalThres $pvalThres $pvalThres > $outDir/$modelType-pars-models-with-p.tsv


