#!/usr/bin/env bash

# 01.08.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================

# activate Qiime manually 
# -----------------------
# export LC_ALL=en_US.utf-8
# export LANG=en_US.utf-8
# export PATH=/programs/miniconda3/bin:$PATH
# source activate qiime2-2019.1

# For debugging only
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

# database files
# --------------

# SILVA132 (99% clustered - 18S)
refdbseq[1]='Zenodo/Reference/Silva132_18S/silva_132_99_18S.fna'
refdbtax[1]='Zenodo/Reference/Silva132_18S/majority_taxonomy_7_levels.txt'

# SILVA132 (99% clustered - 16S)
refdbseq[2]='Zenodo/Reference/Silva132_16S/silva_132_99_16S.fna'
refdbtax[2]='Zenodo/Reference/Silva132_16S/majority_taxonomy_7_levels.txt'

# export to 
# ---------
qiime_import_seq[1]="Zenodo/Qiime/070_Silva132_18S_Qiime_sequence_import.qza"
qiime_import_tax[1]="Zenodo/Qiime/070_Silva132_18S_Qiime_taxonomy_import.qza"

qiime_import_seq[2]="Zenodo/Qiime/070_Silva132_16S_Qiime_sequence_import.qza"
qiime_import_tax[2]="Zenodo/Qiime/070_Silva132_16S_Qiime_taxonomy_import.qza"

# query and assignment files
# --------------------------

# check these sequences against reference data
query[1]="Zenodo/Qiime/065_18S_merged_seq.qza"
query[2]="Zenodo/Qiime/065_16S_merged_seq.qza"

# write taxonomic assignments to this file
tax_assignemnts[1]='Zenodo/Qiime/070_18S_denoised_seq_taxonomy_assignments.qza'
tax_assignemnts[2]='Zenodo/Qiime/070_16S_denoised_seq_taxonomy_assignments.qza'

# rolling log
qiime_assign_log[1]='Zenodo/Qiime/070_18S_denoised_seq_taxonomy_assignments_log.txt'
qiime_assign_log[2]='Zenodo/Qiime/070_16S_denoised_seq_taxonomy_assignments_log.txt'

# Run scripts
# ------------

for i in "${!query[@]}"; do
  
  if [ ! -f "$trpth"/"${qiime_import_seq[$i]}" ]; then

    printf "\n${bold}$(date):${normal} Importing reference sequences into Qiime...\n"
    qiime tools import \
      --input-path  "$trpth"/"${refdbseq[$i]}" \
      --output-path "$trpth"/"${qiime_import_seq[$i]}" \
      --type 'FeatureData[Sequence]' || { echo 'Reference data import failed' ; exit 1; }
  
  fi
  
  if [ ! -f "$trpth"/"${qiime_import_tax[$i]}" ]; then
  
    printf "\n${bold}$(date):${normal} Importing reference taxonomy into Qiime...\n"
    qiime tools import \
      --input-path  "$trpth"/"${refdbtax[$i]}" \
      --output-path "$trpth"/"${qiime_import_tax[$i]}" \
      --type 'FeatureData[Taxonomy]' \
      --input-format HeaderlessTSVTaxonomyFormat || { echo 'Taxonomy import failed' ; exit 1; }
  
  fi

done

printf "\n${bold}$(date):${normal} Running Vsearch Classifier on 18S data...\n"
qiime feature-classifier classify-consensus-vsearch \
  --i-query              "$trpth"/"${query[1]}" \
  --i-reference-reads    "$trpth"/"${qiime_import_seq[1]}" \
  --i-reference-taxonomy "$trpth"/"${qiime_import_tax[1]}" \
  --p-maxaccepts 1 \
  --p-perc-identity 0.875 \
  --p-min-consensus 0.51 \
  --p-query-cov 0.75 \
  --p-threads "$cores" \
  --o-classification "$trpth"/"${tax_assignemnts[1]}" \
  --verbose 2>&1 | tee -a "$trpth"/"${qiime_assign_log[1]}" || { echo 'Taxonomy assigment failed' ; exit 1; }

printf "\n${bold}$(date):${normal} Running Vsearch Classifier on 16S data...\n"
qiime feature-classifier classify-consensus-vsearch \
  --i-query              "$trpth"/"${query[2]}" \
  --i-reference-reads    "$trpth"/"${qiime_import_seq[2]}" \
  --i-reference-taxonomy "$trpth"/"${qiime_import_tax[2]}" \
  --p-maxaccepts 1 \
  --p-perc-identity 0.97 \
  --p-min-consensus 0.51 \
  --p-query-cov 0.75 \
  --p-threads "$cores" \
  --o-classification "$trpth"/"${tax_assignemnts[2]}" \
  --verbose 2>&1 | tee -a "$trpth"/"${qiime_assign_log[2]}" || { echo 'Taxonomy assigment failed' ; exit 1; }
