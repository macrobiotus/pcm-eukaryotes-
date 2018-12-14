#!/bin/bash

# 26.03.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
#   "Given a feature table and the associated feature sequences, cluster the
#   features based on user-specified percent identity threshold of their
#   sequences. This is not a general-purpose de novo clustering method, but
#   rather is intended to be used for clustering the results of quality-
#   filtering/dereplication methods, such as DADA2, or for re-clustering a
#   FeatureTable at a lower percent identity than it was originally clustered
#   at. When a group of features in the input table are clustered into a
#   single feature, the frequency of that single feature in a given sample is
#   the sum of the frequencies of the features that were clustered in that
#   sample. Feature identifiers and sequences will be inherited from the
#   centroid feature of each cluster. See the vsearch documentation for
#   details on how sequence clustering is performed."

# For debugging only
# ------------------ 
set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/AAD_combined"
    thrds="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_combined"
    qiime2cli() { qiime "$@" ; }
    thrds='2'
fi

# Define input locations
# ----------------------
in_tab[1]='Zenodo/Qiime/065_16S_merged_tab.qza'
in_seq[1]='Zenodo/Qiime/065_16S_merged_seq.qza'

in_tab[2]='Zenodo/Qiime/065_18S_merged_tab.qza'
in_seq[2]='Zenodo/Qiime/065_18S_merged_seq.qza'

# Define parameters and output locations
# --------------------------------------

cluster[1]='0.97'
cluster[2]='0.97'

clust_tab[1]='Zenodo/Qiime/110_16S_097_cl_tab.qza'
clust_seq[1]='Zenodo/Qiime/110_16S_097_cl_seq.qza'

clust_tab[2]='Zenodo/Qiime/110_18S_097_cl_tab.qza'
clust_seq[2]='Zenodo/Qiime/110_18S_097_cl_seq.qza'

# stoutlog[1]='Zenodo/Qiime/110_16S_cluster_stout.txt'
# sterrlog[1]='Zenodo/Qiime/110_16S_cluster_sterr.txt'

# stoutlog[2]='Zenodo/Qiime/110_18S_cluster_stout.txt'
# sterrlog[2]='Zenodo/Qiime/110_18S_cluster_sterr.txt'

# Run scripts
# ------------
for ((i=1;i<=2;i++)); do
  qiime vsearch cluster-features-de-novo \
    --p-threads "$thrds" \
    --i-sequences "$trpth"/"${in_seq[$i]}" \
    --i-table "$trpth"/"${in_tab[$i]}" \
    --p-perc-identity "${cluster[$i]}" \
    --o-clustered-table "$trpth"/"${clust_tab[$i]}" \
    --o-clustered-sequences "$trpth"/"${clust_seq[$i]}" \
    --verbose
    # | > >(tee -a "$trpth"/"${stoutlog[$i]}") 2> >(tee -a "$trpth"/"${sterrlog[$i]}" >&2)
done
