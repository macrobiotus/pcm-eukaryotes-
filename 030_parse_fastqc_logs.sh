#!/usr/bin/env bash

# 18.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
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
fi

# define input files
# -------------------

# revised manifest are stored in
manifests='Zenodo/Manifest'

# define input directories
# -----------------------

fastqcdir='Zenodo/FastQC'
fastqclogdir='Zenodo/FastQC_logs'

multiqcdir='Zenodo/MultiQC'
multiqclogdir='Zenodo/MultiQC_logs'


# run commands
# ------------

# loop over manifests - for fastqc 
for filename in "$trpth"/"$manifests"/*.txt; do

  # define FastQC output path
  fqc_path="$trpth"/"$fastqcdir"/"FastQC_$(basename "$filename" .txt)"
  
  # define FastQC log output path 
  fqc_log_path="$trpth"/"$fastqclogdir"
  
  # create directory for qc files
  mkdir -p "$fqc_path"
  
  # create directory for qc log files
  mkdir -p "$fqc_log_path"
  
  # loop over paths in manifests
  while read -r fastq_path; do
     
     # get logfile path
     fqclog="$fqc_log_path"/"$(basename "$fastq_path" .fastq.gz)_fastqc_log.txt"
     echo 
     
     # do sequence check
     fastqc -o "$fqc_path" --threads "$cores" "$fastq_path" 2>&1 | tee -a "$fqclog" 
  
  # read next line in file
  done < "$filename"
  
done

# loop over manifests - for fastqc 
# for filename in "$trpth"/"$manifests"/*.txt; do
# 
#   define FastQC output paths 
#   fqc_path="$trpth"/"$fastqcdir"/"FastQC_$(basename "$filename" .txt)"
#   
#   define MultiQC output paths
#   mqc_path="$trpth"/"$fastqcdir"/"MultiQC_$(basename "$filename" .txt)"
#   
#   echo "$fqc_path"
#   echo "$mqc_path"
#   
#   loop over paths in manifests
#   while read -r fastq_path; do
#      
#      get logfile path
#      echo "$(basename "$fastq_path" .fastq.gz)_log.txt"
#      echo fastqc -o "$fqc_path" --threads "$cores" "$fastq_path" 2>&1 
#   done < "$filename"
#   
#  
#   
# done





