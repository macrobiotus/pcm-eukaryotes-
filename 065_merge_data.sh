#!/usr/bin/env bash

# 28.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.10/tutorials/moving-pictures/
# merging data from different runs, after denoising
# https://docs.qiime2.org/2018.2/tutorials/fmt/

# for debugging only
# ------------------ 
# set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/AAD_combined"
    thrds='40'
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_combined"
    thrds='2'
fi

# define input locations
# -----------------------

# 16S data
seq[1]='Zenodo/Qiime/055_16S_trimmed_run_1_denoised_seq.qza'
seq[2]='Zenodo/Qiime/055_16S_trimmed_run_2_denoised_seq.qza'
seq[3]='Zenodo/Qiime/055_16S_trimmed_run_3_denoised_seq.qza'
seq[4]='Zenodo/Qiime/055_16S_trimmed_run_4_denoised_seq.qza'
seq[5]='Zenodo/Qiime/055_16S_trimmed_run_5_denoised_seq.qza'

# 18S data
seq[6]='Zenodo/Qiime/055_18S_trimmed_run_1_denoised_seq.qza'
seq[7]='Zenodo/Qiime/055_18S_trimmed_run_2_a_denoised_seq.qza'
seq[8]='Zenodo/Qiime/055_18S_trimmed_run_2_b_denoised_seq.qza'
seq[9]='Zenodo/Qiime/055_18S_trimmed_run_3_denoised_seq.qza'
seq[10]='Zenodo/Qiime/055_18S_trimmed_run_4_denoised_seq.qza'
seq[11]='Zenodo/Qiime/055_18S_trimmed_run_5_denoised_seq.qza'
seq[12]='Zenodo/Qiime/055_18S_trimmed_run_6_denoised_seq.qza'


# 16S data
tab[1]='Zenodo/Qiime/055_16S_trimmed_run_1_denoised_tab.qza'
tab[2]='Zenodo/Qiime/055_16S_trimmed_run_2_denoised_tab.qza'
tab[3]='Zenodo/Qiime/055_16S_trimmed_run_3_denoised_tab.qza'
tab[4]='Zenodo/Qiime/055_16S_trimmed_run_4_denoised_tab.qza'
tab[5]='Zenodo/Qiime/055_16S_trimmed_run_5_denoised_tab.qza'

# 18S data
tab[6]='Zenodo/Qiime/055_18S_trimmed_run_1_denoised_tab.qza'
tab[7]='Zenodo/Qiime/055_18S_trimmed_run_2_a_denoised_tab.qza'
tab[8]='Zenodo/Qiime/055_18S_trimmed_run_2_b_denoised_tab.qza'
tab[9]='Zenodo/Qiime/055_18S_trimmed_run_3_denoised_tab.qza'
tab[10]='Zenodo/Qiime/055_18S_trimmed_run_4_denoised_tab.qza'
tab[11]='Zenodo/Qiime/055_18S_trimmed_run_5_denoised_tab.qza'
tab[12]='Zenodo/Qiime/055_18S_trimmed_run_6_denoised_tab.qza'



# define output locations
# ---------------------------------
otpth_seq[1]='Zenodo/Qiime/065_16S_merged_seq.qza'
otpth_seq[2]='Zenodo/Qiime/065_18S_merged_seq.qza'

otpth_tab[1]='Zenodo/Qiime/065_16S_merged_tab.qza'
otpth_tab[2]='Zenodo/Qiime/065_18S_merged_tab.qza'


# merge 16S sequences
# --------------------
qiime feature-table merge-seqs \
  --i-data "$trpth"/"${seq[1]}" \
  --i-data "$trpth"/"${seq[2]}" \
  --i-data "$trpth"/"${seq[3]}" \
  --i-data "$trpth"/"${seq[4]}" \
  --i-data "$trpth"/"${seq[5]}" \
  --o-merged-data "$trpth"/"${otpth_seq[1]}"

# merge 18S sequences
# -------------------
qiime feature-table merge-seqs \
  --i-data "$trpth"/"${seq[6]}" \
  --i-data "$trpth"/"${seq[7]}" \
  --i-data "$trpth"/"${seq[8]}" \
  --i-data "$trpth"/"${seq[9]}" \
  --i-data "$trpth"/"${seq[10]}" \
  --i-data "$trpth"/"${seq[11]}" \
  --i-data "$trpth"/"${seq[12]}" \
  --o-merged-data "$trpth"/"${otpth_seq[2]}"


# merge 16S tables
# --------------------
qiime feature-table merge \
  --i-tables "$trpth"/"${tab[1]}" \
  --i-tables "$trpth"/"${tab[2]}" \
  --i-tables "$trpth"/"${tab[3]}" \
  --i-tables "$trpth"/"${tab[4]}" \
  --i-tables "$trpth"/"${tab[5]}" \
  --o-merged-table "$trpth"/"${otpth_tab[1]}"

# merge 18S table
# -------------------
qiime feature-table merge \
  --i-tables "$trpth"/"${tab[6]}" \
  --i-tables "$trpth"/"${tab[7]}" \
  --i-tables "$trpth"/"${tab[8]}" \
  --i-tables "$trpth"/"${tab[9]}" \
  --i-tables "$trpth"/"${tab[10]}" \
  --i-tables "$trpth"/"${tab[11]}" \
  --i-tables "$trpth"/"${tab[12]}" \
  --p-overlap-method 'sum' \
  --o-merged-table "$trpth"/"${otpth_tab[2]}"
