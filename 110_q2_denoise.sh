#!/usr/bin/env bash

# 30.07.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Denoise 2 sequencing runs using DADA2
# Last time run several ee treshholds (1 to 3) were tried by modifying the script 
#  manually

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
otpth_seq[1]='Zenodo/Processing/110_18S_denoised-seq_run_1_ee3.qza'
otpth_seq[2]='Zenodo/Processing/110_18S_denoised-seq_run_2_ee3.qza'

otpth_tab[1]='Zenodo/Processing/110_18S_denoised-tab_run_1_ee3.qza'
otpth_tab[2]='Zenodo/Processing/110_18S_denoised-tab_run_2_ee3.qza'

otpth_stat[1]='Zenodo/Processing/110_18S_denoised-stt_run_1_ee3.qza'
otpth_stat[2]='Zenodo/Processing/110_18S_denoised-stt_run_2_ee3.qza'

otpth_vis[1]='Zenodo/Processing/110_18S_denoised-vis_run_1_ee3.qzv'
otpth_vis[2]='Zenodo/Processing/110_18S_denoised-vis_run_2_ee3.qzv'

# trimming parameters 18S - reads already filtered for Phred 25 
# --------------------------------------------------------------
# amplicon should be at least 85 bp 
trnc[1]='85'
trnc[2]='85'
# allowed no more then "1" errors in sequence **check log file for last applied value!!!**, default is "2"
eerr[1]='3'
eerr[2]='3'

# run script
# ----------


for ((i=1;i<=2;i++)); do

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
