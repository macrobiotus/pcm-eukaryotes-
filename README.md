
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
* ***08.02.2019*** - stepping through scripts
    * data arrived on `cbsumm21`
    * adjusting file paths
    * running: `140_align_clustered_repseqs.sh` - ok
    * running: `150_mask_clustered_alignment.sh` - ok
    * running: `160_build_clustered_trees.sh` - pending
    * need files `120_16S_097_cl_tab.qzv` and `120_18S_097_cl_tab.qzv` for continuation which appear to be missing
       * on local, in parallel to cluster work, correcting mnetadata file in `Manifest folder - also done on cluster
       * rerunning script `120...` locally - also adjusted on cluster - also ran on cluster, successfully 
       * if accidentally overwritten during back sync just redo, file stamps should be 8-Feb-19 around 16:35 
    * saving to remote home before starting script `170...` on cluster 
    * continuing on cluster with script `170...` - ok
    * back on local
    * running `/Users/paul/Documents/AAD_combined/Github/180_convert_clusters.sh` - ok
       * can't import trees. 
       * Committing then changing syntax in tree import request of script `180...`
       * re-running script `180...`
    * full Phyloseq objects available for review of taxonomy strings, committing.
* ***11.03.2018*** - update
   * results should be usable but can be improved:
     * trim 5' end of all sequences to be imported (Not only 3'. Started this but not finished.)
     * Classify using Blast as done for CU data. (Not only 3'. Started this but not finished.)
* ***11.03.2018*** - checking  primer location in full and filtered reference databases
  * updating todo list (see below)
  * opening all relevant files and save as BBedit project
  * check if primers can principally be found in referenece data
     * primers 
       * 16S Forward (27F, Read 1 Primer) p27F `AGAGTTTGATCMTGGCTCAG`
       * 16S Reverse (519R, Read 2 Primer) p519R `GWATTACCGCGGCKGCTG` (RC: `CAGCMGCCGCGGTAATWC`)
       * 18S Forward (1391f, Read 1 Primer) p1391f `GTACACACCGCCCGTC`
       * 18S Reverse (EukBr, Read 2 Primer) pEukBr `TGATCCTTCTGCAGGTTCACCTAC` (RC: `GTAGGTGAACCTGCAGAAGGATCA`)
     * reference data - untrimmed
       * `/Users/paul/Sequences/References/gg_13_8_otus/rep_set/99_otus.fasta`
       * `/Users/paul/Sequences/References/SILVA_128_QIIME_release/rep_set/rep_set_18S_only/99/99_otus_18S.fasta`
     * reference data export - trimmed - and exported (via `qiime tools export` and manual renaming)
       * `/Users/paul/Documents/AAD_combined/Zenodo/Classifier/095_18S_ref-seqs.qza`
       * `/Users/paul/Documents/AAD_combined/Zenodo/Classifier/085_16S_ref-seqs.qza`
       * `/Users/paul/Documents/AAD_combined/Zenodo/Classifier/095_18S_ref-seqs.fasta`
       * `/Users/paul/Documents/AAD_combined/Zenodo/Classifier/085_16S_ref-seqs.fasta`
    * checking primer coverage 16S full db:
       * `grep "AGAGTTTGATC.TGGCTCAG" /Users/paul/Sequences/References/gg_13_8_otus/rep_set/99_otus.fasta`
         * 203452 seqs in db, 68217 occurrences at read start (33%)
       * `grep "CAGC.GCCGCGGTAAT.C" /Users/paul/Sequences/References/gg_13_8_otus/rep_set/99_otus.fasta`
         * 203452 seqs in db, 169747 occurrences in read middle (83%) 
    * checking for flanking regions in 16S truncated db:
       * `grep "AACGAACGCT" /Users/paul/Documents/AAD_combined/Zenodo/Classifier/085_16S_ref-seqs.fasta`
         * 101431 seqs in db, match found at read start as expected, ~11454 times, (~11% approximate!)   
       * `grep "AACTTCGTGC" /Users/paul/Documents/AAD_combined/Zenodo/Classifier/085_16S_ref-seqs.fasta`
         * 101431 seqs in db, match found at read end as expected, ~7856 times, ~7% approximate!)
    * checking primer coverage 18S full db:
       * `grep "GTACACACCGCCCGTC" /Users/paul/Sequences/References/SILVA_128_QIIME_release/rep_set/rep_set_18S_only/99/99_otus_18S.fasta`
         * 48294 seqs in db, 39926 occurrences found towards read end (82%)
       * `grep "GTAGGTGAACCTGCAGAAGGATCA" /Users/paul/Sequences/References/SILVA_128_QIIME_release/rep_set/rep_set_18S_only/99/99_otus_18S.fasta`
         * 48294 seqs in db, 0 occurrences ?
       * not RC as required `grep "TGATCCTTCTGCAGGTTCACCTAC" /Users/paul/Sequences/References/SILVA_128_QIIME_release/rep_set/rep_set_18S_only/99/99_otus_18S.fasta`
         * 4 occurrences, flanking regions is `GGAAACCAAGATT`
     * checking primer coverage 18S:
       * checking primer coverage 18S truncated db - **aborted, can't get flanking regions to primers listed below:**
         * `grep "GTACACACCGCCCGTC" /Users/paul/Documents/AAD_combined/Zenodo/Classifier/095_18S_ref-seqs.fasta`
         * `grep "TGATCCTTCTGCAGGTTCACCTAC" /Users/paul/Documents/AAD_combined/Zenodo/Classifier/095_18S_ref-seqs.fasta`
    *  additionally checking primer coverage in 18S "full" db SILVA version  119:
       * `grep "GTACACACCGCCCGTC" /Users/paul/Sequences/References/SILVA_119_QIIME_release/Silva_119_provisional_release/rep_set_eukaryotes/99/Silva_119_rep_set99_18S.fna`
         * 36378 seqs in db, 30163 occurrences found towards read end (82%)
       * `grep "GTAGGTGAACCTGCAGAAGGATCA" /Users/paul/Sequences/References/SILVA_119_QIIME_release/Silva_119_provisional_release/rep_set_eukaryotes/99/Silva_119_rep_set99_18S.fna`
         * 48294 seqs in db, 4 occurrences ?
  * 16S data is ok, but cannot define region in 18S data - commit repository for now
* ***18.04.2019*** - restart
  * work in this directory from now on for all data
  * received sorted file lists at `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/input_file_lists_reviewed.zip`
  * edited files and stored backup at `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/input_file_lists_reviewed_bak.zip`
  * created and ran `/Users/paul/Documents/AAD_combined/Github/010_format_file_lists.sh`
  * created and ran `/Users/paul/Documents/AAD_combined/Github/015_check_file_presences.sh`
  * created and ran `/Users/paul/Documents/AAD_combined/Github/020_check_fastq_files.sh`
  * started `/Users/paul/Documents/AAD_combined/Github/025_collate_qc_reports.sh` - not done
  * started `/Users/paul/Documents/AAD_combined/Github/030_parse_fastqc_logs.sh` - not done
  * committed repository
* ***23.04.2019*** - collating FastQC reports
  * created and committed `/Users/paul/Documents/AAD_combined/Github/025_collate_qc_reports.sh` (comit `44e6f4a48c20d0777ee88af8447dc15c7031c517`)
  * running and finished
* ***07.05.2019*** - creating manifest files
  * erased all files in `/Users/paul/Documents/AAD_combined/Zenodo/Qiime`
  * last backup is `/Volumes/Time Machine Backups/Backups.backupdb/macmini/2019-05-07-18391`
  * created and ran `/Users/paul/Documents/AAD_combined/Github/030_parse_fastqc_logs.sh`
    * `Check and remove corresponding read file for "/Users/paul/Documents/AAD_combined/Zenodo/FastQC_logs/613C_S47_L001_R1_001_fastqc_log.txt".`
    * `Check and remove corresponding read file for "/Users/paul/Documents/AAD_combined/Zenodo/FastQC_logs/833A_S86_L001_R1_001_fastqc_log.txt".`
  * created and ran `/Users/paul/Documents/AAD_combined/Github/035_create_manifests.sh`
    * todo:
      * mail Eden - which samples to keep
      * clean out sample id mmanually instead of using awk - use `sed` in shell script `gsed '0,/Apple/{s/Apple/Banana/}' filename`
      * revise the following file to keep only samples of interest
        * `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_unwanted_1.txt`
        * `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_unwanted_2.txt`
        * `Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_18S_fastq_list_unwanted_1.txt`
        * `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_18S_fastq_list_unwanted_2.txt`
        * run drafted `/Users/paul/Documents/AAD_combined/Github/040_imp_qiime.sh`
* ***08.05.2019*** - creating manifest files
  * revised and ran `/Users/paul/Documents/AAD_combined/Github/035_create_manifests.sh` - ok
  * manually checking manifests with unwanted files with Edens files - using these files instead of "unwanted" lists
    * `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/02_16S_fastq_list_new_controls.txt`
    * `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/02_16S_manifest_new_controls.txt`
    * `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/02_18S_fastq_list_new_controls.txt`
    * `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/02_18S_manifest_new_controls.txt`
  * further preparing import
    * copying sampels from `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/02_18S_manifest_new_controls.txt` 
      * to `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_18S_fastq_list_run_6.txt`
      * to enable readwise denoising
    * copying samples from `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/02_16S_manifest_new_controls.txt`
      * to `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_run_5.txt`
      * to enable readwise denoising
    * revising `/Users/paul/Documents/AAD_combined/Github/040_imp_qiime.sh`
    * committing
 

## Todo
* restart the whole pipeline
  * as started **18.04.2019**
  * later dissolve `/Users/paul/Documents/AAD_Davis_station`
  * later dissolve `/Users/paul/Documents/AAD_Davis_station`
* export 16S and 18S primers and align to reference data in Geneious
* export 16s and 18S repsets and match to reference data in Geneious
* representative sequences - adapter content and length distribution
* re-import
* re-classify without bad trimming parameter
* create new files consider silenced next steps allow 2x8h work time
