#!/usr/bin/env bash

# 10.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Getting statistics from demultiplexing, quality info.

# For debugging only
# ------------------ 
set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/AAD_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_combined"
    cores='2'
fi

# input file array
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

# output file array
otpth[1]='Zenodo/Qiime/050_16S_trimmed_run_1.qzv'
otpth[2]='Zenodo/Qiime/050_16S_trimmed_run_2.qzv'
otpth[3]='Zenodo/Qiime/050_16S_trimmed_run_3.qzv'
otpth[4]='Zenodo/Qiime/050_16S_trimmed_run_4.qzv'
otpth[5]='Zenodo/Qiime/050_16S_trimmed_run_5.qzv'

otpth[6]='Zenodo/Qiime/050_18S_trimmed_run_1.qzv'
otpth[7]='Zenodo/Qiime/050_18S_trimmed_run_2_a.qzv'
otpth[8]='Zenodo/Qiime/050_18S_trimmed_run_2_b.qzv'
otpth[9]='Zenodo/Qiime/050_18S_trimmed_run_3.qzv'
otpth[10]='Zenodo/Qiime/050_18S_trimmed_run_4.qzv'
otpth[11]='Zenodo/Qiime/050_18S_trimmed_run_5.qzv'
otpth[12]='Zenodo/Qiime/050_18S_trimmed_run_6.qzv'

# Run script
# ----------
for ((i=1;i<=12;i++)); do
   qiime demux summarize \
      --i-data "$trpth"/"${inpth[$i]}" \
      --o-visualization "$trpth"/"${otpth[$i]}"
done
