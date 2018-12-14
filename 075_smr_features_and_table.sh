#!/bin/bash

# 15.03.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Visualising reads after denoising and merging procedure.

# for debugging only
# ------------------ 
set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/AAD_combined"
    thrds='14'
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_combined"
    qiime2cli() { qiime "$@" ; }
    thrds='2'
fi

# define relative input and output locations
# ---------------------------------
inpth_tab[1]='Zenodo/Qiime/065_16S_merged_tab.qza'
inpth_rep[1]='Zenodo/Qiime/065_16S_merged_seq.qza'

otpth_tab[1]='Zenodo/Qiime/075_16S_sum_feat_tab.qzv'
otpth_rep[1]='Zenodo/Qiime/075_16S_sum_repr_seq.qzv'


inpth_tab[2]='Zenodo/Qiime/065_18S_merged_tab.qza'
inpth_rep[2]='Zenodo/Qiime/065_18S_merged_seq.qza'

otpth_tab[2]='Zenodo/Qiime/075_18S_sum_feat_tab.qzv'
otpth_rep[2]='Zenodo/Qiime/075_18S_sum_repr_seq.qzv'


inpth_map[1]='Zenodo/Manifest/05_DAVIS_metadata.tsv'
inpth_map[2]='Zenodo/Manifest/05_DAVIS_metadata.tsv'

# run script for 16S and 18S
# --------------------------

for ((i=1;i<=2;i++)); do
   qiime2cli feature-table summarize \
      --i-table "$trpth"/"${inpth_tab[$i]}" \
      --o-visualization "$trpth"/"${otpth_tab[$i]}" 
      --m-sample-metadata-file "$trpth"/"${inpth_map[$i]}"
   qiime2cli feature-table tabulate-seqs \
      --i-data "$trpth"/"${inpth_rep[$i]}" \
      --o-visualization "$trpth"/"${otpth_rep[$i]}"
done
