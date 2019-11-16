# VirMiner
Source code for the key steps (including quality control of metagenomic raw reads and phage contig indentification) of VirMiner, which is available at [http://sbb.hku.hk/VirMiner/](http://sbb.hku.hk/VirMiner/).  
The souce code was integrated into two parts: VirMiner PipelineForQC and VirMiner PipelineForVirContigIndentification

## VirMiner pipelineForQC
Here we provide the command-line perl scripts to quality control for metagenomic data, which was used in VirMiner. It can be used to process raw reads of metagenomic samples in FASTQ format by removing the adapters, low quality reads, bases or PCR duplicates.

### Requirements:
#### install perl  
Linux/macOS: A version of Perl is already installed  
Windows: You may need to install one of the versions available at [perl.org](http://www.perl.org/get.html).  
After installation, run in linux system or terminal apps, such as Terminal on macOS, and Command Prompt on Windows.  

### How to Run
command-line perl scripts: `./scripts/PipelineForQC/fqc.pl`  
Run `perl ./scripts/PipelineForQC/fqc.pl -h `to see the parameters of this command line. 

```
$ perl ./scripts/PipelineForQC/fqc.pl -h

Usage for single: $0 $command -i s_1_IDX1_1.fastq -o s_1_IDX1
      for Paired: $0 $command -f s_1_IDX1_1.fastq -r s_1_IDX1_2.fastq -p -o s_1_IDX1

      $command	<str>	: adpter,quality,adp_qual and duplication

Options:
	-i	<str>	: Fastq file (Single)
	-f	<str>	: Forward fastq file (Paired-End)
	-r	<str>	: Reverse fastq file (Paired-End)
	-a	<str>	: Adapter sequence (Default: GATCGGAAGA)
	-c	<Ns>	: Discard sequences lower than N quality. (Default: 20)
	-q	<Ns>	: Quality format 33/64 (Default: 33)
	-l	<Ns>	: Discard sequences shorter than N nucleotides. (Default: 30)
	-o	<str>	: Output prefix
	-p       	: Paired-End Model (Default: Single)
	-v       	: Prints version of the program
	-h       	: Prints this usage summary
```

A sample "run" command:  
input metagenomic raw reads in pair-end FASTQ format (test_1.fastq, test_2.fastq):  
`perl fqc.pl all -p -f test_1.fastq -r test_2.fastq -o test_qc`  
Output clean reads after quality control : `test_qc_1.fastq` and `test_qc_2.fastq`.  

input metagenomic raw reads in single FASTQ format (test_fastq):  
`perl fqc.pl all -i test.fastq -o test_qc`  
Output clean reads after quality control : `test_qc.fastq`.  

## VirMiner PipelineForVirContigIdentification
 
Before running this pipeline to identify phage contigs, you need to prepare input files: 1) fasta file of assembled contigs; 2) the clean reads in pair-end FASTQ format (refers to the output file of VirMiner pipelineForQC).
 

### Requirements:  
1.[rpsblast](http://nebc.nox.ac.uk/bioinformatics/docs/rpsblast.html) (version 2.2.26)  
2.[Diamond](http://ab.inf.uni-tuebingen.de/software/diamond/)  
3.[KOBAS](http://kobas.cbi.pku.edu.cn/) (version 2.0)  
4.[hmmsearch](http://hmmer.org/)  
5.[bwa](http://bio-bwa.sourceforge.net/) (version 0.7.12)  
6.[BLASTP](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download) (version 2.2.26)  
7.[R package randomForest](https://cran.r-project.org/web/packages/randomForest/index.html)  
8.[GeneMark](http://exon.gatech.edu/GeneMark/license_download.cgi)


### Database
1.CDD  
2.updated POG database (uPOGs)  
3.viral hallmark  
4.viral protein family  
5.KO  
6.pre-built_random_forest_model  
You can download the files of databases from here (http://147.8.185.62/VirMiner/downloads/database/).   


### Test data
You can download the test samples (including P5E0_test, P5E7_test etc.) from VirMiner website ([http://147.8.185.62/VirMiner/tasks/exampleData/quality_control/](http://147.8.185.62/VirMiner/tasks/exampleData/quality_control/)) then place them in `VirMiner/data/quality_control/`. For your better understanding, I will take P5E0_test as an example below to show how to run the scripts. 

### The working directory  
 Firstly, create a folder named "VirMiner" under you own directory using the comand line:  
`mkdir VirMiner`  
#### The directory for depositing scripts and databases  
Create a folder named "bin" under VirMiner folder using the comand line:  
`mkdir VirMiner/bin`  
Then put all the scripts of PipelineForVirContigIdentification in the "bin" folder, it should be like this:  

Then make a new folder named "database" under the VirMiner folder (`VirMiner/database`) using the command line:  
`mkdir VirMiner/database`  
Placing these files of databases in `/VirMiner/database/`, you should have these files in your database folder:  
![alt text](https://github.com/TingtZHENG/VirMiner/blob/master/pic/database_folder.png)  

#### The working directory for depositing your own data  
Create a folder named "data" under VirMiner folder for deposing your data using the comand line:  
`mkdir VirMiner/data`  
Create the following folders under data folder to deposit the output files for each step using the comand line:
```
mkdir VirMiner/data/quality_control  
mkdir VirMiner/data/genome_assembly
mkdir VirMiner/data/gene_prediction
mkdir VirMiner/data/functional_annotation
mkdir VirMiner/data/POG_2016_annotation
mkdir VirMiner/data/average_depth_relative_abundance
mkdir VirMiner/data/viral_contig_identification
```

### Input and Output files  
#### Input files  
Option 1. Clean reads in pair-end FASTQ format and the assembled contigs in FASTA format:  
Firstly you need to change the pair-end FASTQ file names and make it ended with "_qc_1.fastq" or "_qc_2.fastq",for example, "P5E0_test_qc_1.fastq" and "P5E0_test_qc_2.fastq". Then place them in `VirMiner/data/quality_control/`;
Secondly, create a folder named "sample_name.assembly.idba" under genome_assembly folder. For example, if you have a sample named "P5E0", the command could be used like this:  
`mkdir VirMiner/data/genome_assembly/P5E0_test.assembly.idba`
Then rename your contig file to "contig.fa" and put it in the directory: `VirMiner/data/genome_assembly/sample_name.assembly.idba`, it should be like this:  

Option 2. Clean reads in pair-end FASTQ format only:  
Firstly you need to change the pair-end FASTQ file names and make it ended with "_qc_1.fastq" or "_qc_2.fastq",for example, "P5E0_test_qc_1.fastq" and "P5E0_test_qc_2.fastq". Then place them in `VirMiner/data/quality_control/`  
in this case, you can choose IDBA_UD to do genome assembly using the command_line (if your pair-end FASTQ file named "P5E0_test_qc_1.fastq" and "P5E0_test_qc_2.fastq"):  
```
/your/path/to/VirMiner/bin/fq2fa --merge /your/path/to/VirMiner/data/quality_control/P5E0_test_qc_1.fastq /your/path/to/VirMiner/data/quality_control/P5E0_test_qc_2.fastq /your/path/to/VirMiner/data/quality_control/P5E0_test_qc.fa
/your/path/to/VirMiner/idba_ud --min_contig 300 --mink 20 --maxk 101 --step 10 -r /your/path/to/VirMiner/data/quality_control/P5E0_test_qc.fa -o /your/path/to/VirMiner/data/genome_assembly/P5E0_test.assembly.idba --pre_correction
```
Notice: you may change the setting of --maxk to your raw read length.  

#### Main output files  
In the folder `VirMiner/data/gene_prediction`:  
1) The predicted gene in GFF format, which showed information of the start and end of predicted genes in contigs.  
2) The protein sequences of predicted genes.  
3) The number of predicted genes on each contig.  

In the folder `VirMiner/data/functional_annotation`:  
1) Genes annotated to KO groups.  
2) Genes annotated to Pfam groups.  
3) Genes annotated to viral protein families.  
4) Genes identified as viral hallmark genes.  
5) The number and the percentage of predicted genes annotated to KO groups on each contig.  
6) The number and the percentage of predicted genes annotated to Pfam groups on each contig.  
7) The number and the percentage of predicted genes annotated to viral protein families on each contig.  
8) The number of identified viral hallmark genes on each contig.  

In the folder `VirMiner/data/POG_2016_annotation`:  
1) Genes annotated to general POGs.  
2) Genes annotated to POGs with high VQ (VQ >0.8) that could be considered as virus-specific.  

In the folder `VirMiner/data/average_depth_relative_abundance`:  
1) The mapped reads count for each contig.  
2) The average depth for each contig.  

In the folder `VirMiner/data/viral_contig_identification`:  
1) The metrics table including functional information like KO, pfam, viral hallmark, viral protein families etc. and other metrics characterizing each contig such as average depth, which is used for phage contigs identification.  
2) The extracted of all the above metrics for predicted phage contigs.  
3) The sequence of predicted phage contigs in FASTA format. 
 

### How to Run
1 If you have clean reads in pair-end FASTQ format only as your input file:  
Firstly you need to rename it ended with "_qc_1.fastq" or "_qc_2.fastq",for example, "P5E0_test_qc_1.fastq" and "P5E0_test_qc_2.fastq".Then you can choose IDBA_UD to do genome assembly and place the assembly file in /your/path/to/VirMiner/data/genome_assembly/your_sample_name.assembly.idba using the command_line (if your pair-end FASTQ file named "P5E0_test_qc_1.fastq" and "P5E0_test_qc_2.fastq"):  
`/your/path/to/VirMiner/idba_ud --min_contig 300 --mink 20 --maxk 101 --step 10 -r /your/path/to/VirMiner/data/quality_control/P5E0_test_qc.fa -o /your/path/to/VirMiner/data/genome_assembly/P5E0_test.assembly.idba --pre_correction`  
Notice: you may change the setting of --maxk to your raw read length  

A sample "run" command:  
Assume you have prepared these input files: `/your/path/to/VirMiner/data/genome_assembly/P5E0_test.assembly.idba/contig.fa`,`/your/path/to/VirMiner/data/quality_control/P5E0_test_qc_1.fastq` and `/your/path/to/VirMiner/data/quality_control/P5E0_test_qc_2.fastq` 
```
cd /your/path/to/VirMiner/data  
sh /your/path/to/VirMiner/bin/Pipeline_For_Viral_Contig_Indentification.sh P5E0_test  
```

2 If you already have clean reads in pair-end FASTQ format and the assembled contigs in FASTA format as your input files:  
Firstly you need to change the pair-end FASTQ file names and make it ended with "_qc_1.fastq" or "_qc_2.fastq",for example, "P5E0_test_qc_1.fastq" and "P5E0_test_qc_2.fastq". You can download the test data from VirMiner website ([http://147.8.185.62/VirMiner/tasks/exampleData/quality_control/](http://147.8.185.62/VirMiner/tasks/exampleData/quality_control/) then place them in `VirMiner/data/quality_control/`;  
Secondly, create a folder named "sample_name.assembly.idba" under genome_assembly folder. For example, if you have a sample named "P5E0", the command could be used like this:
`mkdir VirMiner/data/genome_assembly/P5E0_test.assembly.idba`
Then rename your contig file to "contig.fa" and put it in the directory: VirMiner/data/genome_assembly/sample_name.assembly.idba

A sample "run" command:  
Assume you have prepared these input files: `/your/path/to/VirMiner/data/genome_assembly/P5E0_test.assembly.idba/contig.fa`,`/your/path/to/VirMiner/data/quality_control/P5E0_test_qc_1.fastq` and `/your/path/to/VirMiner/data/quality_control/P5E0_test_qc_2.fastq` 
```
cd /your/path/to/VirMiner/data  
sh /your/path/to/VirMiner/bin/Pipeline_For_Viral_Contig_Indentification.V2.sh P5E0_test  
```

