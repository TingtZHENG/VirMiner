
########################################################################################################################################################################################
#gene prediction
########################################################################################################################################################################################

#mkdir ./gene_prediction

gmhmmp -a -d -f G -m ../bin/MetaGeneMark_v1.mod -o ./gene_prediction/"$1".gff ./genome_assembly/"$1".assembly.idba/contig.fa

cd ./gene_prediction

../../bin/aa_from_gff.pl "$1".gff > "$1".pep.fa

../../bin/nt_from_gff.pl "$1".gff > "$1".cds.fa

cd ../

sh ../bin/get_contig_5k_and_count_gene.V2.sh "$1"

echo "Gene prediction has been completed!"
#finally,we generated the file: *.contig.fa, *.pep.fa for the following analysis.

########################################################################################################################################################################################
#functional annotation
########################################################################################################################################################################################
#mkdir ./functional_annotation

#Pfam annotation

rpsblast -i ./gene_prediction/"$1".pep.fa -d ../database/Cdd -e 1e-5 -o ./functional_annotation/"$1".pep.fa-cdd.rpsblast

perl ../bin/extract_info_from_rpsblast.pl ./functional_annotation/"$1".pep.fa-cdd.rpsblast pfam >./functional_annotation/"$1".pep.fa-cdd.rpsblast.Pfam

#diamond used for KO annotation
mkdir ./functional_annotation/temp_dir_DIAMOND

#for running KO annotation, kobas software need to be installed and annotate.py was copied from /your/path/to/kobas/scripts
sh ../bin/KO_annotation.sh "$1"

#viral protein family annotation

hmmsearch --tblout ./functional_annotation/"$1".contig.hmmalignment.result --cpu 8 -o ./functional_annotation/"$1".contig.hmmalignment.result.outorigin --noali ../database/mVCs_final_list.hmms ./gene_prediction/"$1".pep.fa

sh ../bin/mVC_processing_perSample.sh "$1"


#get the number of gene that could be annotated to KO, Pfam and VPF
perl ../bin/contig_gene_cover_KO_V2.pl -i1 ./genome_assembly/"$1".contig.fa.longer_than_5kb -i2 ./gene_prediction/"$1"_contig_gene_count -i3 ./functional_annotation/"$1".KO.blastp.daa.m8.kobas.KO -i4 ./gene_prediction/"$1".gff -o ./functional_annotation/"$1".contig.Ko.gene.info
perl ../bin/contig_gene_cover_KO_V2.pl -i1 ./genome_assembly/"$1".contig.fa.longer_than_5kb -i2 ./gene_prediction/"$1"_contig_gene_count -i3 ./functional_annotation/"$1".pep.fa-cdd.rpsblast.Pfam -i4 ./gene_prediction/"$1".gff -o ./functional_annotation/"$1".contig.Pfam.gene.info
perl ../bin/identify_mVC_step1_VPF.hits.number_V2.pl -i1 ./genome_assembly/"$1".contig.fa.longer_than_5kb -i2 ./functional_annotation/"$1".contig.hmmalignment.tophits.cutoff -i3 ./gene_prediction/"$1".gff -o ./functional_annotation/"$1".mVC.info

#combining these functional annotation results
sh ../bin/combining_annotation_results.sh "$1"


#viral hallmark gene annotation
sh ../bin/viral_hallmark_annotation.sh "$1"


#rm -r ./functional_annotation/temp_dir_DIAMOND
rm ./functional_annotation/"$1".KO.blastp.daa ./functional_annotation/"$1".KO.blastp.daa.m8 ./functional_annotation/"$1".KO.blastp.daa.m8.kobas ./functional_annotation/"$1".contig.hmmalignment.result.format ./functional_annotation/"$1".contig.hmmalignment.result.format.sort ./functional_annotation/"$1".contig.hmmalignment.result.outorigin ./functional_annotation/"$1".contig.hmmalignment.tophits ./functional_annotation/"$1".pep.fa-cdd.rpsblast
rm ./functional_annotation/"$1".contig.hallmark.hmmalignment.result.outorigin ./functional_annotation/"$1".contig.hallmark.hmmalignment.result.format ./functional_annotation/"$1".contig.hallmark.hmmalignment.result.format.sort


echo "Functional annotation has been completed!"


########################################################################################################################################################################################
#other metrics for chracterizing metagenomic contigs (average depth and relative abundance)
########################################################################################################################################################################################
#mkdir ./average_depth_relative_abundance

#add contig length into the metrics table
sh ../bin/function_results_add_contig_length.V2.sh "$1"

#average depth calculation
sh ../bin/get_average_depth.sh "$1"


perl ../bin/reads_mapped_contigs_average_depth.V2.pl -i1 ./genome_assembly/"$1".contig.len -i2 ./average_depth_relative_abundance/"$1".identity.mapped.reads.per.contig -o ./average_depth_relative_abundance/"$1".identity.mapped.reads.average.depth


#add average depth into the metrics label
perl ../bin/function_results_add_average.depth.pl -i1 ./average_depth_relative_abundance/"$1".identity.mapped.reads.average.depth -i2 ./average_depth_relative_abundance/"$1".contig.length.mVC.KO.Pfam.viral_hallmark.summary -o ./average_depth_relative_abundance/"$1".contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary


echo "Average depth and relative abundance have been calculated!"

########################################################################################################################################################################################
#POG annotation
########################################################################################################################################################################################


#uPOGs_annotation
#mkdir ./POG_2016_annotation

blastpgp -d ../database/updated_POG_seqs.filtered.annotation -i ./gene_prediction/"$1".pep.fa -o ./POG_2016_annotation/"$1".pep.fa.psiBlast.output -h 1e-5 

perl ../bin/extract_hit_from_psiblast.pl -i1 ./POG_2016_annotation/"$1".pep.fa.psiBlast.output -o ./POG_2016_annotation/"$1".psiBlast.output.hits
perl ../bin/extract_best_hit_from_psiblast_2.pl -i1 ./POG_2016_annotation/"$1".psiBlast.output.hits -o ./POG_2016_annotation/"$1".psiBlast.output.best.hits
perl ../bin/extract_POG_highVQ.pl -i1 ../database/updated_POG_seqs.filtered.VQ0.8.final.annotation.fa.header -i2 ./POG_2016_annotation/"$1".psiBlast.output.best.hits -o ./POG_2016_annotation/"$1".psiBlast.best.hits.POG_highVQ


#add uPOGs into the metrics table
perl ../bin/function_results_add_POG.info.pl -i1 ./gene_prediction/"$1".gff -i2 ../database/POG_2016_VQ0.8.list -i3 ./POG_2016_annotation/"$1".psiBlast.output.best.hits -i4 ./average_depth_relative_abundance/"$1".contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary -o ./POG_2016_annotation/"$1".POG2016.contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary

rm ./POG_2016_annotation/"$1".pep.fa.psiBlast.output ./POG_2016_annotation/"$1".psiBlast.output.hits


secho "uPOGs annotation has been completed!"

########################################################################################################################################################################################
#viral contig identification
########################################################################################################################################################################################
#mkdir ./viral_contig_identification

mv ./POG_2016_annotation/"$1".POG2016.contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary ./viral_contig_identification


printf "contig_ID\tPOG_2016\taverage_depth\tcontig_length\tgene_count\tmVCs_count\tmVCs_percentage\tKO_count\tKO_percentage\tPfam_count\tPfam_percentage\tviral_hallmark\n" >./viral_contig_identification/metrics_table.title.txt

cat ./viral_contig_identification/metrics_table.title.txt ./viral_contig_identification/"$1".POG2016.contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary >./viral_contig_identification/"$1".POG2016.contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary.final.txt

cp ../bin/extract_predicted_contigs.info.R ./viral_contig_identification

cd ./viral_contig_identification

Rscript extract_predicted_contigs.info.R "$1".POG2016.contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary.final.txt

rm metrics_table.title.txt "$1".POG2016.contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary
rm extract_predicted_contigs.info.R

cd ../

#extract the sequences of viral contigs identified by our methodology
perl ../bin/extract_seq_8.pl -i1 ./genome_assembly/"$1".assembly.idba/contig.fa -i2 ./viral_contig_identification/"$1".predicted_viral_contig_info.txt -o ./viral_contig_identification/"$1".viral.contigs.final.fa

echo "Viral contig identification has been completed!"