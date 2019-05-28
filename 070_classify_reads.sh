#!/usr/bin/env bash

# 28.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
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
# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/AAD_combined"
    cores='40'
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_combined"
    cores='2'
fi

# database files - SILVA128 extended with Sanger sequences
# ---------------------------------------------------------

# import from
refdbseq="Zenodo/References/Silva128_extract_extended/99_otus_18S.fasta"
refdbtax="Zenodo/References/Silva128_extract_extended/majority_taxonomy_7_levels.txt"

# export to 
qiime_import_seq="Zenodo/Qiime/075_Silva128_Qiime_sequence_import.qza"
qiime_import_tax="Zenodo/Qiime/075_Silva128_Qiime_taxonomy_import.qza"


# query and assignment files
# --------------------------

# check these sequences against reference data
query="Zenodo/Qiime/065_18S_denoised_seq.qza"

# write taxonomic assignments to this file
tax_assignemnts='Zenodo/Qiime/075_18S_denoised_seq_taxonomy_assignment.qza'

# rolling log
qiime_assign_log="Zenodo/Qiime/075_18S_denoised_seq_taxonomy_assignment.txt"

# Run scripts
# ------------

printf "Importing reference sequences into Qiime...\n"
qiime tools import \
  --input-path  "$trpth"/"$refdbseq"   \
  --output-path "$trpth"/"$qiime_import_seq"    \
  --type 'FeatureData[Sequence]' || { echo 'Reference data import failed' ; exit 1; }

printf "Importing reference taxonomy into Qiime...\n"
qiime tools import \
  --input-path  "$trpth"/"$refdbtax" \
  --output-path "$trpth"/"$qiime_import_tax" \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat || { echo 'Taxonomy import failed' ; exit 1; }

printf "Running Vsearch Classifier...\n"
  qiime feature-classifier classify-consensus-vsearch \
    --i-query              "$trpth"/"$query" \
    --i-reference-reads    "$trpth"/"$qiime_import_seq" \
    --i-reference-taxonomy "$trpth"/"$qiime_import_tax" \
    --p-maxaccepts 1 \
    --p-perc-identity 0.875 \
    --p-min-consensus 0.51 \
    --p-query-cov 0.9 \
    --p-threads "$cores" \
    --o-classification "$trpth"/"$tax_assignemnts" \
    --verbose 2>&1 | tee -a "$trpth"/"$qiime_assign_log" || { echo 'Taxonomy assigment failed' ; exit 1; }
