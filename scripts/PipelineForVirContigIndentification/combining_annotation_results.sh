#combining these functional annotation results
perl ../bin/integrate_ko_pfam_VPG.info.pl -i1 ./genome_assembly/$1".contig.fa.longer_than_5kb" -i2 ./functional_annotation/$1".contig.Ko.gene.info" -i3 ./functional_annotation/$1".contig.Pfam.gene.info" -i4 ./functional_annotation/$1".mVC.info" -o ./functional_annotation/$1".contig.function.mVC.KO.Pfam.summary"

