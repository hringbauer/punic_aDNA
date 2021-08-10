#####
# Scripts to plot qpAdm Plots
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

def load_qp_adm(path, infeasible=False):
    """Load, parse and return qp-Adm file.
    Return: 
    res: mxnx2 arryay: m: Nr subsets admixed pops, n: Nr 
    p_vals: List of m p-Values
    pops: List of Strings of analyzed populations. First is target, rest sources.
    infeasible: Whether to return infeasible as result"""
    pop_line, pop_line_end = -1, -1 # Where the populations are found   
    res_begin, res_end = -1, -1
    std_line = -1  # Where the standard Deviation will land
    
    # Iterate over everything and use the signals for start/stop
    with open(path, "r") as f:
        for i, line in enumerate(f):
            if line =="left pops:\n":
                pop_line = i+1 
            if line=="right pops:\n":
                pop_line_end = i-1 # There is an empty line before
                
            # Parse off everything to first space
            s0 = line.split()
            if len(s0)>=2:
                #if s0[0] == "summ:":
                #    res_begin= i+3
                if s0[0] == "fixed" and s0[1]=="pat":
                    res_begin = i+1
                    
                if s0[0] == "best" and s0[1]=="pat:":
                    if res_end < 0: # Only take the first occurence
                        res_end = i
                        
                elif s0[0] == "std." and s0[1]=="errors:":
                    std_line = i
    
    ### Read out the results:
    with open(path, "r") as f:
        lines = f.readlines()
        pops = lines[pop_line:pop_line_end]
        pops = [p.rstrip() for p in pops]  # Chews off new line symbol

        res = lines[res_begin:res_end]
        stds = lines[std_line]
    
    # Post-process the important Lines:
    res_t = np.array([s.split()[:len(pops)+4] for s in res]) # 8 is valid for 3 pops!
    res = res_t[:,5:].astype("float")
    p_vals = res_t[:,4].astype("float")
    stds = np.array(stds.split())[2:].astype("float")  # Extract the Standard Deviations for the first line
            
    # Read out estimates and p-Value
    assert(len(p_vals)==len(res)) # Sanity Check
    return res, p_vals, pops, stds

def load_pvals(path):
    """Load and parse qpAdm log file for p-Value.
    Return: 
    p-val:  p-Value
    pops: [Target, Source]"""
    
    pop_line, pop_line_end = -1, -1 # Where the populations are found   
    p_val_line = -1
    
    # Iterate over everything and use the signals for start/stop
    with open(path, "r") as f:
        for i, line in enumerate(f):
            if line =="left pops:\n":
                pop_line = i+1 
            if line=="right pops:\n":
                pop_line_end = i-1 # There is an empty line before
                
            if line=="codimension 1\n":
                p_val_line = i+2
    
    ### Read out the results:
    with open(path, "r") as f:
        lines = f.readlines()
        pops = lines[pop_line:pop_line_end]
        pops = [p.rstrip() for p in pops]  # Chews off new line symbol

        pval = lines[p_val_line].split()[7]
          
    return float(pval), pops   


def fig_admix(axes=[], res=[], p_vals=[], source_pops=[], 
              labels=[], xlabels=[],
              figsize=(12,8), save_path="", lw=2,
              pval_lim=[1e-6,1.0], stds=[], alpha=0.9,
              l_pos = (1, 0.5), fs = 12, bw = 0.85, 
              c=[], ec = "white", show=False,
              height_ratios=[1, 8], rotation=90, legend=True):
    """Make a Figure of the admixture coefficients.
    axes: 2 axis where to plot Fractions and p-Values onto
    res: Array of Results [n targets, k source pops]
    p_vals: Array of p-Vals [n]
    source_pops: String Array of Source Pops [k]
    xlabels: String Array of Labels on x Axis [n]
    stds: Standard Errors. If none are given do not plot them
    l_pos: Where to place the Legend.
    lw: Linewidth of bar"""
    
    ### Define Axes if not given
    if len(axes)==0:
        fig, axes = plt.subplots(nrows=2, ncols=1,
                                 gridspec_kw={'height_ratios': height_ratios}, 
                                 figsize=figsize)
    ax0, ax1 = axes
    
    if len(labels)==0:
        labels=source_pops
    
    # Plot Parameters
    r = np.arange(len(xlabels))
    barWidth = bw
    if len(c)==0:
        c=["DeepPink", "MediumBlue", "purple", "yellowgreen", "gold"]
    
    for i, s in reversed(list(enumerate(source_pops))): # From last to first (For Legend)
        b = np.sum(res[:,:i], axis=1) # Do the cumsum of all previous admixture fracs
        ax1.bar(r, res[:,i], bottom=b, color=c[i], edgecolor=ec, 
                width=barWidth, label=labels[i], alpha=alpha)
        
        if len(stds)>0: # Plot some standard deviations.
            ax1.errorbar(r, b+res[:,i], yerr=stds[:,i], fmt='none', linewidth=lw, color="k")
    
    ### Add the Model not viable bars:
    su = np.sum(res, axis=1)
    sum0ids = np.where(su==0)[0]
    
    for i in sum0ids:
        ax1.bar(i, 1, color="lightgray", edgecolor='white', width=barWidth, alpha=0.9)
     
    ################
    # Custom x axis
    ax1.set_xticks(r)
    ax1.set_xticklabels(xlabels, fontsize=fs, rotation=rotation)

    # Add a legend
    #l1 = ax1.legend(loc=l_pos, bbox_to_anchor=(1, 0.5), ncol=1, fontsize=fs)
    if legend:
        l1 = ax1.legend(bbox_to_anchor=l_pos, ncol=1, fontsize=fs)
        l1.set_title('Sources: ', prop={'size':fs})
    
    ax1.set_ylabel("Fraction Ancestry", fontsize=fs*1.5)
    ax1.set_ylim([0,1])
    ax1.set_xlim([-0.6, len(xlabels)-0.4])
    
    ax0.set_yscale("log")
    ax0.set_ylim(pval_lim)
    ax0.bar(r, p_vals, color="grey", width=barWidth, alpha=0.8, zorder=1)
    ax0.axhline(y=0.05, color='r', zorder=0)
    ax0.set_ylabel("p-Val", fontsize=fs)
    ax0.set_xlim([-0.6,len(xlabels)-0.4])
    ax0.set_xticks([])
    
    # Adjust position of subplots
    #plt.subplots_adjust(left=0, bottom=0.05, right=None,
    #            wspace=0, hspace=0.06)
    
    if len(save_path) > 0:
        plt.savefig(save_path, bbox_inches = 'tight', pad_inches = 0)
        print("Saved to %s" % save_path)
        # Save the .csv of the Results
    
    if show:
        plt.show()

def create_admix_df(source_pops, admix_coeffs, stds, p_vals):
    """Create Dataframe with Admixture Proportions and Standard Errors.
    Assume all input is as Numpy Array (otherwise indexing errors!!)"""
    n = len(source_pops[0,:])  # Get Number Sources +1
    df = pd.DataFrame({"target":source_pops[:,0], "p-Value":p_vals})
    
    for i in range(1,n):
        df[f"Source_{i}"] = source_pops[:,i]
        
    for i in range(1,n):
        df[f"Fraction_{i}"] = admix_coeffs[:,i-1]
        
    for i in range(1,n):
        df[f"STD_{i}"] = stds[:,i-1]
    return df
    
def give_admix0(res, minval=-1e-4):
    """Return the Admixture Coefficients of the first Model.
    Only return 0 if feasible, else nana"""
    
    feasible = np.min(res[0])>minval  # Check if feasible
    if feasible == 0:
        return np.nan  # No Feasible Model
    return 0
    
def give_admix_index(res):
    """Return index of first viable admixture result.
    res: nxk array. n...Nr of all subsets, k...Nr of Source Pops"""    
    for i, ls in enumerate(res):
        if np.min(ls)>-1e-4:
            return i
    print("Warning: No valid admixture found!!")       
    return np.nan # Default Return

def give_admix_index_best(res, pvals, minval=-1e-4):
    """Return index of best viable admixture result.
    res: nxk array. n...Nr of all subsets, k...Nr of Source Pops"""  
    feasible = np.min(res, axis=1)>minval  # Extract all feasible results
    pvals_okay = feasible * pvals  # Set bad ones to 0.
    
    if np.max(pvals_okay)==0:
        print("Warning: No valid admixture found!!")
        return np.nan
    
    i = np.argmax(pvals_okay) # The Index with the Maximum Value
    return i
    
def sci_notation(num, decimal_digits=1, precision=None, exponent=None):
    """
    Returns a string representation of the scientific
    notation of the given number formatted for use with
    LaTeX or Mathtext, with specified number of significant
    decimal digits and precision (number of decimal digits
    to show). The exponent to be used can also be specified
    explicitly.
    """
    if not exponent:
        exponent = int(np.floor(np.log10(abs(num))))
    coeff = round(num / float(10**exponent), decimal_digits)
    if not precision:
        precision = decimal_digits

    return "${0:.{2}f}\cdot10^{{{1:d}}}$".format(coeff, exponent, precision)


def create_latex_lines(source_pops, admix_coeffs, stds, p_vals, na = "-", rp = "A12"):
    """Print a Line for Latex Table in the main Text. 
    Script to speed things up.
    source_pops, nx(j+1) Array, j...NR of Sources (<=3)
    admix_coeffs, stds: nxj Array
    p_vals: nx1 Array
    na: Character for Missing Data
    rp: String for right population"""
    out =""
    
    for i in range(len(source_pops)): # Iterate over every line
        ls = [na for _ in range(12)] # Create empty vector with na Symbol
        
        assert(len(source_pops[i])<=4) # At most 4 sources
        
        for j, s in enumerate(source_pops[i]): # Fill in the Source Populations
            ls[j] = s   
            
        ls[4] = rp        # Right Pop
        
        p = p_vals[i]
        
        if p==0.0:
            ls[5] = "0" 
        elif p>=0.05:
            ls[5] = "\\textbf{" +  str(np.around(p, 3)) + "}" # Make bold
            
        elif p>= 0.01:
            ls[5] = np.around(p, 3) # Round to three Digits            
        elif p<0.01: 
            ls[5] = sci_notation(p, decimal_digits=1)  # Do proper formatting      
        
        for j, x in enumerate(admix_coeffs[i]): # Fill in the admixture fractions
            ls[6+j] = "{:.3f}".format(x) 
            
        for j, x in enumerate(stds[i]): # Fill in the uncertainty of admixture fractions
            ls[9+j] = "{:.3f}".format(x)        
        
        s = " & ".join(str(x) for x in ls) # Convert to Strings and Join
        s=s.replace("_", "-") # Replace tricky underscore symbols (for Latex tables)
        print(s + "\\\\") # Add two backslashes
        out += (s + "\n") # Do next Line
        
    return out # Return the full text

def plot_qpadm(dir_path, test_pops, xlabels=[], labels=[],
               save_path="", l_pos = (0.4, 1.15), 
               best=True, figsize=(12,8), bw = 0.85, lw=2,
               height_ratios = [1,8], sort_p=False, 
               c=[], alpha=0.9, ec="white", fs=10, pval_lim = [1e-3,1],
               latex=False, dataframe=False):
    """Do 3 Way Admixtures of Sardinia
    best: Whether to use highest p-Val Submodel: 0 use the first, 
    True use the best p-Value, 
    else use the old (first feasible).
    labels: What labels to give to Admixture Components
    sort_p: Whether to sort by p-Values (from highest to lowest)"""
    admix_coeffs = []
    p_vals = []
    pops_t = [] 
    stds = []
    pr = False # Print the statistics

    #for filename in os.listdir(dir_path):
    for f in test_pops:
        full_path = dir_path + str(f) + ".log" # Other "outputMycSicily_"
        res, p_val_ls, pops, std = load_qp_adm(full_path)
        pops_t.append(pops[0])
        
        if best == 0:
            i = give_admix0(res)   # Give the first result (if feasible)
            
        elif best == True:
            i = give_admix_index_best(res, p_val_ls) # Give the best feasible p-Value
        
        else:
            i = give_admix_index(res)
            
        #### Handle Not fitting Models  
        if np.isnan(i): # In Case no valid admixture:
            new_res = np.zeros(np.shape(res)[1]) # Not Plot anything
            std = np.zeros(np.shape(res)[1])     # Not Plot anything
            new_p = -1 # For Sorting
        
        else:
            new_res = res[i,:]
            new_p = p_val_ls[i]
        
        admix_coeffs.append(new_res)
        p_vals.append(new_p)
        stds.append(std)

        if pr == True:
            print("Population: %s" % f)
            print(res[i,:])
            print(std)
            print(p_val_ls[i])

    admix_coeffs, stds = np.array(admix_coeffs), np.array(stds)
    p_vals = np.array(p_vals)
    source_pops = pops[1:]
    
    #print(pops_t)
    if sort_p:
        idx = np.argsort(-p_vals)
        
        admix_coeffs = admix_coeffs[idx,:]
        stds = stds[idx,:]
        p_vals = p_vals[idx]
        pops_t = np.array(pops_t)[idx]
        xlabels = np.array(xlabels)[idx]
    
    fig_admix(res=admix_coeffs, stds=stds, 
              p_vals=p_vals, labels=labels, xlabels=xlabels,
              source_pops=source_pops, 
              pval_lim=pval_lim, save_path = save_path, 
              l_pos = l_pos, lw=lw, 
              height_ratios=height_ratios,
              fs=fs, figsize=figsize, 
              bw = bw, c=c, ec = ec, alpha=alpha)
    
    if latex:
        source_pops = [([t] + pops[1:]) for t in pops_t]
        create_latex_lines(source_pops, admix_coeffs, stds, 
                           p_vals, na = "-", rp = "A15")
        
    if dataframe:
        source_pops = np.array([([t] + pops[1:]) for t in pops_t])
        df = create_admix_df(source_pops, admix_coeffs, stds, p_vals)
        return(df)
    
    
def plot_qpadm_split(dir_path, test_pops=[[]], 
                     save_path="", 
                     best=True, figsize=(12,8),
                     labels=[],
                     bw = 0.85, lw=2,
                     c=[], ec="white", fs=10, 
                     height_ratios=[1, 10], wspace=0.05, hspace=0.05,
                     pval_lim = [1e-3, 1], pr=False,
                     legend=True, l_pos=[]):
    """Do 3 Way Admixtures of Sardinia
    best: Whether to use highest p-Val Submodel: 0 use the first, True use the best p-Value, 
    else use the old (first feasible)
    test_pops: List of lists: Will be split up into subdataframes
    pr: whether to print output"""
    
    ### Prepare the Plots
    width_ratios = [len(ls) for ls in test_pops]
    
    fig = plt.figure(figsize=figsize)
    
    gs = gridspec.GridSpec(2, len(test_pops), 
                           width_ratios = width_ratios, 
                           height_ratios = height_ratios, 
                           figure = fig)
    
    gs.update(wspace=wspace, hspace=hspace) # set the spacing between axes
    
    for j, ls in enumerate(test_pops):        
        # make empty vectors for loading and plotting
        admix_coeffs = []
        p_vals = []
        pops_t = [] 
        stds = []
    
        for f in ls:
            full_path = dir_path + str(f) + ".log" # Other "outputMycSicily_"
            res, p_val_ls, pops, std = load_qp_adm(full_path)

            pops_t.append(pops[0])

            if best == 0:
                i = give_admix0(res)   # Give the first result (if feasible)

            elif best == True:
                i = give_admix_index_best(res, p_val_ls) # Give the best feasible p-Value

            else:
                i = give_admix_index(res)

            #### Handle Not fitting Models  
            if np.isnan(i): # In Case no valid admixture:
                new_res = np.zeros(np.shape(res)[1]) # Not Plot anything
                std = np.zeros(np.shape(res)[1])     # Not Plot anything
                new_p = -1 # For Sorting

            else:
                new_res = res[i,:]
                new_p = p_val_ls[i]

            admix_coeffs.append(new_res)
            p_vals.append(new_p)
            stds.append(std)

            if pr == True:
                print("Population: %s" % f)
                print(res[i,:])
                print(std)
                print(p_val_ls[i])
        
        ### Do the actual Plot
        ax_adm = fig.add_subplot(gs[0, j])
        ax_p = fig.add_subplot(gs[1, j])
        
        #ax_adm = plt.subplot(gs[0, i])
        #ax_p = plt.subplot(gs[1, i])
        
        admix_coeffs, stds = np.array(admix_coeffs), np.array(stds)
        source_pops = pops[1:]
        if j>0:
            legend=False
            
        fig_admix(axes=[ax_adm, ax_p], res=admix_coeffs, 
                  p_vals=p_vals, 
                  xlabels=pops_t, 
                  source_pops=source_pops, 
                  pval_lim=pval_lim, 
                  stds=stds, save_path = "", 
                  lw=lw, 
                  fs=fs, figsize=figsize, 
                  bw = bw, c=c, ec = ec, show=False,
                  legend=legend, l_pos = l_pos)
        
        ### Turn off the Labels for all but first plot
        if j>0:
            for ax in [ax_p, ax_adm]:
                ax.set_yticklabels([])
                ax.set_ylabel("")
                
        if len(labels)>0:
                ax_adm.set_title(labels[j], fontsize=fs)
            
    if len(save_path) > 0:
        plt.savefig(save_path, bbox_inches = 'tight', 
                    pad_inches = 0)
        print("Saved to %s" % save_path)
        # Save the .csv of the Results
    plt.show()