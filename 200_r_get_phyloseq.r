# **********************************************
# * Create, filter, and write Physloseq object *
# **********************************************
# 14-Aug-2020

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


# Order variables in molten_phyloseq_object
# -----------------------------------------

reorder_vars <- function (molten_phyloseq_object){

  require(dplyr)

  var_order <- c(
    "OTU", "Abundance", 
    "Sample", "Location", "Description",
    "COLR", "GRAVL", "TEXT", "AMMN", "NITR", "PHOS", "POTA", "SULPH", "CARB", "COND", "PH_CACL", "PH_H2O",
    "RLU", 
    "QUARTZ", "FELDSPAR", "TITANITE", "GARNETS", "MICAS", "DOLOMITE", "KAOLCHLOR", "CALCITE", "CHLORITE", 
    "ELEVATION", "SLOPE", "ASPECT",  "LongDEC", "LatDEC", "Loci", "AGE_KA",
    "superkingdom", "phylum", "class", "order", "family", "genus", "species",
    "BarcodeSequence", "LinkerPrimerSequence", "TmplHash", "LibContent", "SardiID", "XtrOri", "XtrContent", "RibLibConcAvg","RibPoolConcAvg")
  
  molten_phyloseq_object <- molten_phyloseq_object %>% select(all_of(var_order)) 

  return(molten_phyloseq_object)

} 


# Clean taxonomy strings
# ----------------------

clean_molten_tax_strings <- function(molten_phyloseq_object){

  require(dplyr)
  
  molten_phyloseq_object <- molten_phyloseq_object %>% 
    mutate(across(c("superkingdom", "phylum", "class", "order", "family", "genus", "species"), .funs = gsub, pattern = "__", replacement = " "))

  molten_phyloseq_object <- molten_phyloseq_object %>% 
    mutate(across(c("superkingdom", "phylum", "class", "order", "family", "genus", "species"), .funs = gsub, pattern = "_", replacement = " "))

  molten_phyloseq_object <- molten_phyloseq_object %>% 
    mutate(across(c("superkingdom", "phylum", "class", "order", "family", "genus", "species"), .funs = gsub, pattern = "  ", replacement = " "))

  molten_phyloseq_object <- molten_phyloseq_object %>% arrange(superkingdom, phylum, class, order, family, genus, species)
  
  return(molten_phyloseq_object)

}


# Retain only samples used in this study (no controls, no other locations)
# ------------------------------------------------------------------------

retain_pcm_sample_for_inspection <- function(molten_phyloseq_object){
  
  require(dplyr)
  
  molten_phyloseq_object <- molten_phyloseq_object %>% filter(Location %in% c("Mount Menzies", "Mawson Escarpment", "Lake Terrasovoje"))
  
  return(molten_phyloseq_object)

}


# I. Import Phyloseq object
# =========================

# Read in
# -------

# https://rdrr.io/github/jbisanz/qiime2R/f/vignettes/vignette.Rmd
#  error message stems from "#"  in taxonomy table
psob_raw <- get_phsq_ob (biom_path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/190_18S_merged-tab_q2_export/features-tax-meta.biom", 
                         sequ_path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/190_18S_merged-tab_q2_export/dna-sequences.fasta",
                         tree_path = NULL)

# Rewrite rank names, as they seem to have been lost
# --------------------------------------------------
#   rank names from `/Users/paul/Documents/OU_pcm_eukaryotes/Github/150_r_get_q2_tax-tab.r`
colnames(tax_table(psob_raw)) <- c("superkingdom", "phylum", "class", "order",
  "family", "genus", "species")

# Re-label categories
# -------------------
# unique(sample_data(psob_raw)$Description)
# unique(sample_data(psob_raw)$Location)

sample_data(psob_raw)$Description[which(sample_data(psob_raw)$Description ==  "PCM")] <- "PCMNT"
sample_data(psob_raw)$Description[which(sample_data(psob_raw)$Description =="soilcntrl")] <- "SCNTRL"
sample_data(psob_raw)$Description[which(sample_data(psob_raw)$Description =="PCRneg")] <- "ACNTRL"
sample_data(psob_raw)$Description[which(sample_data(psob_raw)$Description =="XTRneg")] <- "XCNTRL"
sample_data(psob_raw)$Description[which(sample_data(psob_raw)$Description =="AAcntrl")]  <-"COAST"
sample_data(psob_raw)$Description[which(sample_data(psob_raw)$Description =="Inscntrl")] <- "ICNTRL"

sample_data(psob_raw)$Location[which(sample_data(psob_raw)$Location ==  "Reinbolt_Hills")] <- "Reinbolt Hills"
sample_data(psob_raw)$Location[which(sample_data(psob_raw)$Location =="Mount_Menzies")] <- "Mount Menzies"
sample_data(psob_raw)$Location[which(sample_data(psob_raw)$Location =="Mawson_Escarpment")] <- "Mawson Escarpment"
sample_data(psob_raw)$Location[which(sample_data(psob_raw)$Location =="Lake_Terrasovoe")] <- "Lake Terrasovoje"
sample_data(psob_raw)$Location[which(sample_data(psob_raw)$Location =="SARDI_lab")]  <- "SARDI"
sample_data(psob_raw)$Location[which(sample_data(psob_raw)$Location =="EBU_lab")] <- "EBU"
sample_data(psob_raw)$Location[which(sample_data(psob_raw)$Location =="E_Ant_coast")] <- "East Antarctic Coast"

# unique(sample_data(psob_raw)$Description)
# unique(sample_data(psob_raw)$Location)

# Remove truly unneeded samples
# -----------------------------
psob_raw <- subset_samples(psob_raw, Location %!in%  c("East Antarctic Coast", "Reinbolt Hills") )
  
# Remove empty samples and sequence variants
# ------------------------------------------
psob_raw <- remove_empty(psob_raw)

# Save or load initial state after import
# ---------------------------------------
save(psob_raw, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import.Rdata")
save.image(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import-image.Rdata")

# load("/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import.Rdata")
# load("/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import-image.Rdata")


# II. Inspect a molten Phyloseq object copy
# =========================================

# create molten Phyloseq object copy
psob_raw_molten <- psmelt(psob_raw)

# Tidy object 
# -----------

# reorder variables
psob_raw_molten <- reorder_vars(psob_raw_molten)

# clean taxonomy strings
psob_raw_molten <- clean_molten_tax_strings(psob_raw_molten)

# retain PCM samples for inspection
psob_raw_molten <- retain_pcm_sample_for_inspection(psob_raw_molten)

# re-label available data categories for plotting
psob_raw_molten$phylum[which(psob_raw_molten$phylum %in% c("nomatch", "undefined"))] <- "no hit, reference, or complete taxonomy string"

# get a tibble
psob_raw_molten <- psob_raw_molten %>% as_tibble(.)

# remove empty data - hope this works
psob_raw_molten <- psob_raw_molten %>% filter(Abundance > 0) 


# Describe object (as below) 
# --------------------------

# create and save plot
ggplot(psob_raw_molten, aes_string(x = "phylum", y = "Abundance", fill = "phylum")) +
  geom_bar(stat = "identity", position = "stack", colour = NA, size=0) +
  facet_grid(Location ~ ., shrink = TRUE, scales = "free_y") +
  theme_bw() +
  theme(legend.position = "none") +
  theme(strip.text.y = element_text(angle=0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 7), 
        axis.ticks.y = element_blank()) +
  labs( title = "Phyla across all locations before filtering") + 
  xlab("phyla at all locations") + 
  ylab("read counts at each location (y scales variable)")

ggsave("200814_all_unfiltered_phyla_at_all_locations.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# Numerical summaries
# -------------------
length(unique(psob_raw_molten$Sample)) # 154 samples from study sites
unique(psob_raw_molten$Sample) %>% grepl(".MM", . , fixed = TRUE) %>% sum # 26 sample Mount Menzies
unique(psob_raw_molten$Sample) %>% grepl(".ME", . , fixed = TRUE) %>% sum # 70 samples Mawson Escarpment
unique(psob_raw_molten$Sample) %>% grepl(".LT", . , fixed = TRUE) %>% sum # 58 samples Lake Terrasovoje
sum(26 + 70 + 58) # 154 - ok

# get total seqencing effort
sum(psob_raw_molten$Abundance) #  16 524 031 sequences total - after import filtering

# summarize distinct values across the long data frame
show_vars <- c("OTU", "Abundance", "Sample", "BarcodeSequence", "Location", "Description",
  "superkingdom", "phylum", "class", "order", "family", "genus", "species")
psob_raw_molten %>% select(any_of(show_vars)) %>% summarize_all(n_distinct, na.rm = TRUE)

# A tibble: 1 x 13
#     OTU Abundance Sample BarcodeSequence Location Description superkingdom phylum class order family genus species
#   <int>     <int>  <int>           <int>    <int>       <int>        <int>  <int> <int> <int>  <int> <int>   <int>
# 1  8097      2847    154             154        3           1            5     47   131   342    621  1161    1904

# Analyze coverages per samples
coverage_per_sample <- aggregate(psob_raw_molten$Abundance, by=list(Sample=psob_raw_molten$Sample), FUN=sum)
summary(coverage_per_sample)
coverage_per_sample %>% filter(., grepl(".MM", Sample , fixed = TRUE)) %>% summary(x) 
coverage_per_sample %>% filter(., grepl(".ME", Sample , fixed = TRUE)) %>% summary(x) 
coverage_per_sample %>% filter(., grepl(".LT", Sample , fixed = TRUE)) %>% summary(x) 


# Analyze coverages per ASVs
length(unique(psob_raw_molten$OTU)) # 8097
# count eukaryotes and non-eukaryotes 
psob_raw_molten %>% filter(superkingdom %in% c("Eukaryota")) %>% distinct(OTU)  # 2,656 Eukaryota ASV
psob_raw_molten %>% filter(superkingdom %!in% c("Eukaryota")) %>% distinct(OTU) # 5,441 non-Eukaryota ASV


# get coverages per ASV and analyze
coverage_per_asv <- aggregate(psob_raw_molten$Abundance, by=list(ASV=psob_raw_molten$OTU), FUN=sum)
coverage_per_asv <- coverage_per_asv %>% arrange(desc(x))
summary(coverage_per_asv)


# get most species ordered by frequency
psob_asv_list <- left_join(coverage_per_asv , psob_raw_molten, by = c("ASV" = "OTU")) %>%
    distinct_at(vars("ASV", "x", "superkingdom", "phylum", "class", "order", "family", "genus", "species")) 

psob_asv_list %>% head(., n = 12)

#                                 ASV       x superkingdom              phylum               class                       species
# 1  f184ca796a5be28dc3cde4bcbe1d26d3 1491686    Eukaryota no hit or reference           undefined          uncultured eukaryote
# 2  5c882557a215b3ca73569393ee7212b6  888969    Eukaryota        Streptophyta           undefined               Cicer arietinum
# 3  a889334a65362e22039f6bd6b31aceff  454680     Bacteria      Planctomycetes      Planctomycetia     Singulisphaera acidiphila
# 4  7c12dd9bdf0ab53af6f927744d2d6649  291288    Eukaryota          Ascomycota      Eurotiomycetes       Arthrocladium tropicale
# 5  e275f1ca63cb2b3e7b039a2ce85b4dac  272358    Eukaryota            Nematoda             Enoplea      Microdorylaimus modestus
# 6  25ad1fd18126a0c3909c61d2dc8b43c4  270294    Eukaryota            Rotifera          Bdelloidea          Philodina sp. cmbb21
# 7  bd2b68bde1426f96a5a6abc71daabc20  255198    Eukaryota       Heterolobosea           undefined Allovahlkampfia sp. PKD 2011b
# 8  58dd134e3736080c944c9655172c18ec  246207     Bacteria      Proteobacteria Alphaproteobacteria              Sphingomonas sp.
# 9  5004de9015b06c0221fb18cd330bc1e4  207718    Eukaryota          Ascomycota     Lecanoromycetes         Acanthothecis fontana
# 10 d96a424887ab33e2e7cc372d8c8fd40b  201579    Eukaryota          Ascomycota       Leotiomycetes        Ascozonus woolhopensis
# 11 634e9c4059da8b996c8a07faabfb488f  200259    Eukaryota            Cercozoa           undefined             Cercozoa sp. TGS3
# 12 3d3dbac4c47854fe7091ae126d8a7438  186507     Bacteria      Proteobacteria Alphaproteobacteria  Erythrobacteraceae bacterium


psob_asv_list %>% 
  arrange(superkingdom, phylum, class, order, family, genus, species) %>%
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development/200814_all_unfiltered_phyla_at_all_locations.xlsx", overwrite = FALSE)


# save or load molten state 
save.image(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_long_export_raw-image.Rdata")
save(psob_raw_molten, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_long_export_raw.Rdata")
load("/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_long_export_raw.Rdata")



# III. Remove contamination, melt, and remove more
# ===============================================

psob <- psob_raw # create Phyloseq object copy


# plot controls (abundances are aggregated in-call to avoid jagged edges)
psob_molten <- psmelt(psob)
unique(psob_molten$Description) # "PCMNT" "ICNTRL" "SCNTRL" "ACNTRL" "XCNTRL"
molten_contamination <- psob_molten %>% 
  filter(Description %in% c("ICNTRL", "SCNTRL", "ACNTRL", "XCNTRL")) %>% 
  filter(Abundance != 0) # 4,218 x 51

ggplot(molten_contamination, aes_string(x = "phylum", y = molten_contamination$Abundance, fill = "phylum")) +
  geom_bar(stat = "identity", position = "stack", colour = NA, size=0) +
  facet_grid(Description ~ ., shrink = TRUE, scales = "free_y") +
  theme_bw() +
  theme(legend.position = "none") +
  theme(strip.text.y = element_text(angle=0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 7), 
        axis.ticks.y = element_blank()) +
  labs( title = "Phyla in controls across all locations before application of Decontam") + 
  xlab("phyla in control samples") + 
  ylab("read counts at each location (y scales variable)")

ggsave("200814_unfiltered_controls.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# names are being re-used further down, thus avoiding chaos here
rm(molten_contamination, psob_molten)

# Removal of contamination with package `decontam`
# ------------------------------------------------
# following:
#   "https://benjjneb.github.io/decontam/vignettes/decontam_intro.html"

# plot initial library sizes
psob_df <- as.data.frame(sample_data(psob)) # Put sample_data into a ggplot-friendly data.frame
psob_df$LibrarySize <- sample_sums(psob)
psob_df <- psob_df[order(psob_df$LibrarySize),]
psob_df$Index <- seq(nrow(psob_df))

ggplot(data = psob_df, aes(x=Index, y=LibrarySize, color=Description)) + 
  geom_point() +
  theme_bw()
  
ggsave("200814_raw_library_coverage_and_types.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
         scale = 3, width = 50, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)


# set type for subsequent code
sample_data(psob)$RibLibConcAvg <- as.numeric(sample_data(psob)$RibLibConcAvg)

# get combined factor identifying negative controls
sample_data(psob)$is.neg <- sample_data(psob)$Description %in% c("ACNTRL", "XCNTRL")

# frequency and prevalence based contamination identification
contamdf.freq <- isContaminant(psob, method="combined", conc="RibLibConcAvg", neg="is.neg", threshold=0.6)
table(contamdf.freq$contaminant) # FALSE 8917  TRUE 1635 
head(which(contamdf.freq$contaminant))

# randomwly inspecting 81 ASV
set.seed(100)
plot_frequency(psob, taxa_names(psob)[sample(which(contamdf.freq$contaminant),81)], conc="RibLibConcAvg") +
    xlab("DNA Concentration (PicoGreen fluorescent intensity)")

ggsave("200814_decontam_81_likely-contaminats.pdf", plot = last_plot(), 
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
psob.pa.neg <- prune_samples(sample_data(psob.pa)$Description %in% c("ACNTRL", "XCNTRL"), psob.pa)
psob.pa.pos <- prune_samples(sample_data(psob.pa)$Description == "PCMNT", psob.pa)

# Make data.frame of prevalence in positive and negative samples
df.pa <- data.frame(pa.pos = taxa_sums(psob.pa.pos), pa.neg = taxa_sums(psob.pa.neg),
                      contaminant=contamdf.freq$contaminant)

# look at the incidences of taxa observations in negative controls and positive samples.
ggplot(data=df.pa, aes(x=pa.neg, y=pa.pos, color=contaminant)) + 
  geom_point() +
  xlab("prevalence (PCR and Extraction Controls)") +
  ylab("prevalence (PCM Samples)") +
  theme_bw()

ggsave("200814_decontam_contaminant_detection_check.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
         scale = 3, width = 50, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)


# contamination filtering
psob_decontam <- prune_taxa(!contamdf.freq$contaminant, psob)


# Inspect controls in study samples after application of `decontam`
# ----------------------------------------------------------------

psob_molten <- psmelt(psob_decontam) %>% as_tibble()

# "Soil Control": 2,315 ASVs
molten_soilcntrl <- psob_molten %>% filter(Description == "SCNTRL", Abundance != 0) 

molten_soilcntrl %>% select("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% 
  distinct_at(vars("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species")) %>% 
  arrange(superkingdom, phylum, class, order, family, genus, species) # %>% print(n = Inf)


# "Insect Control": 30 ASVs
molten_inscntrl <- psob_molten %>% filter(Description == "ICNTRL", Abundance != 0) 

molten_inscntrl %>% select("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% 
  distinct_at(vars("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species")) %>% 
  arrange(superkingdom, phylum, class, order, family, genus, species) %>%
  print(n = Inf)

# "Extraction Blank": 1 ASV's
molten_xcntrl <- psob_molten %>% filter(Description == "XCNTRL", Abundance != 0) 

molten_xcntrl %>% select("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% 
  distinct_at(vars("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species")) %>% 
  arrange(superkingdom, phylum, class, order, family, genus, species) %>%
  print(n = Inf)

# "PCR Blank": 51 ASV's      
molten_acntrl <- psob_molten %>% filter(Description == "ACNTRL", Abundance != 0) 

molten_acntrl %>% select("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% 
  distinct_at(vars("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species")) %>%
  arrange(superkingdom, phylum, class, order, family, genus, species) %>% 
  print(n = Inf)

# isolate contamination as a whole - instead of looking at things individually
unique(psob_molten$Description) # "PCMNT" "ICNTRL" "SCNTRL" "ACNTRL" "XCNTRL"
molten_contamination <- psob_molten %>% 
  filter(Description %in% c("ICNTRL", "SCNTRL", "ACNTRL", "XCNTRL")) %>% 
  filter(Abundance != 0) # 4,218 x 51

# plot controls (abundances are aggregated in-call to avoid jagged edges)
ggplot(molten_contamination, aes_string(x = "phylum", y = molten_contamination$Abundance, fill = "phylum")) +
  geom_bar(stat = "identity", position = "stack", colour = NA, size=0) +
  facet_grid(Description ~ ., shrink = TRUE, scales = "free_y") +
  theme_bw() +
  theme(legend.position = "none") +
  theme(strip.text.y = element_text(angle=0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 7), 
        axis.ticks.y = element_blank()) +
  labs( title = "Phyla across all locations after application of Decontam") + 
  xlab("phyla in control samples") + 
  ylab("read counts at each location (y scales variable)")

ggsave("200814_decontam_effect_on_controls.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# Remove contamination (ASV and species)
# --------------------------------------

# 28,530 x 51 - ok 
psob_molten %>% filter(Abundance != 0)

# 20,767 x 51 - some removed ok 
psob_molten <- psob_molten %>% anti_join(molten_contamination, by = "OTU") %>% filter(Abundance != 0)

#  7,774 x 51
psob_molten <- psob_molten %>% anti_join(molten_contamination, by = "genus") %>% filter(Abundance != 0)

# Removal of Bacteria
# ------------------------------

unique(psob_molten$superkingdom)
psob_molten <- psob_molten %>% filter(superkingdom == "Eukaryota")
psob_molten %>% filter(Abundance != 0) # 3,047 x 51 lines


# Removal of low-coverage ASV's
# ------------------------------
# unrevised code - skipping for now 
# length(unique (psob_molten$OTU))
# 
# # get coverages per ASV
# coverage_per_asv <- aggregate(psob_molten$Abundance, by=list(ASV=psob_molten$OTU), FUN=sum)
# coverage_per_asv <- coverage_per_asv %>% arrange(desc(x))
# summary(coverage_per_asv)
# 
# # add taxonomy to coverage list
# taxon_strings <- distinct(psob_molten[c("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species")])
# coverage_per_asv <- left_join(coverage_per_asv, taxon_strings, by = c("ASV" = "OTU")) %>% filter(x != 0)
# 
# # inspect 
# head(coverage_per_asv, n = 100)
# coverage_per_asv %>% arrange(superkingdom, phylum, class, order, family, genus, species)
# 
# # ** filtering 110,110 x 48 ** 
# psob_molten <- psob_molten %>% anti_join(as_tibble(coverage_per_asv[which(coverage_per_asv$x < 5), ]), by = c("OTU" = "ASV"))
# 
# # get coverages per ASV
# coverage_per_asv <- aggregate(psob_molten$Abundance, by=list(ASV=psob_molten$OTU), FUN=sum)
# coverage_per_asv <- coverage_per_asv %>% arrange(desc(x))
# summary(coverage_per_asv)
# 
# # add taxonomy to coverage list
# taxon_strings <- distinct(psob_molten[c("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species")])
# coverage_per_asv <- left_join(coverage_per_asv, taxon_strings, by = c("ASV" = "OTU")) %>% filter(x != 0)
# 
# # inspect 
# head(coverage_per_asv, n = 100)
# coverage_per_asv %>% arrange(superkingdom, phylum, class, order, family, genus, species)





# IV. Re-inspect molten and cleaned  Phyloseq object
# ==================================================

# Tidy object 
# -----------

# reorder variables
psob_molten <- reorder_vars(psob_molten)

# clean taxonomy strings
psob_molten <- clean_molten_tax_strings(psob_molten)

# retain PCM samples for inspection
psob_molten <- retain_pcm_sample_for_inspection(psob_molten)

# re-label available data categories for plotting
psob_molten$phylum[which(psob_molten$phylum %in% c("nomatch", "undefined"))] <- "no hit, reference, or complete taxonomy string"

# get a tibble
psob_molten <- psob_molten %>% as_tibble(.)

# remove empty data - hope this works
psob_molten <- psob_molten %>% filter(Abundance > 0) 


# Describe object (as below) 
# --------------------------

# create and save plot
ggplot(psob_molten, aes_string(x = "phylum", y = "Abundance", fill = "phylum")) +
  geom_bar(stat = "identity", position = "stack", colour = NA, size=0) +
  facet_grid(Location ~ ., shrink = TRUE, scales = "free_y") +
  theme_bw() +
  theme(legend.position = "none") +
  theme(strip.text.y = element_text(angle=0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 7), 
        axis.ticks.y = element_blank()) +
  labs( title = "Phyla across all locations after filtering") + 
  xlab("phyla at all locations") + 
  ylab("read counts at each location (y scales variable)")

ggsave("200814_all_filtered_phyla_at_all_locations.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# Numerical summaries
# -------------------
length(unique(psob_molten$Sample)) # 154 samples from study sites
unique(psob_molten$Sample) %>% grepl(".MM", . , fixed = TRUE) %>% sum # 24 sample Mount Menzies
unique(psob_molten$Sample) %>% grepl(".ME", . , fixed = TRUE) %>% sum # 65 samples Mawson Escarpment
unique(psob_molten$Sample) %>% grepl(".LT", . , fixed = TRUE) %>% sum # 56 samples Lake Terrasovoje
sum(24 + 65 + 56) # 154 - ok

# get total seqencing effort
sum(psob_molten$Abundance) #  2 942 264 sequences total - after removal of bacteria and contamination

# summarize distinct values across the long data frame
show_vars <- c("OTU", "Abundance", "Sample", "BarcodeSequence", "Location", "Description",
  "superkingdom", "phylum", "class", "order", "family", "genus", "species")
psob_molten %>% select(any_of(show_vars)) %>% summarize_all(n_distinct, na.rm = TRUE)

# A tibble: 1 x 13
#     OTU Abundance Sample BarcodeSequence Location Description superkingdom phylum class order family genus species
#   <int>     <int>  <int>           <int>    <int>       <int>        <int>  <int> <int> <int>  <int> <int>   <int>
# 1  1099      1062    145             145        3           1            1     26    86   219    362   526     699

# Analyze coverages per samples
coverage_per_sample <- aggregate(psob_molten$Abundance, by=list(Sample=psob_molten$Sample), FUN=sum)
summary(coverage_per_sample)
coverage_per_sample %>% filter(., grepl(".MM", Sample , fixed = TRUE)) %>% summary(x) 
coverage_per_sample %>% filter(., grepl(".ME", Sample , fixed = TRUE)) %>% summary(x) 
coverage_per_sample %>% filter(., grepl(".LT", Sample , fixed = TRUE)) %>% summary(x) 


# Analyze coverages per ASVs
length(unique(psob_molten$OTU)) # 8097
# count eukaryotes and non-eukaryotes 
psob_molten %>% filter(superkingdom %in% c("Eukaryota")) %>% distinct(OTU)  # 1,099 Eukaryota ASV
psob_molten %>% filter(superkingdom %!in% c("Eukaryota")) %>% distinct(OTU) # 0 non-Eukaryota ASV


# get coverages per ASV and analyze
coverage_per_asv <- aggregate(psob_molten$Abundance, by=list(ASV=psob_molten$OTU), FUN=sum)
coverage_per_asv <- coverage_per_asv %>% arrange(desc(x))
summary(coverage_per_asv)


# get most species ordered by frequency
psob_asv_list <- left_join(coverage_per_asv , psob_molten, by = c("ASV" = "OTU")) %>%
  distinct_at(vars("ASV", "x", "superkingdom", "phylum", "class", "order", "family", "genus", "species")) %>% 
  arrange(superkingdom, phylum, class, order, family, genus, species) 

psob_asv_list %>% head(., n = 100)

#                                 ASV       x superkingdom              phylum               class                       species
# 1  f184ca796a5be28dc3cde4bcbe1d26d3 1491686    Eukaryota no hit or reference           undefined          uncultured eukaryote
# 2  5c882557a215b3ca73569393ee7212b6  888969    Eukaryota        Streptophyta           undefined               Cicer arietinum
# 3  a889334a65362e22039f6bd6b31aceff  454680     Bacteria      Planctomycetes      Planctomycetia     Singulisphaera acidiphila
# 4  7c12dd9bdf0ab53af6f927744d2d6649  291288    Eukaryota          Ascomycota      Eurotiomycetes       Arthrocladium tropicale
# 5  e275f1ca63cb2b3e7b039a2ce85b4dac  272358    Eukaryota            Nematoda             Enoplea      Microdorylaimus modestus
# 6  25ad1fd18126a0c3909c61d2dc8b43c4  270294    Eukaryota            Rotifera          Bdelloidea          Philodina sp. cmbb21
# 7  bd2b68bde1426f96a5a6abc71daabc20  255198    Eukaryota       Heterolobosea           undefined Allovahlkampfia sp. PKD 2011b
# 8  58dd134e3736080c944c9655172c18ec  246207     Bacteria      Proteobacteria Alphaproteobacteria              Sphingomonas sp.
# 9  5004de9015b06c0221fb18cd330bc1e4  207718    Eukaryota          Ascomycota     Lecanoromycetes         Acanthothecis fontana
# 10 d96a424887ab33e2e7cc372d8c8fd40b  201579    Eukaryota          Ascomycota       Leotiomycetes        Ascozonus woolhopensis
# 11 634e9c4059da8b996c8a07faabfb488f  200259    Eukaryota            Cercozoa           undefined             Cercozoa sp. TGS3
# 12 3d3dbac4c47854fe7091ae126d8a7438  186507     Bacteria      Proteobacteria Alphaproteobacteria  Erythrobacteraceae bacterium


psob_asv_list %>% 
  arrange(superkingdom, phylum, class, order, family, genus, species) %>%
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development/200814_all_filtered_phyla_at_all_locations.xlsx", overwrite = FALSE)


# V. Export molten Phyloseq object
# ================================


# save or load molten state 
save.image(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_long_export_filtered-image.Rdata")
save(psob_molten, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_long_export_filtered.Rdata")
