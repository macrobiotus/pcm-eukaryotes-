# 06.02.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

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
    thrds='2'
fi

# define input and output locations
# --------------------------------
wdir[1]='Zenodo/Classifier'
wdir[2]='Zenodo/Classifier'

qdir[1]='Zenodo/Qiime'
qdir[2]='Zenodo/Qiime'

# input files
# ------------
clssf[1]="085_16S_classifier.qza"
clssf[2]="095_18S_classifier.qza"

repset[1]="065_16S_merged_seq.qza"
repset[2]="065_18S_merged_seq.qza"

# output files
# ------------
tax[1]="100_16S_taxonomy.qza"
taxv[1]="100_16S_taxonomy.qzv"

tax[2]="100_18S_taxonomy.qza"
taxv[2]="100_18S_taxonomy.qzv"

# Run scripts
# ------------
for ((i=1;i<=2;i++)); do
  qiime feature-classifier classify-sklearn \
    --i-classifier "$trpth"/"${wdir[$i]}"/"${clssf[$i]}" \
    --i-reads "$trpth"/"${qdir[$i]}"/"${repset[$i]}" \
    --o-classification "$trpth"/"${qdir[$i]}"/"${tax[$i]}" \
    --p-n-jobs "$thrds" \
    --verbose
done

for ((i=1;i<=2;i++)); do
  qiime metadata tabulate \
    --m-input-file "$trpth"/"${qdir[$i]}"/"${tax[$i]}" \
    --o-visualization "$trpth"/"${qdir[$i]}"/"${taxv[$i]}"
done
