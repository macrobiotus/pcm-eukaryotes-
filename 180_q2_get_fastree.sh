#!/usr/bin/env bash

# 12.08.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================

# set -x
set -e
set -u

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

# define relative input locations - sequence files
# -----------------------------------------------------------

# (https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash)

# Fill sequence array using find 
inpth_seq_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_seq_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Processing" \( -name '177_18S_merged-seq_alignment_masked.qza' \) -print0)

# for debugging - print unsorted sequences
# printf '%s\n'
# printf '%s\n' "${inpth_seq_unsorted[@]}"

# Sort array 
IFS=$'\n' inpth_seq=($(sort <<<"${inpth_seq_unsorted[*]}"))
unset IFS

# for debugging  - print sorted sequences - ok!
# printf '%s\n'
# printf '%s\n' "${inpth_seq[@]}"

# define output locations - tree files
# ----------------------------------------

# copy previous array to create array for output file names
otpth_tree=("${inpth_seq[@]}")

# create output filenames 
for i in "${!otpth_tree[@]}"; do

  # deconstruct string
  directory="$(dirname "$otpth_tree[$i]")"
  tree_file_tmp="$(basename "${otpth_tree[$i]%.*}")"
  tree_file_name="180_${tree_file_tmp:4}"
  extension="${otpth_tree[$i]##*.}"                                 # get the extension
  otpth_tree[$i]="$directory"/"${tree_file_name}_tree.${extension}" # get name string
 
done

# for debugging -  print output filenames
# printf '%s\n'
# printf '%s\n' "${otpth_tree[@]}"
# exit

# define output locations - rooted tree files
# ----------------------------------------

# copy previous array to create array for output file names
otpth_rtree=("${otpth_tree[@]}")

# create output filenames 
for i in "${!otpth_rtree[@]}"; do
 
  # deconstruct string
  directory="$(dirname "$otpth_rtree[$i]")"
  rtree_file_tmp="$(basename "${otpth_rtree[$i]%.*}")"
  rtree_file_name="180_${rtree_file_tmp:4}"
  extension="${otpth_rtree[$i]##*.}"                                    # get the extension
  otpth_rtree[$i]="$directory"/"${rtree_file_name}_rooted.${extension}" # get name string

done

# for debugging -  print output filenames
# printf '%s\n'
# printf '%s\n' "${otpth_rtree[@]}"

# define output locations - log files
# ----------------------------------------

# copy previous array to create array for output file names
otpth_log=("${otpth_tree[@]}")

# create output filenames 
for i in "${!otpth_log[@]}"; do
 
  # deconstruct string
  directory="$(dirname "$otpth_log[$i]")"
  log_file_tmp="$(basename "${otpth_log[$i]%.*}")"
  log_file_name="180_${log_file_tmp:4}"
  extension="txt"                                                # get the extension
  otpth_log[$i]="$directory"/"${log_file_name}_log.${extension}" # get name string

done

# for debugging -  print output filenames
# printf '%s\n'
# printf '%s\n' "${otpth_log[@]}"

# Run scripts
# ------------

for k in "${!inpth_seq[@]}"; do
  
  if [ ! -f "${otpth_tree[$k]}" ]; then
  
    printf "\n${bold}$(date):${normal} Calculating tree ${inpth_seq[$k]}...\n"
    qiime phylogeny fasttree \
      --i-alignment "${inpth_seq[$k]}" \
      --p-n-threads "$cores" \
      --o-tree "${otpth_tree[$k]}" \
      --verbose  2>&1 | tee -a "${otpth_log[$k]}"
  
    printf "\n${bold}$(date):${normal} Midpoint-rooting "${otpth_tree[$k]}"...\n"  
    qiime phylogeny midpoint-root \
      --i-tree "${otpth_tree[$k]}" \
      --o-rooted-tree "${otpth_rtree[$k]}"
  
  else
 
    # diagnostic message
    printf "${bold}$(date):${normal} Analysis already done for \"$(basename "${inpth_seq[$k]}")\"...\n"

  fi

done
