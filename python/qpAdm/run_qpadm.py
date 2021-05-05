#####
# Scripts to run qpAdm from Python
#
####

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

def qpAdm_run(leftpops, rightpops, output_file, 
              input_folder = "./eigenstrat/combined/", 
              input_file="punic.v44",
              par_file_folder = "./parfiles/", 
              input_ind_suff="_mod1", 
              output_folder ="./output/qpAdm/", 
              path_bin_qpAdm = "/n/groups/reich/hringbauer/o2bin/qpAdm",
              all_snps=False):
    """Run qpAdm. Write temporary parfile and run the analysis
    leftpops: List of left populations
    rightpops: List of right populations
    input_folder: Where to find the input files
    par_file_folder: Folder of the parameterfile
    input_file: The name of the input file
    input_ind_suff: Suffix of .ind file. To allow modified populations
    input_ind: name of the input .ind file. If given - write over default"""
    #print(os.getcwd())
    parfile_path = par_file_folder + "parfile." + output_file
    left_path = par_file_folder + "left." + output_file
    right_path = par_file_folder + "right." + output_file
    
    ### Create the parfile:
    with open(parfile_path, 'w') as f:
        f.write("%s\n" % ("DIR: " + input_folder))
        f.write("%s\n" % ("S1: " + input_file))
        
        indline = "indivname: DIR/S1" + input_ind_suff + ".ind"
        f.write("%s\n" % indline)
        f.write("%s\n" % "snpname: DIR/S1.snp")
        f.write("%s\n" % "genotypename: DIR/S1.geno")
        f.write("%s\n" % ("popleft: " + left_path))
        f.write("%s\n" % ("popright: " + right_path))
        f.write("%s\n" % "details: YES")   
        if all_snps==True:
            f.write("%s\n" % "allsnps: YES")
    
    ### Write leftpops rightpops:       
    with open(left_path, 'w') as f:
        f.write("\n".join(leftpops))
        
    with open(right_path, 'w') as f:
        f.write("\n".join(rightpops))
    
    output_path = output_folder + output_file + ".log"
    command = f"{path_bin_qpAdm} -p {parfile_path} > {output_path}"
    #print(f"Running command: \n{command}")
    
    ### Run qpAdm
    start = time()
    #!$path_bin_qpAdm -p $parfile_path > $output_path
    os.system(command)
    end = time()
    
    print("Runtime: %2f" % (end - start))
    return 0

############################################
### Identify Individuals to run

def load_iids_from_indfile(path_ind, string, 
                           col="clst", col_iid="iid"):
    """Load IIDs from Ind File
    Return List of IIDs"""
    df_ind = pd.read_csv(path_ind, delim_whitespace=True, header=None)
    df_ind.columns=["iid", "sex", "clst"]
    idx = df_ind[col].str.contains(string)
    ls = df_ind[idx][col_iid].values
    return ls

def remove_individuals(df, remove_list=["_d"], iid_col="iid"):
    """Remove indivdiuals from PCA dataframe"""
    idx = df[iid_col].str.contains("|".join(remove_list))
    df = df[~idx].copy()
    print(f"Filtering to {len(df)}/{len(idx)}")
    return df

def get_sub_pops(df, pop_list=[], pop_col="clst"):
    """Get Sub Populations"""
    idx = df[pop_col].str.contains("|".join(pop_list))
    df = df[idx].copy()
    print(f"Found: {len(df)}/{len(idx)}")
    return df

def get_sub_pops_exact(df, pop_list=[], pop_col="clst"):
    """Get Sub Populations"""
    idx = df[pop_col].isin(pop_list)
    df = df[idx].copy()
    print(f"Found: {len(df)}/{len(idx)}")
    return df

def get_sub_iid(df, pops=[""], iid_col="iid"):
    """Remove indivdiuals from PCA dataframe"""
    idx = df[iid_col].str.contains("|".join(pops))
    df = df[idx].copy()
    print(f"Found: {len(df)}/{len(idx)}")
    return df