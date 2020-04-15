#!/usr/bin/env bash

# 15.04.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Remove adapter remnants before downstream processing.

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
done < <(find "$trpth/Zenodo/Processing/050_plate_1" -name '18S.1.*.fastq.gz' -print0)

IFS=$'\n' inpth_plt1=($(sort <<<"${inpth_plt1_unsorted[*]}"))
unset IFS


# define input file for plate 2, and sort
# ---------------------------------------
inpth_plt2_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_plt2_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Processing/050_plate_2" -name '18S.2.*.fastq.gz' -print0)

IFS=$'\n' inpth_plt2=($(sort <<<"${inpth_plt2_unsorted[*]}"))
unset IFS


# combine file name arrays for looping
# ------------------------------------

fastqgzs=("${inpth_plt1[@]}" "${inpth_plt2[@]}")


# define output directories
# -------------------------
destdir="$trpth/Zenodo/Processing/070_cutadapt"

# Defining sequences to be cut out:
# ---------------------------------
#  Keep in mind this configuration:
#  *  forward read(5'-3'): - 5' adapter , pad and linker:
#     `AATGATACGGCGACCACCGAGATCTACAC GACTGCACTGA CG`
#  *  reverse read(5'-3'): - 3' adapter, barcode, pad and linker:
#     `CAAGCAGAAGACGGCATACGAGAT NNNNNNNNNNNN GTCTGCTCGCTCAGT CA`
 
# 5'-3' forward (p1391fF)
fwdcut='GTACACACCGCCCGTC'
# 5'-3' reverse (pEukBrR)
revcut='TGATCCTTCTGCAGGTTCACCTAC'
# 
# reverse-complement of of 5'-3' reverse (pEukBrR)
adpfcut='GTAGGTGAACCTGCAGAAGGATCA'
# reverse-complement of of 5'-3' forward (p1391fF)
adprcut='GACGGGCGGTGTGTAC'

# run trimming script
# -------------------
mkdir -p "$destdir"

for fastqgz in "${fastqgzs[@]}"; do
  cutadapt \
    -g "$adprcut" \
    -a "$revcut" \
    -j "$cores" \
    -o "$destdir"/$(basename "$fastqgz") \
    "$fastqgz" \
     2>&1 | tee -a "$destdir/070_cutadapt_log.txt"
done
