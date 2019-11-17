perl -ne 'chomp; next if (/^#/);@a=split /\s+/,$_;print "$a[0]\t$a[2]\t$a[4]\n";' ./functional_annotation/$1".contig.hmmalignment.result" >./functional_annotation/$1".contig.hmmalignment.result.format"

less ./functional_annotation/$1".contig.hmmalignment.result.format"|sort -k1,1 -k3,3g|less >./functional_annotation/$1".contig.hmmalignment.result.format.sort"

perl ../bin/matched.viral_protein_families.top_hits.pl -i ./functional_annotation/$1".contig.hmmalignment.result.format.sort" -o ./functional_annotation/$1".contig.hmmalignment.tophits"

less ./functional_annotation/$1".contig.hmmalignment.tophits"|awk -F '\t' '$3<=0.00001 {print $0}'|less -S >./functional_annotation/$1".contig.hmmalignment.tophits.cutoff"
