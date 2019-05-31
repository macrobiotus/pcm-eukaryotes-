
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
* ***08.05.2019*** - creating manifest files and running cutadapt
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
    * committing `1d3e42db8a664d15657234ac8e4a0375682fcd28`
    * again trouble-shooting manifest - import now running - pending, check logs
    * to save disk space
      * erasing all files in `/Users/paul/Documents/AAD_Davis_station/Zenodo/Qiime`
      * erasing all `.qza` files in `/Users/paul/Documents/AAD_The_Ridge/Zenodo/Qiime`
  * now running  `/Users/paul/Documents/AAD_combined/Github/040_imp_qiime.sh` - pending - erasing logfiles after succesful import
    * from file `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_18S_fastq_list_run_2_a.txt`
      * removing sample `119950_S150_L001_R_001,/Users/paul/Sequences/Raw/180208_AAD_Davis_Station/DAVIS_18S/fillers_ramaciotti_(75)/R1-R2/119950_S150_L001_R2_001.fastq.gz,reverse`
    * from file `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_18S_fastq_list_run_5.txt`
      * removing sample `119350_S131_L001_R_001,/Users/paul/Sequences/Raw/180208_AAD_Davis_Station/DAVIS_18S/fillers_ramaciotti_(75)/R1-R2/119350_S131_L001_R1_001.fastq.gz,forward`
    * from file `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_run_5.txt`
      * removing samples due to import error 
        * `592C_S45_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/592C_S45_L001_R1_001.fastq.gz,forward`
        * `592C_S45_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/592C_S45_L001_R2_001.fastq.gz,reverse`
        * `588C_S75_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/588C_S75_L001_R1_001.fastq.gz,forward`
        * `588C_S75_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/588C_S75_L001_R2_001.fastq.gz,reverse`
  * import finished
  * starting to work on `/Users/paul/Documents/AAD_combined/Github/045_cut_adapt.sh`
    * draft moved over - draft complete - setting x flag - testing on local
    * commit - moving to cluster - finished - pulled from cluster
* ***10.05.2019*** - stepping further through pipeline
  * copied over for adjustment subsequent script files
    * `/Users/paul/Documents/AAD_combined/Github/050_chk_demux.sh` - adjusted and running. 
    * `/Users/paul/Documents/AAD_combined/Github/055_dns_paired_dada2.sh` - adjusted - upload to cluster pending - after all data is imported.  
    * `/Users/paul/Documents/AAD_combined/Github/060_16S_check_merging_results.gnu` - so far untouched.
    * `/Users/paul/Documents/AAD_combined/Github/060_18S_check_merging_results.gnu` - so far untouched.
  * commit (`6fa9b6262dc446ec60ee6223be8efcbf85c2bbf7`).
  * **trouble shoot: import - cut-adapt - denoise - the following files**:
    * `/Users/paul/Documents/AAD_combined/Zenodo/Qiime/040_16S_import_run_5.qza`
      * use manifest file `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_run_5.txt
        * removed `585A_S40_L001_R_001_150_L001_R1_001.fastq.gz` and `585A_S40_L001_R_001_151_L001_R2_001.fastq.gz` - ok 
    * `/Users/paul/Documents/AAD_combined/Zenodo/Qiime/040_18S_import_run_1.qza`
      * after removing these samples from the manifest files:
        * non identified yet
    * adjusted target indices in loops of `~/Documents/AAD_combined/Github/040_imp_qiime.sh` - not yet run.
    * adjusted target indices in loops of `~/Users/paul/Documents/AAD_combined/Github/045_cut_adapt.sh` - not yet run
    * adjusted target indices in loops of `~/Documents/AAD_combined/Github/050_chk_demux.sh` - not yet run
  * preparing denoising
    * `/Users/paul/Documents/AAD_combined/Github/055_dns_paired_dada2.sh` - adjusting to check for presence of output files, not run yet.
  * adjusted `/Users/paul/Documents/AAD_combined/Github/055_dns_paired_dada2.sh` - commit
  * rewrote `/Users/paul/Documents/AAD_combined/Github/040_imp_qiime.sh` - ok, skips readily available output files. (But not fully tested.)
  * rewrote `/Users/paul/Documents/AAD_combined/Github/045_cut_adapt.sh` - ok, skips readily available output files. (But not fully tested.)
  * rewrote `/Users/paul/Documents/AAD_combined/Github/050_chk_demux.sh` - ok, skips readily available output files. (But not fully tested.)
  * todo
    * using revised script that skip readily available files repeat import, summary, and denoising until there are no more errors
    * run and check logs of `/Users/paul/Documents/AAD_combined/Github/055_dns_paired_dada2.sh`
    * step further through pipeline - plotting
  * working off above todo - check logs - while iterating
    * `./040_imp_qiime.sh` - ok 
    * `./045_cut_adapt.sh` - running - commit `a3a9a577e4042165fd9a6c09e3efe55f7c5f9212`
    * `./050_chk_demux.sh` - queued on local
* **11.5.2019** stepping further through pipline
  * script ``./045_cut_adapt.sh`` finished -  but not checking logs from remote
  * syncing data to cluster to run denoise with script `./050_chk_demux` on available data, before troubleshooting the other two data sets - uploading to cluster
  * `050_chk_demux` needed fixing on cluster - done remotely and restarted on cluster.
* **13.5.2019** - trouble shooting
  * yesterday - retrieved denoising results from cluster
  * trouble shoot iteration 1
    * checking error logs:
    * remove file pointer `585A_S40_L001_R_001_150_L001_R*` from `16S_run_5` manifest  - ok
    * erase imports - `rm *16S_*_run_5*` and `rm *18S_*_run_1*` - ok
    * deleting error logs
    * restarting pipeline `./040_imp_qiime.sh && ./045_cut_adapt.sh && ./050_chk_demux.sh`
  * trouble shoot iteration 2
    * checking error logs
    * remove file pointers `586A_S84_L001_R_001` and `586A_S84_L001_R_001` from manifest from `16S_run_5` manifest  - ok
    * deleting error logs
    * erase imports - `rm *16S_*_run_5*` and `rm *18S_*_run_1*` - ok
    * restarting pipeline `./040_imp_qiime.sh && ./045_cut_adapt.sh && ./050_chk_demux.sh`
* **14.5.2019** - trouble shooting
  * trouble shoot iteration 3
    * checking error logs (pending)
      * errors in `/Users/paul/Documents/AAD_combined/Zenodo/Qiime/045_18S_trimmed_run_1.txt` - deleting file
        * erasing entries in manifest `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_18S_fastq_list_run_1.txt`
          * `19383_1_18S_AGRF_CCTCTACCTACG_AER6L_S25_L001_R`
      * errors in `/Users/paul/Documents/AAD_combined/Zenodo/Qiime/045_16S_trimmed_run_5.txt`
        * erasing entries in manifest
          * `587B_S83_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/587B_S83_L001_R1_001.fastq.gz,forward`
          * `587B_S83_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/587B_S83_L001_R2_001.fastq.gz,reverse
        * erasing log file
      * erase imports - `rm *16S_*_run_5*` and `rm *18S_*_run_1*` - ok
      * restarting pipeline  `./040_imp_qiime.sh && ./045_cut_adapt.sh && ./050_chk_demux.sh`
  * trouble shoot iteration 4
    * 18S data was trimmed and visualized successfully - erasing logs
    * cant't find error in 16S - restarting pipeline - `rm  *16S_*_run_5*`, and `./040_imp_qiime.sh && ./045_cut_adapt.sh && ./050_chk_demux.sh`
  * trouble shoot iteration 5
    * removing from `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_run_5.txt`
      * `589C_S23_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/589C_S23_L001_R1_001.fastq.gz,forward`
      * `589C_S23_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/589C_S23_L001_R2_001.fastq.gz,reverse`
    * restarting pipeline - `rm  *16S_*_run_5*`, and `./040_imp_qiime.sh && ./045_cut_adapt.sh && ./050_chk_demux.sh`
  * trouble shoot iteration 6
    * removing from `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_run_5.txt`
      * `590B_S93_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/590B_S93_L001_R1_001.fastq.gz,forward
      * `590B_S93_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/590B_S93_L001_R2_001.fastq.gz,reverse`
    * restarting pipeline - `rm  *16S_*_run_5*`, and `./040_imp_qiime.sh && ./045_cut_adapt.sh && ./050_chk_demux.sh`
  * trouble shoot iteration 7
    * removing from `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_run_5.txt`
      * `591C_S89_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/591C_S89_L001_R1_001.fastq.gz,forward
      * `591C_S89_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/591C_S89_L001_R2_001.fastq.gz,reverse`
    * restarting pipeline - `rm  *16S_*_run_5*`, and `./040_imp_qiime.sh && ./045_cut_adapt.sh && ./050_chk_demux.sh`
 * trouble shoot iteration 8
    * removing from `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_run_5.txt`
      * `613C_S47_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/613C_S47_L001_R1_001.fastq.gz,forward`
      * `613C_S47_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/613C_S47_L001_R2_001.fastq.gz,reverse`
    * restarting pipeline - `rm  *16S_*_run_5*`, and `./040_imp_qiime.sh && ./045_cut_adapt.sh && ./050_chk_demux.sh`
  * trouble shoot iteration 9
    * removing from `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_run_5.txt`
      * `833A_S86_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/833A_S86_L001_R1_001.fastq.gz,forward`
      * `833A_S86_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/833A_S86_L001_R2_001.fastq.gz,reverse`
   * restarting pipeline - `rm  *16S_*_run_5*`, and `./040_imp_qiime.sh && ./045_cut_adapt.sh && ./050_chk_demux.sh`
   * trouble shoot iteration 10
    * removing from `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_run_5.txt`
      * `834A_S7_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/834A_S7_L001_R1_001.fastq.gz,forward`
      * `834A_S7_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/834A_S7_L001_R2_001.fastq.gz,reverse`
   * restarting pipeline - `rm  *16S_*_run_5*`, and `./040_imp_qiime.sh && ./045_cut_adapt.sh && ./050_chk_demux.sh`
   * trouble shoot iteration 11
    * removing from `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_run_5.txt`
      * `835A_S50_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/835A_S50_L001_R1_001.fastq.gz,forward`
      * `835A_S50_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/835A_S50_L001_R2_001.fastq.gz,reverse`
   * restarting pipeline - `rm  *16S_*_run_5*`, and `./040_imp_qiime.sh && ./045_cut_adapt.sh && ./050_chk_demux.sh`
* **15.5.2019** - trouble shooting
   * trouble shoot iteration 12
    * removing from `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_run_5.txt`
      * `836C_S31_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/836C_S31_L001_R1_001.fastq.gz,forward`
      * `836C_S31_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/836C_S31_L001_R2_001.fastq.gz,reverse`
   * restarting pipeline - `rm  *16S_*_run_5*`, and `./040_imp_qiime.sh && ./045_cut_adapt.sh && ./050_chk_demux.sh`
      * trouble shoot iteration 13
   * removing from `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_manifest_16S_fastq_list_run_5.txt`
      * `535A_S49_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/535A_S49_L001_R1_001.fastq.gz,forward`
      * `535A_S49_L001_R_001,/Users/paul/Sequences/Raw/181212_AAD_The_Ridge/16S_The_Ridge/535A_S49_L001_R2_001.fastq.gz,reverse`
   * restarting pipeline - `rm  *16S_*_run_5*`, and `./040_imp_qiime.sh && ./045_cut_adapt.sh && ./050_chk_demux.sh`
   * finished successfully - commit
   * starting denoising once cluster becomes available
* **16.5.2019**
  * finished denoising - requested metadata
* **23.5.2019** - getting merging stats and combining data set
  * received metadata
    * file `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_18S_mappingfile.txt` - `a5f696d9878a1dd5a1228a9f727b9443`
    * file `/Users/paul/Documents/AAD_combined/Zenodo/Manifest/035_16S_mappingfile.txt` - `ebd78c1921b3a3d00836f51cec96e172`
  * checking merging statistics - omitting graphics creation - using `qiime2-2019.4`
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_6_denoised_stat.qzv` - low yield, much filtered out, repeat
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_5_denoised_stat.qzv` - low yield, much filtered out, repeat
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_4_denoised_stat.qzv` - low yield, much filtered out, repeat
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_3_denoised_stat.qzv` - low yield, much filtered out, repeat
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_2_b_denoised_stat.qzv` - low yield, much filtered out, repeat
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_2_a_denoised_stat.qzv` - low yield, much filtered out, repeat
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_1_denoised_stat.qzv` - low yield, much filtered out, repeat
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_16S_trimmed_run_5_denoised_stat.qzv` - low yield, little merged, repeat
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_16S_trimmed_run_4_denoised_stat.qzv` - low yield, little merged, repeat
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_16S_trimmed_run_3_denoised_stat.qzv` - low yield, little merged, repeat
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_16S_trimmed_run_2_denoised_stat.qzv` - low yield, little merged, repeat
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_16S_trimmed_run_1_denoised_stat.qzv` - low yield, little merged, repeat
  * adjusting `/Users/paul/Documents/AAD_combined/Github/055_dns_paired_dada2.sh`
    * therein relaxing trimming and error filtering parameters
    * removing failed files in Qiime folder before repetition: `rm 055_*`
    * commit
    * uploading files to Biohpc home to restart denoising on cluster - pending
* **28.5.2019** - getting merging stats and combining data set
  * checking merging statistics - omitting graphics creation - using `qiime2-2019.4`
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_6_denoised_stat.qzv` - ok, perhaps too high yield
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_5_denoised_stat.qzv` - ok, perhaps too high yield
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_4_denoised_stat.qzv` - ok, perhaps too high yield
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_3_denoised_stat.qzv` - ok, perhaps too high yield
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_2_b_denoised_stat.qzv` - ok, perhaps too high yield
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_2_a_denoised_stat.qzv` - ok, perhaps too high yield
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_18S_trimmed_run_1_denoised_stat.qzv` - ok, perhaps too high yield
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_16S_trimmed_run_5_denoised_stat.qzv` - ok, perhaps too low yield
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_16S_trimmed_run_4_denoised_stat.qzv` - ok, perhaps too low yield
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_16S_trimmed_run_3_denoised_stat.qzv` - ok, perhaps too low yield
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_16S_trimmed_run_2_denoised_stat.qzv` - ok, perhaps too low yield
    * `qiime tools view /Users/paul/Documents/AAD_combined/Zenodo/Qiime/055_16S_trimmed_run_1_denoised_stat.qzv` - ok, perhaps too low yield
  * omitting adjustment and execution of `/Users/paul/Documents/AAD_combined/Github/060_16S_check_merging_results.gnu`
  * omitting adjustment and execution of `/Users/paul/Documents/AAD_combined/Github/060_18S_check_merging_results.gnu`
  * adjusting and running `/Users/paul/Documents/AAD_combined/Github/065_merge_data.sh`- **WARNING** using sample and feature summing - ok
    * **WARNING** for 18S data: `Same samples are present in some of the provided tables: 121052_S271_L001_R_001, 119910_S16_L001_R_001, 121057_S286_L001_R_001, 121081_S239_L001_R_001, 120511_S73_L001_R_001, 121031_S203_L001_R_001, 121017_S157_L001_R_001, 121048_S259_L001_R_001, 120504_S50_L001_R_001, 120512_S76_L001_R_001, 121046_S253_L001_R_001, 121040_S232_L001_R_001, 120523_S103_L001_R_001, 121074_S130_L001_R_001, 121060_S295_L001_R_001, 121072_S122_L001_R_001, 121044_S246_L001_R_001, 121056_S283_L001_R_001, 120494_S28_L001_R_001, 121070_S87_L001_R_001, 121029_S196_L001_R_001, 121037_S223_L001_R_001, 121066_S44_L001_R_001, 120505_S54_L001_R_001, 121033_S211_L001_R_001, 121010_S136_L001_R_001, 121064_S8_L001_R_001, 120508_S64_L001_R_001, 121039_S229_L001_R_001, 120489_S11_L001_R_001, 121020_S168_L001_R_001, 120517_S82_L001_R_001, 120492_S22_L001_R_001, 121047_S256_L001_R_001, 121067_S48_L001_R_001, 120496_S34_L001_R_001, 120522_S100_L001_R_001, 121080_S208_L001_R_001, 121083_S247_L001_R_001, 120529_S121_L001_R_001, 120513_S79_L001_R_001, 121032_S207_L001_R_001, 120493_S25_L001_R_001, 121018_S160_L001_R_001, 120507_S61_L001_R_001, 121027_S190_L001_R_001, 121034_S214_L001_R_001, 120487_S3_L001_R_001, 121051_S268_L001_R_001, 121014_S148_L001_R_001, 121061_S298_L001_R_001, 120503_S47_L001_R_001, 121050_S265_L001_R_001, 121054_S277_L001_R_001, 121036_S220_L001_R_001, 120510_S70_L001_R_001, 120519_S90_L001_R_001, 120506_S58_L001_R_001, 121049_S262_L001_R_001, 121013_S145_L001_R_001, 121075_S161_L001_R_001, 121009_S133_L001_R_001, 120528_S118_L001_R_001, 121016_S154_L001_R_001, 121078_S200_L001_R_001, 120520_S94_L001_R_001, 120497_S37_L001_R_001, 120502_S43_L001_R_001, 120490_S15_L001_R_001, 121055_S280_L001_R_001, 120526_S112_L001_R_001, 120509_S67_L001_R_001, 121012_S142_L001_R_001, 121063_S4_L001_R_001, 120531_S129_L001_R_001, 121079_S204_L001_R_001, 121043_S242_L001_R_001, 121024_S181_L001_R_001, 121082_S243_L001_R_001, 121062_S301_L001_R_001, 120518_S86_L001_R_001, 121011_S139_L001_R_001, 121025_S184_L001_R_001, 121042_S238_L001_R_001, 121015_S151_L001_R_001, 121041_S235_L001_R_001, 121068_S51_L001_R_001, 121045_S250_L001_R_001, 121058_S289_L001_R_001, 121022_S175_L001_R_001, 120525_S109_L001_R_001, 120527_S115_L001_R_001, 120488_S7_L001_R_001, 120521_S97_L001_R_001, 121065_S12_L001_R_001, 121071_S91_L001_R_001, 121030_S199_L001_R_001, 121021_S172_L001_R_001, 121073_S126_L001_R_001, 120491_S19_L001_R_001, 121059_S292_L001_R_001, 121026_S187_L001_R_001, 121077_S169_L001_R_001, 121076_S165_L001_R_001, 121038_S226_L001_R_001, 121069_S83_L001_R_001, 120498_S40_L001_R_001, 121028_S193_L001_R_001, 121035_S217_L001_R_001, 120495_S31_L001_R_001, 121053_S274_L001_R_001, 121023_S178_L001_R_001, 120524_S106_L001_R_001, 121019_S164_L001_R_001, 120530_S125_L001_R_001`
  * started to adjust `/Users/paul/Documents/AAD_combined/Github/070_classify_reads.sh`
  * commit for today
* **29.5.2019** - preparing taxonomi classification
  * copying 16S reference taxonomy `cp /Users/paul/Sequences/References/gg_13_8_otus/taxonomy/99_otu_taxonomy.txt /Users/paul/Documents/AAD_combined/Zenodo/Reference/`
  * copying 16S reference sequences `cp /Users/paul/Sequences/References/gg_13_8_otus/rep_set/99_otus.fasta /Users/paul/Documents/AAD_combined/Zenodo/Reference/`
  * copying 18S reference taxonomy `cp /Users/paul/Sequences/References/SILVA_128_QIIME_release/taxonomy/18S_only/99/majority_taxonomy_7_levels.txt /Users/paul/Documents/AAD_combined/Zenodo/Reference/`
  * copying 18S reference sequences `cp /Users/paul/Sequences/References/SILVA_128_QIIME_release/rep_set/rep_set_18S_only/99/99_otus_18S.fasta /Users/paul/Documents/AAD_combined/Zenodo/Reference/`
  * adjusted `/Users/paul/Documents/AAD_combined/Github/070_classify_reads.sh`
  * commit and upload to cluster for execution - calling `./200_overwrite_remote_push.sh`
* **30.5.2019** - data is arriving on cluster
 * adjusted and executing `070_classify_reads.sh`
   * `Thu May 30 11:58:59 EDT 2019: Running Vsearch Classifier on 18S data...` 
* **30.5.2019** - tax assignment evaluation 
 * correcting syntax in script - manually sorting files - ok
 * very low yield
   * 18S -  overwrote log file but was ~32% 
   * 16S - `Matching query sequences: 4387 of 26142 (16.78%)`
   * repeat with query coverage 0.75 instead of 0.90
   * renaming and keeping older tax assignments and log files, by adding string `_coverage90`
   * adjusting `/Users/paul/Documents/AAD_combined/Github/070_classify_reads.sh`
   * creating `/Users/paul/Documents/AAD_combined/Github/075_export_queries_for_inspection.sh`
 * commit, push to cluster and re-run `/Users/paul/Documents/AAD_combined/Github/070_classify_reads.sh` - pending
 
## Todo

## high importance
* **low sequence yield**
  * perhaps repeat denoising with even more and less lenient setting - see 23.05.2019
* **summed counts of duplicated sample names during merging steps**
  * abundances will be meaningless unless this is resolved
  * need to repeat later with intact pipeline and revised manifest files
* **low taxonomic assignment success**
  * repeat assignment
  * export 16S and 18S primers and align to reference data in Geneious


## low importance
* later dissolve `/Users/paul/Documents/AAD_Davis_station`
* later dissolve `/Users/paul/Documents/AAD_Davis_station`
