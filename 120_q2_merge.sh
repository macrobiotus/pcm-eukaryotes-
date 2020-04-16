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

# define input and output locations
# ---------------------------------
tab[1]="$trpth/Zenodo/Processing/110_18S_denoised-tab_run_1.qza"
tab[2]="$trpth/Zenodo/Processing/110_18S_denoised-tab_run_2.qza"

seq[1]="$trpth/Zenodo/Processing/110_18S_denoised-seq_run_1.qza"
seq[2]="$trpth/Zenodo/Processing/110_18S_denoised-seq_run_2.qza"

otpth_tab='Zenodo/Processing/120_18S_merged-tab.qza'
otpth_seq='Zenodo/Processing/120_18S_merged-seq.qza'

# run script
# -----------
qiime feature-table merge \
  --i-tables "${tab[1]}" \
  --i-tables "${tab[2]}" \
  --o-merged-table "$trpth"/"$otpth_tab"

qiime feature-table merge-seqs \
  --i-data "${seq[1]}" \
  --i-data "${seq[2]}" \
  --o-merged-data "$trpth"/"$otpth_seq"
