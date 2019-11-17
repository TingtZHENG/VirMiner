#select the contig longer than 5kb and count the genes for each contig

perl ../bin/get_fa_length_longer_than_5kb.pl -i ./genome_assembly/"$1".assembly.idba/contig.fa -o1 ./genome_assembly/"$1".contig.fa.longer_than_5kb -o2 ./genome_assembly/"$1".contig.len

less ./gene_prediction/$1".gff"|grep -v "^$"|grep -v "^#"|cut -f 1|sort|uniq -c|less|perl -ne 'chomp; @a=split /\s+/,$_;print $a[2]." ".$a[3]." ".$a[4]."\t".$a[1];print "\n";'|less >./gene_prediction/$1"_contig_gene_count"
