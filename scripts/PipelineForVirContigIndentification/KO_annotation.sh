diamond blastp -q ./gene_prediction/$1".pep.fa" -d ../database/ko.pep.fasta -p 5 -e 1e-5 --seg yes --sensitive -a ./functional_annotation/$1".KO.blastp" -t ./functional_annotation/temp_dir_DIAMOND
diamond view -a ./functional_annotation/$1".KO.blastp.daa" -o ./functional_annotation/$1".KO.blastp.daa.m8"
python ../bin/annotate.py -i ./functional_annotation/$1".KO.blastp.daa.m8" -t blastout:tab -s ko -e 1e-5 -n 20 -o ./functional_annotation/$1".KO.blastp.daa.m8.kobas"
perl ../bin/extract_KO_and_pathway_from_kobas.pl ./functional_annotation/$1".KO.blastp.daa.m8.kobas" >./functional_annotation/$1".KO.blastp.daa.m8.kobas.KO"
