#!/bin/bash

#SBATCH --partition=priority
#SBATCH -t 20:00:00		# Time in HH:MM:SS
#SBATCH -c 1                    # Number of cores requested
#SBATCH -N 1                    # Ensure that all cores are on one machine (span[hosts=1])
#SBATCH --mem=60G               # Memory total in GB (see also --mem-per-cpu)
#SBATCH --output=./logs/%A_%a.out
#SBATCH --error=./logs/%A_%a.err

##### N&I NAGIC #####
LD_LIBRARY_PATH=/opt/lsf/7.0/linux2.6-glibc2.3-x86_64/lib:/opt/nag/libC/lib:/usr/lib
NAG_KUSARI_FILE=/opt/nag/nag.license
LM_LICENSE_FILE=/opt/nag/license.dat

module load gcc
module load gsl/2.3
module load openblas
#module load R
module load graphviz
#module load matlab
module load fftw

PATH="$PATH:~np29/o2bin"
PATH="$PATH:/n/groups/reich/iosif/sw/fs-2.0.7"
PATH="$PATH:/n/groups/reich/iosif/sw/msdir/msdir"

##### PARAMS #####
TDIR="/n/scratch2/am483"
PFILE="run_NAFR_PCA.par"

##### ACTION #####
~np29/o2bin/smartpca -p ./$PFILE

