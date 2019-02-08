
# Analysing 16S and 18S data from ***The Ridge*** and ***Davis Station*** in combination.

## Progress notes

* ***14.12.2018*** - creating folder structure, no Git repository yet
  * moving scripts over from `/Users/paul/Documents/AAD_The_Ridge`
  * copying project folder structure from `/Users/paul/Documents/AAD_The_Ridge`
  * adjusting file paths in `Transport` folder `find /Users/paul/Documents/AAD_The_Ridge/Transport -type f \( -iname "*.sh" \) -exec sed -i 's#/AAD_Davis_station#/AAD_The_Ridge#g' {} \; 
* ***03.02.2019*** - stepping through scripts
  * adjusting and running `/Users/paul/Documents/AAD_combined/Github/065_merge_data.sh` - ok.
  * formatting metadata files in `/Users/paul/Documents/AAD_combined/Zenodo/Manifest`
     * using `/Users/paul/Documents/AAD_Davis_station/Eden/metadata_combined.csv` as source file, which was copied over to `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/00_metadata_combined.csv`
     * using `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/05_DAVIS_metadata.tsv` as source file, which was copied over to `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/00_DAVIS_metadata.tsv` (and removed the `#` )
     * further see `/Users/paul/Documents/AAD_combined/Github/070_combine_metadata.R`
     * aborted this need proper metadata file to continue can't do without - erasing files - erasing R script
  * needed to continue - otherwise impossible
     * format as in `/Users/paul/Documents/AAD_Davis_station/Zenodo/Manifest/05_DAVIS_metadata.tsv`
     * include metadata in `/Users/paul/Documents/AAD_Davis_station/Eden/metadata_combined.csv`
     * using sample ids for The Ridge data as in file `/Users/paul/Documents/AAD_The_Ridge/Zenodo/Manifest/05_16S_manifest_sorted.txt`
     * using sample ids for The Ridge data as in file `/Users/paul/Documents/AAD_The_Ridge/Zenodo/Manifest/05_18S_manifest_sorted.txt`
     * assign sample ids from manifest files above to field ids using this file  `/Users/paul/Documents/AAD_The_Ridge/Zenodo/Manifest/00_sample_mapping_file.xlsx`
* ***06.02.2019*** - stepping through scripts
  * received new metadata in file `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/00_Davis_and_TheRidge_metdata_curated.csv`
  * matching manifest files from David and The Ridge data with new metadata file
     * creating `~/Documents/AAD_combined/Github/070_check_sample_ids.r` which reads files from outside project tree and may not work later
     * missing samples in metadata file: `a512A`, `BacMck`, `NoTmpl`, `SoilDNA`, `FunMck`
     * adding samples to `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/05_Davis_and_TheRidge_metdata_curated_corrected.csv`
  * running: `/Users/paul/Documents/AAD_combined/Github/075_smr_features_and_table.sh` - ok
  * running: `/Users/paul/Documents/AAD_combined/Github/085_train_16S_classifier.sh` - ok 
  * running: `/Users/paul/Documents/AAD_combined/Github/095_train_18S_classifier.sh` - ok
* ***06.02.2019*** - stepping through scripts
  * running: `/Users/paul/Documents/AAD_combined/Github/100_classify_reads.sh` - ok
  * running: `/Users/paul/Documents/AAD_combined/Github/110_cluster_sequences.sh` - ok
  * for script `/Users/paul/Documents/AAD_combined/Github/120_summarize_clusters.sh`
     * removing "a" in fornt of The Ridge samples ids (smaller numbers and letter) from file `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/05_Davis_and_TheRidge_metdata_curated_corrected.txt`
     * completed successfully after change
  * running `/Users/paul/Documents/AAD_combined/Github/130_show_classification.sh` - ok
  * checking and committing Transport scripts in `/Users/paul/Documents/AAD_combined/Transport`
  * adjusted before cluster roundtrip, followed by commit
    * `/Users/paul/Documents/AAD_combined/Github/140_align_clustered_repseqs.sh`
    * `/Users/paul/Documents/AAD_combined/Github/150_mask_clustered_alignment.sh`
    * `/Users/paul/Documents/AAD_combined/Github/160_build_clustered_trees.sh`
    * pushing to cluster - do not work locally
    * date arrived on `cbsumm21`
    


## Todo
* foo
