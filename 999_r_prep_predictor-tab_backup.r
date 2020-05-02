# *********************************************************
# * Combine and correct sample descriptors and predictors *
# ********************************************************* 
# 01-May-2020

# load packages
# =============
rm(list = ls(all.names = TRUE))
gc()
library("tidyverse")  # work using tibbles
library("readxl")     # read excel sheets
library("stringr")    # rename column names using dplyr
# library("bestNormalize") # automatic selection of normalisations function with ability built-in back-transform
                         # NA handling leaves desires
library("caret")       # Yeo-Johnson transformation

# library("purrr")
# library("tidyr")
# library("ggplot2")


# load sample descriptions
# =========================

p_mtd <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/200420_18S_MF_corrected.xlsx"

tib_mtd <- read_excel(p_mtd) %>%
  mutate_at(vars(SampleID, BarcodeSequence, LinkerPrimerSequence, TmplHash,  LibContent, SardiID,  XtrOri, XtrContent, Location, Loci, Description ), factor) 
  
tib_mtd$LongDEC <- as.numeric(tib_mtd$LongDEC)
tib_mtd$LatDEC <- as.numeric(tib_mtd$LatDEC)

# check for duplicates - there should be none
duplicated(tib_mtd$SampleID)

# test 
# print.data.frame(tib_mtd)

# load predictor tables 
# =====================
# also set types and NA strings

p_atp <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200419_pcm_atp.csv"
p_che <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200419_pcm_csbp.csv"
p_geo <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200419_pcm_geog.csv"
p_xrd <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200421_pcm_xrd.csv"
p_age <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200419_pcm_ages.csv"

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

tib_age <- read_csv(p_age,
  col_types = cols(.default = "d",  "SHA" = col_factor()),
  na = c("", "NA", "<NA>")
  )

# merge data tables, using hash keys
# ==================================

# testing for missing data 
print.data.frame(anti_join(tib_mtd, tib_atp, by = c("XtrContent" = "SHA")))
print.data.frame(anti_join(tib_mtd, tib_che, by = c("XtrContent" = "SHA")))
print.data.frame(anti_join(tib_mtd, tib_geo, by = c("XtrContent" = "SHA")))
print.data.frame(anti_join(tib_mtd, tib_xrd, by = c("XtrContent" = "SHA")))
print.data.frame(anti_join(tib_mtd, tib_age, by = c("XtrContent" = "SHA")))

# Chemical data: merge tables and check for duplicates  
tib_compl <- tib_mtd %>% left_join(tib_che, by = c("XtrContent" = "SHA")) 
  
# Chemical data: duplicates removed:
tib_compl  %>% 
  group_by(XtrContent) %>% filter(n() != 1) %>%
  arrange(XtrContent) %>% print.data.frame()
  
# ATP data: merge tables and check for duplicates  
tib_compl <- tib_compl %>% left_join(tib_atp, by = c("XtrContent" = "SHA"))

# ATP data: check for duplicates - looks ok
tib_compl  %>% 
  group_by(XtrContent) %>% filter(n() != 1) %>%
  arrange(XtrContent) %>% print.data.frame()  

# XRD data: merge tables and check for duplicates
tib_compl <- tib_compl %>% left_join(tib_xrd, by = c("XtrContent" = "SHA"))

# XRD data: check for duplicates - looks ok
tib_compl %>%
  group_by(XtrContent) %>% filter(n() != 1) %>%
  arrange(XtrContent) %>% print.data.frame()
    
# Geographic data: merge tables and check for duplicates
tib_compl <- tib_compl %>% left_join(tib_geo, by = c("XtrContent" = "SHA"))

# Geographic data: check for duplicates - looks ok
tib_compl %>%
  group_by(XtrContent) %>% filter(n() != 1) %>%
  arrange(XtrContent) %>% print.data.frame()

# Age data: merge tables and check for duplicates
tib_compl <- tib_compl %>% left_join(tib_age, by = c("XtrContent" = "SHA"))

# Age data: check for duplicates - looks ok
tib_compl %>%
  group_by(XtrContent) %>% filter(n() != 1) %>%
  arrange(XtrContent) %>% print.data.frame()

# correct types
tib_compl <- tib_compl %>%  mutate_at(vars(XtrContent, SampleID), factor)

# save intermediate state after import
save(tib_compl, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/160_soil-data_raw.Rdata")
save.image(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/160_soil-data_raw_image.Rdata")

# correcting raw data  
# ====================

# check xrd values
tib_compl %>% 
  mutate(row_sum = rowSums(select(., names(tib_xrd)[2:9]))) %>% 
  dplyr:::select(names(tib_xrd)[2:9], row_sum) %>% print.data.frame()

# re-scale xrd values to yield a column sum of 1, i.e. close data
#  after rounding errors in Excel
#  also: Some peak values were negative which doesn't make sense
#  need to set to NA or nee to check with Duanne White
#  for now just using the absolute value.

tib_compl <- tib_compl %>% 
  mutate_at(vars(names(tib_xrd)[2:9]), abs) %>% 
  mutate(row_sum = rowSums(select(., names(tib_xrd)[2:9]))) %>% 
  mutate_at(vars(names(tib_xrd)[2:9]), ~ ./row_sum) %>% 
  select(-row_sum) %>% arrange(SampleID)

# check xrd values
tib_compl %>% 
  mutate(row_sum = rowSums(select(., names(tib_xrd)[2:9]))) %>% 
  select(names(tib_xrd)[2:9], row_sum) %>% print.data.frame()

# plot all raw data
dev.new()
tib_compl %>% keep(is.numeric) %>%  gather() %>% 
  ggplot(aes(value)) + facet_wrap(~ key, scales = "free") + geom_histogram() + geom_density()

# transformation of xrd data for PCA and multivariate analysis  
# ===========================================================

# using Centred Log-Ratio transformation to remove closure effect of xrd data.
#  ird transformation is likely a better option, but not sure how to back-transform data:
#        Filzmoser, P., Hron, K., & Reimann, C. (2009). Principal component
#    analysis for compositional data with outliers. Environmetrics, 20(6),
#    621–632. https://doi.org/10.1002/env.966 Egozcue, J. J.,
#        Pawlowsky-Glahn, V., Mateu-Figueras, G., & Barceló-Vidal, C. (2003).
#    Isometric Logratio Transformations for Compositional Data Analysis.
#    Mathematical Geology, 35(3), 279–300.
#    https://doi.org/10.1023/A:1023818214614
# 
#  isolate relevant columns, and identifiers for later joining 
xrd <- tib_compl %>% dplyr:::select("SampleID", names(tib_xrd)[2:9]) %>% 
  data.frame(., row.names = .$"SampleID" ) 
xrd$"SampleID" <- NULL
#  convert to matrix, with row names for joing 
xrd <- data.matrix(xrd, rownames.force = TRUE) %>% as.matrix(.)
#  transform data 
xrd <- rgr:::clr(xrd) 

# merge xrd data  back with original data 

# convert data back to tibble 
xrd <- xrd %>% as_tibble(., rownames = "SampleID")

# left_join transformed data, drop old xrd cols, truncate names of transformed xrd cols
tib_compl <-  left_join(tib_compl, xrd, by = "SampleID", suffix = c(".raw", ".clr")) %>% 
  select(-contains(".raw")) %>% set_names(~stringr::str_replace_all(., ".clr", ""))

# transformation of all soil and xrd data for PCA and multivariate analysis  
# =========================================================================
# not using bestNormalize https://cran.r-project.org/web/packages/bestNormalize/vignettes/bestNormalize.html
#  http://www.rebeccabarter.com/blog/2017-11-17-caret_tutorial/
# consider using  package Caret to remove correlated variables, to introduce dummy variables for factors
#  and for Yeo Johnson transformation

#  https://topepo.github.io/caret/pre-processing.html
#  
# variables to be transformed
vrs <- c("LongDEC", "LatDEC", "TEXT", "AMMN", "NITR", "PHOS", "POTA",  "SULPH",
  "CARB", "COND", "PH_CACL", "PH_H2O", "RLU", "CHLORITE", "ELEVATION", "SLOPE", "AGE_KA",
  "QUARTZ", "FELDSPAR", "TITANITE", "GARNETS", "MICAS", "DOLOMITE", "KAOLCHLOR", "CALCITE")

# set non-field samples to NA for the variables listed above to exclude them form
#  preprocessing calculations
tib_compl <- tib_compl %>% mutate_at(vars(vrs), funs( ifelse(Description != "PCM", NA, .))) # %>% print.data.frame

# subset data for transformation 
tib_slc <- tib_compl %>% select("SampleID", vrs) %>% 
  data.frame(., row.names = .$"SampleID" ) 
tib_slc$"SampleID" <- NULL

# plot before transformation
dev.new()
tib_slc %>% keep(is.numeric) %>%  gather() %>% 
  ggplot(aes(value)) + facet_wrap(~ key, scales = "free") + geom_histogram()

# use Caret - get estimates
tib_slc_pp <- preProcess(tib_slc, method = c("center", "scale", "YeoJohnson", "nzv"))

# use Caret - apply estimates
sls_transformed <- predict(tib_slc_pp, newdata = tib_slc)

# plot after transformation
dev.new()
sls_transformed %>% keep(is.numeric) %>%  gather() %>% 
  ggplot(aes(value)) + facet_wrap(~ key, scales = "free") + geom_histogram()

# convert data back to tibble 
sls_transformed <- sls_transformed %>% as_tibble(., rownames = "SampleID")

# left_join transformed data, drop old xrd cols, truncate names of transformed xrd cols
tib_compl <-  left_join(tib_compl, sls_transformed, by = "SampleID", suffix = c(".raw_clr", ".yeo_nzv")) %>% 
  select(-contains(".raw_clr")) %>% set_names(~stringr::str_replace_all(., ".yeo_nzv", ""))
  
# correct types
tib_compl <- tib_compl %>%  mutate_at(vars(XtrContent, SampleID), factor)

# save intermediate state after transformations
save(tib_compl, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/160_soil-data_transformed.Rdata")
save.image(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/160_soil-data_transformed_image.Rdata")

# write_merged tables - for Qiime import
# --------------------------------------

p_compl <- tib_compl
p_compl <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/200501_18S_MF_merged.txt"
write_tsv(tib_compl, p_compl, append = FALSE, col_names = TRUE)
