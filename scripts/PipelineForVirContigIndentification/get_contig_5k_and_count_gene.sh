#select the contig longer than 5kb and count the genes for each contig

less ../genome_assembly/$1".contig.fa"|grep ">"|sed 's/>//g'|perl -ne 'chomp;@a=split /\s+/,$_;@b=split /_/,$a[1];if ($b[1]>5000){print join " ",@a;print "\n"}'|less >../genome_assembly/$1".contig.fa.longer_than_5kb"

less $1".gff"|grep "contig"|grep -v "^#"|cut -f 1|sort|uniq -c|less|perl -ne 'chomp; @a=split /\s+/,$_;print $a[2]." ".$a[3]." ".$a[4]."\t".$a[1];print "\n";'|less >$1"_contig_gene_count"
