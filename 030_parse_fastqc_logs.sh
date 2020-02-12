#!/usr/bin/env bash

# 07.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Check fastqc log file for errors

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/AAD_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_combined"
fi

# define input directories
# -----------------------
fastqclogdir='Zenodo/FastQC_logs'

# run commands
# ------------

# loop over manifests - for fastqc 
for logfile in "$trpth"/"$fastqclogdir"/*.txt; do

  # printf "Checking file \"$logfile\" \n"
  if grep -q "truncated" "$logfile"
  then 
    printf "Check and remove corresponding read file for \"$logfile\".\n"
  fi
done
