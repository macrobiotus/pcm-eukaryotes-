#!/usr/bin/env bash

# 07.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# create manifest files from file lists

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
manifests='Zenodo/Manifest'

# erase old file - to not get duplicate headers later 
rm -f "$trpth/$manifests/"035_*.txt

# loop over files
# ---------------
for filename in $trpth/$manifests/*.txt; do
  
  # diagnostic message
  printf "Processing \"$filename\"...\n"
  
  # create output file path 
  manifest="$trpth"/"$manifests"/"035_manifest_$(basename $filename)"
  #   for debugging only 
  # echo $manifest
  
  # create output file - can be erased safely 
  # cp "$filename" "$manifest"
  
  # writing sample identifiers - filename after last slash minus 9 characters (to get rid of file extesnions)
  #  see https://unix.stackexchange.com/questions/305190/remove-last-character-from-string-captured-with-awk?rq=1
  # giving up here
  gawk -F '/' 'BEGIN { OFS = "," } {fmt = substr($NF, 1, length($NF)-9); $0=fmt OFS $0; print}' "$filename" > "$manifest"
    
  # writing sample read directions
  gsed -i '/_R1/ s/$/,forward/' "$manifest"
  gsed -i '/_R2/ s/$/,reverse/' "$manifest"
  
  # adjusting sample ids, since could not be achieved with awk above
  gsed -i 's/R1/R/' "$manifest"
  gsed -i 's/R2/R/' "$manifest"
  
  # sorting file contents - untested - already done in "015_check_file_presences.sh"
  #  gsort -t, -k3,3n -k4,4n -o "$manifest" "$manifest"
  #  gsort --version-sort -o "$manifest" "$manifest"
  
  # adding headers
  gsed -i '1s;^;'sample-id','absolute-filepath','direction'\n;' "$manifest"

done
