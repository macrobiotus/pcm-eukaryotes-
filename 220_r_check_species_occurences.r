# ***************************************************************
# * Check occurrence record of significant Antarctic eukaryotes *
# ***************************************************************
# 21-Jun-20201

rm(list = ls(all.names = TRUE))
gc()

# 1. load packages, define functions
# ================

library("tidyverse")    # en vogue
library("magrittr")     # more pipes
library("spocc")        # https://github.com/ropensci/spocc 
                        # https://docs.ropensci.org/spocc/

library("sp")           # look up names by GPS coordinates
library("maps")         # for maps
library("rworldmap")    # for maps

library("openxlsx")     # for writing summary tables

library("tidygeocoder") # https://stackoverflow.com/questions/21708488/get-country-and-continent-from-longitude-and-latitude-point-in-r

library("ggpubr")       # export plots

# https://stackoverflow.com/questions/21708488/get-country-and-continent-from-longitude-and-latitude-point-in-r
coords2continent <- function(points){  
  countriesSP <- getMap(resolution='low')
  #countriesSP <- getMap(resolution='high') #you could use high res map from rworldxtra if you were concerned about detail
  
  # converting points to a SpatialPoints object
  # setting CRS directly to that from rworldmap
  pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))  
  
  # use 'over' to get indices of the Polygons object containing each point 
  indices = over(pointsSP, countriesSP)
  
  #indices$continent   # returns the continent (6 continent model)
  indices$REGION   # returns the continent (7 continent model)
  #indices$ADMIN  #returns country name
  #indices$ISO3 # returns the ISO3 code 
}

coords2country <- function(points){  
  countriesSP <- getMap(resolution='low')
  #countriesSP <- getMap(resolution='high') #you could use high res map from rworldxtra if you were concerned about detail
  
  # converting points to a SpatialPoints object
  # setting CRS directly to that from rworldmap
  pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))  
  
  # use 'over' to get indices of the Polygons object containing each point 
  indices = over(pointsSP, countriesSP)
  
  #indices$continent   # returns the continent (6 continent model)
  # indices$REGION   # returns the continent (7 continent model)
  indices$ADMIN  #returns country name
  #indices$ISO3 # returns the ISO3 code 
}

'%!in%' <- function(x,y)!('%in%'(x,y))

# 2. load query data
# ==================

# get relevant species 
euks <- readRDS(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_uniq_sign_species.Rdata")


# 3. clean query data
# ===================

# **count species strings in input data** 
count_input_species <- euks %>% distinct(species) %>% pull (species) %>% length # 173

# erase all that may come after "sp." if there is an "sp." at all
euks %<>% mutate(species = gsub("sp\\..*", "sp.", species))
euks %>% pull(species) # check results

# in strings with more then three white spaces delete all after that 
# try with https://spannbaueradam.shinyapps.io/r_regex_tester/
euks %<>% mutate(species = gsub("cf. ", "", species))
euks %<>% mutate(species = str_replace(species, "\\s\\S*\\s\\S*(.*)", ""))
euks %>% pull(species) # 173 records

# 4. get occurrence records 
# =========================

# query names using occ https://rdrr.io/cran/spocc/man/occ.html
# also see ?occ()
# ***load objecet below and be mindful of saving*** steps takes 30 minutes or so 
euk_occ_raw <- occ(query = (euks %>% pull(species)),
                   from = c("gbif",  "bison", "inat", "ebird", "vertnet"),
                   limit = 10,
                   start = NULL,
                   page = NULL,
                   geometry = NULL,
                   has_coords = TRUE,
                   throw_warnings = TRUE
                   )

# saveRDS(euk_occ_raw, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/220_occurence_records_raw.Rdata")
euk_occ_raw <- readRDS(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/220_occurence_records_raw.Rdata")

euk_occ_df <- occ2df(euk_occ_raw)


# some cleaning https://spannbaueradam.shinyapps.io/r_regex_tester/
euk_occ_df %<>% mutate(name = str_match(name, "\\S*\\s\\S*")[, 1])
euk_occ_df %<>% mutate(across(c(longitude, latitude, key), ~as.numeric(.) )) %>% drop_na() 

# 5. counting occurrence records 
# ==============================

# **count obtained records (n= 778)** (may get more when adjusting limit parameter above)
euk_occ_df %>%  drop_na() %>% print(n = Inf) 

# **count unique species strings in looked up data (n = 78)** 
count_retrieved_species <- euk_occ_df %>% distinct(name) %>% pull (name) %>% length # 76

# create table for better comparison
retrieved_records <- left_join(  tibble(euks[ , "species"]),  
            distinct(euk_occ_df[ , "name"]), 
            by = c("species" = "name"),
            keep = TRUE
            ) %>% rename("Query species" = species, "Returned species" = name)

# records that **could not** be found
retrieved_records %>% filter(is.na(`Returned species`)) %>% pull(`Query species`)

# records that *could* be found
retrieved_records %>% filter(!is.na(`Returned species`)) %>% pull(`Query species`)

# **list providers**
euk_occ_df %>% count(prov)

#  53 - BISON United States Federal Resource for Biological Occurrence Data https://bison.usgs.gov
# 523 - GBIF Global Biodiversity Information Facility https://www.gbif.org
# 202 - iNaturalist - https://www.inaturalist.org

# 6. look up continents and countries of occurrence records, then plot 
# =====================================================================

# create summary table with locations - looked up using GPS coordinates (using "geonames()")
euk_occ_df$continent <- coords2continent( euk_occ_df[ , c("longitude", "latitude")] )
euk_occ_df$country   <- coords2country( euk_occ_df[ , c("longitude", "latitude")] )
euk_occ_df

# get data frame for continent plot
# --------------------------------
euk_conti <- euk_occ_df %>% 
  distinct(across(c(name, continent))) %>% 
  filter(!is.na(name), !is.na(continent))

# get a table and save as 

## full table - directly saving as web table

species_on_continents <- addmargins(table(euk_conti))

write.xlsx(species_on_continents, "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/210602_supporting_material/WebTable 6.xlsx",
           asTable = FALSE)

# get a plot
p_continent <- ggplot(euk_conti, aes_string(x = "continent", y = reorder(euk_conti$name, desc(euk_conti$name)))) +
  geom_point(fill = "gray") +
  theme_bw() +
  theme(legend.position = "none", 
        strip.text.y = element_text(angle=0), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 7, face = "italic"), 
        axis.ticks.y = element_blank()
  ) +
  xlab("Continent") + ylab("Putative Species")


# get data frame for country plot
# --------------------------------
euk_count <- euk_occ_df %>% 
  distinct(across(c(name, country))) %>% 
  filter(!is.na(name), !is.na(country))

# get a table 

# -- not done yet --

# get a plot

p_country <- ggplot(euk_count, aes_string(x = "country", y = reorder(euk_count$name, desc(euk_count$name)))) +
  geom_point(fill = "gray") +
  theme_bw() +
  theme(legend.position = "none", 
        strip.text.y = element_text(angle=0), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 7, face = "italic"), 
        axis.ticks.y = element_blank()
  ) +
  xlab("Country") + ylab("Putative Species")

# 5. map out occurrence records  
# ============================


# isolate polar species, North and sout of 66.56349999999999

euk_occ_df %>% filter(latitude >= 66.5635) %>% distinct(name)
euk_occ_df %>% filter(latitude <= -66.5635) %>% distinct(name)

# round gps coordinates to 5th decimal degrees (accurate to 1.11 meter at the equator)
options(digits=8)     # increase reported digits 
euk_occ_df$longitude  # see data not rounded
euk_occ_df %<>% mutate(across(c(longitude, latitude), ~round(as.numeric(.), digits = 5)))
euk_occ_df$longitude  # see data rounded

#   de-duplicate rounded table using fields name longitude  latitude  prov 
euk_occ_df %<>% distinct(name, longitude, latitude)

#   create map without labels 
worldmap <- ggplot2::map_data("world")

p_world <- ggplot() +
  coord_cartesian(xlim = c(-180, 180), ylim = c(-90, 90), expand = FALSE, default = TRUE, clip = "on") +
  geom_polygon(data = worldmap, aes(x = long, y = lat,  group = group), fill="grey", alpha=0.3) +
  geom_point( data=euk_occ_df, aes(x = as.numeric(longitude), y = as.numeric(latitude))) +
  theme_bw() +
  ggtitle("Occurences of 66 putative species assignments derived from 18S data\n accurate to 1.11 m at equator") +
  xlab("Longitude") + ylab("Latitude")

# 6. export graphical summaries
# ============================

# saving maps
# -----------
ggsave("210623_220_r_check_species_occurences_worldmap.pdf", plot = last_plot(), 
       device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots",
       scale = 1, width =297, height = 210, units = c("mm"),
       dpi = 500, limitsize = TRUE)

ggsave("210623_220_r_check_species_occurences_worldmap.pdf", plot = last_plot(), 
       device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
       scale = 1, width =297, height = 210, units = c("mm"),
       dpi = 500, limitsize = TRUE)

# saving plots
# ------------

ggarrange(p_continent, p_country, ncol = 2, nrow = 1,
          labels = "auto", widths = c(0.3, 0.7))

ggsave("210623_220_r_check_species_occurences_tables.pdf", plot = last_plot(), 
       device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots",
       scale = 1.5, width = 210, height = 297, units = c("mm"),
       dpi = 500, limitsize = TRUE)

ggsave("210623_220_r_check_species_occurences_tables.pdf", plot = last_plot(), 
       device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
       scale = 1.5, width = 210, height = 297, units = c("mm"),
       dpi = 500, limitsize = TRUE)

