#!/bin/bash

# 03.02.2019 - Paul Czechowski - paul.czechowski@gmail.com 
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
    qiime2cli() { qiime "$@" ; }
    thrds='2'
fi

# define input and output locations
# ---------------------------------

# 16S data
tab[1]='/Users/paul/Documents/AAD_Davis_station/Zenodo/Qiime/065_16S_merged_tab.qza'
tab[2]='/Users/paul/Documents/AAD_The_Ridge/Zenodo/Qiime/050_16S_ridge-tab.qza'

seq[1]='/Users/paul/Documents/AAD_Davis_station/Zenodo/Qiime/065_16S_merged_seq.qza'
seq[2]='/Users/paul/Documents/AAD_The_Ridge/Zenodo/Qiime/050_16S_ridge-seq.qza'


# 18S data
tab[3]='/Users/paul/Documents/AAD_Davis_station/Zenodo/Qiime/065_18S_merged_tab.qza'
tab[4]='/Users/paul/Documents/AAD_The_Ridge/Zenodo/Qiime/050_18S_ridge-tab.qza'

seq[3]='/Users/paul/Documents/AAD_Davis_station/Zenodo/Qiime/065_18S_merged_seq.qza'
seq[4]='/Users/paul/Documents/AAD_The_Ridge/Zenodo/Qiime/050_18S_ridge-seq.qza'


otpth_tab[1]='Zenodo/Qiime/065_16S_merged_tab.qza'
otpth_seq[1]='Zenodo/Qiime/065_16S_merged_seq.qza'

otpth_tab[2]='Zenodo/Qiime/065_18S_merged_tab.qza'
otpth_seq[2]='Zenodo/Qiime/065_18S_merged_seq.qza'


# merge 16S data
# ---------------
qiime feature-table merge \
  --i-tables "${tab[1]}" \
  --i-tables "${tab[2]}" \
  --o-merged-table "$trpth"/"${otpth_tab[1]}"
qiime feature-table merge-seqs \
  --i-data "${seq[1]}" \
  --i-data "${seq[2]}" \
  --o-merged-data "$trpth"/"${otpth_seq[1]}"

# merge 18S data
# ---------------
qiime feature-table merge \
  --i-tables "${tab[3]}" \
  --i-tables "${tab[4]}" \
  --o-merged-table "$trpth"/"${otpth_tab[2]}"
qiime feature-table merge-seqs \
  --i-data "${seq[3]}" \
  --i-data "${seq[4]}" \
  --o-merged-data "$trpth"/"${otpth_seq[2]}"
