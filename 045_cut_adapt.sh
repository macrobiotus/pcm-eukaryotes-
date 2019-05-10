#!/usr/bin/env bash

# 08.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Wrapper for Qiime cutadapt script

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
inpth[1]='Zenodo/Qiime/040_16S_import_run_1.qza'
inpth[2]='Zenodo/Qiime/040_16S_import_run_2.qza'
inpth[3]='Zenodo/Qiime/040_16S_import_run_3.qza'
inpth[4]='Zenodo/Qiime/040_16S_import_run_4.qza'
inpth[5]='Zenodo/Qiime/040_16S_import_run_5.qza'

inpth[6]='Zenodo/Qiime/040_18S_import_run_1.qza'
inpth[7]='Zenodo/Qiime/040_18S_import_run_2_a.qza'
inpth[8]='Zenodo/Qiime/040_18S_import_run_2_b.qza'
inpth[9]='Zenodo/Qiime/040_18S_import_run_3.qza'
inpth[10]='Zenodo/Qiime/040_18S_import_run_4.qza'
inpth[11]='Zenodo/Qiime/040_18S_import_run_5.qza'
inpth[12]='Zenodo/Qiime/040_18S_import_run_6.qza'


otpth[1]='Zenodo/Qiime/045_16S_trimmed_run_1.qza'
otpth[2]='Zenodo/Qiime/045_16S_trimmed_run_2.qza'
otpth[3]='Zenodo/Qiime/045_16S_trimmed_run_3.qza'
otpth[4]='Zenodo/Qiime/045_16S_trimmed_run_4.qza'
otpth[5]='Zenodo/Qiime/045_16S_trimmed_run_5.qza'

otpth[6]='Zenodo/Qiime/045_18S_trimmed_run_1.qza'
otpth[7]='Zenodo/Qiime/045_18S_trimmed_run_2_a.qza'
otpth[8]='Zenodo/Qiime/045_18S_trimmed_run_2_b.qza'
otpth[9]='Zenodo/Qiime/045_18S_trimmed_run_3.qza'
otpth[10]='Zenodo/Qiime/045_18S_trimmed_run_4.qza'
otpth[11]='Zenodo/Qiime/045_18S_trimmed_run_5.qza'
otpth[12]='Zenodo/Qiime/045_18S_trimmed_run_6.qza'


log[1]='Zenodo/Qiime/045_16S_trimmed_run_1.txt'
log[2]='Zenodo/Qiime/045_16S_trimmed_run_2.txt'
log[3]='Zenodo/Qiime/045_16S_trimmed_run_3.txt'
log[4]='Zenodo/Qiime/045_16S_trimmed_run_4.txt'
log[5]='Zenodo/Qiime/045_16S_trimmed_run_5.txt'

log[6]='Zenodo/Qiime/045_18S_trimmed_run_1.txt'
log[7]='Zenodo/Qiime/045_18S_trimmed_run_2_a.txt'
log[8]='Zenodo/Qiime/045_18S_trimmed_run_2_b.txt'
log[9]='Zenodo/Qiime/045_18S_trimmed_run_3.txt'
log[10]='Zenodo/Qiime/045_18S_trimmed_run_4.txt'
log[11]='Zenodo/Qiime/045_18S_trimmed_run_5.txt'
log[12]='Zenodo/Qiime/045_18S_trimmed_run_6.txt'


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


# run trimming script for 18S 
# ---------------------------

# 18S 
fwdcut[1]='GTACACACCGCCCGTC'
revcut[1]='TGATCCTTCTGCAGGTTCACCTAC'

adpfcut[1]='GTAGGTGAACCTGCAGAAGGATCA'
adprcut[1]='GACGGGCGGTGTGTAC'

for ((i=6;i<=12;i++)); do
    printf "Trimming 18S data from file \"$trpth/${inpth[$i]}\".\n"
    qiime cutadapt trim-paired \
        --i-demultiplexed-sequences "$trpth"/"${inpth[$i]}" \
        --p-cores "$cores" \
        --p-front-f "${fwdcut[1]}" \
        --p-front-r "${revcut[1]}" \
        --p-adapter-f "${adpfcut[1]}" \
        --p-adapter-r "${adprcut[1]}" \
        --p-error-rate 0.1 \
        --o-trimmed-sequences "$trpth"/"${otpth[$i]}" \
        --verbose | tee "$trpth"/"${log[$i]}"
done

# run trimming script for 16S 
# ---------------------------

# 16S
fwdcut[2]='AGAGTTTGATCMTGGCTCAG'
revcut[2]='GWATTACCGCGGCKGCTG'

adpfcut[2]='CAGCMGCCGCGGTAATWC'
adprcut[2]='CTGAGCCAKGATCAAACTCT'

for ((i=1;i<=5;i++)); do
    printf "Trimming 16S data from file \"$trpth/${inpth[$i]}\".\n"
    qiime cutadapt trim-paired \
        --i-demultiplexed-sequences "$trpth"/"${inpth[$i]}" \
        --p-cores "$cores" \
        --p-front-f "${fwdcut[2]}" \
        --p-front-r "${revcut[2]}" \
        --p-adapter-f "${adpfcut[2]}" \
        --p-adapter-r "${adprcut[2]}" \
        --p-error-rate 0.1 \
        --o-trimmed-sequences "$trpth"/"${otpth[$i]}" \
        --verbose | tee "$trpth"/"${log[$i]}"
done

