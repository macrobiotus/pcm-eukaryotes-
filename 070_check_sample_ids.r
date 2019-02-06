# 06.02.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# check if metadata is complete and matches present samples


# empty buffer
# ============
rm(list=ls())

# load packages
# =============
library("data.table")   # fast and convenient handling of large tables
library("tidyverse")    # useful, but mainly loading for `dplyr`


# data read in 16S
# ================

# Path to combined metadate to be checked
# ----------------------------------------
mdc_p <- "/Users/paul/Documents/AAD_combined/Zenodo/Manifest/00_Davis_and_TheRidge_metdata_curated.csv"


# Path to The Ridge
# -----------------
r16m_p <- "/Users/paul/Documents/AAD_The_Ridge/Zenodo/Manifest/05_16S_manifest_sorted.txt"
r18m_p <- "/Users/paul/Documents/AAD_The_Ridge/Zenodo/Manifest/05_18S_manifest_sorted.txt"


# Path to Davis Station
# -------------
d18am_p <- "/Users/paul/Documents/AAD_Davis_station/Zenodo/Manifest/05_18S_manifest_agrf.txt"
d18bm_p <- "/Users/paul/Documents/AAD_Davis_station/Zenodo/Manifest/05_18S_manifest_rama_unsw.txt"
d18cm_p <- "/Users/paul/Documents/AAD_Davis_station/Zenodo/Manifest/05_18S_manifest_rama.txt"

d16am_p <- "/Users/paul/Documents/AAD_Davis_station/Zenodo/Manifest/05_16S_manifest_agrf.txt"
d16bm_p <- "/Users/paul/Documents/AAD_Davis_station/Zenodo/Manifest/05_16S_manifest_rama_unsw.txt"
d16cm_p <- "/Users/paul/Documents/AAD_Davis_station/Zenodo/Manifest/05_16S_manifest_rama.txt"

# Data read-in
# ------------
mdc <- readr:::read_csv(mdc_p)   # Davis and The Ridge metadata
r16m <- readr:::read_csv(r16m_p, skip = 1) # The Ridge 16S manifest
r18m <- readr:::read_csv(r18m_p, skip = 1) # The Ridge 18S manifest

d18am <- readr:::read_csv(d18am_p, skip = 1)
d18bm <- readr:::read_csv(d18bm_p, skip = 1)
d18cm <- readr:::read_csv(d18cm_p, skip = 1)

d16am <- readr:::read_csv(d16am_p, skip = 1)
d16bm <- readr:::read_csv(d16bm_p, skip = 1)
d16cm <- readr:::read_csv(d16cm_p, skip = 1)


# getting maifest-listed sample ids from manifests and from to-be-matched mapping file
# ===================================================================================

# manifest-compatible ids in combined metadata
# ---------------------------------------------
id_table <- data.frame("table_id" = mdc$`#SampleID`)

# The Ridge
# ---------
r16m_id <- data.frame( "r16m_id" = paste("a", r16m$`sample-id`, sep = "" )) # manifest-compatible ids in The Ridge Manifest 16S
r18m_id <- data.frame( "r18m_id" = paste("a", r18m$`sample-id`, sep = "" )) # manifest-compatible ids in The Ridge Manifest 18S

# Davis Station
# -------------
d18am_id <- data.frame("d18am_id" = d18am$`sample-id`)
d18bm_id <- data.frame("d18bm_id" = d18bm$`sample-id`)
d18cm_id <- data.frame("d18cm_id" = d18cm$`sample-id`)

d16am_id <- data.frame("d16am_id" = d16am$`sample-id`)
d16bm_id <- data.frame("d16bm_id" = d16bm$`sample-id`)
d16cm_id <- data.frame("d16cm_id" = d16cm$`sample-id`)

# combining all ids
# -----------------

all_ids <- full_join(id_table, r16m_id, by = c("table_id" = "r16m_id"))
all_ids <- full_join(all_ids, r18m_id, by = c("table_id" = "r18m_id"))

all_ids <- full_join(all_ids, d18am_id, by = c("table_id" = "d18am_id"))
all_ids <- full_join(all_ids, d18bm_id, by = c("table_id" = "d18bm_id"))
all_ids <- full_join(all_ids, d18cm_id, by = c("table_id" = "d18cm_id"))

all_ids <- full_join(all_ids, d16am_id, by = c("table_id" = "d16am_id"))
all_ids <- full_join(all_ids, d16bm_id, by = c("table_id" = "d16bm_id"))
all_ids <- full_join(all_ids, d16cm_id, by = c("table_id" = "d16cm_id"))

# un-duplication
# --------------
all_ids <- data.frame(table_id = all_ids[!duplicated(all_ids$table_id), ])

anti_join ( all_ids, id_table) 

# samples missing in metadata_table
#   a512A
#  BacMck
#  NoTmpl
# SoilDNA
#  FunMck

# Session info
# 
# The code and output in this document were tested and generated in the 
# following computing environment:
sessionInfo()
