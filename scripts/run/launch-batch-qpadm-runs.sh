########################################################
# bash script for executing qpAdm on a list of target
# samples in parallel using the same qpAdm setup.
# This is an embedded bash script that 
# should be run using 'source' from another script.
# The following bash variables have to be defined:
# targets - list of target ids for qpAdm analysis
# sources - list of source populations for qpAdm analysis
# references - list of reference populations for a qpAdm analysis
# outDir - path to directory where all output files are written
# local_dataset - path to local data set files
# jobid - index for next job to run
# scriptDir - the directory where all utility scripts are placed
#
#
# The script runs qpAdm on all targets in the list in parallel
# using the specified source (left) pops and reference (right pops).
# qpAdm output files are generated in $outDir/tsv/
# qpAdm log files are generated in $outDir/log/
# The individual output files are then combined and processed
########################################################

########################################################
# This script is called by:
# - run-analysis-*.sh
# This script calls:
# - run-qpadm-admixr.R
# - group-out-tables.sh
# - compute-nested-p-values.R
# - expand-sources.R
# - targets-with-no-models.R
########################################################

num_targets=`echo $targets | tr -s " " "\n" | wc -l`
targetsPerJob=$(((num_targets-1)/maxJobs+1))
tsvFiles=""
startJob=$jobid
target_start=1
echo  >> $outDir/README
echo "Batch of jobs with sources = $sources" >> $outDir/README
while [ $target_start -le $num_targets ]
do
        # figure out python-style list for subset of targets
        ((target_end=target_start+targetsPerJob-1))
        my_targets=`echo $targets | tr -s " " "\n" | head -n$target_end | tail -n+$target_start | tr "\n"  " "`

	echo "- Running job $jobid with targets = $my_targets" >> $outDir/README
        # run qpadm on given set of targets
        nohup Rscript $scriptDir/run-qpadm-admixr.R \
                $local_dataset               \
                $outDir/tsv/job-$jobid.tsv       \
                "$references"                \
                "$sources"                   \
                "$my_targets"                   \
                &> $outDir/log/job-$jobid.log &

        tsvFiles="$tsvFiles $outDir/tsv/job-$jobid.tsv"
        ((target_start=target_end+1))
        ((jobid++))
done
endJob=$((jobid-1))
wait

# group results
bash $scriptDir/group-out-tables.sh $tsvFiles 1> $outDir/jobs$startJob-$endJob.tsv 2> $outDir/log/summary.log
Rscript $scriptDir/compute-nested-p-values.R $outDir/jobs$startJob-$endJob.tsv $outDir/jobs$startJob-$endJob-with-p-a.tsv
Rscript $scriptDir/expand-sources.R $outDir/jobs$startJob-$endJob-with-p-a.tsv "$allSources" > $outDir/jobs$startJob-$endJob-with-p.tsv
rm $outDir/jobs$startJob-$endJob-with-p-a.tsv

# remaining targets with no models in this round
targets=`Rscript $scriptDir/targets-with-no-models.R $outDir/jobs$startJob-$endJob-with-p.tsv $pvalThres`
echo "Targets with no valid model:" >> $outDir/README
echo $targets >> $outDir/README

