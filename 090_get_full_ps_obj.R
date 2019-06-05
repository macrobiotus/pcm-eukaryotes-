#' ---
#' title: "Importing complete Phyloseq objects."
#' author: "Paul Czechowski"
#' date: "Jun 5, 2019"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' ---

#' This code commentary is included in the R code itself and can be rendered at
#' any stage using  `rmarkdown::render ("/Users/paul/Documents/AAD_combined/Github/090_get_full_ps_obj.R")`.
#' (The path may have to be adjusted.)
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.
#'
#' # Prepare Environment
#'
#' ## Empty Buffer

rm(list=ls())

#' ## Load Packages

library("ape")          # read tree file
library("Biostrings")   # read fasta file
library("phyloseq")     # filtering and utilities for such objects
library("data.table")   # fast and convenient handling of large tables
library("tidyverse")    # useful, but mainly loading for `dplyr`
library("data.table")

#' # Construct 16S Object  
#'
#' ## Set Paths

bim_fpath = "/Users/paul/Documents/AAD_combined/Zenodo/Qiime/085_16S_merged_qiime_artefacts/features-tax-meta.biom" 
# tre_fpath = ""
seq_fpath = "/Users/paul/Documents/AAD_combined/Zenodo/Qiime/085_16S_merged_qiime_artefacts/dna-sequences.fasta"

#' ## Import
 
phsq <- import_biom (bim_fpath)
# tre <- ape::read.tree(tre_fpath)
fas <- Biostrings::readDNAStringSet(seq_fpath)  

#' ## Construct Object and Export

bak_phsq <- merge_phyloseq(phsq, tre, fas)
save(bak_phsq, file = "/Users/paul/Documents/AAD_combined/Zenodo/R/16S_physeq_obj.Rdata")

#' # Construct 18S Object  
#'
#' ## Set Paths

bim_fpath = "/Users/paul/Documents/AAD_combined/Zenodo/Qiime/085_18S_merged_qiime_artefacts/features-tax-meta.biom" 
# tre_fpath = ""
seq_fpath = "/Users/paul/Documents/AAD_combined/Zenodo/Qiime/085_18S_merged_qiime_artefacts/dna-sequences.fasta"

#' ## Import

phsq <- import_biom (bim_fpath)
# tre <- ape::read.tree(tre_fpath)
fas <- Biostrings::readDNAStringSet(seq_fpath)  

#' ## Construct Object and Export

euk_phsq <- merge_phyloseq(phsq, tre, fas)
save(euk_phsq, file = "/Users/paul/Documents/AAD_combined/Zenodo/R/18S_physeq_obj.Rdata")

#' # Session info
#' 
#' The code and output in this document were tested and generated in the 
#' following computing environment:
#+ echo=FALSE
sessionInfo()
