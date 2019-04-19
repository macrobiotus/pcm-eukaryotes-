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
    trpth="/data/AAD_combined"
    thrds='14'
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_combined"
    qiime2cli() { qiime "$@" ; }
    thrds='2'
fi

# define input and output locations
# --------------------------------
wdir="Zenodo/Classifier"
mkdir -p "$trpth"/"$wdir"

# primers
# -------
# 18S_Forward (1391f, Read 1 Primer)
p1391f='GTACACACCGCCCGTC'

# 18S_Reverse (EukBr, Read 2 Primer) 
pEukBr='TGATCCTTCTGCAGGTTCACCTAC'

# database files - SILVA128
# -------------------------
taxdbseq="/Users/paul/Sequences/References/SILVA_128_QIIME_release/rep_set/rep_set_18S_only/99/99_otus_18S.fasta"
taxdbmed="/Users/paul/Sequences/References/SILVA_128_QIIME_release/taxonomy/18S_only/99/majority_taxonomy_7_levels.txt"

# target files
# ------------
seqf="095_18S_otus.qza"
taxf="095_18S_ref-taxonomy.qza"
refseq="095_18S_ref-seqs.qza"
clssf="095_18S_classifier.qza"

# Run scripts
# ------------
printf "Importing reference sequences into Qiime...\n"
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path "$taxdbseq" \
  --output-path "$trpth"/"$wdir"/"$seqf"

printf "Importing reference taxonomy into Qiime...\n"
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path "$taxdbmed" \
  --output-path "$trpth"/"$wdir"/"$taxf"

printf "Extracting reference reads from database, using primers...\n"
qiime feature-classifier extract-reads \
  --i-sequences "$trpth"/"$wdir"/"$seqf" \
  --p-f-primer "$p1391f" \
  --p-r-primer "$pEukBr"\
  --p-trunc-len 600 \
  --o-reads "$trpth"/"$wdir"/"$refseq"

printf "Training classifier...\n"  
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads "$trpth"/"$wdir"/"$refseq" \
  --i-reference-taxonomy "$trpth"/"$wdir"/"$taxf" \
  --o-classifier "$trpth"/"$wdir"/"$clssf"

# ring the bell - script is done
printf '\7'
