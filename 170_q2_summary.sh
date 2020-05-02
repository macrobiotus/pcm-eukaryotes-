#!/usr/bin/env bash

# 02.05.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Denoise 2 sequencing runs using DAD2

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

# define relative input locations - Qiime files
# --------------------------------------------------------
inpth_map='Zenodo/Manifest/200501_18S_MF_merged_q2_import.txt'
inpth_tax='Zenodo/Blast/150_18S_merged-seq_q2taxtable.qza'

# define relative input locations - sequence files
# -----------------------------------------------------------

# (https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash)
# (https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash)

# Fill sequence array using find 
inpth_seq_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_seq_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Processing" \( -name '120_18S_merged-seq.qza' \) -print0)

# for debugging - print unsorted sequences
# printf '%s\n'
# printf '%s\n' "${inpth_seq_unsorted[@]}"

# Sort array 
IFS=$'\n' inpth_seq=($(sort <<<"${inpth_seq_unsorted[*]}"))
unset IFS

# for debugging  - print sorted sequences - ok!
# printf '%s\n'
# printf '%s\n' "${inpth_seq[@]}"

# define relative input locations - feature tables
# ------------------------------------------------

# Fill table array using find 
inpth_tab_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_tab_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Processing" \( -name '120_18S_merged-tab.qza' \) -print0)

# for debugging -  print unsorted tables
# printf '%s\n'
# printf '%s\n' "${inpth_tab_unsorted[@]}"

# Sort array 
IFS=$'\n' inpth_tab=($(sort <<<"${inpth_tab_unsorted[*]}"))
unset IFS

# for debugging -  print sorted tables - ok!
# printf '%s\n'
# printf '%s\n' "${inpth_tab[@]}"

# define relative output locations - feature tables
# otpth_tabv='Zenodo/Qiime/080_18S_denoised_tab_vis.qzv'
# otpth_seqv='Zenodo/Qiime/080_18S_denoised_seq_vis.qzv'
# otpth_bplv='Zenodo/Qiime/080_18S_denoised_tax_vis.qzv'

# loop over filtering parameters, and corresponding file name names additions
for i in "${!inpth_seq[@]}"; do

  # check if files can be mathced otherwise abort script because it would do more harm then good
  seqtest="$(basename "${inpth_seq[$i]//-seq/}")"
  tabtest="$(basename "${inpth_tab[$i]//-tab/}")"
  
  # for debugging
  # echo "$seqtest"
  # echo "$tabtest"
  
  
  if [ "$seqtest" == "$tabtest" ]; then
    echo "Sequence- and table files have been matched, continuing..."
  
    # get input sequence file name - for debugging 
    # echo "${inpth_seq[$i]}"
    
    # get input table file name  - for debugging
    # echo "${inpth_tab[$i]}"
    
    directory="$(dirname "$inpth_seq[$i]")"
    seq_file_tmp="$(basename "${inpth_seq[$i]%.*}")"
    seq_file_name="${seq_file_tmp:4}"
    
    tab_file_tmp="$(basename "${inpth_tab[$i]%.*}")"
    tab_file_name="${tab_file_tmp:4}"
    
    plot_file_temp="$(basename "${inpth_seq[$i]//_seq/}")"
    plot_file_temp="${plot_file_temp:4}"
    plot_file_name="${plot_file_temp%.*}"
    
    extension=".qzv"
    
    # check string construction - for debugging
    # echo "$seq_file_name"
    # echo "$tab_file_name"
    # echo "$plot_file_name"
    
    seq_file_vis_path="$directory/170_$seq_file_name""$extension"
    tab_file_vis_path="$directory/170_$tab_file_name""$extension"
    plot_file_vis_path="$directory/170_$plot_file_name"_barplot"$extension"
    
    # check string construction - for debugging
    # echo "$seq_file_vis_path"
    # echo "$tab_file_vis_path"
    # echo "$plot_file_vis_path"
    
    # Qiime calls
    qiime feature-table tabulate-seqs \
      --i-data "${inpth_seq[$i]}" \
      --o-visualization "$seq_file_vis_path" \
      --verbose

    qiime feature-table summarize \
      --m-sample-metadata-file "$trpth"/"$inpth_map" \
      --i-table "${inpth_tab[$i]}" \
      --o-visualization "$tab_file_vis_path" \
      --verbose
 
    qiime taxa barplot \
      --m-metadata-file "$trpth"/"$inpth_map" \
      --i-taxonomy "$trpth"/"$inpth_tax" \
      --i-table "${inpth_tab[$i]}" \
      --o-visualization "$plot_file_vis_path" \
      --verbose

  else
  
    echo "Sequence- and table files can't be matched, aborting."
    exit
  
  fi
  
done
