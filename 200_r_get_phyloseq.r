# **********************************************
# * Create, filter, and write Physloseq object *
# **********************************************
# 12-Aug-2020

# load packages
# =============
rm(list = ls(all.names = TRUE))
gc()

library("tidyverse")   # work using tibbles
library("phyloseq")    # handle Qiime 2 data in R - best used to generate long dataframe
library("decontam")    # decontamination - check `https://benjjneb.github.io/decontam/vignettes/decontam_intro.html`
library("openxlsx")    # write Excel tables

# functions
# =========

# Define new operator "not in"
'%!in%' <- function(x,y)!('%in%'(x,y))

# Create phyloseq object.
# -----------------------

# Creates `phyloseq` objects from Qiime` compatible data.
get_phsq_ob <- function(biom_path, sequ_path, tree_path){

  # read data into R 
  btab <- phyloseq::import_biom (biom_path)
  # tree <- ape::read.tree(tree_path)
  sequ <- Biostrings::readDNAStringSet(sequ_path)  
  
  # construct object  
  phsq_ob <- phyloseq::merge_phyloseq(btab, tree_path, sequ)
  
  # return object
  return (phsq_ob)
}

# Remove empty data
# -----------------

# This function removes "0" count phylotypes from samples and samples with "0"
# phylotypes.
remove_empty <- function(phsq_ob){

  # filter Phylotypes
  phsq_ob <- phyloseq::prune_taxa (taxa_sums (phsq_ob) > 0, phsq_ob)
  
  # filter samples
  phsq_ob <- phyloseq::prune_samples (sample_sums (phsq_ob) > 0, phsq_ob)
  
  # return object
  return (phsq_ob)
}



# import and melt Phyloseq objects
# ================================

# read in object
# --------------

# https://rdrr.io/github/jbisanz/qiime2R/f/vignettes/vignette.Rmd
#  error message stems from "#"  in taxonomy table
psob_raw <- get_phsq_ob (biom_path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/190_18S_merged-tab_q2_export/features-tax-meta.biom", 
                         sequ_path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/190_18S_merged-tab_q2_export/dna-sequences.fasta",
                         tree_path = NULL)

# remove empty samples and sequence variants
psob_raw <- remove_empty(psob_raw)

# rewrite rank names, as they seem to have been lost
#   rank names from `/Users/paul/Documents/OU_pcm_eukaryotes/Github/150_r_get_q2_tax-tab.r`
colnames(tax_table(psob_raw)) <- c("superkingdom", "phylum", "class", "order",
  "family", "genus", "species")

# save or load initial state after import
# 
save(psob_raw, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import.Rdata")
save.image(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import-image.Rdata")

# load("/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import.Rdata")
# load("/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import-image.Rdata")


# try package `decontam` (currently omitted)
# -------------------------------------------
# 
# following:
#   "https://benjjneb.github.io/decontam/vignettes/decontam_intro.html"
#   carrying out filtering in case this will be used later, but for now subtracting
#   all blanks anyways after this code 

# plot library sizes
# ...................

psob <- psob_raw # copy for cleanup - just in case
psob_df <- as.data.frame(sample_data(psob)) # Put sample_data into a ggplot-friendly data.frame
psob_df$LibrarySize <- sample_sums(psob)
psob_df <- psob_df[order(psob_df$LibrarySize),]
psob_df$Index <- seq(nrow(psob_df))

ggplot(data = psob_df, aes(x=Index, y=LibrarySize, color=Description)) + 
  geom_point() +
  theme_bw()
  
ggsave("200812_raw_library_coverage_and_types.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
         scale = 3, width = 50, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)
  
# contamination identification using package `decontam`
# ......................................................

# contamination analysis and plotting

# set type for subsequent code
sample_data(psob)$RibLibConcAvg <- as.numeric(sample_data(psob)$RibLibConcAvg)

# get combined factor identifying negative controls
sample_data(psob)$is.neg <- sample_data(psob)$Description %in% c("PCRneg", "XTRneg")

# prevalence-based contamination identification
contamdf.prev <- isContaminant(psob, method="prevalence", neg="is.neg", threshold=0.5)
table(contamdf.prev$contaminant) # FALSE 12386  TRUE 51 
head(which(contamdf.prev$contaminant))

# frequency-based contamination identification
contamdf.freq <- isContaminant(psob, method="frequency", conc="RibLibConcAvg")
table(contamdf.freq$contaminant) # FALSE 12386  TRUE 239 
head(which(contamdf.freq$contaminant))

# frequency and prevalence based contamination identification
contamdf.freq <- isContaminant(psob, method="combined", conc="RibLibConcAvg", neg="is.neg", threshold=0.5)
table(contamdf.freq$contaminant) # FALSE 12386  TRUE 1184 
head(which(contamdf.freq$contaminant))

# randomwly inspecting 5 ASV
set.seed(100)
plot_frequency(psob, taxa_names(psob)[sample(which(contamdf.freq$contaminant),81)], conc="RibLibConcAvg") +
    xlab("DNA Concentration (PicoGreen fluorescent intensity)")

ggsave("200812_81_likely_contaminats.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
         scale = 3, width = 200, height = 200, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# "In this plot the dashed black line shows the model of a noncontaminant
# sequence feature for which frequency is expected to be independent of the input
# DNA concentration. The red line shows the model of a contaminant sequence
# feature, for which frequency is expected to be inversely proportional to input
# DNA concentration, as contaminating DNA will make up a larger fraction of the
# total DNA in samples with very little total DNA. Clearly Seq3 fits the red
# contaminant model very well, while Seq1 does not."

# Make phyloseq object of presence-absence in negative controls and true samples
psob.pa <- transform_sample_counts(psob, function(abund) 1*(abund>0))
psob.pa.neg <- prune_samples(sample_data(psob.pa)$Description %in% c("PCRneg", "XTRneg"), psob.pa)
psob.pa.pos <- prune_samples(sample_data(psob.pa)$Description == "PCM", psob.pa)

# Make data.frame of prevalence in positive and negative samples
df.pa <- data.frame(pa.pos = taxa_sums(psob.pa.pos), pa.neg = taxa_sums(psob.pa.neg),
                      contaminant=contamdf.prev$contaminant)

# look at the incidences of taxa observations in negative controls and positive samples.
ggplot(data=df.pa, aes(x=pa.neg, y=pa.pos, color=contaminant)) + 
  geom_point() +
  xlab("Prevalence (PCR and Extraction Controls)") +
  ylab("Prevalence (PCM Samples)") +
  theme_bw()

ggsave("200812_contaminant_detection_check.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
         scale = 3, width = 50, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)


# contamination filtering
psob_decontam <- prune_taxa(!contamdf.prev$contaminant, psob)
psob_decontam


# melt Phyloseq object and get a tibble
# -------------------------------------

psob_molten <- psmelt(psob_decontam)  # object processed by `decontam`
# psob_molten <- psmelt(psob_raw)           # object not processed by `decontam`

psob_molten <- psob_molten %>% as_tibble(.)

# save or load molten state after import
save(psob_molten, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/200_all_data_long_export_raw.Rdata")
# load("/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/200_all_data_long_export_raw.Rdata")

# format and pre-filter Phyloseq object
# =====================================

# rename and sort variables
# -------------------------

# define variable order - follows "190_q2_export_objects.sh"
names(psob_molten)

var_order <- c(
    "OTU", "Abundance", 
    "Sample", "Location", "Description",
    "COLR", "GRAVL", "TEXT", "AMMN", "NITR", "PHOS", "POTA", "SULPH", "CARB", "COND", "PH_CACL", "PH_H2O",
    "RLU", 
    "QUARTZ", "FELDSPAR", "TITANITE", "GARNETS", "MICAS", "DOLOMITE", "KAOLCHLOR", "CALCITE", "CHLORITE", 
    "ELEVATION", "SLOPE", "ASPECT",  "LongDEC", "LatDEC", "Loci", "AGE_KA",
    "superkingdom", "phylum", "class", "order", "family", "genus", "species",
    "BarcodeSequence", "LinkerPrimerSequence", "TmplHash", "LibContent", "SardiID", "XtrOri", "XtrContent", "RibLibConcAvg","RibPoolConcAvg"
)

psob_molten <- psob_molten %>% select(all_of(var_order))

# retain only eukaryotes
# ----------------------

# count non-eukaryotes in raw data (7,720)
psob_molten %>% filter(superkingdom %!in% c("Eukaryota")) %>% distinct(OTU) 

# count eukaryotes in raw data (4,666)
psob_molten %>% filter(superkingdom %in% c("Eukaryota")) %>% distinct(OTU) 

# retain only eukaryotes
psob_molten <- psob_molten %>% filter(superkingdom %in% c("Eukaryota"))

# clean taxonomy strings
# ----------------------

psob_molten <- psob_molten %>% 
  mutate(across(c("superkingdom", "phylum", "class", "order", "family", "genus", "species"), .funs = gsub, pattern = "__", replacement = " "))

psob_molten <- psob_molten %>% 
  mutate(across(c("superkingdom", "phylum", "class", "order", "family", "genus", "species"), .funs = gsub, pattern = "_", replacement = " "))

psob_molten <- psob_molten %>% 
  mutate(across(c("superkingdom", "phylum", "class", "order", "family", "genus", "species"), .funs = gsub, pattern = "  ", replacement = " "))

# print and save a species list
psob_species_list <- psob_molten %>% arrange(superkingdom, phylum, class, order, family, genus, species) %>% 
  select("superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% distinct() %>% print(n = Inf)
write.xlsx(psob_species_list, "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development/200812_200_eukaryote_asv_no_abundances_decontam_filtered.xlsx", overwrite = FALSE)

psob_molten <- psob_molten %>% arrange(superkingdom, phylum, class, order, family, genus, species)

# save or load molten state after import
save(psob_molten, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/200_all_data_long_export_prefiltered.Rdata")
load("/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/200_all_data_long_export_prefiltered.Rdata")

# filter Phyloseq object 
# ======================

#  pre-filter state: 1,064,882 x 48 (without `decontam` or with `decontam` -  not checking for 0-count ASV's) 
psob_molten

# formate data for further work
# -----------------------------

# filter for some controls: 70,212 x 48
unique(psob_molten$Description)
molten_controls <- psob_molten %>% filter(Description %in% unique(psob_molten$Description)[c(2:6)])

molten_controls <- molten_controls %>% 
  mutate(Description = case_when(Description == "AAcntrl" ~ "Antarctic Control",
                              Description == "soilcntrl" ~ "Soil Control",
                              Description == "PCRneg"  ~ "PCR Blank",
                              Description == "Inscntrl" ~ "Insect Control",
                              Description == "XTRneg"  ~ "Extraction Blank"))

unique(molten_controls$Description)

# plot controls (abundances are aggregated in-call to avoid jagged edges)
# ---------------------------------------------------------------------
ggplot(molten_controls, aes_string(x = "phylum", y = ave(molten_controls$Abundance, molten_controls$phylum, FUN=sum), fill = "phylum")) +
  geom_bar(stat = "identity", position = "stack", colour = NA, size=0) +
  facet_grid(Description ~ ., shrink = TRUE, scales = "fixed") +
  theme_bw() +
  theme(legend.position = "none") +
  theme(strip.text.y = element_text(angle=0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 7), 
        axis.ticks.y = element_blank()) +
  labs( title = "Phyla across all locations") + 
  xlab("phyla in control samples") + 
  ylab("read counts at each location (y scales fixed)")

ggsave("200720_all_controls_at_all_locations.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)


# "Soil Control": 4,446 ASVs
# ---------------------------
molten_soilcntrl <- molten_controls %>% filter(Description == "Soil Control", Abundance != 0)

molten_soilcntrl %>% select("superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% distinct() %>% print(n = Inf)


# "Insect Control": 36 ASV
# ----------------------------
molten_inscntrl <- molten_controls %>% filter(Description == "Insect Control", Abundance != 0)

molten_inscntrl %>% select("superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% distinct() %>% print(n = Inf)

# "Extraction Blank": 5,816 ASV's
# -------------------------------
molten_xtrneg <- molten_controls %>% filter(Description == "Extraction Blank")

molten_xtrneg %>% select("superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% distinct() %>%  print(n = Inf)


# "PCR Blank": 33 ASV's      
# ----------------------
molten_pcrneg <- molten_controls %>% filter(Description == "PCR Blank", Abundance != 0)

molten_pcrneg %>% select("superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% distinct() %>%  print(n = Inf)


# retain only Antarctic reads of relevance 
# ----------------------------------------

# A tibble: 895,664 x 48
psob_molten <- psob_molten %>% filter(Location %in% c("Mount_Menzies", "Lake_Terrasovoe", "Mawson_Escarpment"))

# remove contamination (ASV and species) 
# ----------------------------------------
# checks
unique(molten_controls$Description) # "Soil Control"     "PCR Blank"        "Insect Control"   "Extraction Blank"
molten_controls # 76,608
psob_contamination <- molten_controls %>% filter(Abundance != 0) # 4,516 x 48 - ok 

# 895,66 x 48 - ok 
psob_molten 

# 552,398 x 48
psob_molten <- psob_molten %>% anti_join(psob_contamination, by = ("OTU"))

# 255,486 x 48
psob_molten <- psob_molten %>% anti_join(psob_contamination, by = "species")


# remove extremely low coverage ASVs 
# --------------------------------

length(unique (psob_molten$OTU))

# get coverages per ASV
coverage_per_asv <- aggregate(psob_molten$Abundance, by=list(ASV=psob_molten$OTU), FUN=sum)
coverage_per_asv <- coverage_per_asv %>% arrange(desc(x))
summary(coverage_per_asv)

# add taxonomy to coverage list
taxon_strings <- distinct(psob_molten[c("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species")])
coverage_per_asv <- left_join(coverage_per_asv, taxon_strings, by = c("ASV" = "OTU")) %>% filter(x != 0)

# inspect 
head(coverage_per_asv, n = 100)
coverage_per_asv %>% arrange(superkingdom, phylum, class, order, family, genus, species)



# filtering 110,110 x 48
psob_molten <- psob_molten %>% anti_join(as_tibble(coverage_per_asv[which(coverage_per_asv$x < 5), ]), by = c("OTU" = "ASV"))



# get coverages per ASV
coverage_per_asv <- aggregate(psob_molten$Abundance, by=list(ASV=psob_molten$OTU), FUN=sum)
coverage_per_asv <- coverage_per_asv %>% arrange(desc(x))
summary(coverage_per_asv)

# add taxonomy to coverage list
taxon_strings <- distinct(psob_molten[c("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species")])
coverage_per_asv <- left_join(coverage_per_asv, taxon_strings, by = c("ASV" = "OTU")) %>% filter(x != 0)

# inspect 
head(coverage_per_asv, n = 100)
coverage_per_asv %>% arrange(superkingdom, phylum, class, order, family, genus, species)


# ---- continue here after 27-Jul-2020 -----


# species list of cleaned data: 
psob_molten %>% select("superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% distinct() %>%  print(n = Inf)

# save or load molten state after import
save(psob_molten, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/200_all_data_long_export_filtered.Rdata")



# get numeric not yet available above
# -----------------------------------

# check for high abundance values
# -------------------------------

# check for contaminants - as per below 
# how widespread is Solanum pennellii, a highly covered read in the data?
# its quite common, check alignments
# psob_molten$Abundance[which (psob_molten$OTU == "f88660c48713384b141b7cf376e1a118")]



# retain final object for export
# ------------------------------


# plot Phyloseq object 
# =====================

# copy and agglomerate taxonomic levels
# ----------------------------------

psob_plot_data <- psob_molten

# plot object
# ----------- 

# re-label locations for plotting
psob_plot_data <- psob_plot_data %>%  
  mutate(Location = case_when(Location == "Mount_Menzies" ~ "Mount Menzies",
                              Location == "Mawson_Escarpment"  ~ "Mawson Escarpment", 
                              Location == "Lake_Terrasovoe"  ~ "Lake Terrasovoje"))

# re-label Phyla for plotting
psob_plot_data$phylum[which(psob_plot_data$phylum %in% c("nomatch", "undefined"))] <- NA


# create and save plot
ggplot(psob_plot_data, aes_string(x = "phylum", y = "Abundance", fill = "phylum")) +
  geom_bar(stat = "identity", position = "stack", colour = NA, size=0) +
  facet_grid(Location ~ ., shrink = TRUE, scales = "fixed") +
  theme_bw() +
  theme(legend.position = "none") +
  theme(strip.text.y = element_text(angle=0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 7), 
        axis.ticks.y = element_blank()) +
  labs( title = "Phyla across all locations") + 
  xlab("phyla at all locations") + 
  ylab("read counts at each location (y scales fixed)")

ggsave("200717_all_phyla_at_all_locations.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)


# export molten Phyloseq object
# =============================

# for further analysis
save(psob_molten, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/200_all_data_long_export_filtered.Rdata")

# workspace
save.image(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_export-image_filtered.Rdata")










# ================================== old code below =============================









# 17.07.2020 - Plots and numerical summaries for results
# =======================================================

load("/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/200_all_data_long_export_filtered.Rdata")

# Numerical summaries
# -------------------
length(unique(psob_molten$Sample))
unique(psob_molten$Sample) %>% grepl(".MM", . , fixed = TRUE) %>% sum
unique(psob_molten$Sample) %>% grepl(".ME", . , fixed = TRUE) %>% sum
unique(psob_molten$Sample) %>% grepl(".LT", . , fixed = TRUE) %>% sum

# get total seqencing effort
sum(psob_molten$Abundance)


# summarize distinct values across the long data frame
show_vars <- c("OTU", "Abundance", "Sample", "BarcodeSequence", "Location", "Description",
  "superkingdom", "phylum", "class", "order", "family", "genus", "species")
psob_molten %>% select(any_of(show_vars)) %>% summarize_all(n_distinct, na.rm = TRUE)

# A tibble: 1 x 13
#     OTU Abundance Sample BarcodeSequence Location Description superkingdom phylum class order family genus species
#   <int>     <int>  <int>           <int>    <int>       <int>        <int>  <int> <int> <int>  <int> <int>   <int>
# 1  2743      1831    147             147        3           1            1     31   106   277    496   787    1134


# get coverages per sample and analyze
coverage_per_sample <- aggregate(psob_molten$Abundance, by=list(Sample=psob_molten$Sample), FUN=sum)
coverage_per_sample$Sample %>% grepl(".MM", . , fixed = TRUE) %>% sum
coverage_per_sample$Sample %>% grepl(".ME", . , fixed = TRUE) %>% sum
coverage_per_sample$Sample %>% grepl(".LT", . , fixed = TRUE) %>% sum
summary(coverage_per_sample)

# get ASV count again
length(unique(psob_molten$OTU))

# get coverages per ASV and analyze
coverage_per_asv <- aggregate(psob_molten$Abundance, by=list(ASV=psob_molten$OTU), FUN=sum)
coverage_per_asv <- coverage_per_asv %>% arrange(desc(x))
summary(coverage_per_asv)

head(coverage_per_asv)
head(psob_molten)

# get most species ordered by frequency
left_join(coverage_per_asv , psob_molten, by = c("ASV" = "OTU")) %>%
    distinct_at(vars("ASV", "x", "superkingdom", "phylum", "class", "species")) %>% head(., n = 12)

#                                ASV      x superkingdom       phylum           class                             species
# 1  5004de9015b06c0221fb18cd330bc1e4 215462    Eukaryota   Ascomycota Lecanoromycetes               Acanthothecis fontana
# 2  d96a424887ab33e2e7cc372d8c8fd40b 206939    Eukaryota   Ascomycota   Leotiomycetes              Ascozonus woolhopensis
# 3  50baba76780ac5b54c70079f1af75604 194591    Eukaryota   Ascomycota Lecanoromycetes                  Lecanora rugosella
# 4  d1cae5b7608113426bfb3bd92ff6ffcf 145295    Eukaryota Streptophyta      Liliopsida                Gastridium phleoides
# 5  f88660c48713384b141b7cf376e1a118 140853    Eukaryota Streptophyta       undefined                   Solanum pennellii
# 6  e881c59b29254fd091cee7feaaff143e 130422    Eukaryota     Nematoda     Chromadorea                 Scottnema lindsayae
# 7  31a6dcb475a929ef9cc4186da075ea07 129971    Eukaryota     Rotifera      Bdelloidea               Philodina acuticornis
# 8  ffba4e2457bbb54ce9dff4de75f4bff7 125600    Eukaryota     Rotifera      Bdelloidea               Philodina acuticornis
# 9  b1c61b2e584822a0cf5c55ef502eb08f 124030    Eukaryota   Ciliophora Phyllopharyngea Pseudochilodonopsis quadrivacuolata
# 10 413cf364a1daf21eb3c4f24ba076f5a3 114018    Eukaryota   Ascomycota Lecanoromycetes                    Pyxine sorediata
# 11 b7f842c137861b77b4ebe9adc233bc54 112059    Eukaryota   Ascomycota   Leotiomycetes                 Thelebolus globosus
# 12 8d7e8b0361dfc41dfac402c6daa5920b  96774    Eukaryota   Arthropoda       undefined             Derocheilocaris typicus

# re-check locations
psob_molten %>% distinct(Location,  .keep_all = FALSE)
