#!/usr/bin/env bash

# 24.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================

# activate Qiime manually 
# -----------------------
# export LC_ALL=en_US.utf-8
# export LANG=en_US.utf-8
# export PATH=/programs/miniconda3/bin:$PATH
# source activate qiime2-2019.1

# For debugging only
# ------------------ 
# set -x

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


# define input directories
# -----------------------

fastqcdir='Zenodo/FastQC'
fastqclogdir='Zenodo/FastQC_logs'

multiqcdir='Zenodo/MultiQC'
multiqclogdir='Zenodo/MultiQC_logs'


# prepare environment 
# -------------------

# not sure if needed
shopt -s dotglob  # Bash includes filenames beginning with a ‘.’ in the results of filename expansion
shopt -s nullglob # Bash allows filename patterns which match no files to expand to a null string, rather than themselves

# custom environment needs to activated, otherwise script will crash 
source activate activate multiqc 

# create target diretory to hold results ...
mkdir -p "$trpth"/"$multiqcdir"

# ... and log files
mkdir -p "$trpth"/"$multiqclogdir"

# fill an aray with directory list
array=("$trpth"/"$fastqcdir"/*)


# run Multiqc
# -----------

for dir in "${array[@]}"; do 

  # get input diretory - for debugging 
  # echo "$dir"
  
  # get output directory - for debugging 
  # echo "$trpth"/"$multiqcdir"/"$(basename $dir)"
  
  # get logfile - for debugging 
  # echo "$trpth"/"$multiqclogdir"/"$(basename $dir)_multiqc_log.txt"
  
  # run the program 
  multiqc \
    --fullnames \
    --title \""$(basename $dir)"\" \
    --verbose \
    --force \
    --outdir "$trpth"/"$multiqcdir"/"$(basename $dir)" \
    "$dir" 2>&1 | tee -a "$trpth"/"$multiqclogdir"/"$(basename $dir)_multiqc_log.txt" || \
      printf "Multiqc failed at "$(date)" on \"$dir\". \n"

done

conda deactivate # custom environment needs is deactivated
