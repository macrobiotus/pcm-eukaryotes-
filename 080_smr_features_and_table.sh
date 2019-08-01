#!/usr/bin/env bash

# 01.08.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Visualising reads after denoising and merging procedure.

# for debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "macmini.staff.uod.otago.ac.nz" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/AAD_combined"
    cores="$(nproc --all)"
    bold=$(tput bold)
    normal=$(tput sgr0)
elif [[ "$HOSTNAME" == "macmini.staff.uod.otago.ac.nz" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_combined"
    cores='2'
    bold=$(tput bold)
    normal=$(tput sgr0)
fi

# define relative input and output locations
# ---------------------------------
inpth_map[1]='Zenodo/Manifest/035_16S_mappingfile.txt'
inpth_map[2]='Zenodo/Manifest/035_18S_mappingfile.txt'

inpth_tax[1]='Zenodo/Qiime/070_16S_denoised_seq_taxonomy_assignments.qza'
inpth_tax[2]='Zenodo/Qiime/070_18S_denoised_seq_taxonomy_assignments.qza'


inpth_tab[1]='Zenodo/Qiime/065_16S_merged_tab.qza'
inpth_tab[2]='Zenodo/Qiime/065_18S_merged_tab.qza'

inpth_seq[1]='Zenodo/Qiime/065_16S_merged_seq.qza'
inpth_seq[2]='Zenodo/Qiime/065_18S_merged_seq.qza'


otpth_tab[1]='Zenodo/Qiime/080_16S_merged_tab.qzv'
otpth_tab[2]='Zenodo/Qiime/080_18S_merged_tab.qzv'

otpth_seq[1]='Zenodo/Qiime/080_16S_merged_seq.qzv'
otpth_seq[2]='Zenodo/Qiime/080_18S_merged_seq.qzv'

otpth_plot[1]='Zenodo/Qiime/080_16S_merged_barplot.qzv'
otpth_plot[2]='Zenodo/Qiime/080_18S_merged_barplot.qzv'


# run script for 16S and 18S
# --------------------------

for ((i=1;i<=2;i++)); do
   qiime feature-table summarize \
      --i-table "$trpth"/"${inpth_tab[$i]}" \
      --o-visualization "$trpth"/"${otpth_tab[$i]}" \
      --m-sample-metadata-file "$trpth"/"${inpth_map[$i]}"
      
   qiime feature-table tabulate-seqs \
      --i-data "$trpth"/"${inpth_seq[$i]}" \
      --o-visualization "$trpth"/"${otpth_seq[$i]}"
      
   qiime taxa barplot \
      --m-metadata-file "$trpth"/"${inpth_map[$i]}" \
      --i-taxonomy "$trpth"/"${inpth_tax[$i]}" \
      --i-table "$trpth"/"${inpth_tab[$i]}" \
      --o-visualization "$trpth"/"${otpth_plot[$i]}" \
      --verbose
done
