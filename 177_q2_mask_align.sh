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
done < <(find "$trpth/Zenodo/Processing" \( -name '175_18S_merged-seq_alignment.qza' \) -print0)

# for debugging - print unsorted sequences
# printf '%s\n'
# printf '%s\n' "${inpth_seq_unsorted[@]}"

# Sort array 
IFS=$'\n' inpth_seq=($(sort <<<"${inpth_seq_unsorted[*]}"))
unset IFS

# for debugging  - print sorted sequences - ok!
# printf '%s\n'
# printf '%s\n' "${inpth_seq[@]}"

# define output locations - alignment files
# -----------------------------------------

# copy previous array to create array for output file names
otpth_seq=("${inpth_seq[@]}")

# create output filenames 
for i in "${!otpth_seq[@]}"; do

  # deconstruct string
  directory="$(dirname "$otpth_seq[$i]")"
  seq_file_tmp="$(basename "${otpth_seq[$i]%.*}")"
  seq_file_name="177_${seq_file_tmp:4}"
  extension="${otpth_seq[$i]##*.}"                                  # get the extension
  otpth_seq[$i]="$directory"/"${seq_file_name}_masked.${extension}" # get name string

done

# for debugging -  print output filenames
# printf '%s\n'
# printf '%s\n' "${otpth_seq[@]}"

# define output locations - log files
# ----------------------------------------

# copy previous array to create array for output file names
otpth_log=("${otpth_seq[@]}")

# create output filenames 
for i in "${!otpth_log[@]}"; do
 
  # deconstruct string
  directory="$(dirname "$otpth_log[$i]")"
  seq_file_tmp="$(basename "${otpth_log[$i]%.*}")"
  seq_file_name="177_${seq_file_tmp:4}"
  extension=".txt"                                               # get the extension
  otpth_log[$i]="$directory"/"${seq_file_name}_log${extension}" # get name string    
  
done

# for debugging -  print output filenames
# printf '%s\n'
# printf '%s\n' "${otpth_log[@]}"

# exit

# Run scripts
# ------------

for k in "${!inpth_seq[@]}"; do
  
  # actual filtering
  # continue only if output file isn't already there
  if [ ! -f "${otpth_seq[$k]}" ]; then

    printf "\n${bold}$(date):${normal} Masking alignment file ${inpth_seq[$k]}...\n"
    qiime alignment mask \
      --i-alignment "${inpth_seq[$k]}" \
      --o-masked-alignment "${otpth_seq[$k]}" \
      --p-min-conservation 0.5 \
      --p-max-gap-frequency 0.1 \
      --verbose 2>&1 | tee -a "${otpth_log[$k]}"

  else
 
    # diagnostic message
    printf "${bold}$(date):${normal} Analysis already done for \"$(basename "${inpth_seq[$k]}")\"...\n"

  fi

done
