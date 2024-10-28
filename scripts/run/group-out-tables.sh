#!/bin/bash

###################################################################
# Merges a list of output files from run-qpadm-admixr.R into
# one merged table with all results.
# 
# Receives as arguments a list of output tsv files.
# First lines in merged table include comments about the data set and the
# set of reference populations. This should be identical in all 
# log files. If not, then the printing is aborted.
# Then, all tables are printed one after the other.
#
# Table is printed to stdout
######################################################################

logfiles=$*
numrefs=`head -qn2 $logfiles | grep "^# Dataset" | sort |uniq | wc -l`
if [ $numrefs -gt 1 ]; then
   echo "More than one reference set in logs:"
   head -qn2 $logfiles | grep "^# Dataset" | sort |uniq
   exit 1
fi
head -qn2 $logfiles | grep "^# Dataset" | sort |uniq

numrefs=`head -qn2 $logfiles | grep "^# Reference" | sort |uniq | wc -l`
if [ $numrefs -gt 1 ]; then
   echo "More than one reference set in logs:"
   head -qn2 $logfiles | grep "^# Reference" | sort |uniq
   exit 1
fi
head -qn2 $logfiles | grep "^# Reference" | sort |uniq

numrefs=`head -qn3 $logfiles | grep "^target[[:space:]]" | sort |uniq | wc -l`
if [ $numrefs -gt 1 ]; then
   echo "More than one reference set in logs:"
   head -qn3 $logfiles | grep "^target[[:space:]]" | sort |uniq
   exit 1
fi
head -qn3 $logfiles | grep "^target[[:space:]]" | sort |uniq
tail -qn+4 $logfiles

