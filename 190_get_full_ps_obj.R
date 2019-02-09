#' ---
#' title: "Importing complete Phyloseq objects."
#' author: "Paul Czechowski"
#' date: "February 8, 2018"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' ---

#' This code commentary is included in the R code itself and can be rendered at
#' any stage using  `rmarkdown::render ("/Users/paul/Documents/AAD_combined/Github/200_import_to_phyloseq.R")`.
#' (The path may have to be adjusted.)
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.


# empty buffer
# ============
rm(list=ls())

# load packages
# =============
library("ape")          # read tree file
library("Biostrings")   # read fasta file
library("phyloseq")     # filtering and utilities for such objects
library("biomformat")   # perhaps unnecessary
library("data.table")   # fast and convenient handling of large tables
library("tidyverse")    # useful, but mainly loading for `dplyr`
library("data.table")

# functions
# =========

# none

# data read in 16S
# ================
# adjust these - perhaps use lists, too
bim_fpath = "/Users/paul/Documents/AAD_combined/Zenodo/Qiime/180_16S_097_cl_q1exp/features-tax-meta.biom" 
tre_fpath = "/Users/paul/Documents/AAD_combined/Zenodo/Qiime/180_16S_097_cl_q1exp/180_16S_097_cl_tree_rooted.tre"
seq_fpath = "/Users/paul/Documents/AAD_combined/Zenodo/Qiime/180_16S_097_cl_q1exp/dna-sequences.fasta"

# read data into R 
phsq <- import_biom (bim_fpath)
tre <- ape::read.tree(tre_fpath)
fas <- Biostrings::readDNAStringSet(seq_fpath)  

# construct object  
bak_phsq <- merge_phyloseq(phsq, tre, fas)
save(bak_phsq, file = "/Users/paul/Documents/AAD_combined/Zenodo/R/16S_physeq_obj.Rdata")

# data read in 18S
# =================
# adjust these - perhaps use lists, too
bim_fpath = "/Users/paul/Documents/AAD_combined/Zenodo/Qiime/180_18S_097_cl_q1exp/features-tax-meta.biom" 
tre_fpath = "/Users/paul/Documents/AAD_combined/Zenodo/Qiime/180_18S_097_cl_q1exp/180_18S_097_cl_tree_rooted.tre"
seq_fpath = "/Users/paul/Documents/AAD_combined/Zenodo/Qiime/180_18S_097_cl_q1exp/dna-sequences.fasta"

# read data into R 
phsq <- import_biom (bim_fpath)
tre <- ape::read.tree(tre_fpath)
fas <- Biostrings::readDNAStringSet(seq_fpath)  

# construct object  
euk_phsq <- merge_phyloseq(phsq, tre, fas)
save(euk_phsq, file = "/Users/paul/Documents/AAD_combined/Zenodo/R/18S_physeq_obj.Rdata")

# metadata preparation
# ====================

# metadata read-in
# -----------------

# using revised data here, but input path can be changed
md_path = "/Users/paul/Documents/AAD_combined/Eden/metadata_combined.csv"

# importing data
md <- fread(md_path, skip = "w")

# metadata formatting
# -------------------

# saving possibly syntactically incorrect metadata column headers prior to correction
md_namses_old <- names(md)

# correcting possibly syntactically incorrect metadata column headers in metadata
names(md) <- make.names(names(md), unique = FALSE, allow_ = TRUE)

# new data has empty lines, which need to be deleted
tokeep <- seq(2, nrow(md), 2)
md <- md[ tokeep ,]

# luckily, no more duplicates
which(duplicated(md$SampleID))

# The metadata sample ids (`md$SampleID`) need to be matched up with the 
#  sample ids of the Phyloseq objects (`sample_data(euk_phsq)$USRCD`). The
#  Phyloseq objects use use "-" instead of "/", ans the "/" is problematic
#  anyways. Hence replacing it.
md$SampleID <- gsub("/", "-", md$SampleID)

# getting sample date from Phyloseq object to Tibbles
# ---------------------------------------------------

# Getting tibbles from PS object for easier work with Tidyverse.
#   This should be written as function.
df_sd_euk <- data.frame(sample_data(euk_phsq))
df_sd_euk <- as.tibble(rownames_to_column(df_sd_euk, var = "ps_rowname"))
# 372 samples

# Getting tibbles from PS object for easier work with Tidyverse.
#   This should be written as function.
df_sd_bak <- data.frame(sample_data(bak_phsq))
df_sd_bak <- as.tibble(rownames_to_column(df_sd_bak, var = "ps_rowname"))
# 371 samples

# nothing is duplicated
which(duplicated(df_sd_euk$ps_rowname))
which(duplicated(df_sd_bak$ps_rowname))

# combining metadata from csv with metadata of Phyloseq objects
# --------------------------------------------------------------

# some samples have no metadata in the provided .csv
anti_join(df_sd_euk, md, by = c("USRCD" = "SampleID"), copy = TRUE, suffix = c(".x", ".y"))
anti_join(df_sd_bak, md, by = c("USRCD" = "SampleID"), copy = TRUE, suffix = c(".x", ".y"))

# Now matching up metadata sample ids (`md$SampleID`) with the 
#  sample ids of the Phyloseq object (`sample_data(euk_phsq)$USRCD` 
#  and `sample_data(bak_phsq)$USRCD`)
df_md_euk <- left_join(df_sd_euk, md, by = c("USRCD" = "SampleID"), copy = TRUE, suffix = c(".x", ".y"))
# 372 samples - as it should be - good.

df_md_bak <- left_join(df_sd_bak, md, by = c("USRCD" = "SampleID"), copy = TRUE, suffix = c(".x", ".y"))
# 372 samples - as it should be - good. 

# checking types and formatting of metadata
# =========================================
# - check column header names, also for duplicates
# - check variable types


# overwriting sample data slots in Phyloseq objects
# -------------------------------------------

# convert Tibble to DF to not get warned, setting row names, plugging to PS slot(s)
sample_data(bak_phsq) <- column_to_rownames( data.frame(df_md_bak), var = "ps_rowname")
sample_data(euk_phsq) <- column_to_rownames( data.frame(df_md_euk), var = "ps_rowname")

# check Phyloseq slots 
# ====================
# - check tree
# - check abundances
# - check zero count samples and OTUs


# safe fully annotated PS objects
# =================================

# the columns aren't very sorted yet, and the columns names of the csv aren't
#  checked yet, but this will do to test the subsequent step

save(bak_phsq, file = "/Users/paul/Documents/AAD_combined/Zenodo/R/bac_physeq_obj_full.Rdata")
save(euk_phsq, file = "/Users/paul/Documents/AAD_combined/Zenodo/R/euk_physeq_obj_full.Rdata")

#' # Session info
#' 
#' The code and output in this document were tested and generated in the 
#' following computing environment:
#+ echo=FALSE
sessionInfo()
