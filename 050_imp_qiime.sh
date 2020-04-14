#!/usr/bin/env bash

# 14.04.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Import files to Qiime

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

# input file array - 18S
inpth[1]='/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S3_PC_merged.Read.fastq.gz'
inpth[2]='/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S3_PC_merged.Read.fastq.gz'

# output file array - 16S
otpth[1]='Zenodo/Qiime/040_18S_import_run_1'
otpth[2]='Zenodo/Qiime/040_18S_import_run_2'

# output file array
sf='MultiplexedSingleEndBarcodeInSequence'

# Run import script - adjust `i` starting number! 
# -----------------------------------------------
for ((i=1;i<=2;i++)); do
    
    # call import only if output file isn't already there
    if [ ! -f "$trpth"/"${otpth[$i]}.qza" ]; then
    
      # diagnostic message
      printf "${bold}$(date):${normal} Starting importing from \"$(basename "$trpth"/"${inpth[$i]}")\"...\n"
      qiime tools import \
        --type 'EMPSingleEndSequences ' \
        --input-path  "${inpth[$i]}" \
        --output-path "$trpth"/"${otpth[$i]}" \
     2>&1 | tee -a "$trpth"/"Zenodo/Qiime"/"$(basename ${otpth[$i]} .qza)_import_log.txt" || \
      printf "Import failed at "$(date)" on \"${otpth[$i]}\". \n"
    
    else
    
      # diagnostic message
      printf "${bold}$(date):${normal} Import available for \"$(basename "$trpth"/"${inpth[$i]}")\", skipping.\n"
  
    fi

done
