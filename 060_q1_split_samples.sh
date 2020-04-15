#!/usr/bin/env bash

# 15.04.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Import ancient files using Qiime 1 so as to use DADA2 pipeline

# set -x
set -e

# Paths need to be adjusted for remote execution
# ----------------------------------------------
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

# define input files
inseq[1]="$trpth/Zenodo/Qiime/050_plate_1/seqs.fastq"
inseq[2]="$trpth/Zenodo/Qiime/050_plate_2/seqs.fastq"

prmtp[1]="fastq"
prmtp[2]="fastq"

# output locations
outdir[1]="$trpth/Zenodo/Processing/050_plate_1"
outdir[2]="$trpth/Zenodo/Processing/050_plate_2"

outlog[1]="$trpth/Zenodo/Processing/050_plate_1/050_plate_1_log.txt"
outlog[2]="$trpth/Zenodo/Processing/050_plate_2/050_plate_2_log.txt"

# Run import script - adjust `i` starting number! 
# -----------------------------------------------
for ((i=1;i<=2;i++)); do
    
  # call import only if output file isn't already there
  if [ ! -f "${outdir[$i]}/out${prmtp[$i]}" ]; then
    
    # diagnostic message
    printf "${bold}$(date):${normal} Wriring out demultiplxed files from \""${inseq[$i]}"\"...\n"
    
    split_sequence_file_on_sample_ids.py \
      -i "${inseq[$i]}"  \
      -o "${outdir[$i]}" \
      --file_type "${prmtp[$i]}" \
    2>&1 | tee -a "${outlog[$i]}" || \
    printf "Import failed at "$(date)" on \""${inseq[$i]}"\". \n"
    
  else
    
    # diagnostic message
    printf "${bold}$(date):${normal} Import available for \""${inseq[$i]}"\", skipping.\n"
  
  fi

done
