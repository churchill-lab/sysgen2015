## Scripts

This folder collects all the script used at the workshop, both to build virtual machine and datasets and scripts used during tutorials.

### Tutorials
* [RNASeq_pipeline.sh](https://github.com/churchill-lab/sysgen2015/blob/master/scripts/RNASeq_pipeline.sh) - RNASeq pipeline by KB Choi
* [DOQTL_workshop_2015.R](https://github.com/churchill-lab/sysgen2015/blob/master/scripts/DOQTL_workshop_2015.R) - DOQTL Workshop by Dan Gatti
* [LookAround.R](https://github.com/churchill-lab/sysgen2015/blob/master/scripts/LookAround.R) - Analysis of DO liver 192 RNA & Protein, Part I Walk Through the Data Environment by Gary Churchill
* [RNAProt_Correlation.R](https://github.com/churchill-lab/sysgen2015/blob/master/scripts/RNAProt_Correlation.R) - Analysis of DO liver 192 RNA & Protein, Part II Are RNA and Protein correlated?  by Gary Churchill
* [Mediation_Glul.R](https://github.com/churchill-lab/sysgen2015/blob/master/scripts/Mediation_Glul.R) - Analysis of DO liver 192 RNA & Protein, Part III Mediation Analysis Example: Glul by Gary Churchill
* [mediation.examples.R](https://github.com/churchill-lab/sysgen2015/blob/master/scripts/mediation.examples.R) - Analysis of DO liver 192 RNA & Protein, Part IV Another examples of mediation analysis by Steve Munger

### Other
* [run_one_DO_machine.R](https://github.com/churchill-lab/sysgen2015/blob/master/scripts/run_one_DO_machine.R) - create one machine on Digital Ocean, pull and run docker containers
* [run_many_DO_machine.R](https://github.com/churchill-lab/sysgen2015/blob/master/scripts/run_many_DO_machines.R) - read list of participants, create a machine and docker containers for each of them, create HTML page with the list of machines, email each participant with URL address of his/her machine
* [download_data_from_ftp.sh](https://github.com/churchill-lab/sysgen2015/blob/master/scripts/download_data_from_ftp.sh) - download files from FTP site to `/data` folder
* [get_expected_read_counts.sh](https://github.com/churchill-lab/sysgen2015/blob/master/scripts/get_expected_read_counts.sh) - for a list of samples, download FASTQ file and quantify transcript-level expression for each sample
* [summarize_on_gene_level.r](https://github.com/churchill-lab/sysgen2015/blob/master/scripts/summarize_on_gene_level.r) converd read counts from transcript level to gene level
