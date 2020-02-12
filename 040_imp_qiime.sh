#!/usr/bin/env bash

# 10.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Import files to Qiime

# For debugging only
# ------------------ 
# set -x

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

# input file array - 16S
inpth[1]='Zenodo/Manifest/035_manifest_16S_fastq_list_run_1.txt'
inpth[2]='Zenodo/Manifest/035_manifest_16S_fastq_list_run_2.txt'
inpth[3]='Zenodo/Manifest/035_manifest_16S_fastq_list_run_3.txt'
inpth[4]='Zenodo/Manifest/035_manifest_16S_fastq_list_run_4.txt'
inpth[5]='Zenodo/Manifest/035_manifest_16S_fastq_list_run_5.txt'

# input file array - 18S
inpth[6]='Zenodo/Manifest/035_manifest_18S_fastq_list_run_1.txt'
inpth[7]='Zenodo/Manifest/035_manifest_18S_fastq_list_run_2_a.txt'
inpth[8]='Zenodo/Manifest/035_manifest_18S_fastq_list_run_2_b.txt'
inpth[9]='Zenodo/Manifest/035_manifest_18S_fastq_list_run_3.txt'
inpth[10]='Zenodo/Manifest/035_manifest_18S_fastq_list_run_4.txt'
inpth[11]='Zenodo/Manifest/035_manifest_18S_fastq_list_run_5.txt'
inpth[12]='Zenodo/Manifest/035_manifest_18S_fastq_list_run_6.txt'

# output file array - 16S
otpth[1]='Zenodo/Qiime/040_16S_import_run_1'
otpth[2]='Zenodo/Qiime/040_16S_import_run_2'
otpth[3]='Zenodo/Qiime/040_16S_import_run_3'
otpth[4]='Zenodo/Qiime/040_16S_import_run_4'
otpth[5]='Zenodo/Qiime/040_16S_import_run_5'

# output file array - 18S
otpth[6]='Zenodo/Qiime/040_18S_import_run_1'
otpth[7]='Zenodo/Qiime/040_18S_import_run_2_a'
otpth[8]='Zenodo/Qiime/040_18S_import_run_2_b'
otpth[9]='Zenodo/Qiime/040_18S_import_run_3'
otpth[10]='Zenodo/Qiime/040_18S_import_run_4'
otpth[11]='Zenodo/Qiime/040_18S_import_run_5'
otpth[12]='Zenodo/Qiime/040_18S_import_run_6'

# output file array
sf='PairedEndFastqManifestPhred33'

# Run import script - adjust `i` starting number! 
# -----------------------------------------------
for ((i=1;i<=12;i++)); do
    
    # call import only if output file isn't already there
    if [ ! -f "$trpth"/"${otpth[$i]}.qza" ]; then
    
      # diagnostic message
      printf "${bold}$(date):${normal} Starting importing from \"$(basename "$trpth"/"${inpth[$i]}")\"...\n"
      qiime tools import \
        --type 'SampleData[PairedEndSequencesWithQuality]' \
        --input-path  "$trpth"/"${inpth[$i]}" \
        --output-path "$trpth"/"${otpth[$i]}" \
        --input-format "$sf" 2>&1 | tee -a "$trpth"/"Zenodo/Qiime"/"$(basename ${otpth[$i]} .qza)_import_log.txt" || \
      printf "Import failed at "$(date)" on \"${otpth[$i]}\". \n"
    
    else
    
      # diagnostic message
      printf "${bold}$(date):${normal} Import available for \"$(basename "$trpth"/"${inpth[$i]}")\", skipping.\n"
  
    fi
done
