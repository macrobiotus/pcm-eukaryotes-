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

# define input locations
# ---------------------------------
inpth[1]='Zenodo/Processing/100_18S_import_run_1.qza'
inpth[2]='Zenodo/Processing/100_18S_import_run_2.qza'

# define output locations
# ---------------------------------
otpth_seq[1]='Zenodo/Processing/110_18S_denoised-seq_run_1.qza'
otpth_seq[2]='Zenodo/Processing/110_18S_denoised-seq_run_2.qza'

otpth_tab[1]='Zenodo/Processing/110_18S_denoised-tab_run_1.qza'
otpth_tab[2]='Zenodo/Processing/110_18S_denoised-tab_run_2.qza'

otpth_stat[1]='Zenodo/Processing/110_18S_denoised-stt_run_1.qza'
otpth_stat[2]='Zenodo/Processing/110_18S_denoised-stt_run_2.qza'

otpth_vis[1]='Zenodo/Processing/110_18S_denoised-vis_run_1.qzv'
otpth_vis[2]='Zenodo/Processing/110_18S_denoised-vis_run_2.qzv'

# trimming parameters 18S - reads already filtered for Phred 20 
# --------------------------------------------------------------
# amplicon should be at least 85 bp 
trnc[1]='85'
trnc[2]='85'
# allow no more then "5" errors in sequence,  default is "2"
eerr[1]='5'
eerr[2]='5'

# run script
# ----------
for ((i=2;i<=2;i++)); do

   # denoising
   qiime dada2 denoise-single \
      --i-demultiplexed-seqs "$trpth"/"${inpth[$i]}" \
      --p-trunc-len "${trnc[$i]}" \
      --p-max-ee "${eerr[$i]}" \
      --p-n-threads "$cores" \
      --o-table "$trpth"/"${otpth_tab[$i]}" \
      --o-representative-sequences "$trpth"/"${otpth_seq[$i]}" \
      --o-denoising-stats "$trpth"/"${otpth_stat[$i]}" \
      --verbose

    # export stats file for manual inspection and gnuplot
    qiime metadata tabulate\
      --m-input-file "$trpth"/"${otpth_stat[$i]}" \
      --o-visualization "$trpth"/"${otpth_vis[$i]}"
done
