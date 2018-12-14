#!/bin/bash

# 15.03.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.10/tutorials/moving-pictures/
# merging data from different runs, after denoising
# https://docs.qiime2.org/2018.2/tutorials/fmt/

# for debugging only
# ------------------ 
set -x

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
tab[1]='/Users/paul/Documents/AAD_combined/Zenodo/Qiime/050_16S_agrf-tab.qza'
tab[2]='/Users/paul/Documents/AAD_combined/Zenodo/Qiime/050_16S_rama-tab.qza'
tab[3]='/Users/paul/Documents/AAD_combined/Zenodo/Qiime/050_16S_rama_unsw-tab.qza'

seq[1]='/Users/paul/Documents/AAD_combined/Zenodo/Qiime/050_16S_agrf-seq.qza'
seq[2]='/Users/paul/Documents/AAD_combined/Zenodo/Qiime/050_16S_rama-seq.qza'
seq[3]='/Users/paul/Documents/AAD_combined/Zenodo/Qiime/050_16S_rama_unsw-seq.qza'


tab[4]='/Users/paul/Documents/AAD_combined/Zenodo/Qiime/050_18S_agrf-tab.qza'
tab[5]='/Users/paul/Documents/AAD_combined/Zenodo/Qiime/050_18S_rama-tab.qza'
tab[6]='/Users/paul/Documents/AAD_combined/Zenodo/Qiime/050_18S_rama_unsw-tab.qza'

seq[4]='/Users/paul/Documents/AAD_combined/Zenodo/Qiime/050_18S_agrf-seq.qza'
seq[5]='/Users/paul/Documents/AAD_combined/Zenodo/Qiime/050_18S_rama-seq.qza'
seq[6]='/Users/paul/Documents/AAD_combined/Zenodo/Qiime/050_18S_rama_unsw-seq.qza'


otpth_tab[1]='Zenodo/Qiime/065_16S_merged_tab.qza'
otpth_seq[1]='Zenodo/Qiime/065_16S_merged_seq.qza'


otpth_tab[2]='Zenodo/Qiime/065_18S_merged_tab.qza'
otpth_seq[2]='Zenodo/Qiime/065_18S_merged_seq.qza'


# merge 16S data
# ---------------
qiime feature-table merge \
  --i-tables "${tab[1]}" \
  --i-tables "${tab[2]}" \
  --i-tables "${tab[3]}" \
  --o-merged-table "$trpth"/"${otpth_tab[1]}"
qiime feature-table merge-seqs \
  --i-data "${seq[1]}" \
  --i-data "${seq[2]}" \
  --i-data "${seq[3]}" \
  --o-merged-data "$trpth"/"${otpth_seq[1]}"

# merge 18S data
# ---------------
qiime feature-table merge \
  --i-tables "${tab[3]}" \
  --i-tables "${tab[4]}" \
  --i-tables "${tab[5]}" \
  --o-merged-table "$trpth"/"${otpth_tab[2]}"
qiime feature-table merge-seqs \
  --i-data "${seq[3]}" \
  --i-data "${seq[4]}" \
  --i-data "${seq[5]}" \
  --o-merged-data "$trpth"/"${otpth_seq[2]}"
