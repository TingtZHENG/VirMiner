less ./genome_assembly/$1".assembly.idba"/contig.fa|grep ">"|sed 's/>//g'|less >./genome_assembly/$1".contig.header"
perl ../bin/function_results_add_contig_length.pl -i1 ./genome_assembly/$1".contig.header" -i2 ./functional_annotation/$1".contig.mVC.KO.Pfam.viral_hallmark.summary" -o ./average_depth_relative_abundance/$1".contig.length.mVC.KO.Pfam.viral_hallmark.summary"
