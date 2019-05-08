#!/bin/bash

# 08.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Wrapper for Qiime cutadapt script


#############DRAFT!!!!!!!!!!!!!!!!#################

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/AAD_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/AAD_combined"
    cores='2'
fi

# Defining paths
# --------------
# input file array - ordered ascending by size of input files - check README
inpth[1]='Zenodo/Qiime/020_16S_ridge.qza'
inpth[2]='Zenodo/Qiime/020_18S_ridge.qza'

otpth[1]='Zenodo/Qiime/030_16S_ridge-trimmed.qza'
otpth[2]='Zenodo/Qiime/030_18S_ridge-trimmed.qza'

log[1]='Zenodo/Qiime/030_16S_ridge-trimmed.txt'
log[2]='Zenodo/Qiime/030_18S_ridge-trimmed.txt'


# Defining sequences to be cut out - as per email
# ==============================================
# 
# 16S_Foward (27F, Read 1 Primer)
# 1. Forward primer pad
# 2. Forward primer linker
# 3. Forward primer
# 
# TATGGCGAGT GA 5'-AGAGTTTGATCMTGGCTCAG-3'
# 
# 16S_Reverse (519R, Read 2 Primer) 
# 1. Reverse primer pad
# 2. Reverse primer linker
# 3. Reverse primer
# 
# AGTCAGTCAG GG 5'-GWATTACCGCGGCKGCTG-3'
#
# 18S_Forward (1391f, Read 1 Primer)
# 1.Forward primer pad
# 2.Forward primer linker
# 3.Forward primer
# 
# TATCGCCGTT CG 5'-GTACACACCGCCCGTC-3'
# 
# 18S_Reverse (EukBr, Read 2 Primer) 
# 1. Reverse primer pad
# 2. Reverse primer linker
# 3. Reverse primer
# 
# AGTCAGTCAG CA 5'-TGATCCTTCTGCAGGTTCACCTAC-3'

# 16S
fwdcut[1]='AGAGTTTGATCMTGGCTCAG'
revcut[1]='GWATTACCGCGGCKGCTG'

adpfcut[1]='CAGCMGCCGCGGTAATWC'
adprcut[1]='CTGAGCCAKGATCAAACTCT'

# 18S 
fwdcut[2]='GTACACACCGCCCGTC'
revcut[2]='TGATCCTTCTGCAGGTTCACCTAC'

adpfcut[2]='GTAGGTGAACCTGCAGAAGGATCA'
adprcut[2]='GACGGGCGGTGTGTAC'

# run trimming script
# -------------------
for ((i=1;i<=2;i++)); do
    qiime cutadapt trim-paired \
        --i-demultiplexed-sequences "$trpth"/"${inpth[$i]}" \
        --p-cores "$cores" \
        --p-front-f "${fwdcut[$i]}" \
        --p-front-r "${revcut[$i]}" \
        --p-adapter-f "${adpfcut[$i]}" \
        --p-adapter-r "${adprcut[$i]}" \
        --p-error-rate 0.1 \
        --o-trimmed-sequences "$trpth"/"${otpth[$i]}" \
        --verbose | tee "$trpth"/"${log[$i]}"
done
