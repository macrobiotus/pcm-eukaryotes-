#!/bin/bash

# 03.12.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Aligning sequences provided by Eden using MAFFT auto for
# subsequent tree building (intended purpose: get trees for
# manually constructed Phyloseq objects).
#
# For debugging only
# ------------------ 
# set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
# Script written on laptop - adjust hostnames accordingly
#   if necessary after moving file to other machine

if [[ "$HOSTNAME" != "Pauls-MacBook-Pro.local" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/AAD_Davis_station"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "Pauls-MacBook-Pro.local" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_Davis_station"
    qiime2cli() { qiime "$@" ; }
    cores='2'
fi

# Define input and output locations
# ---------------------------------
seqpth[1]='Eden/181004_16s_seq.fa'
seqpth[2]='Eden/181011_18s_seqs.fa'

algnpth[1]='Eden/181004_16s_seq_algn.fa'
algnpth[2]='Eden/181011_18s_seq_algn.fa'

treeid[1]='181118_16s_seq_tree'
treeid[2]='181118_18s_seq_tree'

# Run scripts
# ------------

# commented out, RAxML call had to be optimised
#
# for ((i=1;i<=2;i++)); do  
#  printf "Calculating alignment $i ...\n"
#  /programs/mafft/bin/mafft \
#    --thread -1 --auto "$trpth"/"${seqpth[$i]}" > "$trpth"/"${algnpth[$i]}" 
#  done  

for ((i=1;i<=2;i++)); do
  printf "Calculating tree $i ...\n"
  
  /programs/RAxML-8.2.12/raxmlHPC-PTHREADS-SSE3 -T "$cores" \
    -m GTRGAMMA -p 12345 -x 12345 -N autoMRE_IGN -s "$trpth"/"${algnpth[$i]}" -n "${treeid[$i]}"

done

