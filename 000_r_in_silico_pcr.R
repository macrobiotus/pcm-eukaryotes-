# In-silico PCR to check  primer ‘Euk1391f’ and ‘EukBr’ specificity
# ------------------------------------------------------------------

# Cannon, M. V. et al. In silico assessment of primers for eDNA studies 
#   using PrimerTree and application to characterize the biodiversity 
#   surrounding the Cuyahoga River. Sci. Rep. 6, 22908; doi: 10.1038/srep22908 (2016).

# load packages
library("curl")
library("primerTree") # https://github.com/MVesuviusC/primerTree
                      # compile failed from source as per https://github.com/MVesuviusC/primerTree/blob/master/README.md
                      # using precompiled version http://clustal.org/omega/
library("tidyverse")


# forward primer
# --------------
p1391fF <- "GTACACACCGCCCGTC"

# reverse primer
# --------------
pEukBrR <- "TGATCCTTCTGCAGGTTCACCTAC"


# run remote primer BLAST - prior to that export API key in system shell environment 
spp_result <- search_primer_pair(name='18S', 'GTACACACCGCCCGTC', 'TGATCCTTCTGCAGGTTCACCTAC',
                                 api_key =  Sys.getenv("NCBI_API"),
                                 clustal_options=c(exec='/Users/paul/Biobin/clustalo/clustal-omega-1.2.3-macosx'),
                                 num_aligns=500, total_primer_specificity_mismatch=4
                                )
saveRDS(spp_result, "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/000_r_in_silico_pcr__results.Rds")



# plot primer BLAST results
plot(spp_result, ranks = "class", type = "radial", size = 1, legend_cutoff = 100)
ggsave("210602_18S_primers_in_silico.pdf", plot = last_plot(), 
       device = "pdf", path = "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/ProcessingPlots/",
       scale = 1, width = 300, height = 300, units = c("mm"),
       dpi = 500, limitsize = TRUE)


