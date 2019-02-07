#!/bin/bash

# 07.02.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Summarizing clustering output, part 2 of 2

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

# input files
# ------------
clust_tab[1]='Zenodo/Qiime/110_16S_097_cl_tab.qza'
clust_tab[2]='Zenodo/Qiime/110_18S_097_cl_tab.qza'

# classifiers from unclustered data - works if cluster ids have not been changed
#   during clustering
tax_map[1]='Zenodo/Qiime/100_16S_taxonomy.qza'
tax_map[2]='Zenodo/Qiime/100_18S_taxonomy.qza'

inpth_map[1]='Zenodo/Manifest/05_Davis_and_TheRidge_metdata_curated_corrected.txt'
inpth_map[2]='Zenodo/Manifest/05_Davis_and_TheRidge_metdata_curated_corrected.txt'

# output files
# ------------
plot_dir[1]="Zenodo/Qiime/130_16S_clustered_taxonomy"
plot_dir[2]="Zenodo/Qiime/130_18S_clustered_taxonomy"

# Run scripts
# ------------
for ((i=1;i<=2;i++)); do
  qiime taxa barplot \
    --i-table "$trpth"/"${clust_tab[$i]}" \
    --i-taxonomy "$trpth"/"${tax_map[$i]}" \
    --m-metadata-file "$trpth"/"${inpth_map[$i]}" \
    --output-dir "$trpth"/"${plot_dir[$i]}" \
    --verbose
done
