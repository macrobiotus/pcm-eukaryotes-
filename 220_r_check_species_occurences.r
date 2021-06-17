# ***************************************************************
# * Check occurrence record of significant Antarctic eukaryotes *
# ***************************************************************
# 17-Jun-20201

rm(list = ls(all.names = TRUE))
gc()

# load packages
# =============

library(tidyverse)  # en vogue
library(magrittr)   # more pipes


library(spocc)   # https://github.com/ropensci/spocc 
                 # https://docs.ropensci.org/spocc/

library(scrubr)  # data cleaning  


# load data
# =========

# get relevant species 
euks <- readRDS(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_uniq_sign_species.Rdata")


# clean data
# ===========

euks$species

# rease all that may come after "sp." if there is an "sp." at all
euks %<>% mutate(species = gsub("sp\\..*", "sp.", species))

# in strings with more then three whitespaces keep everything before that
euks 

euks %>% pull(species)

# query names using occ https://rdrr.io/cran/spocc/man/occ.html

occ(query = NULL,
    from = "gbif",
    limit = 500,
    start = NULL,
    page = NULL,
    geometry = NULL,
    has_coords = NULL,
    ids = NULL,
    date = NULL,
    callopts = list(),
    gbifopts = list(),
    bisonopts = list(),
    inatopts = list(),
    ebirdopts = list(),
    vertnetopts = list(),
    idigbioopts = list(),
    obisopts = list(),
    alaopts = list(),
    throw_warnings = TRUE
)