#!/usr/bin/env bash

# 15.04.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Create Qiime 2 manifest files.

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


# define input directories
# -----------------------
manifests='Zenodo/Manifest'

# write manifest files from sorted arrays
# ---------------------------------------

# erase old file - to not get duplicate headers later 
rm -f "$trpth/$manifests/090_q2_plate?_manifest.txt"

printf "%s\n" "${inpth_plt1[@]}" > "$trpth/$manifests/090_q2_plate1_manifest.txt"
printf "%s\n" "${inpth_plt2[@]}" > "$trpth/$manifests/090_q2_plate2_manifest.txt"
 
# loop over newly created files
# ------------------------------
for filename in "$trpth/$manifests/090_q2_plate1_manifest.txt"; do
    
  # diagnostic message
  printf "Processing \"$filename\"...\n"

   
    # writing sample identifiers - filename after last slash minus 9 characters (to get rid of file extesnions)
    #  see https://unix.stackexchange.com/questions/305190/remove-last-character-from-string-captured-with-awk?rq=1
    /usr/local/bin/gawk -i inplace -F '/' 'BEGIN { OFS = "," } {fmt = substr($NF, 1, length($NF)-9); $0=fmt OFS $0; print}' "$filename"
    
   #   writing sample read directions
   #   gsed -i '/_R1/ s/$/,forward/' "$manifest"
   #   gsed -i '/_R2/ s/$/,reverse/' "$manifest"
   
   #   adjusting sample ids, since could not be achieved with awk above
   #   gsed -i 's/R1/R/' "$manifest"
   #   gsed -i 's/R2/R/' "$manifest"

   # adding headers
   /usr/local/bin/gsed -i '1s;^;'sample-id','absolute-filepath'\n;' "$filename"

done
