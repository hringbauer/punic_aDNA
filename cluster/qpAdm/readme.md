### How to run Analysis in ./cluster/qpAdm

The script in qpAdm_run.sh is the one that is batched to the O2 Slurm cluster.

One needs to manually update it to
1) What script to batch in ./scripts or ./versionXX.X
2) Set the number of indivduals to run 

Do not forget to remove ./logs occasionally (that's where the log files of the run are)