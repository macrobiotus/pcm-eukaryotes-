# **********************************************
# * Create, filter, and write Physloseq object *
# **********************************************
# 03-May-2020

# load packages
# =============
rm(list = ls(all.names = TRUE))
gc()

library("tidyverse")   # work using tibbles
library("qiime2R")     # various function to import Qiime2 data remotes::install_github("jbisanz/qiime2R")
library("phyloseq")    # handle Qiime 2 data in R =
library("microbiomeutilities") # get long data format - remotes::install_github("microsud/microbiomeutilities-shiny")


# import Phyloseq objects
# =======================
# https://rdrr.io/github/jbisanz/qiime2R/f/vignettes/vignette.Rmd

psob_raw <- qza_to_phyloseq (features = "table.qza", 
                             taxonomy = "taxonomy.qza",
                             metadata = "sample_metadata.tsv")

# filter Phyloseq objects
# =======================

# correct abundances
# ------------------

# subtract blanks
# ---------------

# select PCM samples
# -------------------


# consolidate on taxonomic level
# ------------------------------


# write files
# ===========

# Phyloseq object
# ---------------

# Long table
# -----------
# https://rdrr.io/github/microsud/microbiomeutilities-shiny/man/phy_to_ldf.html
