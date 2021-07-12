# Add Blast results to Supplemental Online Materials 
# ==================================================

# last run 13-July-2021
# see https://ropensci.org/tutorials/taxize_tutorial/
#  for handling blast data and getting correct taxonomy strings from the net

# load packages
# --------------
rm(list = ls(all.names = TRUE))
gc()

library("magrittr")
library("readxl")
library("openxlsx")     # for writing summary tables

library("Biostrings") # read fasta file 
library("furrr")      # parallel purrrs - for loading 
library("blastxml")   # read blast xml - get via `library(devtools); install_github("BigelowLab/blastxml")`
library("tidyverse")  # work using tibbles
library("janitor")    # clean column names
library("taxonomizr") # query taxon names
library("purrr")      # dplyr applies

# Part I: Load Blast results
# --------------------------

# define file path components for listing 
blast_results_folder <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast"
blast_results_pattern <- "*.xml$"

# read all file into lists for `lapply()` -  new file: 68M Aug  4 13:11
blast_results_files <- list.files(path=blast_results_folder, pattern = blast_results_pattern, full.names = TRUE)

# enable multithreading - only useful for multiple files
plan(multicore) 

# takes 7-10 hours on four cores - avoid by reloading full object from disk 
blast_results_list <- furrr::future_map(blast_results_files, blastxml_dump, form = "tibble", .progress = TRUE) 

save(blast_results_list, file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv.Rdata")
load(file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv.Rdata", verbose = TRUE)

names(blast_results_list) <- blast_results_files # works

# save object and some time by reloading it - comment in if necessary
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
save(blast_results_list, file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv.Rdata")
load(file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv.Rdata", verbose = TRUE)

# check table
names(blast_results_list[[1]])

# hash keys of query sequences
unique(blast_results_list[[1]]$`Iteration_query-def`)

# count observations for each hash key 
blast_results_list[[1]] %>% count(`Iteration_query-def`) %>% pull(n) %>% hist
blast_results_list[[1]] %>% count(`Iteration_query-def`) %>% pull(n) %>% summary


# create one large item from many few, while keeping source file info fo grouping or subsetting
blast_results_list %>% bind_rows(, .id = "src" ) %>%        # add source file names as column elements
                       clean_names(.) %>%                   # clean columns names 
                       group_by(iteration_query_def) %>%    # isolate groups of hits per sequence hash
                       slice(which.max(hsp_bit_score)) -> blast_results # save subset

# save object and some time by reloading it - comment in if necessary
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# save(blast_results, file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv_sliced.Rdata")
load(file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv_sliced.Rdata", verbose = TRUE)
nrow(blast_results) # 11675 - 10302, better

# Part II: Re-annotate Blast results
# ----------------------------------

# inspect Blast results
blast_results %<>% as_tibble
blast_results %>% arrange(iteration_query_def)

# merge on `iteration_query_id`
path_a <- "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/210602_supporting_material/WebTable 4.xlsx"
path_b  <- "/Users/paul/Documents/OU_pcm_eukaryotes/Manuscript/210602_supporting_material/WebTable 5.xlsx"

som_a <- read_excel(path_a)
som_b <- read_excel(path_b)

# check matching fields
som_a$ASV %in% blast_results$iteration_query_def
som_b$OTU %in% blast_results$iteration_query_def

# re-write tables
som_a %>% left_join(blast_results, by = c("ASV" = "iteration_query_def")) %>% write.xlsx(.,  file = path_a, asTable = TRUE, overwrite = FALSE)
som_b %>% left_join(blast_results, by = c("OTU" = "iteration_query_def")) %>% write.xlsx(., file = path_b, asTable = TRUE, overwrite = FALSE)

