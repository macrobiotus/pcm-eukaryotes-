#!/bin/bash

# 25.03.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/AAD_Davis_station"
    thrds='14'
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_Davis_station"
    qiime2cli() { qiime "$@" ; }
    thrds='1'
fi

# define input and output locations
# --------------------------------
wdir="Zenodo/Classifier"
mkdir -p "$trpth"/"$wdir"

# primers
# -------
# 16S_Foward (27F, Read 1 Primer)
p27F='AGAGTTTGATCMTGGCTCAG'

# 16S_Reverse (519R, Read 2 Primer) 
p519R='GWATTACCGCGGCKGCTG'

# database files - GreenGeenes 13.8
# ---------------------------------
taxdbseq="/Users/paul/Sequences/References/gg_13_8_otus/rep_set/99_otus.fasta"
taxdbmed="/Users/paul/Sequences/References/gg_13_8_otus/taxonomy/99_otu_taxonomy.txt"

# target files
# ------------
seqf="085_16S_otus.qza"
taxf="085_16S_ref-taxonomy.qza"
refseq="085_16S_ref-seqs.qza"
clssf="085_16S_classifier.qza"

# Run scripts
# ------------
printf "Importing 16S reference sequences into Qiime...\n"
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path "$taxdbseq" \
  --output-path "$trpth"/"$wdir"/"$seqf"

printf "Importing 16S reference taxonomy into Qiime...\n"
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --source-format HeaderlessTSVTaxonomyFormat \
  --input-path "$taxdbmed" \
  --output-path "$trpth"/"$wdir"/"$taxf"

printf "Extracting 16S reference reads from database, using primers...\n"
qiime feature-classifier extract-reads \
  --i-sequences "$trpth"/"$wdir"/"$seqf" \
  --p-f-primer "$p27F" \
  --p-r-primer "$p519R"\
  --p-trunc-len 800 \
  --o-reads "$trpth"/"$wdir"/"$refseq"

printf "Training 16S classifier...\n"  
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads "$trpth"/"$wdir"/"$refseq" \
  --i-reference-taxonomy "$trpth"/"$wdir"/"$taxf" \
  --o-classifier "$trpth"/"$wdir"/"$clssf"

# ring the bell - script is done
printf '\7'
