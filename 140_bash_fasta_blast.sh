#!/usr/bin/env bash

# 16.04.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Blast fasta file against locally installed copy of NCBI nt database. See
#   https://stackoverflow.com/questions/45014279/running-locally-blastn-against-nt-db-thru-python-script.
# For array handling refer to
#   https://stackoverflow.com/questions/23356779/how-can-i-store-find-command-result-as-arrays-in-bash
#   https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash)
# If executed on cluster install reference db via script in "Transport" folder.
# As parser use  "http://sing-group.org/blasterjs/" and '-outfmt "0"' or '-outfmt "5"' 

# for debugging only
# ------------------ 
# set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "Pauls-MacBook-Pro.local" ]] && [[ "$HOSTNAME" != "macmini-fastpost.staff.uod.otago.ac.nz" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/OU_pcm_eukaryotes"
    cores="$(nproc --all)"
    # find parameters for cluster at
    #  https://biohpc.cornell.edu/lab/userguide.aspx?a=software&i=16#c
    export PATH=/programs/ncbi-blast-2.9.0+/bin:$PATH
    dbpath="/workdir/pc683/BLAST_NCBI/nt"
    # files will be there after running "../Transport/350_sync_ncbi_nt_to_scratch.sh"
    #  on cluster
elif [[ "$HOSTNAME" == "Pauls-MacBook-Pro.local" ]]  || [[ "$HOSTNAME" == "macmini-fastpost.staff.uod.otago.ac.nz" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/OU_pcm_eukaryotes"
    cores='3'
    dbpath="/Users/paul/Sequences/References/blastdb/nt"
fi


# Define input paths and parameters for blasting 
# ----------------------------------------------
# find all .fasta files incl. their paths and put them into an array

inpth_seq_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_seq_unsorted+=("$REPLY")

# testing query - comment in or out
# done < <(find "$trpth/Zenodo/Qiime" -name '105_18S_all_samples_subsampled_seq_clustered90_Vsearch_Metazoans_taxonomy_assignment_50.fasta.gz' -print0)

# general query - comment in or out
done < <(find "$trpth/Zenodo/Blast" -type f \( -name "*.fasta.gz" \) -print0)

# Sort array 
IFS=$'\n' inpth_seq=($(sort <<<"${inpth_seq_unsorted[*]}"))
unset IFS

# for debugging -  print sorted input filenames
# printf '%s\n' "${inpth_seq[@]}"

# loop over array of fasta files, create result file, call blast
# ----------------------------------------------------------------
for fasta in "${inpth_seq[@]}";do
  
  # create target file  names
  filename=$(dirname "$fasta")
  src_dir=$(basename "$fasta")
  tmp_file="140${src_dir:3}"
  # old call using complete data:
  # `tgt_file="${tmp_file%%.*}_blast_result.txt"`
  # for adjusted blast call 18.07.2019 using
  tgt_file="${tmp_file%%.*}_blast-noenv.xml"

  # for debugging only 
  # printf "$fasta\n"
  # printf "$trpth"/Zenodo/Blast/"$tgt_file.gz\n"
  
  if [ ! -f "$trpth"/Zenodo/Blast/"$tgt_file".gz ]; then
    #   Needed by parser "http://sing-group.org/blasterjs/" is '-outfmt "0"' or '-outfmt "5"'.
    # Diagnostic message
    printf "\nOn $(date) querying \"$fasta\" against \"$dbpath\"...\n" && \
    
    gzip -dc "$fasta" | \
      blastn \
        -db "$dbpath" \
        -task blastn \
        -evalue 1e-5 \
        -max_hsps 5 \
        -outfmt 5 \
        -max_target_seqs 5 \
        -out "$trpth"/Zenodo/Blast/"$tgt_file" \
        -num_threads "$cores" \
        -negative_gilist "$trpth"/Zenodo/Blast/190718_gi_list_environmental.txt && \
      printf "...on $(date) Blast finished writing to \"$trpth/Zenodo/Blast/$tgt_file\".\n" || \
      { printf "Blastn failed at $(date +"%T") on \"$fasta\". \n" ; exit 1; }
    printf "\nOn $(date) Compressing \"$trpth/Zenodo/Blast/$tgt_file\".\n"
    
    gzip -9 "$trpth"/Zenodo/Blast/"$tgt_file"
  
  fi
  
done
