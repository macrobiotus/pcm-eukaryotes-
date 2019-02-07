#!/bin/bash

# 07.02.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Summarizing clustering output, part 1 of 2

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

# Define input files
# ------------------

inpth_map[1]='Zenodo/Manifest/05_Davis_and_TheRidge_metdata_curated_corrected.txt'
inpth_map[2]='Zenodo/Manifest/05_Davis_and_TheRidge_metdata_curated_corrected.txt'

clust_tab[1]='Zenodo/Qiime/110_16S_097_cl_tab.qza'
clust_tab[2]='Zenodo/Qiime/110_18S_097_cl_tab.qza'

clust_seq[1]='Zenodo/Qiime/110_16S_097_cl_seq.qza'
clust_seq[2]='Zenodo/Qiime/110_18S_097_cl_seq.qza'


# Define output files
# -------------------

seq_vis[1]='Zenodo/Qiime/120_16S_097_cl_seq.qzv'
seq_vis[2]='Zenodo/Qiime/120_18S_097_cl_seq.qzv'

tab_vis[1]='Zenodo/Qiime/120_16S_097_cl_tab.qzv'
tab_vis[2]='Zenodo/Qiime/120_18S_097_cl_tab.qzv'

# Run scripts:
# -------------------

for ((i=1;i<=2;i++)); do
  # summarize feature tables
  printf "Summarizing  \"${clust_tab[$i]}\" at $(date +"%T")  ... \n"
  qiime2cli feature-table summarize \
     --i-table "$trpth"/"${clust_tab[$i]}" \
     --o-visualization "$trpth"/"${tab_vis[$i]}" \
     --m-sample-metadata-file "$trpth"/"${inpth_map[$i]}"
done

for ((i=1;i<=2;i++)); do
  # summarize sequence tables
  printf "Summarizing  \"${clust_seq[$i]}\" at $(date +"%T")  ... \n"
  qiime2cli feature-table tabulate-seqs \
    --i-data "$trpth"/"${clust_seq[$i]}" \
    --o-visualization "$trpth"/"${seq_vis[$i]}"
done
