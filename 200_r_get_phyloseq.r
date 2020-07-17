# **********************************************
# * Create, filter, and write Physloseq object *
# **********************************************
# 17-Jul-2020

# load packages
# =============
rm(list = ls(all.names = TRUE))
gc()

library("tidyverse")   # work using tibbles
# library("qiime2R")   # various buggy functions to import Qiime2 data remotes::install_github("jbisanz/qiime2R")
library("phyloseq")    # handle Qiime 2 data in R 
# library("microbiomeutilities") # get long data format - remotes::install_github("microsud/microbiomeutilities-shiny")

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

# Retain only Antarctic phylotypes
# This function removes phylotypes contained in Australian controls from the entire data, and keeps only the Antarctic data

subset_pcm <- function (ps_ob){
  
  require("phyloseq")
  
  # OTU table - remove zero count OTUs
  ps_ob.p <- prune_taxa(taxa_sums(ps_ob) > 0, ps_ob)
  
  # isolate control samples
  ps_ob.aac <- prune_samples (sample_names (ps_ob.p)[c (grep ("AAcntrl", sample_names(ps_ob.p)))], ps_ob.p)
  ps_ob.inc <- prune_samples (sample_names (ps_ob.p)[c (grep ("Inscntrl", sample_names(ps_ob.p)))], ps_ob.p)
  ps_ob.soc <- prune_samples (sample_names (ps_ob.p)[c (grep ("soilcntrl", sample_names(ps_ob.p)))], ps_ob.p)
  
  # remove 0 count OTU's from subsets
  ps_ob.aac <- prune_taxa (taxa_sums (ps_ob.aac) > 0, ps_ob.aac)
  ps_ob.inc <- prune_taxa (taxa_sums (ps_ob.inc) > 0, ps_ob.inc)
  ps_ob.soc <- prune_taxa (taxa_sums (ps_ob.soc) > 0, ps_ob.soc)
  
  # filter out Australian control phylotypes
  otu_table (ps_ob.p) <- subset (otu_table (ps_ob.p), subset = 
    rownames (otu_table (ps_ob.p)) %!in% rownames (otu_table (ps_ob.inc)), drop = FALSE)
  otu_table (ps_ob.p) <- subset (otu_table (ps_ob.p), subset =  
    rownames (otu_table (ps_ob.p)) %!in% rownames (otu_table (ps_ob.soc)), drop = FALSE)
   
  # keep only PCM samples
  ps_ob.p <- prune_samples (sample_names (ps_ob.p)[c (grep ("PCM", sample_names (ps_ob.p)))], ps_ob.p)
  
  # keep only PCM phylotypes
  ps_ob.p <- prune_taxa (taxa_sums (ps_ob.p) > 0, ps_ob.p)
  
  # remove unwanted characters from taxonomy strings
  tax_table (ps_ob.p) <- gsub ("__", "", tax_table (ps_ob.p)) 
  tax_table (ps_ob.p) <- gsub ("_", " ", tax_table (ps_ob.p)) 
  tax_table (ps_ob.p) <- gsub ("-", " ", tax_table (ps_ob.p)) 
  tax_table (ps_ob.p) <- gsub (" ", " ", tax_table (ps_ob.p))
  
  # remove zero count taxa again, to be sure
  ps_ob.p <- prune_taxa (taxa_sums (ps_ob.p) > 0, ps_ob.p)
  
  # print summary
  message (length (sample_names (ps_ob.p)), " Samples (", appendLF = FALSE)
  message (100 * round (length(sample_names(ps_ob.p)) / length (sample_names (ps_ob)), digits = 2)," %) and ", appendLF = FALSE)
  message (length (taxa_names(ps_ob.p)), " Taxa (", appendLF = FALSE) 
  message (100 * round (length (taxa_names (ps_ob.p)) / length(taxa_names (ps_ob)), digits = 2)," %) retained")
  
  # return sub-setted object
  return (ps_ob.p)
}

# import Phyloseq objects
# =======================
# https://rdrr.io/github/jbisanz/qiime2R/f/vignettes/vignette.Rmd
#  error message stems from "#"  in taxonomy table
psob_raw <- get_phsq_ob (biom_path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/190_18S_merged-tab_q2_export/features-tax-meta.biom", 
                         sequ_path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/190_18S_merged-tab_q2_export/dna-sequences.fasta",
                         tree_path = NULL)

# Rewriting rank names, as they seem to have been lost
#  rank names from `/Users/paul/Documents/OU_pcm_eukaryotes/Github/150_r_get_q2_tax-tab.r`
colnames(tax_table(psob_raw)) <- c("superkingdom", "phylum", "class", "order",
  "family", "genus", "species")

# copy to accommodate possible future changes
psob_main <- psob_raw

# save initial state after import
# save(psob_main, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import.Rdata")
# save.image(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import-image.Rdata")

load("/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import.Rdata")
load("/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import-image.Rdata")

# filter Phyloseq objects
# =======================

# correct abundances
# ------------------

# subtract blanks
# ---------------

psob_main <- subset_pcm(psob_main)

# select PCM samples
# -------------------

# consolidate on taxonomic level
# ------------------------------

# Enable if desirable, but mind that some filtering will take place.
if(TRUE == FALSE ){

    # checking on which level to agglomerate, choose one value based on preference
    as_tibble(as(tax_table(psob_main), "matrix")) %>% summarize_all(n_distinct, na.rm = TRUE)

    # taxonomy agglomeration, later best done using a tree
    psob_main <- tax_glom(psob_main, taxrank = rank_names(psob_main)[5], NArm = TRUE, bad_empty=c(NA, "undefined", "nomatch"))

    head (tax_table(psob_main))

    # checking on which level was agglomerate, not removal of NA and undefine strings
    as_tibble(as(tax_table(psob_main), "matrix")) %>% summarize_all(n_distinct, na.rm = TRUE)
}


# write files
# ===========

# Phyloseq objects (intermediary)
# -------------------------------

save(psob_main, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/200_all_data_psob_export_filtered.Rdata")

# Long table
# -----------

# melt table
psob_molten <- psmelt(psob_main) 

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
    "BarcodeSequence", "LinkerPrimerSequence", "TmplHash", "LibContent", "SardiID", "XtrOri", "XtrContent"
)

psob_molten <- psob_molten %>% select(all_of(var_order))

# 17.07.2020 - Keep only main areas and Eukaryota
psob_molten <- psob_molten %>% filter(Location %in% c("Mount_Menzies", "Lake_Terrasovoe", "Mawson_Escarpment"))
psob_molten <- psob_molten %>% filter(Superkingdom %in% c("Eukaryota"))

save(psob_molten, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/200_all_data_long_export_filtered.Rdata")

# save state after export
# -------------------------
save.image(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_export-image_filtered.Rdata")

# 17.07.2020 - Plots and numerical summaries for results
# =======================================================

# Numerical summaries
# -------------------

# show data dimension as overview 
psob_molten <- psob_molten %>% as_tibble(.)
# A tibble: 1,300,992 x 48

# summarize distinct values across the long data frame
show_vars <- c("OTU", "Abundance", "Sample", "BarcodeSequence", "Location", "Description",
  "superkingdom", "phylum", "class", "order", "family", "genus", "species")
psob_molten %>% select(any_of(show_vars)) %>% summarize_all(n_distinct, na.rm = TRUE)
# A tibble: 1 x 13
#     OTU Abundance Sample BarcodeSequence Location Description superkingdom phylum class order family genus species
#   <int>     <int>  <int>           <int>    <int>       <int>        <int>  <int> <int> <int>  <int> <int>   <int>
# 1  8448      2264    154             154        3           1            6     57   150   379    675  1243    2051

# get total seqencing effort
sum(psob_molten$Abundance)

# re-check locations
psob_molten %>% distinct(Location,  .keep_all = FALSE) 

# Plotting
# --------

# re-label locations for plotting
psob_molten <- psob_molten %>%  
  mutate(Location = case_when(Location == "Mount_Menzies" ~ "Mount Menzies",
                              Location == "Mawson_Escarpment"  ~ "Mawson Escarpment", 
                              Location == "Lake_Terrasovoe"  ~ "Lake Terrasovoje"))

# re-label Phyla for plotting
length(which (psob_molten$phylum %in% c("nomatch", "undefined")))
length(psob_molten$phylum)

psob_molten$phylum[which(psob_molten$phylum %in% c("nomatch", "undefined"))] <- NA


# this doesn't work for some reason
# psob_molten %>&  mutate(phylum = case_when(phylum == "nomatch" ~ "NA",
#                             phylum == "undefined"  ~ "NA"))

ggplot(psob_molten, aes_string(x = "phylum", y = "Abundance", fill = "phylum")) +
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
