#viral hallmark gene annotation

hmmsearch --tblout $1".contig.hallmark.hmmalignment.result" --cpu 8 -o $1".contig.hallmark.hmmalignment.result.outorigin" --noali ../../database/viral_hallmark_Pool_clusters.hmm ../gene_prediction/$1".pep.fa"

blastall -p blastp -i ../gene_prediction/$1".pep.fa" -d ../../database/viral_hallmark_Pool_new_unclustered.faa -e 1e-3 -o $1".pep.blastp.result" -m 8

less $1".contig.hallmark.hmmalignment.result"|perl -ne 'chomp; next if (/^#/);@a=split /\s+/,$_;print "$a[0]\t$a[2]\t$a[4]\t$a[5]\n";'|less >$1".contig.hallmark.hmmalignment.result.format"

less $1".contig.hallmark.hmmalignment.result.format"|sort -k1,1 -k4,4gr|less >$1".contig.hallmark.hmmalignment.result.format.sort"

perl ../../scripts/PipelineForVirContigIndentification/matched.viral_hallmark_genes.top_hits.pl -i $1".contig.hallmark.hmmalignment.result.format.sort" -o $1".contig.hallmark.hmmalignment.tophits"


less $1".contig.hallmark.hmmalignment.tophits"|awk -F '\t' '$3<=1e-5 && $4>=40 {print $0}'|less >$1".hallmark.hmmalignment.tophits.filter"
perl ../../scripts/PipelineForVirContigIndentification/identify_viral_hallmark_from_tophits.pl -i1 $1".hallmark.hmmalignment.tophits.filter" -i2 ../../database/viral_hallmark_Phage_Clusters_current.tab -o $1".hallmark.hmmalignment.tophits.identified.hallmark"
perl ../../scripts/PipelineForVirContigIndentification/select_top_hit_test2.pl -i $1".pep.blastp.result" -o $1".pep.blastp.result.top.hits"
less $1".pep.blastp.result.top.hits"|awk '$11 <=1e-3 && $12 >=50 {print $0}'|less >$1".pep.blastp.top.hits.filter"
perl ../../scripts/PipelineForVirContigIndentification/identify_viral_hallmark_from_tophits.pl -i1 $1".pep.blastp.top.hits.filter" -i2 ../../database/viral_hallmark_Phage_Clusters_current.tab -o $1".blastp.top.hits.identified.hallmark"
cat $1".blastp.top.hits.identified.hallmark" $1".hallmark.hmmalignment.tophits.identified.hallmark" >$1".identified.hallmark.final"
perl ../../scripts/PipelineForVirContigIndentification/identify_mVC_step1_VPF.hits.number_V2.pl -i1 ../genome_assembly/$1".contig.fa.longer_than_5kb" -i2 $1".identified.hallmark.final" -i3 ../gene_prediction/$1".gff" -o $1".viral_hallmark.info"
perl ../../scripts/PipelineForVirContigIndentification/viral_hallmark_mVC_KO_Pfam.info.summary.pl -i1 $1".viral_hallmark.info" -i2 $1".contig.function.mVC.KO.Pfam.summary" -o $1".contig.mVC.KO.Pfam.viral_hallmark.summary"