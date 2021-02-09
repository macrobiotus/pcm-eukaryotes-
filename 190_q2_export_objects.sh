#!/usr/bin/env bash

# 12.08.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================

# For debugging only
# ------------------ 
# set -x
set -e
set -u

# Paths need to be adjusted for remote execution
# ==============================================
if [[ "$HOSTNAME" != "Pauls-MacBook-Pro.local" ]] && [[ "$HOSTNAME" != "macmini-fastpost.staff.uod.otago.ac.nz" ]]; then
    bold=$(tput bold)
    normal=$(tput sgr0)
    printf "${bold}$(date):${normal} Execution on remote...\n"
    trpth="/workdir/pc683/OU_pcm_eukaryotes"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "Pauls-MacBook-Pro.local" ]]  || [[ "$HOSTNAME" = "macmini-fastpost.staff.uod.otago.ac.nz" ]]; then
    bold=$(tput bold)
    normal=$(tput sgr0)
    printf "${bold}$(date):${normal} Execution on local...\n"
    trpth="/Users/paul/Documents/OU_pcm_eukaryotes"
    cores='2'
fi

# define relative input and output locations
# ==========================================

# Qiime files
# -----------

# MD5 (/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_q2taxtable.qza) = b5e1e51cb160982300b9c1794b3044c4
tax_assignemnts='Zenodo/Blast/150_18S_merged-seq_q2taxtable.qza'
# MD5 (/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/200810_18S_MF_merged_q2_import.txt) = 62f8ced6d6c8ceb682c53e446c568df8
# inpth_map='Zenodo/Manifest/200810_18S_MF_merged_q2_import.txt'
inpth_map='Zenodo/Manifest/210209_18S_MF_merged_q2_import.txt'
# Find all feature tables and put into array
# ------------------------------------------
inpth_features_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_features_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Processing" -name '120_18S_merged-tab.qza' -print0)

# Sort array 
IFS=$'\n' inpth_features=($(sort <<<"${inpth_features_unsorted[*]}"))
unset IFS

# Find all sequence tables and put into array
# ------------------------------------------
inpth_sequences_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_sequences_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Processing" -name '120_18S_merged-seq.qza' -print0)

# Sort array 
IFS=$'\n' inpth_sequences=($(sort <<<"${inpth_sequences_unsorted[*]}"))
unset IFS

# print all sorted arrays (debugging)
# ------------------------------------------

# printf '%s\n'
# printf '%s\n' "${inpth_features[@]}"
# printf '%s\n'
# printf '%s\n' "${inpth_sequences[@]}"

for i in "${!inpth_features[@]}"; do

  # check if files can be matched otherwise abort script because it would do more harm then good
  tabstump=$(basename "${inpth_features[$i]//-tab/}")
  seqstump=$(basename "${inpth_sequences[$i]//-seq/}")
  
  # echo "$tabstump"
  # echo "$seqstump"
  # exit
  
  if [ "$seqstump" == "$tabstump" ]; then
  
    # diagnostic only 
    printf "${bold}$(date):${normal} Sequence-, and featurefiles have been matched, continuing...\n"
    
    
    # create path for output directory
    results_tmp=$(basename "${inpth_features[$i]}".qza)
    results_tmp=${results_tmp:4:-8}
    results_dir="$trpth/Zenodo/Processing/190_"$results_tmp"_q2_export"
    # echo "$results_dir"
    # exit
    
    if [ ! -d "$results_dir" ]; then
    
      mkdir -p "$results_dir"
    
      # Exporting Qiime 2 files
      printf "${bold}$(date):${normal} Exporting Qiime 2 files...\n"
      qiime tools export --input-path "${inpth_features[$i]}" --output-path "$results_dir" && \
      qiime tools export --input-path "${inpth_sequences[$i]}" --output-path "$results_dir" && \
      qiime tools export --input-path "$trpth"/"$tax_assignemnts" --output-path "$results_dir" || \
      { echo "${bold}$(date):${normal} Qiime export failed" ; exit 1; }
    
#       # Editing taxonomy file - unnecessary in present data
#       printf "${bold}$(date):${normal} Rewriting headers of taxonomy information (backup copy is kept)...\n"
#       new_header='#OTUID  taxonomy    confidence' && \
#       gsed -i.bak "1 s/^.*$/$new_header/" "$results_dir"/taxonomy.tsv || \
#       { echo "${bold}$(date):${normal} Taxonomy Edit failed" ; exit 1; }
  
      # Adding taxonomy information to .biom file
      printf "${bold}$(date):${normal} Adding taxonomy information to .biom file...\n"
      biom add-metadata \
        -i "$results_dir"/feature-table.biom \
        -o "$results_dir"/features-tax.biom \
        --observation-metadata-fp "$results_dir"/taxonomy.tsv \
        --observation-header OTUID,taxonomy,confidence \
        --sc-separated taxonomy || { echo 'taxonomy addition failed' ; exit 1; }
   
      # Adding metadata to .biom file
      printf "${bold}$(date):${normal} Adding metadata to .biom file...\n"
      biom add-metadata \
        -i "$results_dir"/features-tax.biom \
        -o "$results_dir"/features-tax-meta.biom \
        -m "$trpth"/"$inpth_map" \
        --observation-header OTUID,taxonomy,confidence \
        --sample-header SampleID,BarcodeSequence,LinkerPrimerSequence,TmplHash,LibContent,SardiID,XtrOri,XtrContent,Location,LongDEC,LatDEC,Loci,RibLibConcAvg,RibPoolConcAvg,Description,COLR,GRAVL,TEXT,AMMN,NITR,PHOS,POTA,SULPH,CARB,COND,PH_CACL,PH_H2O,RLU,QUARTZ,FELDSPAR,TITANITE,GARNETS,MICAS,DOLOMITE,KAOLCHLOR,CALCITE,CHLORITE,ELEVATION,SLOPE,ASPECT,AGE_KA,RACMO_precip_mm_35to1km,RACMO_windsp_10m_35to1km,RACMO_tmp_2m_35to1km || { echo 'Metadata addition failed' ; exit 1; }
  
      # Exporting .biom file to .tsv
      printf "${bold}$(date):${normal} Exporting to .tsv file...\n"
      biom convert \
        -i "$results_dir"/features-tax-meta.biom \
        -o "$results_dir"/features-tax-meta.tsv \
        --to-tsv && \
      gsed -i.bak 's/#//' "$results_dir"/features-tax-meta.tsv \
      || { echo 'TSV export failed' ; exit 1; }
        
    else
    
      # diagnostic message
      printf "${bold}$(date):${normal} Detected readily available results, skipping analysis of one file set.\n"

    fi

  else
  
    echo "Files triplets can't be matched, aborting."
    exit
  
  fi
  
done
