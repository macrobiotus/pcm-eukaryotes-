# Import Blast results, format, get new taxonomy strings, and write out compatible with Qiime 2 
# ==============================================================================================

# see https://ropensci.org/tutorials/taxize_tutorial/
#  for handling blast data and getting correct taxonomy strings from the net

# load packages
# --------------
rm(list = ls(all.names = TRUE))
gc()


library("furrr")      # parallel purrrs - for loading 
library("blastxml")   # read blast xml - get via `library(devtools); install_github("BigelowLab/blastxml")`

library("tidyverse")  # work using tibbles
library("janitor")    # clean column names
library("taxonomizr") # query taxon names
# library("purrr")      # dplyr applies


# load Blast results
# ------------------

# define file path components for listing 
blast_results_folder <- "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast"
blast_results_pattern <- "*.xml$"

# read all file into lists for `lapply()` usage
blast_results_files <- list.files(path=blast_results_folder, pattern = blast_results_pattern, full.names = TRUE)

# enable multithreading - only useful for multiple files
plan(multiprocess) 

# takes 7-10 hours on four cores - avoid by reloading full object from disk 
# blast_results_list <- furrr::future_map(blast_results_files, blastxml_dump, form = "tibble", .progress = TRUE) 

# save(blast_results_list, file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv.Rdata")
# load(file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv.Rdata", verbose = TRUE)

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
nrow(blast_results) # 11675

# prepareDatabase not needed to be run multiple times
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 17-Apr-2020: check external hard drive for readily created database files
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
# load(file="/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_blast-noenv_with-taxid.Rdata", verbose=TRUE)

length(blast_results_appended$tax_id) # 11675

# look up taxonomy table - takes a long time, needs external database.
tax_table <- as_tibble(get_strng(blast_results_appended$tax_id), rownames = "tax_id") %>% mutate(tax_id= as.numeric(tax_id))
nrow(tax_table) # 11675

# *****************************************
# * continue here on or after 18-Apr-2020 * 
# *****************************************

# getting a tax table without duplicates to enable proper join command later
tax_table <- tax_table %>% arrange(tax_id) %>% distinct(tax_id, superkingdom, phylum, class, order, family, genus, species, .keep_all= TRUE)

# checks
head(tax_table)
nrow(tax_table)             # 3891 - as it should
all(!duplicated(tax_table)) #        and no duplicated tax ids anymore
lapply(list(blast_results_appended,tax_table), nrow) # first 17586, second deduplicated and with 3891 - ok 

# https://stackoverflow.com/questions/5706437/whats-the-difference-between-inner-join-left-join-right-join-and-full-join
blast_results_final <- left_join(blast_results_appended, tax_table, copy = TRUE) 
nrow(blast_results_final) # 17586 - table has correct length now 

# correcting factors
blast_results_final %>% ungroup(.) %>% mutate(src = as.factor(src)) -> blast_results_final
levels(blast_results_final$src) 

# diagnostic plot - ok 
ggplot(blast_results_final, aes(x = src, y = phylum, fill = phylum)) + 
    geom_bar(position="stack", stat="identity") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

blast_results_final$src <- plyr::revalue(blast_results_final$src, c("/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_1_ports_blast_result_euk_only_no_env.txt" =  "1 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_10_ports_blast_result_euk_only_no_env.txt" = "10 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_11_ports_blast_result_euk_only_no_env.txt" = "11 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_12_ports_blast_result_euk_only_no_env.txt" = "12 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_13_ports_blast_result_euk_only_no_env.txt" = "13 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_14_ports_blast_result_euk_only_no_env.txt" = "14 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_15_ports_blast_result_euk_only_no_env.txt" = "15 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_16_ports_blast_result_euk_only_no_env.txt" = "16 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_2_ports_blast_result_euk_only_no_env.txt" = "2 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_3_ports_blast_result_euk_only_no_env.txt" = "3 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_4_ports_blast_result_euk_only_no_env.txt" = "4 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_5_ports_blast_result_euk_only_no_env.txt" = "5 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_6_ports_blast_result_euk_only_no_env.txt" = "6 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_7_ports_blast_result_euk_only_no_env.txt" = "7 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_8_ports_blast_result_euk_only_no_env.txt" = "8 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/110_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_seqeunces_overlap_9_ports_blast_result_euk_only_no_env.txt" = "9 Port(s)"))

# diagnostic plot -ok 
ggplot(blast_results_final, aes(x = src, y = phylum, fill = phylum)) + 
    geom_bar(position="stack", stat="identity") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))


blast_results_final$src <- factor(blast_results_final$src, levels = c("1 Port(s)", "2 Port(s)","3 Port(s)","4 Port(s)","5 Port(s)","6 Port(s)","7 Port(s)","8 Port(s)","9 Port(s)","10 Port(s)","11 Port(s)","12 Port(s)","13 Port(s)","14 Port(s)","15 Port(s)","16 Port(s)"))

# save object and some time by reloading it
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# save(blast_results_final, file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/191009_main_results_calculations__blast_with_ncbi_taxonomy.Rdata")
# load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/191009_main_results_calculations__blast_with_ncbi_taxonomy.Rdata")

# Part II: Plot Tax at ports with blast taxonomy 
# ----------------------------------------------

ggplot(blast_results_final, aes(x = src, y = phylum, fill = phylum)) + 
    geom_bar(position="stack", stat="identity") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

    


# Part III: relate taxonomy ids with route data and plot  
# -----------------------------------------------------

# (copy and adjust original blast subsetting code)

# use alluvial diagram
# https://cran.r-project.org/web/packages/ggalluvial/vignettes/ggalluvial.html
