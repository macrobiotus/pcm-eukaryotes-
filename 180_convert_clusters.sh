#!/bin/bash

# 26.03.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Converting clustering results to biom files for Qiime 1 and
# network graphics.

# For debugging only
# ------------------ 
set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/AAD_combined"
    shpth="/workdir/pc683/AAD_combined"
    qiime() { qiime2cli "$@"; }
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
    shpth="$(dirname "$PWD")"
    cores='2'
fi

# Define input files
# ------------------
clust_tab[1]='Zenodo/Qiime/110_16S_097_cl_tab.qza'
clust_tab[2]='Zenodo/Qiime/110_18S_097_cl_tab.qza'

clust_seq[1]='Zenodo/Qiime/110_16S_097_cl_seq.qza'
clust_seq[2]='Zenodo/Qiime/110_18S_097_cl_seq.qza'

# classifiers from unclustered data 
#  - works only if biom tool accepts these
#  - they have more OTUs then the clustered data since they are from the 
#    unclustered tables
tax_map[1]='Zenodo/Qiime/100_16S_taxonomy.qza'
tax_map[2]='Zenodo/Qiime/100_18S_taxonomy.qza'

rooted_tree[1]='Zenodo/Qiime/160_16S_097_cl_tree_rooted.qza'
rooted_tree[2]='Zenodo/Qiime/160_18S_097_cl_tree_rooted.qza'

mapping[1]='Zenodo/Manifest/05_DAVIS_metadata.tsv'
mapping[2]='Zenodo/Manifest/05_DAVIS_metadata.tsv'

# Define output files files
# -------------------------
clust_exp[1]='Zenodo/Qiime/180_16S_097_cl_q1exp'
clust_exp[2]='Zenodo/Qiime/180_18S_097_cl_q1exp'

tree_exp[1]="180_16S_097_cl_tree_rooted.tre"
tree_exp[2]="180_18S_097_cl_tree_rooted.tre"

for ((i=1;i<=2;i++)); do
   printf "Exporting Qiime 2 files at $(date +"%T")...\n"
   qiime tools export "$trpth"/"${clust_tab[$i]}" --output-dir "$trpth"/"${clust_exp[$i]}" && \
   qiime tools export "$trpth"/"${clust_seq[$i]}" --output-dir "$trpth"/"${clust_exp[$i]}" && \
   qiime tools export "$trpth"/"${tax_map[$i]}" --output-dir "$trpth"/"${clust_exp[$i]}" && \
   unzip -p "$shpth"/"${rooted_tree[$i]}" > "$shpth"/"${clust_exp[$i]}"/"${tree_exp[$i]}" || { echo 'Qiime 2 export failed' ; exit 1; }

done

for ((i=1;i<=2;i++)); do
   printf "Modifying taxonomy file to match exported feature table at $(date +"%T") ...\n" && \
   new_header='#OTUID  taxonomy    confidence' && \
   sed -i.bak "1 s/^.*$/$new_header/" "$trpth"/"${clust_exp[$i]}"/taxonomy.tsv || { echo 'Taxonomy table edit failed' ; exit 1; }
done

for ((i=1;i<=2;i++)); do
   printf "Adding taxonomy information to .biom file at $(date +"%T") ...\n"
   biom add-metadata \
     -i "$shpth"/"${clust_exp[$i]}"/feature-table.biom \
     -o "$shpth"/"${clust_exp[$i]}"/features-tax.biom \
     --observation-metadata-fp "$shpth"/"${clust_exp[$i]}"/taxonomy.tsv \
     --observation-header OTUID,taxonomy,confidence \
     --sc-separated taxonomy || { echo 'Addition of taxonomy to biom table failed' ; exit 1; }
done

for ((i=1;i<=2;i++)); do
   printf "Adding metadata information to .biom file at $(date +"%T")...\n"
   biom add-metadata \
     -i "$shpth"/"${clust_exp[$i]}"/features-tax.biom \
     -o "$shpth"/"${clust_exp[$i]}"/features-tax-meta.biom \
     --sample-metadata-fp "$trpth"/"${mapping[$i]}" \
     --observation-header OTUID,taxonomy,confidence || { echo 'Addition of metadata to biom table failed' ; exit 1; }
done
