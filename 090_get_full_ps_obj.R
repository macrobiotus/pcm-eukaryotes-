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
tre_fpath = "/Users/paul/Documents/AAD_combined/Zenodo/Qiime/180_16S_097_cl_q1exp/180_16S_097_cl_tree_rooted.tre/tree.nwk"
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
tre_fpath = "/Users/paul/Documents/AAD_combined/Zenodo/Qiime/180_18S_097_cl_q1exp/180_18S_097_cl_tree_rooted.tre/tree.nwk"
seq_fpath = "/Users/paul/Documents/AAD_combined/Zenodo/Qiime/180_18S_097_cl_q1exp/dna-sequences.fasta"

# read data into R 
phsq <- import_biom (bim_fpath)
tre <- ape::read.tree(tre_fpath)
fas <- Biostrings::readDNAStringSet(seq_fpath)  

# construct object  
euk_phsq <- merge_phyloseq(phsq, tre, fas)
save(euk_phsq, file = "/Users/paul/Documents/AAD_combined/Zenodo/R/18S_physeq_obj.Rdata")

#' # Session info
#' 
#' The code and output in this document were tested and generated in the 
#' following computing environment:
#+ echo=FALSE
sessionInfo()
