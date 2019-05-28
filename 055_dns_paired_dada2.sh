#!/usr/bin/env bash

# 23.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.10/tutorials/moving-pictures/
# Citing this plugin: DADA2: High-resolution sample inference from Illumina
# amplicon data. Benjamin J Callahan, Paul J McMurdie, Michael J Rosen,
# Andrew W Han, Amy Jo A Johnson, Susan P Holmes. Nature Methods 13, 581–583
# (2016) doi:10.1038/nmeth.3869.

# for debugging only
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
    cores='1'
    bold=$(tput bold)
    normal=$(tput sgr0)
fi

# define relative input locations - data files
# ------------------------------------------------

# Fill table array using find 
inpth_data_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_data_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '045_???_trimmed_*.qza' -print0)

# Sort array 
IFS=$'\n' data_tab=($(sort <<<"${inpth_data_unsorted[*]}"))
unset IFS

# for debugging -  print sorted tables - ok!
# printf '%s\n'
# printf '%s\n' "$(basename $data_tab)"


# loop over input data files
# ------------------------------------------------
for i in "${!data_tab[@]}"; do

  # create output file names
  trunc=$(basename "${data_tab[$i]}")
  # for debugging 
  # echo $(dirname "${data_tab[$i]")
  # echo ${trunc:4:-4}

  otpth_seq="$(dirname "${data_tab[$i]}")/055_"${trunc:4:-4}"_denoised_seq.qza"
  otpth_tab="$(dirname "${data_tab[$i]}")/055_"${trunc:4:-4}"_denoised_tab.qza"
  otpth_stat="$(dirname "${data_tab[$i]}")/055_"${trunc:4:-4}"_denoised_stat.qza"
  otpth_statv="$(dirname "${data_tab[$i]}")/055_"${trunc:4:-4}"_denoised_stat.qzv"
  output_log="$(dirname "${data_tab[$i]}")/055_"${trunc:4:-4}"_denoised_log.txt"

  # echo "$otpth_seq"
  # echo "$otpth_tab"
  # echo "$otpth_stat"
  # echo "$otpth_statv"
  # echo "$output_log"

  # call denoising only if output file isn't already there
  if [ ! -f "$otpth_seq" ]; then

    # diagnostic message
    printf "${bold}$(date):${normal} Starting denoising of \"$(basename "${data_tab[$i]}")\"...\n"

    # setting processing parameters
    case "${data_tab[$i]}" in
      *"045_16S_trimmed_"* )
         lenf='0'
         lenr='0'
         ee='15'
#        lenf='145'
#        lenr='145'
#        ee='5'
        echo "${bold}Parameters for 16S set to:${normal} lenf = $lenf, lenr = $lenr, ee = $ee. "
        ;;
      *"045_18S_trimmed_"* )
         lenf='0'
         lenr='0'
         ee='5'

#        lenf='145'
#        lenr='145'
#        ee='9'
        echo "${bold}Parameters for 18S set to:${normal} lenf = $lenf, lenr = $lenr, ee = $ee."
        ;;
      *)
        echo "Depth setting error in case statemnet, aborting."
        exit
        ;;
    esac
   
   # qiime calls
   qiime dada2 denoise-paired \
      --i-demultiplexed-seqs "${data_tab[$i]}" \
      --p-trunc-len-f "$lenf" \
      --p-trunc-len-r "$lenr" \
      --p-n-threads "$cores" \
      --p-max-ee "$ee" \
      --o-representative-sequences "$otpth_seq" \
      --o-denoising-stats "$otpth_stat" \
      --o-table "$otpth_tab" \
      --verbose  2>&1 | tee -a "$output_log"
    printf "${bold}$(date):${normal} ...finished denoising of \"$(basename "${data_tab[$i]}")\".\n"
        
    # export stats file for manual inspection and gnuplot
    qiime metadata tabulate \
      --m-input-file "$otpth_stat" \
      --o-visualization "$otpth_statv"

  else

    # diagnostic message
    printf "${bold}$(date):${normal} Analysis already done for \"$(basename "${data_tab[$i]}")\"...\n"

  fi

done
