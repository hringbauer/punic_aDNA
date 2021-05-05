#########################################################
### Script to run qpAdm competation on Harvard Cluster
### v46.3

#################################
### Imports
import numpy as np
import os  # For Saving to Folder
import pandas as pd
import matplotlib.pyplot as plt
import socket
import os as os
import sys as sys
import multiprocessing as mp
import itertools as it
from time import time

socket_name = socket.gethostname()
print(socket_name)

if socket_name.startswith("compute-"):
    print("HSM Computational partition detected.")
    path = "/n/groups/reich/hringbauer/git/punic_aDNA/"  # The Path on Midway Cluster
else:
    raise RuntimeWarning("Not compatible machine. Check!!")

os.chdir(path)  # Set the right Path (in line with Atom default)
# Show the current working directory. Should be HAPSBURG/Notebooks/ParallelRuns
print(os.getcwd())
print(f"CPU Count: {mp.cpu_count()}")
print(sys.version)

sys.path.append("./python")
from qpAdm.run_qpadm import qpAdm_run, remove_individuals, get_sub_pops_exact, get_sub_pops

##################################
### Necessary Functions

def get_iids(df, pops=[], exact=True):
    """Get IIDs within certain populations from dataframe df.
    Return list of indivdiuals as well as dataframe"""
    if exact:
        df1 = get_sub_pops_exact(df, pop_list=pops)
    else:
        df1 = get_sub_pops(df, pop_list=pops)

    df_all = pd.concat((df1,))
    all_iids = df_all["iid"].values
    print(f"Will run {len(all_iids)} Indvidiuals")
    return all_iids, df_all

def get_iids_batch_i(iids=[], i=1, batch_size=5):
    """Get List of IIDs in batch i in batches of size batch_size.
    Return list of iids"""
    iids_t = iids[i * batch_size : (i+1) * batch_size]
    assert(len(iids_t) == batch_size)
    return iids_t

#########################################################
#########################################################
### Set Parameters

batch_size = 1 ### How many Individuals to run concurrently
outgroups = ["Anatolia_N", "Villabruna", "Steppe_MLBA", "Levant_N", "Natufian",
             "Tunisia_N", "Morocco_Iberomaurusian"] 

### "Steppe_EMBA" # Natufian
sources = ['Algeria_IA', 'Greece_BA_Mycenaean', 'Spain_IA']

input_folder = "/n/groups/reich/hringbauer/git/punic_aDNA/eigenstrat/combined"
input_file = "punic.v46.3"
output_folder = f"/n/groups/reich/hringbauer/git/punic_aDNA/output/qpAdm/v46.3/nafr3way/"
path_iids = "/n/groups/reich/hringbauer/git/punic_aDNA/output/tables/qpAdm30Kpunic.v46.3.tsv"

par_file_folder = "/n/groups/reich/hringbauer/git/punic_aDNA/parfiles/qpAdm/"
input_ind_suff = "_ind"
path_bin_qpAdm = "/n/groups/reich/hringbauer/git/AdmixTools/bin/qpAdm"

### Parameters
all_snps=True

#########################################################
#########################################################
### Do the full run

if __name__ == "__main__":
    ### Read out the batch parameter
    if len(sys.argv) < 2:
            raise RuntimeError("Script needs 1 argument")
    i = int(sys.argv[1]) # The Parameter passed to the Python Script
    
    ### Get IIDs
    df1 = pd.read_csv(path_iids, sep="\t")
    iids = df1["iid"].values
    print(f"Loaded {len(iids)} IIDs to analyze with qpAdm.")

    iids_batch = get_iids_batch_i(iids=iids, i=i, batch_size=batch_size)
    
    ### Iterate over source numbers:
    for iid in iids_batch:
        print(f"Running Individual {iid} with sources {sources}...")
        leftpops = [iid] + sources
        qpAdm_run(leftpops = leftpops, 
                  rightpops = outgroups,
                  output_file = ".".join(leftpops), 
                  input_folder = input_folder, 
                  input_file = input_file,
                  par_file_folder = par_file_folder, 
                  input_ind_suff = input_ind_suff, 
                  output_folder = output_folder, 
                  path_bin_qpAdm = path_bin_qpAdm,
                  all_snps=all_snps)