#!/usr/bin/env bash

# 10.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.10/tutorials/moving-pictures/
# Citing this plugin: DADA2: High-resolution sample inference from Illumina
# amplicon data. Benjamin J Callahan, Paul J McMurdie, Michael J Rosen,
# Andrew W Han, Amy Jo A Johnson, Susan P Holmes. Nature Methods 13, 581–583
# (2016) doi:10.1038/nmeth.3869.

# for debugging only
# ------------------ 
set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/AAD_combined"
    cores="$(nproc --all)"
    bold=$(tput bold)
    normal=$(tput sgr0)
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_combined"
    cores='2'
    bold=$(tput bold)
    normal=$(tput sgr0)
fi

# define input locations
# ---------------------------------
inpth[1]='Zenodo/Qiime/045_16S_trimmed_run_1.qza'
inpth[2]='Zenodo/Qiime/045_16S_trimmed_run_2.qza'
inpth[3]='Zenodo/Qiime/045_16S_trimmed_run_3.qza'
inpth[4]='Zenodo/Qiime/045_16S_trimmed_run_4.qza'
inpth[5]='Zenodo/Qiime/045_16S_trimmed_run_5.qza'

inpth[6]='Zenodo/Qiime/045_18S_trimmed_run_1.qza'
inpth[7]='Zenodo/Qiime/045_18S_trimmed_run_2_a.qza'
inpth[8]='Zenodo/Qiime/045_18S_trimmed_run_2_b.qza'
inpth[9]='Zenodo/Qiime/045_18S_trimmed_run_3.qza'
inpth[10]='Zenodo/Qiime/045_18S_trimmed_run_4.qza'
inpth[11]='Zenodo/Qiime/045_18S_trimmed_run_5.qza'
inpth[12]='Zenodo/Qiime/045_18S_trimmed_run_6.qza'

# trimming parameters 16S - aiming for Phred 30 
# ---------------------------------------------
lenf[1]='145'
lenr[1]='145'
ee[1]='5'

# trimming parameters 18S - aiming for Phred 30 
# ---------------------------------------------
lenf[2]='145'
lenr[2]='145'
ee[2]='9'

# run denoising 
# -----------

printf "Processing 16S data.\n"
for ((i=1;i<=5;i++)); do
   
   # define output locations
   otpth_seq="$(dirname "${inpth[$i]}")/055_"${$inpth:4:-4}"_denoised_seq.qza"
   otpth_tab="$(dirname "${inpth[$i]}")/055_"${$inpth:4:-4}"_denoised_tab.qza"
   otpth_stat="$(dirname "${inpth[$i]}")/055_"${$inpth:4:-4}"_denoised_stat.qza"
   otpth_statv="$(dirname "${inpth[$i]}")/055_"${$inpth:4:-4}"_denoised_stat.qzv"
   output_log="$(dirname "${inpth[$i]}")/055_"${$inpth:4:-4}"_denoised_log.txt"

   # qiime calls
   printf "${bold}$(date):${normal} Starting denoising of \"$(basename "$trpth"/"${inpth[$i]}")\"...\n"
   qiime dada2 denoise-paired \
      --i-demultiplexed-seqs "$trpth"/"${inpth[$i]}" \
      --p-trunc-len-f "${lenf[1]}" \
      --p-trunc-len-r "${lenr[1]}" \
      --p-n-threads "$cores" \
      --p-max-ee "${ee[1]}" \
      --o-representative-sequences "$otpth_seq" \
      --o-denoising-stats "$otpth_stat" \
      --o-table "$otpth_tab" \
      --verbose  2>&1 | tee -a "$output_log"
    printf "${bold}$(date):${normal} ...finished denoising of \"$(basename "$trpth"/"${inpth[$i]}")\".\n"
    
    # export stats file for manual inspection and gnuplot
    qiime metadata tabulate \
      --m-input-file "$otpth_stat" \
      --o-visualization "$otpth_statv"

done

printf "Processing 18S data.\n"
for ((i=6;i<=12;i++)); do
   
   # define output locations
   otpth_seq="$(dirname "${inpth[$i]}")/055_"${$inpth:4:-4}"_denoised_seq.qza"
   otpth_tab="$(dirname "${inpth[$i]}")/055_"${$inpth:4:-4}"_denoised_tab.qza"
   otpth_stat="$(dirname "${inpth[$i]}")/055_"${$inpth:4:-4}"_denoised_stat.qza"
   otpth_statv="$(dirname "${inpth[$i]}")/055_"${$inpth:4:-4}"_denoised_stat.qzv"
   output_log="$(dirname "${inpth[$i]}")/055_"${$inpth:4:-4}"_denoised_log.txt"

   # qiime calls
   printf "${bold}$(date):${normal} Starting denoising of \"$(basename "$trpth"/"${inpth[$i]}")\"...\n"
   qiime dada2 denoise-paired \
      --i-demultiplexed-seqs "$trpth"/"${inpth[$i]}" \
      --p-trunc-len-f "${lenf[2]}" \
      --p-trunc-len-r "${lenr[2]}" \
      --p-n-threads "$cores" \
      --p-max-ee "${ee[2]}" \
      --o-representative-sequences "$otpth_seq" \
      --o-denoising-stats "$otpth_stat" \
      --o-table "$otpth_tab" \
      --verbose 2>&1 | tee -a "$output_log"
   printf "${bold}$(date):${normal} ...finished denoising of \"$(basename "$trpth"/"${inpth[$i]}")\".\n"
    
    # export stats file for manual inspection and gnuplot
    qiime metadata tabulate \
      --m-input-file "$otpth_stat" \
      --o-visualization "$otpth_statv"

done
