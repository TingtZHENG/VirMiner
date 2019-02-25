# VirMiner
Source code for the key steps (including quality control of metagenomic raw reads and phage contig indentification) of VirMiner, available at [http://147.8.185.62/VirMiner/](http://147.8.185.62/VirMiner/).  
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
Before running this pipeline to identify phage contigs, you need to prepare input files: 1)fasta file of assembled contigs; 2)the clean reads in pair-end FASTQ format (refers to the output file of VirMiner pipelineForQC).
 

### Requirements:  
1.rpsblast (version 2.2.26)  
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
You can download the files of databases from here (http://147.8.185.62/VirMiner/downloads/database/) and place them in `database/` 

### Input and Output files  
#### Input files  
1) the assembled contigs in FASTA format and place them in `data/genome_assembly`;  
2) clean reads in pair-end FASTQ format and place them in `data/quality_control/`.  
#### Main output files  
In the folder `/data/gene_prediction`:  
1) The predicted gene in GFF format, which showed information of the start and end of predicted genes in contigs.  
2) The protein sequences of predicted genes.  
3) The number of predicted genes on each contig.  

In the folder `/data/functional_annotation`:  
1) Genes annotated to KO groups.  
2) Genes annotated to Pfam groups.  
3) Genes annotated to viral protein families.  
4) Genes identified as viral hallmark genes.  
5) The number and the percentage of predicted genes annotated to KO groups on each contig.  
6) The number and the percentage of predicted genes annotated to Pfam groups on each contig.  
7) The number and the percentage of predicted genes annotated to viral protein families on each contig.  
8) The number of identified viral hallmark genes on each contig.  

In the folder `/data/POG_2016_annotation`:  
1) Genes annotated to general POGs.  
2) Genes annotated to POGs with high VQ (VQ >0.8) that could be considered as virus-specific.  

In the folder `/data/average_depth_relative_abundance`:  
1) The mapped reads count for each contig.  
2) The average depth for each contig.  

In the folder `/data/viral_contig_identification`:  
1) The metrics table including functional information like KO, pfam, viral hallmark, viral protein families etc. and other metrics characterizing each contig such as average depth, which is used for phage contigs identification.  
2) The extracted of all the above metrics for predicted phage contigs.  
3) The sequence of predicted phage contigs in FASTA format. 
 

### How to Run
command-line sh scripts: `./scripts/PipelineForVirContigIndentification/Pipeline_For_Viral_Contig_Indentification.sh`
A sample "run" command:  
Assume there are input files: `data/genome_assembly/test.contig.fa`,`data/quality_control/test_1.fastq` and  `data/quality_control/test_2.fastq`
```
cd /data/genome_assembly/
sh ./scripts/PipelineForVirContigIndentification/Pipeline_For_Viral_Contig_Indentification.sh test
```


 
