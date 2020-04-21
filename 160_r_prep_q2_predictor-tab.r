# *********************************************************
# * Combine and correct sample descriptors and predictors *
# ********************************************************* 
# 20-Apr-2020

# load packages
# --------------
rm(list = ls(all.names = TRUE))
gc()
library("tidyverse")  # work using tibbles
library("readxl")

# load sample descriptions
# ------------------------

p_mtd <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/200420_18S_MF_corrected.xlsx"

tib_mtd <- read_excel(p_mtd) %>%
  mutate_at(vars(SampleID, BarcodeSequence, LinkerPrimerSequence, TmplHash,  LibContent, SardiID,  XtrOri, XtrContent, Location, Loci, Description ), factor) 
  
tib_mtd$LongDEC <- as.numeric(tib_mtd$LongDEC)
tib_mtd$LatDEC <- as.numeric(tib_mtd$LatDEC)

# test 
print.data.frame(tib_mtd)

# load predictor tables 
# ----------------------
# also set types and NA strings

p_atp <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200419_pcm_atp.csv"
p_che <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200419_pcm_csbp.csv"
p_geo <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200419_pcm_geog.csv"
p_xrd <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200419_pcm_xrd.csv"

tib_atp <- read_csv(p_atp,
  col_types = cols(.default = "d",  "SHA" = col_factor()),
  na = c("", "NA", "<NA>")
  )

tib_che <- read_csv(p_che,
  col_types = cols(.default = "d", "SHA" = col_factor(), "COLR" = col_factor(), "GRAVL" = col_factor()),
  na = c("", "NA", "<NA>")
  )

tib_geo <- read_csv(p_geo,
  col_types = cols(.default = "d", "SHA" = col_factor(), "ASPECT" = col_factor()),
  na = c("", "NA", "<NA>")
  )

tib_xrd <- read_csv(p_xrd,
  col_types = cols(.default = "d", "SHA" = col_factor()),
  na = c("", "NA", "<NA>")
  )

tib_xrd %>% 
  mutate(row_sum = rowSums(select(., names(tib_xrd), -SHA))) %>% 
  mutate_at(vars(names(tib_xrd), -SHA), ~ ./row_sum) %>% 
  select(-row_sum) %>% 
  print.data.frame()

# merge tables, using hash keys
# -----------------------------

# testing for missing data 
print.data.frame(anti_join(tib_mtd, tib_atp, by = c("XtrContent" = "SHA")))
print.data.frame(anti_join(tib_mtd, tib_che, by = c("XtrContent" = "SHA")))
print.data.frame(anti_join(tib_mtd, tib_geo, by = c("XtrContent" = "SHA")))
print.data.frame(anti_join(tib_mtd, tib_xrd, by = c("XtrContent" = "SHA")))

tib_compl <- tib_mtd %>%
  left_join(tib_che, by = c("XtrContent" = "SHA")) %>%
  left_join(tib_atp, by = c("XtrContent" = "SHA")) %>%
  left_join(tib_xrd, by = c("XtrContent" = "SHA")) %>%
  left_join(tib_geo, by = c("XtrContent" = "SHA")) %>%
  mutate_at(vars(XtrContent), factor)


# format predictor tables 
# ----------------------

# re-scale xrd values to yield a column sum of 1
tib_compl <- tib_compl %>% 
  mutate(row_sum = rowSums(select(., names(tib_xrd)[2:9]))) %>% 
  mutate_at(vars(names(tib_xrd)[2:9]), ~ ./row_sum) %>% 
  select(-row_sum) %>% arrange(SampleID)

# write_merged tables
# ----------------------

p_compl <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/210421_18S_MF_merged.txt"
write_tsv(tib_compl, p_compl, append = FALSE, col_names = TRUE)
