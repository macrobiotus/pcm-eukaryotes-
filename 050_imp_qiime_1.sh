#!/usr/bin/env bash

# 14.04.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Import ancient files using Qiime 1 so as to use DADA2
#  pipline

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

# define input files for 18S
inseq[1]='/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S4_PC_merged.Read.fastq.gz'
inseq[2]='/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S3_PC_merged.Read.fastq.gz'

inidx[1]='/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S4_PC_merged.Index.fastq.gz'
inidx[2]='/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S3_PC_merged.Index.fastq.gz'

inmap[1]='/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/160202_18S_MF.txt'
inmap[2]='/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/160202_18S_MF.txt'

# define input files and parameters for 18S
prmqual[1]='19'
prmqual[2]='19'

prmidx[1]='100000000'
prmidx[2]='200000000'

# output file array - 16S
outseq[1]='/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Qiime/050_plate_1'
outseq[2]='/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Qiime/050_plate_2'

outlog[1]='/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Qiime/050_plate_1/050_plate_1_log.txt'
outlog[2]='/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Qiime/050_plate_2/050_plate_2_log.txt'


# Run import script - adjust `i` starting number! 
# -----------------------------------------------
for ((i=1;i<=2;i++)); do
    
  # call import only if output file isn't already there
  if [ ! -f "${outseq[$i]}" ]; then
    
    # diagnostic message
    printf "${bold}$(date):${normal} Starting importing from \""${inseq[$i]}"\"...\n"
    split_libraries_fastq.py \
      -i "${inseq[$i]}" \
      -b "${inidx[$i]}" \
      -o "${outseq[$i]}" \
      -m "${inmap[$i]}" \
      -q "${prmqual[$i]}" \
      -s "${prmidx[$i]}" \
      --store_qual_scores \
      --rev_comp_mapping_barcodes \
      2>&1 | tee -a "${outlog[$i]}" || \
    printf "Import failed at "$(date)" on \"${outseq[$i]}\". \n"
    
  else
    
  # diagnostic message
   printf "${bold}$(date):${normal} Import available for \""${inseq[$i]}"\", skipping.\n"
  
  fi

done

