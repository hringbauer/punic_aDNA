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

def run_qpAdm_batch(iids, outgroups, comp_groups, n_source=3, 
                    input_folder="", input_file="", output_folder = "", 
                    par_file_folder="", input_ind_suff = "", path_bin_qpAdm="",
                    all_snps=True):
    """Run qpAdm for batch of individuals.
    sources: Run all combinations of sources
    outgroups"""
    source_list = it.combinations(comp_groups, n_source)
    
    for sources in source_list:
        add_out = [c for c in comp_groups if c not in sources]
        sources = list(sources)
        
        for iid in iids[:]:
            print(f"Running Individual {iid} with sources {sources}...")
            leftpops = [iid] + sources
            qpAdm_run(leftpops = leftpops, 
                      rightpops = outgroups + add_out, 
                      output_file = ".".join(leftpops) + ".log", 
                      input_folder = input_folder, 
                      input_file = input_file,
                      par_file_folder = par_file_folder, 
                      input_ind_suff = input_ind_suff, 
                      output_folder = output_folder, 
                      path_bin_qpAdm = path_bin_qpAdm,
                      all_snps=all_snps) 
            

#########################################################
#########################################################
### Set Parameters

batch_size = 1 ### How many Individuals to run concurrently
source_ns = range(1,6)

outgroups = ["Mota", "Ust_Ishim", "Kostenki14", "GoyetQ116-1", "Vestonice16", "MA1",
            "ElMiron", "Villabruna", "EHG", "CHG", 
            "Levant_N", "Anatolia_N"] # "Steppe_EMBA" # Natufian
comp_groups = ["Italy_Sicily_IA_Polizzello", "Tunisia_N", "Greece_BA_Mycenaean", 
               "Israel_Phoenician", "Italy_Sardinia_BA_Nuragic"]

input_folder = "/n/groups/reich/hringbauer/git/punic_aDNA/eigenstrat/combined"
input_file = "punic.v46.3"
par_file_folder = "/n/groups/reich/hringbauer/git/punic_aDNA/parfiles/"
input_ind_suff = "_ind"
path_bin_qpAdm = "/n/groups/reich/hringbauer/git/AdmixTools/bin/qpAdm"
path_iids = "/n/groups/reich/hringbauer/git/punic_aDNA/output/tables/qpAdm30Kpunic.v46.3.tsv"
df1 = pd.read_csv(path_iids, sep="\t")
iids = df1["iid"].values
print(f"Loaded {len(iids)} IIDs to analyze with qpAdm.")

if len(sys.argv) < 2:
        raise RuntimeError("Script needs 1 argument")
i = int(sys.argv[1]) # The Parameter passed to the Python Script

#########################################################
#########################################################
### Do the full run

if __name__ == "__main__":
    iids_batch = get_iids_batch_i(iids=iids, i=i, batch_size=batch_size)
    
    ### Iterate over source numbers:
    for n in source_ns:
        output_folder = f"/n/groups/reich/hringbauer/git/punic_aDNA/output/qpAdm/v46.3/{n}way/"
        
        run_qpAdm_batch(iids = iids_batch, outgroups=outgroups, n_source=n,
                        comp_groups=comp_groups, input_folder=input_folder,
                        input_file=input_file, par_file_folder=par_file_folder, 
                        input_ind_suff=input_ind_suff, path_bin_qpAdm=path_bin_qpAdm, 
                        output_folder=output_folder)