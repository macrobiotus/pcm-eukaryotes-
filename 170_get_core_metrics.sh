#!/bin/bash

# 26.03.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Qiime biodiversity core analyses
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/
# This workflow script is using clustred sequences as an input and as a rsults
# communities may be appear more similar then they (actually) are if amplicon variants
# are considered. I suggest repetaing this analysis on unclustered data.

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
inpth_map[1]='Zenodo/Manifest/05_DAVIS_metadata.tsv'
inpth_map[2]='Zenodo/Manifest/05_DAVIS_metadata.tsv'

clust_tab[1]='Zenodo/Qiime/110_16S_097_cl_tab.qza'
clust_tab[2]='Zenodo/Qiime/110_18S_097_cl_tab.qza'

rooted_tree[1]='Zenodo/Qiime/160_16S_097_cl_tree_rooted.qza'
rooted_tree[2]='Zenodo/Qiime/160_18S_097_cl_tree_rooted.qza'

plot_dir[1]="Zenodo/Qiime/170_16S_core_metrics"
plot_dir[2]="Zenodo/Qiime/170_18S_core_metrics"

depth[1]='5935' # using frequency of 120_16S_097_cl_tab.qzv 
depth[2]='3381' # using frequency of 120_18S_097_cl_tab.qzv

# Run scripts
# ------------
for ((i=1;i<=2;i++)); do
  qiime2cli diversity core-metrics-phylogenetic \
    --i-phylogeny "$trpth"/"${rooted_tree[$i]}" \
    --i-table "$trpth"/"${clust_tab[$i]}" \
    --m-metadata-file "$trpth"/"${inpth_map[$i]}" \
    --output-dir "$trpth"/"${plot_dir[$i]}" \
    --p-sampling-depth "${depth[$i]}"
done
