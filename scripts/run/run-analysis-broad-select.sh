#!/bin/bash
########################################################
# bash script for fitting Broad ancestry models using qpAdm.
# analyses are run in parallel. 
# A small subset of indivudlas is considered to illustrate
# uncertainty in ancestry modeling.
#
# set maxJobs variable to max number of jobs you
# would like to allow to run in parallel.
#
# Reference (right) and source proxy (left) pops
# are set according to the Broad ancestry approach
# The final output files are:
#    All models:
#    %_OUTDIR%/qpAdm/broadModels/broadModels-all-models-with-p.tsv
#    Parsimonious models:
#    %_OUTDIR%/qpAdm/broadModels/broadModels-pars-models-with-p.tsv
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

modelType=broadModelsSelect
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
# reference (right) pops: 14 base pops
references="ElMiron_back Mota_back Ust_Ishim_back Kostenki14_back GoyetQ116_back Vestonice16_back Villabruna_back WHG_back EHG_back CHG_back MA1_back Natufian_back Levant_N_back Tunisia_N_back"
# source (left) pops:
sources="Greece_BA_Myc_source Sicily_EMBA_source Steppe_MLBA_source Sardinia_LBA_source Iberia_EBA_source Iran_N_source Levant_MLBA_source North_Africa_IA_source"


# select individuals with complex inferred broad models
targets="I22252 I22258 I12666 I28504 I24031 I4798 I21853 I26931 I27613 I18201 I22096 VIL006"


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
#           Round 2 - all but Sardinia                #
#######################################################
sources="Greece_BA_Myc_source Sicily_EMBA_source Steppe_MLBA_source Iberia_EBA_source Iran_N_source Levant_MLBA_source North_Africa_IA_source"
source $scriptDir/launch-batch-qpadm-runs.sh

#######################################################
#           Round 3 - all but Steppe                  #
#######################################################
sources="Greece_BA_Myc_source Sicily_EMBA_source Sardinia_LBA_source Iberia_EBA_source Iran_N_source Levant_MLBA_source North_Africa_IA_source"
source $scriptDir/launch-batch-qpadm-runs.sh

#######################################################
#           Round 4 - all but Iberia                  #
#######################################################
sources="Greece_BA_Myc_source Sicily_EMBA_source Steppe_MLBA_source Sardinia_LBA_source Iran_N_source Levant_MLBA_source North_Africa_IA_source"
source $scriptDir/launch-batch-qpadm-runs.sh

#######################################################
#           Round 5 - all but NorAf                   #
#######################################################
sources="Greece_BA_Myc_source Sicily_EMBA_source Steppe_MLBA_source Sardinia_LBA_source Iberia_EBA_source Iran_N_source Levant_MLBA_source"
source $scriptDir/launch-batch-qpadm-runs.sh

#######################################################
#           Round 6 - all but Sicily                  #
#######################################################
sources="Greece_BA_Myc_source Steppe_MLBA_source Sardinia_LBA_source Iberia_EBA_source Iran_N_source Levant_MLBA_source North_Africa_IA_source"
source $scriptDir/launch-batch-qpadm-runs.sh

#######################################################
#           Round 7 - all but Greece                  #
#######################################################
sources="Sicily_EMBA_source Steppe_MLBA_source Sardinia_LBA_source Iberia_EBA_source Iran_N_source Levant_MLBA_source North_Africa_IA_source"
source $scriptDir/launch-batch-qpadm-runs.sh

#######################################################
#           Round 8 - all but Iran                    #
#######################################################
sources="Greece_BA_Myc_source Sicily_EMBA_source Steppe_MLBA_source Sardinia_LBA_source Iberia_EBA_source Levant_MLBA_source North_Africa_IA_source"
source $scriptDir/launch-batch-qpadm-runs.sh

#######################################################
#           Round 9 - all but Levant                  #
#######################################################
sources="Greece_BA_Myc_source Sicily_EMBA_source Steppe_MLBA_source Sardinia_LBA_source Iberia_EBA_source Iran_N_source North_Africa_IA_source"
source $scriptDir/launch-batch-qpadm-runs.sh

#######################################################
#           Round 10 - CenMed + NorAf                 #
#######################################################
sources="Greece_BA_Myc_source Sicily_EMBA_source North_Africa_IA_source"
source $scriptDir/launch-batch-qpadm-runs.sh

#######################################################
#           Round 11 - Levant + NorAf                 #
#######################################################
sources="Iran_N_source Levant_MLBA_source North_Africa_IA_source"
source $scriptDir/launch-batch-qpadm-runs.sh


bash $scriptDir/group-out-tables.sh `ls $outDir/jobs*-with-p.tsv` > $outDir/$modelType-all-models-with-p.tsv
Rscript $scriptDir/filter-parsimony-models.R $outDir/$modelType-all-models-with-p.tsv $pvalThres $pvalThres $pvalThres > $outDir/$modelType-pars-models-with-p.tsv


