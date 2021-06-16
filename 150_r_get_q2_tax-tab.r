# Import Blast results, format, get new taxonomy strings, and write out compatible with Qiime 2 
# ==============================================================================================

# last run 6-Aug-2020
# see https://ropensci.org/tutorials/taxize_tutorial/
#  for handling blast data and getting correct taxonomy strings from the net

# load packages
# --------------
rm(list = ls(all.names = TRUE))
gc()

library("Biostrings") # read fasta file 
library("furrr")      # parallel purrrs - for loading 
library("blastxml")   # read blast xml - get via `library(devtools); install_github("BigelowLab/blastxml")`
library("tidyverse")  # work using tibbles
library("janitor")    # clean column names
library("taxonomizr") # query taxon names
# library("purrr")      # dplyr applies

# Part I: Load Blast results
# --------------------------

# define file path components for listing 
blast_results_folder <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast"
blast_results_pattern <- "*.xml$"

# read all file into lists for `lapply()` -  new file: 68M Aug  4 13:11
blast_results_files <- list.files(path=blast_results_folder, pattern = blast_results_pattern, full.names = TRUE)

# enable multithreading - only useful for multiple files
plan(multiprocess) 

# takes 7-10 hours on four cores - avoid by reloading full object from disk 
# blast_results_list <- furrr::future_map(blast_results_files, blastxml_dump, form = "tibble", .progress = TRUE) 

# save(blast_results_list, file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv.Rdata")
load(file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv.Rdata", verbose = TRUE)

names(blast_results_list) <- blast_results_files # works

# save object and some time by reloading it - comment in if necessary
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# save(blast_results_list, file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv.Rdata")
load(file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv.Rdata", verbose = TRUE)

# create one large item from many few, while keeping source file info fo grouping or subsetting
blast_results_list %>% bind_rows(, .id = "src" ) %>%        # add source file names as column elements
                       clean_names(.) %>%                   # clean columns names 
                       group_by(iteration_query_def) %>%    # isolate groups of hits per sequence hash
                       slice(which.max(hsp_bit_score)) -> blast_results # save subset

# save object and some time by reloading it - comment in if necessary
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# save(blast_results, file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv_sliced.Rdata")
# load(file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv_sliced.Rdata", verbose = TRUE)
nrow(blast_results) # 11675 - 10302, better

# Part II: Re-annotate Blast results
# ----------------------------------

# prepareDatabase not needed to be run multiple times
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 10-Aug-2020: check external hard drive for readily created database files
# prepareDatabase(sqlFile = "accessionTaxa.sql", tmpDir = "/Users/paul/Sequences/References/taxonomizR/", vocal = TRUE) # takes a very long time - avoid by reloading full object from disk

# function for mutate to convert NCBI accession numbers to taxonomic IDs
#  path updated to external value 17.04.2020
get_taxid <- function(x) {accessionToTaxa(x, "/Volumes/HGST1TB/Users/paul/Sequences/References/taxonomizR/accessionTaxa.sql", version='base')}

# function for mutate to use taxonomic IDs and add taxonomy strings
#  path updated to external value 17.04.2020
get_strng <- function(x) {getTaxonomy(x,"/Volumes/HGST1TB/Users/paul/Sequences/References/taxonomizR/accessionTaxa.sql")}

# add tax ids to table for string lookup - probably takes long time
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
blast_results_appended <- blast_results %>% mutate(tax_id = get_taxid(hit_accession)) # takes some time... 

# save(blast_results_appended, file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv_with-taxid.Rdata")
load(file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv_with-taxid.Rdata", verbose=TRUE)

length(blast_results_appended$tax_id) # 11675 - now 10302, better

# look up taxonomy table - takes a long time, needs external database.
tax_table <- as_tibble(get_strng(blast_results_appended$tax_id), rownames = "tax_id") %>% mutate(tax_id= as.numeric(tax_id))
nrow(tax_table) # 11675 now 10302, as above

# getting a tax table without duplicates to enable proper join command later
tax_table <- tax_table %>% arrange(tax_id) %>% distinct(tax_id, superkingdom, phylum, class, order, family, genus, species, .keep_all= TRUE)

# checks
head(tax_table)
nrow(tax_table)             # was 3891, now 2761 - Blast parameters can be kept
all(!duplicated(tax_table)) #        and no duplicated tax ids anymore
lapply(list(blast_results_appended,tax_table), nrow) # first 10302, second deduplicated and with 2761 - ok 

# https://stackoverflow.com/questions/5706437/whats-the-difference-between-inner-join-left-join-right-join-and-full-join
blast_results_final <- left_join(blast_results_appended, tax_table, copy = TRUE) 
nrow(blast_results_final) # 10302 - table has correct length now 

# Part III: Format Blast results for export
# -----------------------------------------

# correcting factors
blast_results_final %>% ungroup(.) %>% mutate(src = as.factor(src)) -> blast_results_final
levels(blast_results_final$src) 

# diagnostic plot - ok 
ggplot(blast_results_final, aes(x = src, y = phylum, fill = phylum)) + 
    geom_bar(position="stack", stat="identity") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

# adjust this if reading in multiple source files and they need to be re-ordered on the plot
# blast_results_final$src <- plyr::revalue(blast_results_final$src, c("/multiple/path/to/files/"))

# diagnostic plot -ok 
# ggplot(blast_results_final, aes(x = src, y = phylum, fill = phylum)) + 
#     geom_bar(position="stack", stat="identity") +
#     theme(axis.text.x = element_text(angle = 45, hjust = 1))

# omitting factor level correction, didn't work as expected
# blast_results_final$src <- factor(blast_results_final$src, levels = c("18S eukaryotes"))

# save object and some time by reloading it
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# save(blast_results_final, file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv_with-ncbi_taxonomy.Rdata")
load(file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv_with-ncbi_taxonomy.Rdata")

# Part II: Format taxonomy table for export and export  
# -----------------------------------------------------

# Formatting taxonomy table - selecting relevant columns
#   to match `#OTUID`, `taxonomy`, `confidence`
q2taxtable <- blast_results_final %>% 
  select("iteration_query_def", "superkingdom", "phylum", "class", "order", "family",
    "genus", "species", "hsp_bit_score") %>% mutate_all(replace_na, "undefined")

# - Insert further cleanup code here if desirable - 

# formatting `taxonomy` column
q2taxtable <- q2taxtable %>% unite(taxonomy, c("superkingdom", "phylum", "class", "order",
  "family", "genus", "species"), sep = ";", remove = TRUE, na.rm = FALSE)

names(q2taxtable) <- c("#OTUID", "taxonomy", "confidence")

# Extending taxonomy table from fasta file 
# ----------------------------------------

# read fasta used for Blasting
fnapth <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/120_18S_merged-seq.fasta"
fna = readDNAStringSet(fnapth)
length(names(fna)) # was 12399 as expected, now 12437

# get length of main table without missing hash values
length(q2taxtable$taxonomy) # 10302 as expected

# add missing hash values from fasts to main table to get complete table  
q2taxtable <- left_join(enframe(names(fna), value = '#OTUID'), q2taxtable, by = c('#OTUID'))

# add indicative taxonomy strings
q2taxtable <- q2taxtable %>% mutate_at(vars(taxonomy), ~replace_na(., "nomatch;nomatch;nomatch;nomatch;nomatch;nomatch;nomatch"))
q2taxtable <- q2taxtable %>% mutate_at(vars(confidence), ~replace_na(., "0"))

q2taxtable$name <- NULL

# Part VI: Export tsv  
# -----------------------------------------------------

# qiime2R compatibility, added 4-May-2020, doesn't help
# names(q2taxtable) <- c("Feature.ID", "Taxon", "Confidence")

write_tsv(q2taxtable, path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_q2taxtable.tsv",
  append = FALSE, col_names = TRUE)
