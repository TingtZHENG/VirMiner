
########################################################################################################################################################################################
#gene prediction
########################################################################################################################################################################################

mkdir ../gene_prediction

gmhmmp -a -d -f G -m ../../scripts/PipelineForVirContigIndentification/MetaGeneMark_v1.mod -o ../gene_prediction/"$1".gff ./"$1".contig.fa

cd /dh9/ting/VirMiner/tasks/$1/gene_prediction

../../scripts/PipelineForVirContigIndentification/aa_from_gff.pl "$1".gff > "$1".pep.fa

../../scripts/PipelineForVirContigIndentification/nt_from_gff.pl "$1".gff > "$1".cds.fa

sh ../../scripts/PipelineForVirContigIndentification/get_contig_5k_and_count_gene.sh "$1"


echo "Gene prediction has been completed!"
#finally,we generated the file: *.contig.fa, *.pep.fa for the following analysis.


########################################################################################################################################################################################
#functional annotation
########################################################################################################################################################################################
mkdir ../functional_annotation

#Pfam annotation

rpsblast -i "$1".pep.fa -d ../../database/Cdd -e 1e-5 -o ../functional_annotation/"$1".pep.fa-cdd.rpsblast

perl ../../scripts/PipelineForVirContigIndentification/extract_info_from_rpsblast.pl ../functional_annotation/"$1".pep.fa-cdd.rpsblast pfam >../functional_annotation/"$1".pep.fa-cdd.rpsblast.Pfam"}'|sh

#diamond used for KO annotation
mkdir ../functional_annotation/temp_dir_DIAMOND

sh ../../scripts/PipelineForVirContigIndentification/KO_annotation.sh "$1"

#viral protein family annotation

hmmsearch --tblout ../functional_annotation/"$1".contig.hmmalignment.result --cpu 8 -o ../functional_annotation/"$1".contig.hmmalignment.result.outorigin --noali ../../database/mVCs_final_list.hmms "$1".pep.fa


cd ../functional_annotation

sh ../../scripts/PipelineForVirContigIndentification/mVC_processing_perSample.sh "$1"


#get the number of gene that could be annotated to KO, Pfam and VPF
perl ../../scripts/PipelineForVirContigIndentification/contig_gene_cover_KO_V2.pl -i1 ../genome_assembly/"$1".contig.fa.longer_than_5kb -i2 ../gene_prediction/"$1"_contig_gene_count -i3 "$1".KO.blastp.daa.m8.kobas.KO -i4 ../gene_prediction/"$1".gff -o "$1".contig.Ko.gene.info
perl ../../scripts/PipelineForVirContigIndentification/contig_gene_cover_KO_V2.pl -i1 ../genome_assembly/"$1".contig.fa.longer_than_5kb -i2 ../gene_prediction/"$1"_contig_gene_count -i3 "$1".pep.fa-cdd.rpsblast.Pfam -i4 ../gene_prediction/"$1".gff -o "$1".contig.Pfam.gene.info
perl ../../scripts/PipelineForVirContigIndentification/identify_mVC_step1_VPF.hits.number_V2.pl -i1 ../genome_assembly/"$1".contig.fa.longer_than_5kb -i2 "$1".contig.hmmalignment.tophits.cutoff -i3 ../gene_prediction/"$1".gff -o "$1".mVC.info

#combining these functional annotation results
sh ../../scripts/PipelineForVirContigIndentification/combining_annotation_results.sh "$1"


#viral hallmark gene annotation
sh ../../scripts/PipelineForVirContigIndentification/viral_hallmark_annotation.sh "$1"



rm -r temp_dir_DIAMOND
rm *.KO.blastp.daa *.KO.blastp.daa.m8 *.KO.blastp.daa.m8.kobas *.contig.hmmalignment.result.format *.contig.hmmalignment.result.format.sort *.contig.hmmalignment.result.outorigin *.contig.hmmalignment.tophits *.pep.fa-cdd.rpsblast
rm *.contig.hallmark.hmmalignment.result.outorigin *.contig.hallmark.hmmalignment.result.format *.contig.hallmark.hmmalignment.result.format.sort


echo "Functional annotation has been completed!"




########################################################################################################################################################################################
#other metrics for chracterizing metagenomic contigs (average depth and relative abundance)
########################################################################################################################################################################################
mkdir ../average_depth_relative_abundance

#add contig length into the metrics table
sh ../../scripts/PipelineForVirContigIndentification/function_results_add_contig_length.sh "$1""}'|sh

#average depth calculation
sh ../../scripts/PipelineForVirContigIndentification/get_average_depth.sh "$1""}'|sh

cd ../average_depth_relative_abundance

perl ../../scripts/PipelineForVirContigIndentification/reads_mapped_contigs_average_depth.pl -i1 ../genome_assembly/"$1".contig.header -i2 "$1".identity.mapped.reads.per.contig -o "$1".identity.mapped.reads.average.depth


#add average depth into the metrics label
perl ../../scripts/PipelineForVirContigIndentification/function_results_add_average.depth.pl -i1 "$1".identity.mapped.reads.average.depth -i2 "$1".contig.length.mVC.KO.Pfam.viral_hallmark.summary -o "$1".contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary


echo "Average depth and relative abundance have been calculated!"


########################################################################################################################################################################################
#POG annotation
########################################################################################################################################################################################


#uPOGs_annotation
mkdir ../POG_2016_annotation

blastpgp -d ../../database/updated_POG_seqs.filtered.annotation -i ../gene_prediction/"$1".pep.fa -o ../POG_2016_annotation/"$1".pep.fa.psiBlast.output -h 1e-5 
cd ../POG_2016_annotation
perl ../../scripts/PipelineForVirContigIndentification/extract_hit_from_psiblast.pl -i1 "$1".pep.fa.psiBlast.output -o "$1".psiBlast.output.hits
perl ../../scripts/PipelineForVirContigIndentification/extract_best_hit_from_psiblast_2.pl -i1 "$1".psiBlast.output.hits -o "$1".psiBlast.output.best.hits
perl ../../scripts/PipelineForVirContigIndentification/extract_POG_highVQ.pl -i1 ../../database/updated_POG_seqs.filtered.VQ0.8.final.annotation.fa.header -i2 "$1".psiBlast.output.best.hits -o "$1".psiBlast.best.hits.POG_highVQ


#Rscript taxon_category.heatmap.convert.args.input.R all.sample.list taxon.list taxon-specific_POG.info.final


#add uPOGs into the metrics table
perl ../../scripts/PipelineForVirContigIndentification/function_results_add_POG.info.pl -i1 ../gene_prediction/"$1".gff -i2 ../../database/POG_2016_VQ0.8.list -i3 "$1".psiBlast.output.best.hits -i4 ../average_depth_relative_abundance/"$1".contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary -o "$1".POG2016.contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary

rm *.pep.fa.psiBlast.output *.psiBlast.output.hits


echo "uPOGs annotation has been completed!"


########################################################################################################################################################################################
#viral contig identification
########################################################################################################################################################################################
mkdir ../viral_contig_identification

mv "$1".POG2016.contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary ../viral_contig_identification

cd ../viral_contig_identification

printf "contig_ID\tPOG_2016\taverage_depth\tcontig_length\tgene_count\tmVCs_count\tmVCs_percentage\tKO_count\tKO_percentage\tPfam_count\tPfam_percentage\tviral_hallmark\n" >metrics_table.title.txt

cat metrics_table.title.txt "$1".POG2016.contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary >"$1".POG2016.contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary.final.txt

cp ../../scripts/PipelineForVirContigIndentification/extract_predicted_contigs.info.R ./

Rscript extract_predicted_contigs.info.R "$1".POG2016.2012.contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary.final.txt

rm metrics_table.title.txt *.POG2016.2012.contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary
rm extract_predicted_contigs.info.R

#extract the viral contigs identified by our methodology
perl ../../scripts/PipelineForVirContigIndentification/extract_seq_8.pl -i1 ../genome_assembly/"$1".contig.fa -i2 "$1".predicted_viral_contig_info.txt -o "$1".viral.contigs.final.fa

echo "Viral contig identification has been completed!"

