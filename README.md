# VirMiner pipelineForQC
Here we provide the command-line perl scripts to quality control for metagenomic data, which was used in VirMiner. It can be used to process raw reads of metagenomic samples in FASTQ format by removing the adapters, low quality reads, bases or PCR duplicates.

## Requirments:
### install perl  
macOS: A version of Perl is already installed  
Windows: You may need to install oe of the versions available at [perl.org](http://www.perl.org/get.html).  
After installation, run in linux system or terminal apps, such as Terminal on macOS, and Command Prompt on Windows.  

## How to Run
command-line perl scripts: `scripts/fqc.pl`  
Run `perl ./scripts/fqc.pl -h `to see the parameters of this command line.    

A sample "run" command:  
input metagenomic raw reads in pair-end FASTQ format:  
`perl fqc.pl all -p -f indiA_merge_viral_contig_TP_5_1.fastq -r indiA_merge_viral_contig_TP_5_2.fastq -o indiA_merge_viral_contig_TP_5_qc`

input metagenomic raw reads in single FASTQ format:
