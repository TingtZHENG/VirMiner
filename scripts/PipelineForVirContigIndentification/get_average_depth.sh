#average depth calculation and add this information into the metrics label
bwa index ./genome_assembly/$1".assembly.idba"/contig.fa
bwa mem -t 8 -R '@RG\tID:IDa\tPU:81MMNABXX\tSM:exomeSM\tPL:Illumina' -T 30 ./genome_assembly/$1".assembly.idba"/contig.fa ./quality_control/$1"_qc_1.fastq" ./quality_control/$1"_qc_2.fastq" >./average_depth_relative_abundance/$1".mapped_to_contig.sam"
perl ../bin/sam_identity.pl ./average_depth_relative_abundance/$1".mapped_to_contig.sam" > ./average_depth_relative_abundance/$1".identity"
awk '$2>=0.99 {print $1,$2,$3}' ./average_depth_relative_abundance/$1".identity" > ./average_depth_relative_abundance/$1".identity.0.99"
perl ../bin/mapped_reads_counts_per_contig.pl -i1 ./average_depth_relative_abundance/$1".identity.0.99" -o ./average_depth_relative_abundance/$1".identity.mapped.reads.per.contig"

rm ./average_depth_relative_abundance/$1".mapped_to_contig.sam"
rm ./average_depth_relative_abundance/$1".identity"
