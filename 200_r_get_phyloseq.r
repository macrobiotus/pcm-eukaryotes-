# **********************************************
# * Create, filter, and write Physloseq object *
# **********************************************
# 05-May-2020

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
save(psob_main, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import.Rdata")
save.image(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import-image.Rdata")

# filter Phyloseq objects
# =======================

# correct abundances
# ------------------

# subtract blanks
# ---------------

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

# Phyloseq object
# ---------------

save(psob_main, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/200_all_data_psob_export.Rdata")

# Long table
# -----------

psob_molten <- psmelt(psob_main) 

names(psob_molten)

# define variable order - follows "190_q2_export_objects.sh"
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

save(psob_molten, file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/200_all_data_long_export.Rdata")

# save state after export
# -------------------------
save.image(file = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_export-image.Rdata")


# 06.05.2020 - data check 
# -----------------------
# show data dimension as overview 
psob_molten <- psob_molten %>% as_tibble(.)
# A tibble: 2,256,618 x 48

# compare Location strings with MdLs email 
psob_molten %>% distinct(Location,  .keep_all = FALSE) 
# A tibble: 8 x 1
#   Location         
#   <chr>            
# 1 Mount_Menzies    
# 2 Mawson_Escarpment
# 3 Lake_Terrasovoe  
# 4 E_Ant_coast      
# 5 Reinbolt_Hills   
# 6 Australia        
# 7 EBU_lab          
# 8 SARDI_lab   

# summarize distinct values across the long data frame
show_vars <- c("OTU", "Abundance", "Sample", "BarcodeSequence", "Location", "Description",
  "superkingdom", "phylum", "class", "order", "family", "genus", "species")
psob_molten %>% select(any_of(show_vars)) %>% summarize_all(n_distinct, na.rm = TRUE)
# A tibble: 1 x 13
#     OTU Abundance Sample Location Description superkingdom phylum class order family genus species BarcodeSequence
#   <int>     <int>  <int>    <int>       <int>        <int>  <int> <int> <int>  <int> <int>   <int>           <int>
# 1 12399      3102    182        8           6            6     64   181   477    929  1796    3042             182

# check for correct length of taxon columns - needs to sum up to 2,256,618 - ok
length(which(psob_molten$species=='undefined')) #    2184
length(which(psob_molten$species!='undefined')) # 2254434

length(which(psob_molten$genus=='undefined')) #  769314
length(which(psob_molten$genus!='undefined')) # 1487304

length(which(psob_molten$genus=='undefined')) #  769314
length(which(psob_molten$genus!='undefined')) #  1487304
