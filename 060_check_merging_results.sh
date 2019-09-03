#!/usr/bin/env bash

# 08.08.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Get (gnu)plots for multiple merging statistic .tsv exports of Qiime 2
# .tsv files need to be generated manually.
# Compare
#   https://askubuntu.com/questions/701986/how-to-execute-commands-in-gnuplot-using-shell-script
#   https://groups.google.com/forum/#!topic/comp.graphics.apps.gnuplot/sCOqvk7EzRU
# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "macmini.staff.uod.otago.ac.nz" ]]; then
    printf "Execution on remote not implemnted, aborting. \n"
    trpth="/workdir/pc683/AAD_combined"
    exit 
    # cores="$(nproc --all)"
    # bold=$(tput bold)
    # normal=$(tput sgr0)
elif [[ "$HOSTNAME" == "macmini.staff.uod.otago.ac.nz" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_combined"
    cores='1'
    bold=$(tput bold)
    normal=$(tput sgr0)
fi

# input file array
inpth[1]='Zenodo/Qiime/060_16S_trimmed_run_1_denoised_stat.tsv'
inpth[2]='Zenodo/Qiime/060_16S_trimmed_run_2_denoised_stat.tsv'
inpth[3]='Zenodo/Qiime/060_16S_trimmed_run_3_denoised_stat.tsv' 
inpth[4]='Zenodo/Qiime/060_16S_trimmed_run_4_denoised_stat.tsv' 
inpth[5]='Zenodo/Qiime/060_16S_trimmed_run_5_denoised_stat.tsv' 

inpth[6]='Zenodo/Qiime/060_18S_trimmed_run_1_denoised_stat.tsv'
inpth[7]='Zenodo/Qiime/060_18S_trimmed_run_2_a_denoised_stat.tsv'
inpth[8]='Zenodo/Qiime/060_18S_trimmed_run_3_denoised_stat.tsv'
inpth[9]='Zenodo/Qiime/060_18S_trimmed_run_4_denoised_stat.tsv'
inpth[10]='Zenodo/Qiime/060_18S_trimmed_run_5_denoised_stat.tsv'
inpth[11]='Zenodo/Qiime/060_18S_trimmed_run_6_denoised_stat.tsv'


# output paths
otpth[1]='Zenodo/Qiime/060_16S_trimmed_run_1_denoised_stat.svg'
otpth[2]='Zenodo/Qiime/060_16S_trimmed_run_2_denoised_stat.svg'
otpth[3]='Zenodo/Qiime/060_16S_trimmed_run_3_denoised_stat.svg' 
otpth[4]='Zenodo/Qiime/060_16S_trimmed_run_4_denoised_stat.svg' 
otpth[5]='Zenodo/Qiime/060_16S_trimmed_run_5_denoised_stat.svg' 

otpth[6]='Zenodo/Qiime/060_18S_trimmed_run_1_denoised_stat.svg'
otpth[7]='Zenodo/Qiime/060_18S_trimmed_run_2_a_denoised_stat.svg'
otpth[8]='Zenodo/Qiime/060_18S_trimmed_run_3_denoised_stat.svg'
otpth[9]='Zenodo/Qiime/060_18S_trimmed_run_4_denoised_stat.svg'
otpth[10]='Zenodo/Qiime/060_18S_trimmed_run_5_denoised_stat.svg'
otpth[11]='Zenodo/Qiime/060_18S_trimmed_run_6_denoised_stat.svg'


# file labels
label[1]='16S trimmed run 1 denoising statistics'
label[2]='16S trimmed run 2 denoising statistics'
label[3]='16S trimmed run 3 denoising statistics' 
label[4]='16S trimmed run 4 denoising statistics' 
label[5]='16S trimmed run 5 denoising statistics' 

label[6]='18S trimmed run 1 denoising statistics'
label[7]='18S trimmed run 2 a denoising statistics'
label[8]='18S trimmed run 3 denoising statistics'
label[9]='18S trimmed run 4 denoising statistics'
label[10]='18S trimmed run 5 denoising statistics'
label[11]='18S trimmed run 6 denoising statistics'



# Run script
# ----------
for ((i=1;i<=11;i++)); do
    
  # call import only if output file isn't already there
  if [ ! -f "$trpth"/"${otpth[$i]}" ]; then
    
    # diagnostic message
    printf "${bold}$(date):${normal} Plotting \"$(basename "$trpth"/"${inpth[$i]}")\"...\n"
      
gnuplot -persist <<-EOFMarker
  # Output W3C Scalable Vector Graphics
  set terminal svg size 1250, 350
  
  # Set plot size
  set size 1,1
  
  # Set graph title **use backticks to interpret shell variable**
  set title "`echo "${label[$i]}"`"
  
  # Set label of x-axis
  set xlabel 'FastQ file'
  
  # Set label of y-axis
  set ylabel 'Reads at Stage'
  
  # Use a histogram
  set style data histogram
  
  # Use clustered histogram (gap size of 1 makes xtics position better)
  set style histogram clustered gap 1
  
  # Use a solid fill style for histogram bars
  set style fill solid 1 noborder
  
  # Rotate x-axis labels by 60 degrees
  set xtics rotate by 45 right
  
  # define output path  **use backticks to interpret shell variable**
  set output "`echo $trpth"/"${otpth[$i]}`"
  
  # plot  **use backticks to interpret shell variable**
  plot for [i=2:5] "`echo $trpth"/"${inpth[$i]}`" using i:xtic(1) title columnheader linewidth 4
EOFMarker
    
else
    
      # diagnostic message
      printf "${bold}$(date):${normal} Plot already available for \"$(basename "$trpth"/"${inpth[$i]}")\", skipping.\n"
  
    fi
done
