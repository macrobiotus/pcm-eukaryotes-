#!/usr/bin/env bash

# 16.04.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Denoise 2 sequencing runs using DAD2

# set -x
set -e

# Adjust base paths
# -----------------
if [[ "$HOSTNAME" != "Pauls-MacBook-Pro.local" ]] && [[ "$HOSTNAME" != "macmini-fastpost.staff.uod.otago.ac.nz" ]]; then
    bold=$(tput bold)
    normal=$(tput sgr0)
    printf "${bold}$(date):${normal} Execution on remote...\n"
    trpth="/workdir/pc683/OU_pcm_eukaryotes"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "Pauls-MacBook-Pro.local" ]]  || [[ "$HOSTNAME" == "macmini-fastpost.staff.uod.otago.ac.nz" ]]; then
    bold=$(tput bold)
    normal=$(tput sgr0)
    printf "${bold}$(date):${normal} Execution on local...\n"
    trpth="/Users/paul/Documents/OU_pcm_eukaryotes"
    cores="2"
fi

# define relative input and output locations
# ---------------------------------

inpth_map[1]='Zenodo/Manifest/160202_18S_MF.txt'

inpth_tab[1]='Zenodo/Processing/120_18S_merged-tab.qza'
inpth_seq[1]='Zenodo/Processing/120_18S_merged-seq.qza'

otpth_tab[1]='Zenodo/Processing/130_18S_merged-tab.qzv'
otpth_seq[1]='Zenodo/Processing/130_18S_merged-seq.qzv'

# run script for 18S
# --------------------------

for ((i=1;i<=1;i++)); do
   qiime feature-table summarize \
      --i-table "$trpth"/"${inpth_tab[$i]}" \
      --o-visualization "$trpth"/"${otpth_tab[$i]}" \
      --m-sample-metadata-file "$trpth"/"${inpth_map[$i]}"
   qiime feature-table tabulate-seqs \
      --i-data "$trpth"/"${inpth_seq[$i]}" \
      --o-visualization "$trpth"/"${otpth_seq[$i]}"
done
