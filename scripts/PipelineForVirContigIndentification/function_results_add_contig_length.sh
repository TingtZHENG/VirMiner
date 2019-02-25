less ../genome_assembly/$1".contig.fa"|grep ">"|sed 's/>//g'|less >../genome_assembly/$1".contig.header"
perl ../../scripts/PipelineForVirContigIndentification/function_results_add_contig_length.pl -i1 ../genome_assembly/$1".contig.header" -i2 $1".contig.mVC.KO.Pfam.viral_hallmark.summary" -o ../average_depth_relative_abundance/$1".contig.length.mVC.KO.Pfam.viral_hallmark.summary"
