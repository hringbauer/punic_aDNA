This GitHub repository contains the code for analyzing and plotting results that we describe in the manuscript **Punic people had exceptionally diverse
ancestry with few genetic links to their eastern Phoenician cultural forebears**.

# Key contacts and contributors
Harald Ringbauer, Ayelet Salman-Minkov, Ilan Gronau

Please feel free to email any of us if you have questions about our code.

# Key directories
Below, please find a description of the important folders in this repository.

## `./notebooks`
This directory includes scripts to run analysis and plot results with `jupyter notebooks`. These files, wrapping Python code to run interactively, are the primary analysis tools written by Harald Ringbauer.

A key subfolder is `./notebooks/figs/`. It contains code to plot several primary and extended data figures of the manuscript. 


## `./scripts`
This directory includes scripts written to run qpAdm analysis and plot results described in our work.

**All scripts in this directory were written by Tomer Peled, Ayelet Salman-Minkov, and Ilan Gronau**

The scripts in this pipeline are in bash and R.
They are designed to run on Linux, so beware if you try on other systems
Required packages for R are specified in the run and plot pipleines

The analysis pipeline is executed via the following steps:
1) Edit the configuration script (`configureScripts.sh`)
   in the marked places to set up directories for:
   - qpAdm binary file
   - data files (ind geno snp)
   - output files (qpAdm results and plots)
   
2) Run configuration script (`bash configureScripts.sh`)

3) Run all qpAdm analyses. See run/REAMDE
   - all output of qpAdm analyses will be put in
     the qpAdm subdir of the output dir specified
     in the config script

4) Plot different figures with results. See plot/README
   - PDFs of all figures will be put in the plots
     subdir of the output dir specified in the
     config script


Directory contents:
* `configureScripts.sh`
    Configuration script - to be set up and executed before
    analysis or plotting

* `sample-info.tsv`
    Table with 140 Phoenician/Punic indicivuals +
    additional non-Punic indivudals analyzed by
    qpAdm. Table contains partial information
    on each individual sample, including:
     site
     time    (time range indicator)
     region  (one of five regions)
     cov     (sequencing coverage)
     PC1,PC2 (two major PC coordinates - used for PCA-based estimates on North African ancestry in Fig S4)
     category (used when plotting)
    This table is used by analysis scritps and by plotting scripts.

* `run/`
    Directory with scripts used when running
    qpAdm analysis. Main outcome is file
    combined-pars-models.tsv with qpAdm inference.
    For more details, see run/README

* `plot/`
    Directory with scripts used when plotting
    qpAdm estimates. Main outcome is PDF files
    with plots for different panel figures.
    For more details, see plot/README
