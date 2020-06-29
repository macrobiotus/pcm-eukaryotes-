# Analysing 18S data from **Prince Charles Mountains**

Using **Gradient Forrest Techniques** to analyse abiotic predictor affect on
eukaryotic soil biodiversity. Paul Czechowski 2011-2020, Material released with
Creative Commons Attribution 4.0 International Public License as per
`https://creativecommons.org/licenses/by/4.0/legalcode`

## Progress notes
* **12.20.2020** - adjusting repository for analysis restart
  * commit `4e8dccdaa9ac0501b6bf0655bef4b5d2fe91ae3d` in GitHub folder
  * commit `0ec21a12a03aa416ffd159cd3020f46a9437e510` in Transport folder.
  * removing `x` flags in Github and Transport folders
  * erasing unneeded file in project tree or marking them `red`.
  * collating sequence metadata
    * `cp /Users/paul/Archive/PhD_Thesis/07_agrf_library_prep/140319_AGRF_plate_layout_actual_pooling.xlsx /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200212_18S_pooling.xlsx`
    * `cp /Users/paul/Archive/PhD_Thesis/06_sequence_runs/phd_140401_Illumina_run_18S_Antarctic_pools/140401_barcode_and_primer_info/*  /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/`
  * finding 18S sequnece data - merged reads are available at `/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide`
    * `/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S3_PC_merged.Index.fastq.gz`
    * `/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S3_PC_merged.Read.fastq.gz
    * `/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S4_PC_merged.Index.fastq.gz
    * `/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S4_PC_merged.Read.fastq.gz
  * find old Qiime mapping file - **pending**
  * find predictor data - formatted or unformatted **pending**
  * commit `4e8dccdaa9ac0501b6bf0655bef4b5d2fe91ae3d`
* * **13.02.2020** - adjusting repository for analysis restart
  * `cp /Users/paul/Archive/PhD_Thesis/09_pcm_2011_sample_information/150901_PCM_data_with_ages.xlsm /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Predictors/200213_PCM_predictors.xlsm`
  * edited file to have stable hashes (hashes not generated in sheet anymore by VBA function, but saved within:)
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Predictors/200213_PCM_predictors.xlsx`
  * started R script - **pending**
    * to read in `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Predictors/200213_PCM_predictors.xlsx`
    * import function doesn't handle column names correctly, needs correction
    * check `set_names()` function in script context, as a starting point
* **14.04.2020** - re-start sequencing processing
  * continuing on `/Users/paul/Documents/OU_pcm_eukaryotes/Github/05_join_predictors.R` - **aborted**
  * mapping file drafts already available at
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Predictors/200213_PCM_predictors.xlsx`
  * moving to scratch folder
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Github/05_join_predictors.R`
  * getting sequence data to MacbookPro
    * sequence data is at:
      * `/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S3_PC_merged.Index.fastq.gz`
      * `/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S3_PC_merged.Read.fastq.gz`
      * `/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S4_PC_merged.Index.fastq.gz`
      * `/Users/paul/Sequences/Raw/140401_18S_Illumina_Adelaide/18S4_PC_merged.Read.fastq.gz`
  * adjusting scripts at `/Users/paul/Documents/OU_pcm_eukaryotes/Github`
    * adjusting `/Users/paul/Documents/OU_pcm_eukaryotes/Github/020_check_fastq_files.sh`  - **aborted**
       * check commit for earlier version
    * moving files to scratch
      * `/Users/paul/Documents/OU_pcm_eukaryotes/Github/020_check_fastq_files.sh`
      * `/Users/paul/Documents/OU_pcm_eukaryotes/Github/025_collate_qc_reports.sh`
      * `/Users/paul/Documents/OU_pcm_eukaryotes/Github/030_parse_fastqc_logs.sh`
      * `/Users/paul/Documents/OU_pcm_eukaryotes/Github/035_create_manifests.sh`
    * adjusting and running `/Users/paul/Documents/OU_pcm_eukaryotes/Github/040_imp_qiime.sh`
  * still not working - checking old files
  * obtained original analysis files from 2016 and earlier, from:
    * `/Volumes/Macintosh HD-1/Users/paul/Archive/Papers/Czechowski_et_al_2017/analyses/5_mapping_files`
    * `/Volumes/Macintosh HD-1/Users/paul/Archive/Papers/Czechowski_et_al_2017/analyses`
  * copied to 
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Scratch/160127_data_analysis_1a_18S.sh`
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Manifest/160202_18S_MF.txt`
  * restoring from commit `4e8dccdaa9ac0501b6bf0655bef4b5d2fe91ae3d`
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Github/040_imp_qiime.sh`
  * moving all script to `scratch` folder
  * commit `ed26ec6e134a61ee0bb64c620e825d99d2fe43e0`
  * adjusting `/Users/paul/Documents/OU_pcm_eukaryotes/Github/050_imp_qiime.sh` - **ok**
    * check documentation for further information `http://qiime.org/scripts/split_libraries_fastq.html`
    * uses Qiime 1 code and mapping files
    * writes Fastq's
* **15.04.2020** - re-start sequencing processing
  * running and adjusting:
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Github/050_q1_demultiplex.sh`
      * syntax corrections  
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Github/060_q1_split_samples.sh`
      * creation and running
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Github/070_bash_check_quality.sh`
      * creating and running
      * update `Zenodo/Manifest/fastqc_adapter_reference.tsv`
  * commit `41d2a297a6bc5eb3404fc4328550e8222c2fde5f`
  * erasing all files in `/Users/paul/Sequences/Raw/`
  * compressing imports:
    * `pigz /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/050_plate_1/seqs.*`
    * `pigz /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/050_plate_2/seqs.*`
    * `pigz /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/050_plate_1/*.fastq`
    * `pigz /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/050_plate_2/*.fastq`
  * script `/Users/paul/Documents/OU_pcm_eukaryotes/Github/080_bash_cutadapt.sh`
    * creating
    * checking primers in Geneious
  *  commit `b7ac2c2b37e06ee238349673b3432854e84084cc`
  * checked DADA2 - too complicated - adjusting old Qiime2 scripts
  * created and ran `/Users/paul/Documents/OU_pcm_eukaryotes/Github/090_q2_create_manifests.sh`
  * installing Qiime 2019-10 for cluster compatibility
  * adjusting and running `/Users/paul/Documents/OU_pcm_eukaryotes/Github/100_q2_import.sh` - **pending**
  * commit `9caed66a0551c4268e24d9640ee48e6ac8b8e68c`
  * adjusting and running `/Users/paul/Documents/OU_pcm_eukaryotes/Github/100_q2_import.sh` - **ok**
  * also re-created valid manifest file
  * commit `cd88ed0e0836bb26c3aae2a185ed6890e2db0438`
* **16.04.2020** - re-start sequencing processing
  * adjusted `/Users/paul/Documents/OU_pcm_eukaryotes/Github/110_q2_denoise.sh`
  * commit `fbf6117688023906d86ca83fd7a308f052500620`
  * denoising started after syntax corrections, finishes quite soon
    * using Qiime 2019-10 to stay compatible with Cornell cluster
  * adjusted and ran:
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Github/115_gnu_plot_denoise_plate1.gnu`
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Github/115_gnu_plot_denoise_plate2.gnu`
    * results in `svgs` look well
  * wrote and ran `/Users/paul/Documents/OU_pcm_eukaryotes/Github/120_q2_merge.sh`
  * wrote and ran  `/Users/paul/Documents/OU_pcm_eukaryotes/Github/130_q2_summary.sh`
  * commit `fb06ccb18f8f00c936e6a5ca4728f5f5970266e3`
  * exporting sequences for BLAST taxonomy annotation on cluster
    * `qiime tools export --input-path /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/120_18S_merged-seq.qza --output-path /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/120_18S_merged-seq.fasta`
    * `pigz /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/120_18S_merged-seq.fasta`
    * file names are:
     * `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/140_18S_merged-seq.fasta`
     * `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/140_18S_merged-seq.fasta.gz`
  * copying environmental definition file for BLAST script
    * `cp ~/Documents/CU_combined/Zenodo/Blast/190718_gi_list_environmental.txt ../Zenodo/Blast/`
  * preparing blast on cluster by reviewing
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Transport/050_sync_ncbi_nt_to_scratch.sh`
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Github/140_bash_fasta_blast.sh`
  * blast taxonomy assignment ongoing on cluster - finished after 6 h **ok**
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/110_18S_merged-seq_blast-noenv.xml.gz`
* **17.04.2020** - sequence processing - get taxonomy table
  * get `.tsv` from Blast results 
    * at `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/140_18S_merged-seq.fasta.gz`
    * column headers are:
     * `#OTUID`, `taxonomy`, `confidence`
    * example taxonomy table at  `/Users/paul/Documents/CU_combined/Zenodo/Qiime/180_18S_eDNA_samples_clustered99_tab_Eukaryote-shallow_qiime_artefacts_non_phylogenetic/taxonomy.tsv`
    * starting to work on `/Users/paul/Documents/OU_pcm_eukaryotes/Github/150_r_get_q2_tax-tab.r`
      * installed all packages
      * updated paths to database on external external drive
      * waiting for `.xml` input to finish (since 15:15)
    * commit ` 8a5d9d565cb7f0f5398e2d1a0308c9b3d78cf9eb`
* **18.04.2020** - getting taxonomy table
  * progressed passed `.xml` import as indicated in script
  * commit `e657584f98d43f73e715b2eb7c0bd4968c64`
  * taxonomy table now available at
    * `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_q2taxtable.tsv` 
  * commit `dc91a5f4d69bdfa1e3219293774d654aaff38a8`
* **19.04.2020** - combining metadata for Qiime import
  * script `/Users/paul/Documents/OU_pcm_eukaryotes/Github/160_r_prep_q2_predictor-tab.r`
  * mapping file `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/160202_18S_MF.txt`
  * predictor source `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200213_PCM_predictors.xlsx`
    * exported predictors `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200419_pcm_atp.csv`
      * reviewed for import - **ok**
    * exported predictors `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200419_pcm_geog.csv`
       * reviewed for import - **ok**   
    * exported predictors `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200419_pcm_xrd.csv`
      * reviewed for import - **ok**    
    * exported predictors `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200419_pcm_csbp.csv`
       * reviewed for import - **ok** 
* **20.04.2020** - data verification
  * checking number formats in above `csv` files - **ok**
  * checking hash formats via `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Metadata/200420_hash_correction.xlsm`
    * exporting new mapping files with checked hash keys
      * `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/200420_18S_MF_corrected.txt`
      * `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/200420_18S_MF_corrected.xlsx`
    * checking all data files mentioned above for correct hash keys - **ok**
    * re-insert hash character in `#SmpleID`
  * in `* script /Users/paul/Documents/OU_pcm_eukaryotes/Github/160_r_prep_q2_predictor-tab.r`
    * table import is done
    * commit `f836ff3f885c6172720ffad4cf167930e4d32566`
* **20.04.2020** - data merging finished
  * finished `/Users/paul/Documents/OU_pcm_eukaryotes/Github/160_r_prep_q2_predictor-tab.r`
    * writes to `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/210421_18S_MF_merged.txt`
    * created `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/210421_18S_MF_merged_q2.txt`
      * added `#` version for Qiime
* **20.04.2020** - data merging finished
  * finished `/Users/paul/Documents/OU_pcm_eukaryotes/Github/160_r_prep_q2_predictor-tab.r`
    * writes to `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/210421_18S_MF_merged.txt`
    * created `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/210421_18S_MF_merged_q2.txt`
      * added `#` version for Qiime`
  * commit `6bc9dd6dfb530aa4634f6ad08b29af39dd207a10`
  * started to add code for transformations in `/Users/paul/Documents/OU_pcm_eukaryotes/Github/160_r_prep_q2_predictor-tab.r`
    * **unfinished, see todo**
* **24.04.2020** - correct data errors and implement transformation
  * worked on script `/Users/paul/Documents/OU_pcm_eukaryotes/Github/160_r_prep_q2_predictor-tab.r`
    * duplicate hash values in input tables have been resolved by going back to source tables
    * implemented `clr` transformation for xrd data
    * commit `fa9ffdd3ba20b9bfe8abae9f1c4947d1aca0b8cd`
* **01.05.2020** - working on `/Users/paul/Documents/OU_pcm_eukaryotes/Github/160_r_prep_q2_predictor-tab.r`
  * preprocessing completed as in Czchowski 2016 RSOCOS
  * **ok** - introduced plotting code
  * **ok** - writing intermediate object for Michel de Lange
  * **ok** - writing final object object as `.tsv` for Qiime import
  * commit `62951db4d44e135c7fea62a4ebd765bac5066359`
* **02.05.2020** - working on `/Users/paul/Documents/OU_pcm_eukaryotes/Github/160_r_prep_q2_predictor-tab.r`
  * save backup copy for later processing
  * simplifying script and export
  * rewrote `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/200501_18S_MF_merged.txt`
  * adjusted `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Manifest/200501_18S_MF_merged_q2_import.txt`
  * importing taxonomy file:
        `qiime tools import \
           --input-path  "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_q2taxtable.tsv" \
           --output-path "/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_q2taxtable.qza" \
           --type 'FeatureData[Taxonomy]' \
           --input-format HeaderlessTSVTaxonomyFormat || { echo 'Taxonomy import failed' ; exit 1; }`
  * adjusting `/Users/paul/Documents/OU_pcm_eukaryotes/Github/170_q2_summary.sh`
    * working, but Blast files incomplete:
      * some ids in `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/140_18S_merged-seq.fasta`
      * are not in `~/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_q2taxtable.tsv`
      * converting `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/110_18S_merged-seq_blast-noenv.xml`
      * for further inspection as `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/110_18S_merged-seq_blast-noenv.txt`
      * sequence counts:
        * 12399 in `.fasta` file `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/140_18S_merged-seq.fasta`
        * 11675 in `.xml`:  (`awk '{print $1}'  /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/110_18S_merged-seq_blast-noenv.txt | sort | uniq | wc -l`)
        * 11675 in q2 tax table: `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_q2taxtable.tsv`
  * commit `dea8784c3aa3004a7794a87ac79bf2629c14b699`
* **03.05.2020** - extending taxonomy table with dropped blast hits
  * working on `/Users/paul/Documents/OU_pcm_eukaryotes/Github/150_r_get_q2_tax-tab.r`
  * re-wrote `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_q2taxtable.tsv`
  * rewrote `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/150_18S_merged-seq_q2taxtable.qza` manually as above
  * now working: `/Users/paul/Documents/OU_pcm_eukaryotes/Github/170_q2_summary.sh`
  * taxonomy table corrected **ok**
  * commit ` f8c36917a67326ee5bddc2f288025ffbf6d0ae05`
  * started working on `/Users/paul/Documents/OU_pcm_eukaryotes/Github/200_r_get_phyloseq.r`
  * commit `63ff7efbe3caaa8f05bf077cb4e39108f90b05fa`
* **04.05.2020** - testing `qiime2R`
  * `qiime2R` import function (`qza_to_phyloseq()`) is buggy.
  * `150_r_get_q2_tax-tab.r` should be yesterday's state. 
  * commit `61ecbb94869d87ecea2779db68368467628c5033`
* **05.05.2020** - creating Phyloseqs objects
  * working on `~/Documents/OU_pcm_eukaryotes/Github/200_r_get_phyloseq.r`
  * using bash based conversion, as implemented in `/Users/paul/Documents/OU_pcm_eukaryotes/Github/190_q2_export_objects.sh`
  * got long format for MdL
  * created Phyloseq object
  * rudimentary version working - create tape archive for Mdl
        `gtar -cf /Users/paul/Documents/OU_pcm_eukaryotes/Tarballs/200_r_get_phyloseq.results.tar.gz \
           /Users/paul/Documents/OU_pcm_eukaryotes/Github/200_r_get_phyloseq.r \
           /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/200_all_data_long_export.Rdata \
           /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Processing/200_all_data_psob_export.Rdata \
           /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_export-image.Rdata \
           /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import-image.Rdata \
           /Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/R/200_all_data_psob_import.Rdata`
  * commit `8ae070056cc00c5f61b98a9929c840f166cfe30d`
* **06.05.2020** - creating Phyloseqs objects
  * checking `~/Documents/OU_pcm_eukaryotes/Github/200_r_get_phyloseq.r`
* **07.05.2020** - working on obtaining trees
  * creating and running `/Users/paul/Documents/OU_pcm_eukaryotes/Github/175_q2_seq_align.sh`  
  * creating and running `/Users/paul/Documents/OU_pcm_eukaryotes/Github/177_q2_mask_align.sh`
  * creating and running `/Users/paul/Documents/OU_pcm_eukaryotes/Github/180_q2_get_fastree.sh`
* **29.06.2020** -  in `200_r_get_phyloseq.r` implement filtering
  * done: `160 Samples (88 %) and 8448 Taxa (68 %) retained`
  * writing new output files as described in script (check commit history for details)
  * commit ``

* **todo**
  * **before publication**
    * see _02.05.2020_ - find cause negative XRD values in `/Users/paul/Documents/OU_pcm_eukaryotes/Github/160_r_prep_q2_predictor-tab.r`
    * see _02.05.2020_ - find cause for missing sequences in `/Users/paul/Documents/OU_pcm_eukaryotes/Zenodo/Blast/110_18S_merged-seq_blast-noenv.txt`
  * export qiime objects using shell script
  * in `160_r_prep_q2_predictor-tab.r`
    * possibly: include variable sorting code and remove from `200_r_get_phyloseq.r`
  * in `200_r_get_phyloseq.r`
    * possibly: check contaminating sequences 
    * possibly: implement tree tip agglomeration
    * possibly: adjust variable sorting code to match `160_r_prep_q2_predictor-tab.r`
  * in new version of predictor pre-processing
    * adjust Caret package
      * co-linearities
      * dummy variables
  * add trees to Phyloseq
    * then use `phyloseq::tip_glom()` instead of `phyloseq::tax_glom()` in `/Users/paul/Documents/OU_pcm_eukaryotes/Github/200_r_get_phyloseq.r`
  * check masked alignment - adjust older script
  
