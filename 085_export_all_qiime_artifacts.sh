#!/usr/bin/env bash

# for debugging only
# ================== 
# set -x

# 01.08.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Visualising reads after denoising and merging procedure.

# for debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "macmini.staff.uod.otago.ac.nz" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/AAD_combined"
    cores="$(nproc --all)"
    bold=$(tput bold)
    normal=$(tput sgr0)
elif [[ "$HOSTNAME" == "macmini.staff.uod.otago.ac.nz" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_combined"
    cores='2'
    bold=$(tput bold)
    normal=$(tput sgr0)
fi

# define relative input and output locations
# ==========================================

# Qiime files
# -----------
inpth_map[1]='Zenodo/Manifest/035_16S_mappingfile.txt'
inpth_map[2]='Zenodo/Manifest/035_18S_mappingfile.txt'

tax_assignemnts[1]='Zenodo/Qiime/070_16S_denoised_seq_taxonomy_assignments.qza'
tax_assignemnts[2]='Zenodo/Qiime/070_18S_denoised_seq_taxonomy_assignments.qza'

inpth_features[1]='Zenodo/Qiime/065_16S_merged_tab.qza'
inpth_features[2]='Zenodo/Qiime/065_18S_merged_tab.qza'

inpth_sequences[1]='Zenodo/Qiime/065_16S_merged_seq.qza'
inpth_sequences[2]='Zenodo/Qiime/065_18S_merged_seq.qza'

for i in "${!inpth_features[@]}"; do

  # check if files can be matched otherwise abort script because it would do more harm then good
  tabstump=$(basename "${inpth_features[$i]//_tab.qza/}")
  seqstump=$(basename "${inpth_sequences[$i]//_seq.qza/}")

  
  # echo "$tabstump"
  # echo "$seqstump"
  # echo "$trestump"
  
  if [ "$seqstump" == "$tabstump" ]; then
  
    # diagnostic only 
    echo "Sequence- and feature-, continuing..."
    
    # create path for output directory
    results_tmp=$(basename "${inpth_features[$i]}".qza)
    results_tmp=${results_tmp:4:-12}
    results_dir="$trpth/Zenodo/Qiime/085_"$results_tmp"_qiime_artefacts"
    # echo "$results_dir"
    mkdir -p "$results_dir"
    
    # Exporting Qiime 2 files
    printf "${bold}$(date):${normal} Exporting Qiime 2 files...\n"
    qiime tools export --input-path "$trpth"/"${inpth_features[$i]}" --output-path "$results_dir" && \
    qiime tools export --input-path "$trpth"/"${inpth_sequences[$i]}" --output-path "$results_dir" && \
    qiime tools export --input-path "$trpth"/"${tax_assignemnts[$i]}" --output-path "$results_dir" || \
    { echo "${bold}$(date):${normal} Qiime export failed" ; exit 1; }
    
    # Editing taxonomy file
    printf "${bold}$(date):${normal} Rewriting headers of taxonomy information (backup copy is kept)...\n"
    new_header='#OTUID  taxonomy    confidence' && \
    gsed -i.bak "1 s/^.*$/$new_header/" "$results_dir"/taxonomy.tsv || \
    { echo "${bold}$(date):${normal} Taxonomy Edit failed" ; exit 1; }
  
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
      -m "$trpth"/"${inpth_map[$i]}" \
      --observation-header OTUID,taxonomy,confidence \
      --sample-header sample-ID,USRCD,TYPE,RUN,SEQ,SITE,MSL,LATI,LONG,ELEV,SLPE,ASPC,DMF,COND,PH,TC,TN,TP,PHOSCO,CL,NO2,BR,NO3,PO4,SO4,NH4,P,K,CA,MG,ZN,B,S,CU,FE,MN,NA,AL,M3PSR,CECe,CAMEQ,MGMEQ,KMEQ,NAMEQ,BSESAT,CECCA,CECMG,CECK,CECNA,MUD,SAND,GRVL,MIN,MAX,MEAN,QPD,SO,GRSKW,IGS,KURT,SIO2,TIO2,AL2O3,FE2O3,MNO,MGO,CAO,NA2O,K2O,P2O5,SO3,CLPPM,QRTZ,PLAG,ORTH,AMPH,PYRO,GRNT,MGNTE,BIOT,CHLO,DOLO,CALC,HALI,APAT,BASSA,MUSC || { echo 'Metadata addition failed' ; exit 1; }
  
    # Exporting .biom file to .tsv
    printf "${bold}$(date):${normal} Exporting to .tsv file...\n"
    biom convert \
      -i "$results_dir"/features-tax-meta.biom \
      -o "$results_dir"/features-tax-meta.tsv \
      --to-tsv && \
    gsed -i.bak 's/#//' "$results_dir"/features-tax-meta.tsv \
    || { echo 'TSV export failed' ; exit 1; }
     
    # Summarize exported OTU tables
    # printf "${bold}$(date):${normal} Summarizing .tsv files...\n"
    #  "$trpth/Github/090_parse_otu_tables.R" \
    #  "$results_dir/features-tax-meta.tsv" \
    #  "$results_dir/features-tax-meta-feature-summary.txt" \
    #  "$results_dir/features-tax-meta-feature-histogram.png"

  else
  
    echo "Files pairs can't be matched, aborting."
    exit
  
  fi
  
done
