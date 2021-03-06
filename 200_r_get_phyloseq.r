# **********************************************
# * Create, filter, and write Physloseq object *
# **********************************************
# 26-Aug-2020, 03-Jan-2021, 04-Jan-2021, 07-Jan-2021, 10-Feb-2021, 16-Feb-2021, 
# 03-Mar-2021

# load packages
# =============
rm(list = ls(all.names = TRUE))
gc()

library("tidyverse")    # work using tibbles
library("phyloseq")     # handle Qiime 2 data in R - best used to generate long dataframe
library("decontam")     # decontamination - check `https://benjjneb.github.io/decontam/vignettes/decontam_intro.html`
library("openxlsx")     # write Excel tables

library("data.table")   # faster handling of large tables
library("future.apply") # faster handling of large tables

library("magrittr")     # more pipes

library("ggpubr")       # combine plots


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
    "RACMO_precip_mm_35to1km", "RACMO_windsp_10m_35to1km", "RACMO_tmp_2m_35to1km",
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

# as per https://stackoverflow.com/questions/11610377/how-do-i-change-the-formatting-of-numbers-on-an-axis-with-ggplot
fancy_scientific <- function(l) {
     # turn in to character string in scientific notation
     l <- format(l, scientific = TRUE)
     # quote the part before the exponent to keep all the digits
     l <- gsub("^(.*)e", "'\\1'e", l)
     # turn the 'e+' into plotmath format
     l <- gsub("e", "%*%10^", l)
     # return this as an expression
     parse(text=l)
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

ggsave("200814_all_unfiltered_phyla_at_all_locations.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)


# Numerical summaries
# -------------------
length(unique(psob_raw_molten$Sample)) # 154 samples from study sites
unique(psob_raw_molten$Sample) %>% grepl(".MM", . , fixed = TRUE) %>% sum # 26 sample Mount Menzies
unique(psob_raw_molten$Sample) %>% grepl(".ME", . , fixed = TRUE) %>% sum # 70 samples Mawson Escarpment
unique(psob_raw_molten$Sample) %>% grepl(".LT", . , fixed = TRUE) %>% sum # 58 samples Lake Terrasovoje
sum(26 + 70 + 58) # 154 - ok

# summary of RLU values
# -----------------------
psob_raw_molten$RLU
RLU_locations <- psob_raw_molten %>% filter(RLU != "NA") %>% dplyr::select(Sample, Location, RLU) %>% unique() %>% group_by(Location) 
RLU_locations %>% print(n = Inf)
table(RLU_locations$Location)

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

# ASV counts unfiltered data
length(unique(psob_raw_molten$OTU)) # 8097
# count eukaryotes and non-eukaryotes 
psob_raw_molten %>% filter(superkingdom %in% c("Eukaryota")) %>% distinct(OTU)  # 2,656 Eukaryota ASV
psob_raw_molten %>% filter(superkingdom %!in% c("Eukaryota")) %>% distinct(OTU) # 5,441 non-Eukaryota ASV

# Analyze coverages per samples
coverage_per_sample <- aggregate(psob_raw_molten$Abundance, by=list(Sample=psob_raw_molten$Sample), FUN=sum)
summary(coverage_per_sample)
hist(coverage_per_sample$x)

# added 16-Jul-2021 - 1 of 6
# --------------------------
p_smpl_cov_uf <- ggplot(coverage_per_sample, aes(x=x)) +
  geom_histogram(color="black", fill="white") +
  geom_vline(aes(xintercept=median(x)), color="blue", size=0.5) + 
  scale_x_continuous(labels=fancy_scientific) +
  theme_bw() +
  labs( title = "Prior to filtering: sequence coverage \nper sample") + 
  ylab("sample count (n = 154)") + 
  xlab("sequences for each sample (median in blue)")

sd(coverage_per_sample$x) # 60940.4

coverage_per_sample %>% filter(., grepl(".MM", Sample , fixed = TRUE)) %>% summary(x)
coverage_per_sample %>% filter(., grepl(".MM", Sample , fixed = TRUE)) %>% pull(x) %>% sd() # 32205

coverage_per_sample %>% filter(., grepl(".ME", Sample , fixed = TRUE)) %>% summary(x) 
coverage_per_sample %>% filter(., grepl(".ME", Sample , fixed = TRUE)) %>% pull(x) %>% sd() # 37983.14

coverage_per_sample %>% filter(., grepl(".LT", Sample , fixed = TRUE)) %>% summary(x)
coverage_per_sample %>% filter(., grepl(".LT", Sample , fixed = TRUE)) %>% pull(x) %>% sd() # 87005.67

# get coverages per ASV and analyze
coverage_per_asv <- aggregate(psob_raw_molten$Abundance, by=list(ASV=psob_raw_molten$OTU), FUN=sum)
coverage_per_asv <- coverage_per_asv %>% arrange(desc(x))
summary(coverage_per_asv)
plot(density(coverage_per_asv$x))

# added 16-Jul-2021 - 2 of 6
# --------------------------
p_asv_cov_uf <- ggplot(coverage_per_asv, aes(x=x)) +
  geom_histogram(color="black", fill="white") +
  geom_vline(aes(xintercept=median(x)), color="blue", size=0.5) + 
  scale_x_continuous(labels=fancy_scientific) +
  theme_bw() +
  labs( title = "Prior to filtering: sequence coverage \nper ASV") + 
  ylab("ASV count (n = 8097)") + 
  xlab("sequences for each ASV (median in blue)")


# get most species ordered by frequency
psob_asv_list <- left_join(coverage_per_asv , psob_raw_molten, by = c("ASV" = "OTU")) %>%
    distinct_at(vars("ASV", "x", "superkingdom", "phylum", "class", "order", "family", "genus", "species")) 

psob_asv_list %>% head(., n = 50)

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
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development/200814_all_unfiltered_phyla_at_all_locations.xlsx", overwrite = TRUE)

psob_asv_list %>% 
  arrange(superkingdom, phylum, class, order, family, genus, species) %>%
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/SpeciesLists/200814_all_unfiltered_phyla_at_all_locations.xlsx", overwrite = TRUE)

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

ggsave("200814_unfiltered_controls.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots",
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

ggsave("200814_raw_library_coverage_and_types.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots",
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

ggsave("200814_decontam_81_likely-contaminats.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots",
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

ggsave("200814_decontam_contaminant_detection_check.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots",
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
  arrange(superkingdom, phylum, class, order, family, genus, species) %>% print(n = Inf) %>%
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/201230_supplemental_information/210301__soilcntrl__200_r_get_phyloseq.xlsx", overwrite = TRUE)

molten_soilcntrl %>% select("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% 
  distinct_at(vars("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species")) %>% 
  arrange(superkingdom, phylum, class, order, family, genus, species) %>% print(n = Inf) %>%
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/SpeciesLists/210301__soilcntrl__200_r_get_phyloseq.xlsx", overwrite = TRUE)

# "Insect Control": 30 ASVs
molten_inscntrl <- psob_molten %>% filter(Description == "ICNTRL", Abundance != 0) 

molten_inscntrl %>% select("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% 
  distinct_at(vars("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species")) %>% 
  arrange(superkingdom, phylum, class, order, family, genus, species) %>%
  print(n = Inf) %>%
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/201230_supplemental_information/210301__inscntrl__200_r_get_phyloseq.xlsx", overwrite = TRUE)

molten_inscntrl %>% select("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% 
  distinct_at(vars("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species")) %>% 
  arrange(superkingdom, phylum, class, order, family, genus, species) %>%
  print(n = Inf) %>%
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/SpeciesLists/210301__inscntrl__200_r_get_phyloseq.xlsx", overwrite = TRUE)

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
  print(n = Inf) %>%
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/201230_supplemental_information/210301__acntrl__200_r_get_phyloseq.xlsx", overwrite = TRUE)

molten_acntrl %>% select("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species") %>% 
  distinct_at(vars("OTU", "superkingdom", "phylum", "class", "order", "family", "genus", "species")) %>%
  arrange(superkingdom, phylum, class, order, family, genus, species) %>% 
  print(n = Inf) %>%
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/SpeciesLists/210301__acntrl__200_r_get_phyloseq.xlsx", overwrite = TRUE)

  
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

ggsave("200814_decontam_effect_on_controls.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots",
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
psob_molten %>% filter(Abundance != 0) # 2,055 x 54



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
psob_molten <- psob_molten %>% as_tibble()

# remove empty data - hope this works
psob_molten <- psob_molten %>% filter(Abundance > 0) 


# Describe object (as above)
# -------------------------

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
         
ggsave("200814_all_filtered_phyla_at_all_locations.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# Numerical summaries
# -------------------
length(unique(psob_molten$Sample)) # 154 samples from study sites
unique(psob_molten$Sample) %>% grepl(".MM", . , fixed = TRUE) %>% sum # 24 sample Mount Menzies
unique(psob_molten$Sample) %>% grepl(".ME", . , fixed = TRUE) %>% sum # 65 samples Mawson Escarpment
unique(psob_molten$Sample) %>% grepl(".LT", . , fixed = TRUE) %>% sum # 56 samples Lake Terrasovoje
sum(24 + 65 + 56) # 154 - ok

# get total sequencing effort
sum(psob_molten$Abundance) #  2 285 773 sequences total - after removal of bacteria and contamination

# Analyze coverages per samples
coverage_per_sample <- aggregate(psob_molten$Abundance, by=list(Sample=psob_molten$Sample), FUN=sum)
summary(coverage_per_sample)
coverage_per_sample %>% filter(., grepl(".MM", Sample , fixed = TRUE)) %>% summary(x) 
coverage_per_sample %>% filter(., grepl(".ME", Sample , fixed = TRUE)) %>% summary(x) 
coverage_per_sample %>% filter(., grepl(".LT", Sample , fixed = TRUE)) %>% summary(x) 

# added 16-Jul-2021 - 3 of 6
# --------------------------
p_smpl_cov_pf <- ggplot(coverage_per_sample, aes(x=x)) +
  geom_histogram(color="black", fill="white") +
  geom_vline(aes(xintercept=median(x)), color="blue", size=0.5) + 
  scale_x_continuous(labels=fancy_scientific) +
  theme_bw() +
  labs( title = "After filtering: sequence coverage per \nsample") + 
  ylab("sample count (n = 142)") + 
  xlab("sequences for each sample (median in blue)")

# get coverages per ASV and analyze
coverage_per_asv <- aggregate(psob_molten$Abundance, by=list(ASV=psob_molten$OTU), FUN=sum)
coverage_per_asv <- coverage_per_asv %>% arrange(desc(x))
summary(coverage_per_asv)

# added 16-Jul-2021 - 4 of 6
# --------------------------
p_asv_cov_pf <- ggplot(coverage_per_asv, aes(x=x)) +
  geom_histogram(color="black", fill="white") +
  geom_vline(aes(xintercept=median(x)), color="blue", size=0.5) + 
  scale_x_continuous(labels=fancy_scientific) +
  theme_bw() +
  labs( title = "After filtering: sequence coverage per \nASV") + 
  ylab("ASV count (n = 766)") + 
  xlab("sequences for each ASV (median in blue)")

# Analyze coverages per ASVs
length(unique(psob_molten$OTU)) # 766
# count eukaryotes and non-eukaryotes 
psob_molten %>% filter(superkingdom %in% c("Eukaryota")) %>% distinct(OTU)  # 766 Eukaryota ASV
psob_molten %>% filter(superkingdom %!in% c("Eukaryota")) %>% distinct(OTU) # 0 non-Eukaryota ASV

# summarize distinct values across the long data frame
show_vars <- c("OTU", "Abundance", "Sample", "BarcodeSequence", "Location", "Description",
  "superkingdom", "phylum", "class", "order", "family", "genus", "species")
psob_molten %>% select(any_of(show_vars)) %>% summarize_all(n_distinct, na.rm = TRUE)

# A tibble: 1 x 13
#     OTU Abundance Sample BarcodeSequence Location Description superkingdom phylum class order family genus species
#   <int>     <int>  <int>           <int>    <int>       <int>        <int>  <int> <int> <int>  <int> <int>   <int>
# 1   766       880    142             142        3           1            1     25    81   200    312   432     495

# get most species ordered by frequency
psob_asv_list <- left_join(coverage_per_asv , psob_molten, by = c("ASV" = "OTU")) %>%
  distinct_at(vars("ASV", "x", "superkingdom", "phylum", "class", "order", "family", "genus", "species")) %>% 
  arrange(superkingdom, phylum, class, order, family, genus, species)  %>%
  arrange(desc(x))

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

# rewrite list for supplement, should include location)
psob_asv_list_and_location <- left_join(coverage_per_asv, psob_molten, by = c("ASV" = "OTU")) %>% rename(TotalAbundance = x) %>% 
  select("ASV", "TotalAbundance", "Abundance", "Location", "Sample", "LongDEC", "LatDEC", "superkingdom", "phylum", "class", "order", "family", "genus", "species") %>%
  arrange( desc(TotalAbundance), ASV, desc(Abundance), Location) %>%
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development/200814_all_filtered_phyla_at_all_locations.xlsx", overwrite = TRUE)

psob_asv_list_and_location <- left_join(coverage_per_asv, psob_molten, by = c("ASV" = "OTU")) %>% rename(TotalAbundance = x) %>% 
  select("ASV", "TotalAbundance", "Abundance", "Location", "Sample", "LongDEC", "LatDEC", "superkingdom", "phylum", "class", "order", "family", "genus", "species") %>%
  arrange( desc(TotalAbundance), ASV, desc(Abundance), Location) %>%
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/SpeciesLists/200814_all_filtered_phyla_at_all_locations.xlsx", overwrite = TRUE)


# V. Export molten Phyloseq object
# ================================

# save or load molten state 
save.image(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_long_export_filtered-image.Rdata")
save(psob_molten, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_long_export_filtered.Rdata")


# VI. Export coordinate list for map
# ===================================
names(psob_molten)
psob_molten %>% 
  distinct_at(vars("Sample", "Location", "LongDEC", "LatDEC")) %>%
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development/200828_coordinates_all_filtered_phyla_at_all_locations.xlsx", overwrite = TRUE)


# VII. Get barplot and other plots of ASV that proved to be significant after MdLs analysis
# =========================================================================

# keep only significant phyla as per MdL's analysis
psob_signif <- psob_molten %>% filter(phylum  == "Basidiomycota" | phylum  == "Chlorophyta" | phylum  == "Ciliophora" | phylum  ==  "Nematoda" | phylum  == "Tardigrada") 


# insert 03.03.2020
# ----------------
#  trouble shooting - sample counts are off bewtween MdL and PC
#  compare Tardigrade counts between PC and ML to check sample counts

# load MdLs file with tardigrade observations
load("/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/210222_MDL_psob_return.Rdata")

tard_sid_ml <- s %>% filter( distinct.otus  != 0) %>% pull(Sample) 
tard_sid_pc <- psob_signif %>% filter( phylum  == "Tardigrada") %>% filter( Abundance  != 0) %>% pull(Sample) 

psob_signif_tard <- psob_signif %>% filter( phylum  == "Tardigrada") %>% filter( Abundance  != 0)
psob_signif_tard_mdlcols <- psob_signif_tard %>% dplyr::select("OTU", "Abundance", "Sample", "Location", "LongDEC", "LatDEC", 
                       "CALCITE", "CHLORITE",
                       "COND", "DOLOMITE", "FELDSPAR", "GARNETS", "KAOLCHLOR", "MICAS", "PH_CACL", "POTA", "RLU", 
                       "SLOPE", "SULPH", "TITANITE") %>% print(n = Inf)
# -------------------------
# end insert 03.03.2020                        

# use data.table to speed up things and to reuse older code from other project 
psob_signif <- psob_signif %>% data.table()

# aggregate counts by location
psob_signif <- psob_signif[, lapply(.SD, sum, na.rm=TRUE), by=c("Location", "OTU", "Sample", "LongDEC", "LatDEC", "superkingdom", "phylum", "class", "order", "family", "genus", "species"), .SDcols=c("Abundance") ]

# add presence-absence abundance column
psob_signif <- psob_signif[ , AsvPresent :=  fifelse(Abundance == 0 , 0, 1, na=NA)]

# understand data structures
future_apply(psob_signif, 2, function(x) length(unique(x)))

# get species counts for Results text 
psob_signif [which(psob_signif$phylum  == "Basidiomycota"),]$species %>% unique() %>% length()
psob_signif [which(psob_signif$phylum  == "Chlorophyta"),]$species %>% unique() %>% length()
psob_signif [which(psob_signif$phylum  == "Ciliophora"),]$species %>% unique() %>% length()
psob_signif [which(psob_signif$phylum  == "Nematoda"),]$species %>% unique() %>% length()
psob_signif [which(psob_signif$phylum  == "Tardigrada"),]$species %>% unique() %>% length()

length(unique(psob_signif$OTU))

# Analyze coverage per samples
coverage_per_sample <- aggregate(psob_signif$Abundance, by=list(Sample=psob_signif$Sample), FUN=sum)
summary(coverage_per_sample)
coverage_per_sample %>% filter(., grepl(".MM", Sample , fixed = TRUE)) %>% summary(x) 
coverage_per_sample %>% filter(., grepl(".ME", Sample , fixed = TRUE)) %>% summary(x) 
coverage_per_sample %>% filter(., grepl(".LT", Sample , fixed = TRUE)) %>% summary(x) 

# added 16-Jul-2021 - 5 of 6
# --------------------------
p_smpl_cov_pfs <- ggplot(coverage_per_sample, aes(x=x)) +
  geom_histogram(color="black", fill="white") +
  geom_vline(aes(xintercept=median(x)), color="blue", size=0.5) + 
  scale_x_continuous(labels=fancy_scientific) +
  theme_bw() +
  labs( title = "After filtering and keeping significant \nphyla: sequence coverage per sample") + 
  ylab("sample count (n = 128)") + 
  xlab("sequences for each sample (median in blue)")

# get coverage per ASV and analyze
coverage_per_asv <- aggregate(psob_signif$Abundance, by=list(ASV=psob_signif$OTU), FUN=sum)
coverage_per_asv <- coverage_per_asv %>% arrange(desc(x))
summary(coverage_per_asv)

# added 16-Jul-2021 - 6 of 6
# --------------------------
p_asv_cov_pfs <- ggplot(coverage_per_asv, aes(x=x)) +
  geom_histogram(color="black", fill="white") +
  geom_vline(aes(xintercept=median(x)), color="blue", size=0.5) + 
  scale_x_continuous(labels=fancy_scientific) +
  theme_bw() +
  labs( title = "After filtering and keeping significant \nphyla: sequence coverage per ASV") + 
  ylab("ASV count (n = 256)") + 
  xlab("sequences for each ASV (median in blue)")


# added 16-Jul-2021 - 4 of 6 - combine histograms 


plt_comb <- ggarrange(ggarrange( p_smpl_cov_uf, p_smpl_cov_pf, p_smpl_cov_pfs, ncol = 3),
                      ggarrange( p_asv_cov_uf, p_asv_cov_pf, p_asv_cov_pfs, ncol = 3), 
                      nrow = 2,
                      align = "hv")

ggsave("210616_coverage_plots.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
         scale = 1, width = 297, height = 210, units = c("mm"),
         dpi = 500, limitsize = TRUE)


# write table for supplemental information will be a "WebTable"
write.xlsx(psob_signif,"/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/SpeciesLists/200104_significant_species.xlsx", overwrite = TRUE)

# get species plot as Figure 2
# plot plain ASV per phylum and port - facetted
ggplot(psob_signif, aes_string(x = "phylum", y = "AsvPresent", fill="phylum")) +
  geom_bar(stat = "identity", position = "stack", size = 0) +
  facet_grid(Location ~ ., shrink = TRUE, scales = "fixed") + 
  theme_bw() +
  theme(strip.text.y = element_text(angle = 0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 8), 
        axis.ticks.y = element_blank()) +
  theme(legend.position = "none") +
  ylab("ASV count")

ggsave("210104_significant_asvs.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development",
         scale = 3, width = 40, height = 30, units = c("mm"),
         dpi = 500, limitsize = TRUE)
         
ggsave("210104_significant_asvs.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots",
         scale = 3, width = 40, height = 30, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# new code below 7-Jan-2020
# =========================

# Numerical summaries
# -------------------
length(unique(psob_signif$Sample)) # 128 samples from study sites
unique(psob_signif$Sample) %>% grepl(".MM", . , fixed = TRUE) %>% sum # 16 sample Mount Menzies
unique(psob_signif$Sample) %>% grepl(".ME", . , fixed = TRUE) %>% sum # 57 samples Mawson Escarpment
unique(psob_signif$Sample) %>% grepl(".LT", . , fixed = TRUE) %>% sum # 55 samples Lake Terrasovoje
sum(16 + 57 + 55) # 128 - ok

# get total sequencing effort
sum(psob_signif$Abundance) #   1 210 855 sequences total - after removal of bacteria and contamination

# Analyze coverages per samples
coverage_per_sample <- aggregate(psob_signif$Abundance, by=list(Sample=psob_signif$Sample), FUN=sum)
summary(coverage_per_sample)
coverage_per_sample %>% filter(., grepl(".MM", Sample , fixed = TRUE)) %>% summary(x) 
coverage_per_sample %>% filter(., grepl(".ME", Sample , fixed = TRUE)) %>% summary(x) 
coverage_per_sample %>% filter(., grepl(".LT", Sample , fixed = TRUE)) %>% summary(x) 

# get coverage per ASV and analyze
coverage_per_asv <- aggregate(psob_signif$Abundance, by=list(ASV=psob_signif$OTU), FUN=sum)
coverage_per_asv <- coverage_per_asv %>% arrange(desc(x))
summary(coverage_per_asv)

# Analyze coverage per ASVs
length(unique(psob_signif$OTU)) # 766
# count eukaryotes and non-eukaryotes 
psob_signif %>% filter(superkingdom %in% c("Eukaryota")) %>% distinct(OTU)  # 766 Eukaryota ASV
psob_signif %>% filter(superkingdom %!in% c("Eukaryota")) %>% distinct(OTU) # 0 non-Eukaryota ASV

# summarize distinct values across the long data frame
show_vars <- c("OTU", "Abundance", "Sample", "BarcodeSequence", "Location", "Description",
               "superkingdom", "phylum", "class", "order", "family", "genus", "species")
psob_signif %>% select(any_of(show_vars)) %>% summarize_all(n_distinct, na.rm = TRUE)

# used as /Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/210602_supporting_material/WebTable 4.xlsx
psob_signif_distinct <- psob_signif %>% distinct(across(c("superkingdom", "phylum", "class", "order", "family", "genus", "species")))
write.xlsx(psob_signif_distinct,"/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/SpeciesLists/200104_significant_species_unique.xlsx", overwrite = TRUE)
saveRDS(psob_signif_distinct, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_uniq_sign_species.Rdata")

# get most species ordered by frequency
psob_asv_list <- left_join(coverage_per_asv , psob_signif, by = c("ASV" = "OTU")) %>%
  distinct_at(vars("ASV", "x", "superkingdom", "phylum", "class", "order", "family", "genus", "species")) %>% 
  arrange(superkingdom, phylum, class, order, family, genus, species)  %>%
  arrange(desc(x))

 # VII. Export coordinate list for map
# ===================================
names(psob_molten)
psob_molten %>% 
  distinct_at(vars("Sample", "Location", "LongDEC", "LatDEC")) %>%
  write.xlsx(.,"/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/200622_display_item_development/200828_coordinates_all_filtered_phyla_at_all_locations.xlsx", overwrite = TRUE)
