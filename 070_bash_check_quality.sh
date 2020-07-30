#!/usr/bin/env bash

# 29.07.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Check quality of fastq files.

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


# define input file for plate 1, and sort
# ---------------------------------------
inpth_plt1_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_plt1_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Processing/050_plate_1/" -name '18S.1.*.fastq' -print0)

IFS=$'\n' inpth_plt1=($(sort <<<"${inpth_plt1_unsorted[*]}"))
unset IFS


# define input file for plate 2, and sort
# ---------------------------------------
inpth_plt2_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_plt2_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Processing/050_plate_2/" -name '18S.2.*.fastq' -print0)

IFS=$'\n' inpth_plt2=($(sort <<<"${inpth_plt2_unsorted[*]}"))
unset IFS


# Parameters
# ---------

# adapter files
adpts[1]='Zenodo/Manifest/fastqc_adapter_reference.tsv'
adpts[2]='Zenodo/Manifest/fastqc_adapter_reference.tsv'

# MultiQC report title
ttl[1]="Plate 1 qualities after Qiime1 demultiplexing and Q20 filtering" 
ttl[2]="Plate 2 qualities after Qiime1 demultiplexing and Q20 filtering"


# Output directories
# ------------------
fstqc[1]='Zenodo/QualityCheck/070_plate1_FastQC'
fstqc[2]='Zenodo/QualityCheck/070_plate2_FastQC'

mltqc[1]='Zenodo/QualityCheck/070_plate1_MultiQC'
mltqc[2]='Zenodo/QualityCheck/070_plate2_MultiQC'


# Loop over arrays
# ================

# Plate 1
# -------

mkdir -p "$trpth"/"${fstqc[1]}"

for fastq in "${inpth_plt1[@]}"
  do
    /usr/local/bin/fastqc -o "$trpth"/"${fstqc[1]}" --threads "$cores" --adapters "$trpth"/"${adpts[1]}" \
      "$fastq"
  done


mkdir -p "$trpth"/"${mltqc[1]}" 
multiqc --fullnames --verbose --force --title "${ttl[1]}" \
    --outdir "$trpth"/"${mltqc[1]}" "$trpth"/"${fstqc[1]}"


# Plate 2
# -------

mkdir -p "$trpth"/"${fstqc[2]}"

for fastq in "${inpth_plt2[@]}"
  do
    /usr/local/bin/fastqc -o "$trpth"/"${fstqc[2]}" --threads "$cores" --adapters "$trpth"/"${adpts[2]}" \
      "$fastq"
  done

mkdir -p "$trpth"/"${mltqc[2]}" 
multiqc --fullnames --verbose --force --title "${ttl[2]}" \
    --outdir "$trpth"/"${mltqc[2]}" "$trpth"/"${fstqc[2]}"
