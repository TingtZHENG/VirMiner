perl -ne 'chomp; next if (/^#/);@a=split /\s+/,$_;print "$a[0]\t$a[2]\t$a[4]\n";' $1".contig.hmmalignment.result" >$1".contig.hmmalignment.result.format"

less $1".contig.hmmalignment.result.format"|sort -k1,1 -k3,3g|less >$1".contig.hmmalignment.result.format.sort"

perl ../../scripts/PipelineForVirContigIndentification/matched.viral_protein_families.top_hits.pl -i $1".contig.hmmalignment.result.format.sort" -o $1".contig.hmmalignment.tophits"

less $1".contig.hmmalignment.tophits"|awk -F '\t' '$3<=0.00001 {print $0}'|less -S >$1".contig.hmmalignment.tophits.cutoff"
