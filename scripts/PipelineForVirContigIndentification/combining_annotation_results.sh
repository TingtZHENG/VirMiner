#combining these functional annotation results
perl ../../scripts/PipelineForVirContigIndentification//integrate_ko_pfam_VPG.info.pl -i1 ../genome_assembly/$1".contig.fa.longer_than_5kb" -i2 $1".contig.Ko.gene.info" -i3 $1".contig.Pfam.gene.info" -i4 $1".mVC.info" -o $1".contig.function.mVC.KO.Pfam.summary"

