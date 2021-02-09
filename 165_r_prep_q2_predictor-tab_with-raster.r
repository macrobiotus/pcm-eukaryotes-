# *********************************************************
# * Combine and correct sample descriptors and predictors *
# ********************************************************* 
# 09-Feb-2021

# load packages
# =============
rm(list = ls(all.names = TRUE))
gc()

library("tidyverse")  # work using tibbles
library("readxl")     # read excel sheets
library("stringr")    # rename column names using dplyr

library("raster")  # work with geographic raster data
library("sp")      # work with spatial points
# library("gstat")   # raster interpolation - unused



# load sample descriptions
# =========================

# formerly
# p_mtd <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/200420_18S_MF_corrected.xlsx"
# recently - with DNA concentration values for possiby better cleanup
p_mtd <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/200727_18S_MF.xlsx"

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
p_xrd <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200812_pcm_xrd.csv"
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
  mutate(row_sum = rowSums(select(., names(tib_xrd)[2:10]))) %>% 
  dplyr:::select(names(tib_xrd)[2:10], row_sum) %>% print.data.frame()

# re-scale xrd values to yield a column sum of 1, i.e. close data
#  after rounding errors in Excel now just using the absolute value.

tib_compl <- tib_compl %>% 
  mutate_at(vars(names(tib_xrd)[2:10]), abs) %>% 
  mutate(row_sum = rowSums(select(., names(tib_xrd)[2:10]))) %>% 
  mutate_at(vars(names(tib_xrd)[2:10]), ~ ./row_sum) %>% 
  select(-row_sum) %>% arrange(SampleID)

# check xrd values again - looking good
tib_compl %>% 
  mutate(row_sum = rowSums(select(., names(tib_xrd)[2:10]))) %>% 
  select(names(tib_xrd)[2:9], row_sum) %>% print.data.frame()

# save intermediate state after corrections
save(tib_compl, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/160_soil-data_corrected.Rdata")
save.image(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/160_soil-data_corrected_image.Rdata")

# older code above - can be kept 
#########################################

# Adding data from climate rasters 
# =================================

# import climate rasters and coordinates from data 
# -------------------------------------------------

# import the raster data and stack it
racmo_prc <- raster("/Users/paul/Quantarctica/Quantarctica3/Atmosphere/Van Wessem RACMO/RACMO_Precipitation_35km.tif")
racmo_wnd <- raster("/Users/paul/Quantarctica/Quantarctica3/Atmosphere/Van Wessem RACMO/RACMO_WindSpeed_10m_35km.tif")
racmo_tmp <- raster("/Users/paul/Quantarctica/Quantarctica3/Atmosphere/Van Wessem RACMO/RACMO_Temperature_2m_35km.tif")
racmo <- stack(racmo_prc,racmo_wnd, racmo_tmp ) 

# check data projection and plot
projection(racmo) 
par(mfrow=c(2,2))
plot(racmo_prc, main="RACMO Precipitation 35km")
plot(racmo_wnd, main="RACMO WindSpeed_10m 35km")
plot(racmo_tmp, main="RACMO Temperature_2m 35km")

# simplifying data structure for raster work 
fld_locs <- tib_compl %>% 
  dplyr::select(SampleID, Description, Location, LongDEC, LatDEC) %>% 
  filter(Description %in% "PCM")  %>%
  filter(Location %in% c("Lake_Terrasovoe", "Mawson_Escarpment", "Mount_Menzies")) 

# get spacial points data frame from data structure - set to EPSG 4326 - WGS 84
# set to WGS84 (EPSG: 4326) +init=epsg:4326 +proj=longlat+ellps=WGS84 +datum=WGS84 +no_defs+towgs84=0,0,0
fld_locs_spdf <- SpatialPointsDataFrame(fld_locs[,4:5], proj4string = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"), fld_locs)
projection(fld_locs_spdf) 

# re-project coordinates in pcm data frame to match raster 
# -------------------------------------------------------

# re-project points to match rasters
fld_locs_spdf_stere <- spTransform(fld_locs_spdf, crs(racmo))
projection(fld_locs_spdf_stere) 

# check if coordinates systems align by plotting
dev.new()
par(mfrow=c(2,2))
plot(racmo_prc, main="A: RACMO Precipitation 35km", interpolate=TRUE)
points(fld_locs_spdf_stere, pch=3, cex = 2 )
plot(racmo_wnd, main="B: RACMO WindSpeed 10m 35km")
points(fld_locs_spdf_stere, pch=3, cex = 2 )
plot(racmo_tmp, main="C: RACMO Temperature 2m 35km")
points(fld_locs_spdf_stere, pch=3, cex = 2 )
dev.copy(pdf,'/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots/210209_RACMO_selection_raw.pdf')
dev.off()


# resample raster for higher spatial resolution
# ------------------------------------------------

# check spatial resolution of data - it is quite coarse
dev.new()
par(mfrow=c(2,2))
zoom(racmo_prc, ext=fld_locs_spdf_stere, maxpixels=100000, layer=1, new=FALSE, useRaster=TRUE, main="A: RACMO Precipitation 35km (zoom)")
points(fld_locs_spdf_stere, pch=3, cex = 2)
plot(buffer(fld_locs_spdf_stere, width=20000), add=TRUE)

zoom(racmo_wnd, ext=fld_locs_spdf_stere, maxpixels=100000, layer=1, new=FALSE, useRaster=TRUE, main="B: RACMO WindSpeed 10m 35km (zoom)")
points(fld_locs_spdf_stere, pch=3, cex = 2 )
plot(buffer(fld_locs_spdf_stere, width=20000), add=TRUE)

zoom(racmo_tmp, ext=fld_locs_spdf_stere, maxpixels=100000, layer=1, new=FALSE, useRaster=TRUE, , main = "C: RACMO Temperature 2m 35km (zoom)")
points(fld_locs_spdf_stere, pch=3, cex = 2 )
plot(buffer(fld_locs_spdf_stere, width=20000), add=TRUE)


dev.copy(pdf,'/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots/210209_RACMO_selection_raw_data_extent.pdf')
dev.off()


# increase raster resolution - possibly improve using Inverse Distance Weighting
#   https://swilke-geoscience.net/post/spatial_interpolation/

racmo_prc_d <- disaggregate(racmo_prc, fact=c(35, 35), method='bilinear')
racmo_wnd_d <- disaggregate(racmo_wnd, fact=c(35, 35), method='bilinear')
racmo_tmp_d <- disaggregate(racmo_tmp, fact=c(35, 35), method='bilinear')

save(racmo_prc_d, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/165_r_prep_q2_predictor-tab_with-ratser__RACMO_Precipitation_35km_to_1km.Rdata") 
save(racmo_wnd_d, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/165_r_prep_q2_predictor-tab_with-ratser__RACMO_WindSpeed_10m_35km_to_1km.Rdata") 
save(racmo_tmp_d, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/165_r_prep_q2_predictor-tab_with-ratser__RACMO_Temperature_2m_35km_to_1km.Rdata") 

# check new spatial resolution of data - 1 px 1 km 
# check spatial resolution of data - it is quite coarse

dev.new()
par(mfrow=c(2,2))

zoom(racmo_prc_d, ext=fld_locs_spdf_stere, maxpixels=100000, layer=1, new=FALSE, useRaster=TRUE, main="A: RACMO Precipitation 35km (zoom)")
points(fld_locs_spdf_stere, pch=3, cex = 2)
plot(buffer(fld_locs_spdf_stere, width=20000), add=TRUE)


zoom(racmo_wnd_d, ext=fld_locs_spdf_stere, maxpixels=100000, layer=1, new=FALSE, useRaster=TRUE, main="B: RACMO WindSpeed 10m 35km (zoom)")
points(fld_locs_spdf_stere, pch=3, cex = 2 )
plot(buffer(fld_locs_spdf_stere, width=20000), add=TRUE)


zoom(racmo_tmp_d, ext=fld_locs_spdf_stere, maxpixels=100000, layer=1, new=FALSE, useRaster=TRUE, , main = "C: RACMO Temperature 2m 35km (zoom)")
points(fld_locs_spdf_stere, pch=3, cex = 2 )
plot(buffer(fld_locs_spdf_stere, width=20000), add=TRUE)

dev.copy(pdf,'/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots/210209_RACMO_selection_disagr_data_extent.pdf')
dev.off()





# extract data from raster and format
# ------------------------------------

# https://www.neonscience.org/resources/learning-hub/tutorials/extract-values-rasters-r

racmo_prc_d_buffered <- raster::extract(racmo_prc_d,   # raster layer
     fld_locs_spdf_stere,                              # SPDF with centroids for buffer
     buffer = 20000,                                    # buffer size - 1000 m, units depend on CRS (here: m)
     fun=median,                                       # what to value to extract
     df=TRUE)                                          # return a dataframe?

racmo_wnd_d_buffered <- raster::extract(racmo_wnd_d,   # raster layer
     fld_locs_spdf_stere,                              # SPDF with centroids for buffer
     buffer = 20000,                                    # buffer size - 1000 m, units depend on CRS (here: m)
     fun=median,                                       # what to value to extract
     df=TRUE)                                          # return a dataframe?

racmo_tmp_d_buffered <- raster::extract(racmo_tmp_d,   # raster layer
     fld_locs_spdf_stere,                              # SPDF with centroids for buffer
     buffer = 20000,                                    # buffer size - 1000 m, units depend on CRS (here: m)
     fun=median,                                       # what to value to extract
     df=TRUE)                                          # return a dataframe?


# create a more handy object
fld_locs_spdf_stere_ramcmo <-  merge(merge(racmo_prc_d_buffered, racmo_wnd_d_buffered, by="ID"), racmo_tmp_d_buffered, by="ID")
fld_locs_spdf_stere_ramcmo$ID <- fld_locs_spdf_stere$SampleID 
names(fld_locs_spdf_stere_ramcmo) <- c("SampleID", "RACMO_precip_mm_35to1km", "RACMO_windsp_10m_35to1km", "RACMO_tmp_2m_35to1km")



# merge data with input data frame
# --------------------------------
tib_compl_clim <- left_join( tib_compl, as_tibble(fld_locs_spdf_stere_ramcmo), by = "SampleID" )

# plot all raw data
# -----------------
tib_compl_clim %>% keep(is.numeric) %>%  gather() %>% 
  ggplot2:::ggplot(aes(value)) + facet_wrap(~ key, scales = "free") + geom_histogram() + geom_density() + theme_bw() +
  theme(legend.position = "none") +
  theme(strip.text.y = element_text(angle=0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 7), 
        axis.ticks.y = element_blank())

ggsave("200810_predictor_data_of_script_160.pdf", plot = last_plot(), 
       device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development/",
       scale = 3, width = 75, height = 50, units = c("mm"),
       dpi = 500, limitsize = TRUE)

# write_merged tables - for Qiime import
# ======================================

# tib_compl
tib_compl_clim
# formerly:
# p_compl <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/200501_18S_MF_merged.txt" 
# p_compl <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/200810_18S_MF_merged.txt"
p_compl <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/210209_18S_MF_merged.txt"
# write_tsv(tib_compl, p_compl, append = FALSE, col_names = TRUE)
write_tsv(tib_compl_clim, p_compl, append = FALSE, col_names = TRUE)
