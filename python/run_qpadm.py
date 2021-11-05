#####
# Scripts to run qpAdm from Python
# Includes Wrappers for qpAdm
# and functins to generate modified .ind files
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
              all_snps=False, delete=True):
    """Run qpAdm. Write temporary parfile and run the analysis
    leftpops: List of left populations
    rightpops: List of right populations
    input_folder: Where to find the input files
    par_file_folder: Folder of the parameterfile
    input_file: The name of the input file
    input_ind_suff: Suffix of .ind file. To allow modified populations
    input_ind: name of the input .ind file. If given - write over default
    delete: Whether to delete the parfile after the run. Default True as
    these info can be found in the output file"""
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
    
    ### Delete the parfiles if selected
    if delete:
        os.remove(left_path)
        os.remove(right_path)
        os.remove(parfile_path)
    
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


################################################
### Modify Ind Files

################################################################
### To overwrite .ind Files

def overwrite_ind_df(df, string, col="clst", 
                     output=False, overwrite="", iids=False):
    """Overwrite Individual Dataframe where col
    contains string. Return modified dataframe (Copy)
    where overwrite is the new Cluster ID
    iids: Overwrite with IIDs if True!"""
    idx = df[col].str.contains(string)
    
    if np.sum(idx)==0:
        if output: 
            print("No Indivdiuals found")
        return
    
    if output:
        print(f"Found {np.sum(idx)} Matches")
        print(df[idx][col].value_counts())
    
    ### Actually  overwrite the Column
    if len(overwrite)>0:
        df.loc[idx, col] = overwrite
        if output: 
            print(f"{np.sum(idx)} Overwritten!")
            
    if iids:
        df.loc[idx, col] = df.loc[idx, "iid"] 
        
        
### Overwrite Individual IIDs
def modifiy_iid_files(df_ind, pops_overwrite, 
                      pops_overwrite12=[], ind_modified=""):
    """Modify .ind file. Overwrite individuals from pops_overwrite (list)
    with their individuals labels. 
    df_int: Dataframe from Individuals.
    pops_overwrite12: [[pop1,pop2]] list (nx2). Overwrites ALL string matches
    for pop1 (contain) with pop2"""
    
    ### Overwrite with other Label
    for pop1,pop2 in pops_overwrite12:
        overwrite_ind_df(df_ind, pop1, overwrite=pop2)
        
    ### Overwrite with individual IIds
    for pop in pops_overwrite:
        overwrite_ind_df(df_ind, pop, 
                     iids=True, output=True)
    
    ### Save here
    df_ind.to_csv(ind_modified, sep=" ", index=None, header=False)
    print(f"Saved {len(df_ind)} Individuals to {ind_modified}")
    
def set_iids_to_label(df_ind, iids_overwrite, label_new="",
                    pops_overwrite12=[], savepath=""):
    """Modify .ind file. Overwrite individuals from pops_overwrite (list)
    with their individuals labels. Return modified Data Frame
    df_ind: Dataframe from Individuals in .ind file
    iids_overwrite: List of iids to overwrite
    label_new: New label. If empty, use individual iids
    pops_overwrite12: [[pop1,pop2]] list (nx2). Overwrites ALL string matches
    for pop1 (contain) with pop2"""
    
    ### Overwrite with other Label
    idx = df_ind["iid"].isin(iids_overwrite)
    print(f"Overwriting {np.sum(idx)} Individuals")
    
    if len(label_new)==0:
        df_ind.loc[idx, "clst"] = df_ind.loc[idx, "iid"]  ### Use indiviual Labels
    else:
        df_ind.loc[idx, "clst"] = label_new               ### Use new group label
        
    ### Overwrite with other Label
    for pop1,pop2 in pops_overwrite12:
        overwrite_ind_df(df_ind, pop1, overwrite=pop2)
    
    ### Save here
    if len(savepath)>0:
        df_ind.to_csv(savepath, sep=" ", index=None, header=False)
        print(f"Saved {len(df_ind)} Individuals to {savepath}")
        
    return df_ind
        
        
def load_individuals_filetered(
                            path_anno = "/n/groups/reich/hringbauer/Data/v42.3.anno.csv",
                            col="clst", col_iid="iid",
                            min_snps_cov=50000,
                            snp_cov_col="n_cov_snp",
                            master_id_col="Master ID",
                            ):
    """Filter List of Individuals against meta,
    using minimal Nr of SNPs and unique IDs"""

    df_all = pd.read_csv(path_anno)

    ### Keep only the best coerage Indivdual
    df_all = df_all.sort_values(by=snp_cov_col, ascending=False)
    df_all = df_all.drop_duplicates(subset=master_id_col)
    
    ### Filter to min Nr of SNPs
    df_all = df_all[df_all[snp_cov_col]>=min_snps_cov]
    
    ### 
    df_all = df_all
    return df_all["iid"].values

def get_meta_ind_table(path_ind="./eigenstrat/combined/punic.v49.0.ind",
                       path_anno="/n/groups/reich/hringbauer/Data/v49.0.anno.csv",
                       min_snp=30000):
    """Load .ind file, extract all individuals > min_snp SNPs
    and merge with .anno File"""
    df = pd.read_csv(path_ind, delim_whitespace=True, header=None)
    df.columns=["iid", "sex", "clst"]
    df = remove_individuals(df, remove_list=["_d"])
    print(f"Loaded {len(df)} Individuals")

    df_meta = pd.read_csv(path_anno, sep=",")
    df2 = df_meta[["iid", "Master ID", "loc", "n_cov_snp", "mean_cov", "sex"]]
    df = pd.merge(df, df2, on="iid", how="left")
    idx = (df["n_cov_snp"]<min_snp)
    df = df[~idx]
    df.loc[df["loc"].isnull(), "loc"]="not assigned"
    print(f"Filtered to {len(df)} Individuals based on #SNP covered> {min_snp}")

    df = df.sort_values(by="n_cov_snp", ascending=False)
    dup = (df["Master ID"].duplicated() & ~df["Master ID"].isnull())
    df = df[~dup].copy().reset_index(drop=True)
    print(f"Filtered to {len(df)} Individuals based on duplicates.")
    return df