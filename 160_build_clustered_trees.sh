#!/bin/bash

# 26.03.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Getting tree matching clustered sequences.
# Ideally one would do this with the unclustered sequences, but the
# resulting tree would have more branches the sequences are in the clustered
# repsets. I suggest repeating this analysis on the unclustered sequences.

# For debugging only
# ------------------ 
set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/AAD_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_combined"
    qiime2cli() { qiime "$@" ; }
    cores='2'
fi

# Define input and output locations
# ---------------------------------
masked_algn[1]='Zenodo/Qiime/150_16S_097_cl_masked_alignment.qza'
masked_algn[2]='Zenodo/Qiime/150_18S_097_cl_masked_alignment.qza'

noroot_tree[1]='Zenodo/Qiime/160_16S_097_cl_tree_noroot.qza'
noroot_tree[2]='Zenodo/Qiime/160_18S_097_cl_tree_noroot.qza'

rooted_tree[1]='Zenodo/Qiime/160_16S_097_cl_tree_rooted.qza'
rooted_tree[2]='Zenodo/Qiime/160_18S_097_cl_tree_rooted.qza'

# Run scripts
# ------------
for ((i=1;i<=2;i++)); do
  printf "Calculating tree...\n"
  qiime2cli phylogeny fasttree \
    --i-alignment "$trpth"/"${masked_algn[$i]}" \
    --o-tree "$trpth"/"${noroot_tree[$i]}" \
    --p-n-threads "$cores"
  
  printf "Rooting at midpoint...\n"  
  qiime2cli phylogeny midpoint-root \
    --i-tree "$trpth"/"${noroot_tree[$i]}" \
    --o-rooted-tree "$trpth"/"${rooted_tree[$i]}"
done

