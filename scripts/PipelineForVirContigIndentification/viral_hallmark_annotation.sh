#viral hallmark gene annotation

hmmsearch --tblout ./functional_annotation/$1".contig.hallmark.hmmalignment.result" --cpu 8 -o ./functional_annotation/$1".contig.hallmark.hmmalignment.result.outorigin" --noali ../database/viral_hallmark_Pool_clusters.hmm ./gene_prediction/$1".pep.fa"

blastall -p blastp -i ./gene_prediction/$1".pep.fa" -d ../database/viral_hallmark_Pool_new_unclustered.faa -e 1e-3 -o ./functional_annotation/$1".pep.blastp.result" -m 8

less ./functional_annotation/$1".contig.hallmark.hmmalignment.result"|perl -ne 'chomp; next if (/^#/);@a=split /\s+/,$_;print "$a[0]\t$a[2]\t$a[4]\t$a[5]\n";'|less >./functional_annotation/$1".contig.hallmark.hmmalignment.result.format"

less ./functional_annotation/$1".contig.hallmark.hmmalignment.result.format"|sort -k1,1 -k4,4gr|less >./functional_annotation/$1".contig.hallmark.hmmalignment.result.format.sort"

perl ../bin/matched.viral_hallmark_genes.top_hits.pl -i ./functional_annotation/$1".contig.hallmark.hmmalignment.result.format.sort" -o ./functional_annotation/$1".contig.hallmark.hmmalignment.tophits"


less ./functional_annotation/$1".contig.hallmark.hmmalignment.tophits"|awk -F '\t' '$3<=1e-5 && $4>=40 {print $0}'|less >./functional_annotation/$1".hallmark.hmmalignment.tophits.filter"
perl ../bin/identify_viral_hallmark_from_tophits.pl -i1 ./functional_annotation/$1".hallmark.hmmalignment.tophits.filter" -i2 ../database/viral_hallmark_Phage_Clusters_current.tab -o ./functional_annotation/$1".hallmark.hmmalignment.tophits.identified.hallmark"
perl ../bin/select_top_hit_test2.pl -i ./functional_annotation/$1".pep.blastp.result" -o ./functional_annotation/$1".pep.blastp.result.top.hits"
less ./functional_annotation/$1".pep.blastp.result.top.hits"|awk '$11 <=1e-3 && $12 >=50 {print $0}'|less >./functional_annotation/$1".pep.blastp.top.hits.filter"
perl ../bin/identify_viral_hallmark_from_tophits.pl -i1 $1".pep.blastp.top.hits.filter" -i2 ../database/viral_hallmark_Phage_Clusters_current.tab -o ./functional_annotation/$1".blastp.top.hits.identified.hallmark"
cat ./functional_annotation/$1".blastp.top.hits.identified.hallmark" ./functional_annotation/$1".hallmark.hmmalignment.tophits.identified.hallmark" >./functional_annotation/$1".identified.hallmark.final"
perl ../bin/identify_mVC_step1_VPF.hits.number_V2.pl -i1 ./genome_assembly/$1".contig.fa.longer_than_5kb" -i2 ./functional_annotation/$1".identified.hallmark.final" -i3 ./gene_prediction/$1".gff" -o ./functional_annotation/$1".viral_hallmark.info"
perl ../bin/viral_hallmark_mVC_KO_Pfam.info.summary.pl -i1 ./functional_annotation/$1".viral_hallmark.info" -i2 ./functional_annotation/$1".contig.function.mVC.KO.Pfam.summary" -o ./functional_annotation/$1".contig.mVC.KO.Pfam.viral_hallmark.summary"
