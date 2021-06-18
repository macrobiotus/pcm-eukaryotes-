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


library(spocc)      # https://github.com/ropensci/spocc 
                    # https://docs.ropensci.org/spocc/

library(scrubr)     # data cleaning - unused  

library("maps")     # for maps - maps
library("ggrepel")  # for maps - labels



# load data
# =========

# get relevant species 
euks <- readRDS(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_uniq_sign_species.Rdata")


# clean data
# ===========

# check vector
euks$species

# erase all that may come after "sp." if there is an "sp." at all
euks %<>% mutate(species = gsub("sp\\..*", "sp.", species))
euks %>% pull(species) # check results

# in strings with more then three white spaces delet all after that 
# try with https://spannbaueradam.shinyapps.io/r_regex_tester/
euks %<>% mutate(species = gsub("cf. ", "", species))
euks %<>% mutate(species = str_replace(species, "\\s\\S*\\s\\S*(.*)", ""))
euks %>% pull(species) # 173 records

# query names using occ https://rdrr.io/cran/spocc/man/occ.html
# also see ?occ()
euk_occ_raw <- occ(query = (euks %>% pull(species)),
                   from = c("gbif",  "bison", "inat", "ebird", "vertnet"),
                   limit = 5,
                   start = NULL,
                   page = NULL,
                   geometry = NULL,
                   has_coords = TRUE,
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

euk_occ_df <- occ2df(euk_occ_raw)

# https://spannbaueradam.shinyapps.io/r_regex_tester/
euk_occ_df %<>% mutate(name = str_match(name, "\\S*\\s\\S*"))
euk_occ_df %>% distinct(name) %>% print(n = Inf) # 114 records

# continue here after 18-Jun-2021:  save workspace and clean results

#   round gps coordinates to 5th decimal degrees (accurate to 1.11 meter at the equator)
#   de-duplicate rounded table suing fields name longitude  latitude  prov 

                                   
worldmap <- ggplot2::map_data("world")

ggplot() +
  geom_polygon(data = worldmap, aes(x = long, y = lat,  group = group), fill="grey", alpha=0.3) +
  geom_point( data=euk_occ_df, aes(x = as.numeric(longitude), y = as.numeric(latitude))) +
  geom_label_repel( data=euk_occ_df, aes(x = as.numeric(longitude), y = as.numeric(latitude), label = name), 
                    max.iter = 100000, max.time = 10) +
  theme_linedraw()



