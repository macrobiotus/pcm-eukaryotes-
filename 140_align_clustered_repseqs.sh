#!/bin/bash

# 26.03.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Aligning clustered sequences. For tree matching clustered sequences.
# Ideally one would do this with the unclustered sequences, but the
# resulting tree would have more branches the sequences are in the clustered
# repsets. I suggest repeating this analysis on the unclustered sequences

# For debugging only
# ------------------ 
set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/AAD_Davis_station"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_Davis_station"
    qiime2cli() { qiime "$@" ; }
    cores='2'
fi

# Define input and output locations
# ---------------------------------
inpth[1]='Zenodo/Qiime/110_16S_097_cl_seq.qza'
inpth[2]='Zenodo/Qiime/110_18S_097_cl_seq.qza'

otpth[1]='Zenodo/Qiime/140_16S_097_cl_raw_alignment.qza'
otpth[2]='Zenodo/Qiime/140_18S_097_cl_raw_alignment.qza'

# Run scripts
# ------------
for ((i=1;i<=2;i++)); do
  qiime2cli alignment mafft \
    --i-sequences "$trpth"/"${inpth[$i]}" \
    --o-alignment "$trpth"/"${otpth[$i]}" \
    --p-n-threads "$cores"
done

