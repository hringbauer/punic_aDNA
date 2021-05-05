#!/bin/bash
#SBATCH --time=2:30:00
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=10g
#SBATCH --job-name=qpAdm_punic
#SBATCH --output=nb-log-%J.out
#SBATCH --error=nb-log-%J.err
#SBATCH --export=NONE
#SBATCH --output=./logs/%A_%a.out
#SBATCH --error=./logs/%A_%a.err
#SBATCH --array=0-193  #0-500%200

#unset SLURM_EXPORT_ENV
#export OMP_NUM_THREADS=1

module load gcc/6.2.0
module load python/3.7.4
module load gsl/2.3 openblas/0.2.19

source /n/groups/reich/hringbauer/explore_ntbk/jptvenv37/bin/activate

# Execute the following tasks
python3 scripts/qpadm.distal.algeriaIA_v46.3.py $SLURM_ARRAY_TASK_ID 