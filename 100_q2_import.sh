#!/usr/bin/env bash

# 29.07.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Import Qiime1-derived files into Qiime 2.

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

# input file array - 18S
inpth[1]='Zenodo/Manifest/090_q2_plate1_manifest.txt'
inpth[2]='Zenodo/Manifest/090_q2_plate2_manifest.txt'

# output file array - 18S
otpth[1]='Zenodo/Processing/100_18S_import_run_1'
otpth[2]='Zenodo/Processing/100_18S_import_run_2'

# Run import script - adjust `i` starting number! 
# -----------------------------------------------
for ((i=1;i<=2;i++)); do
    
    # call import only if output file isn't already there
    if [ ! -f "$trpth"/"${otpth[$i]}.qza" ]; then
    
      # diagnostic message
      printf "${bold}$(date):${normal} Starting importing from \"$(basename "$trpth"/"${inpth[$i]}")\"...\n"
      qiime tools import \
        --type "SampleData[SequencesWithQuality]" \
        --input-path  "$trpth"/"${inpth[$i]}" \
        --output-path "$trpth"/"${otpth[$i]}" \
        --input-format "SingleEndFastqManifestPhred33" 2>&1 | tee -a "$trpth"/"Zenodo/Processing"/"$(basename ${otpth[$i]} .qza)_import_log.txt" || \
      printf "Import failed at "$(date)" on \"${otpth[$i]}\". \n"
    
    else
    
      # diagnostic message
      printf "${bold}$(date):${normal} Import available for \"$(basename "$trpth"/"${inpth[$i]}")\", skipping.\n"
  
    fi
done
