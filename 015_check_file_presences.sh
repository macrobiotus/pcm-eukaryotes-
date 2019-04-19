#!/usr/bin/env bash

# 18.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================

# activate Qiime manually 
# -----------------------
# export LC_ALL=en_US.utf-8
# export LANG=en_US.utf-8
# export PATH=/programs/miniconda3/bin:$PATH
# source activate qiime2-2019.1

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

# define input and output files
# -----------------------------

# revised manifest are stored in
manifests='Zenodo/Manifest'


# run commands
# ------------

# loop over manifests
for filename in "$trpth"/"$manifests"/*.txt; do
  # check if paths in files exit
  while read -r fastq_path; do
   if [ ! -f "$fastq_path" ]; 
     then echo "$fastq_path not found";
   fi 
  done < "$filename"
done