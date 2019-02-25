#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $BEGIN_TIME=time();
my $version="1.0.0";
#######################################################################################

# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($fIn1,$fIn2,$fOut,$PMDepth);
GetOptions(
				"help|?" =>\&USAGE,
				"i1:s"=>\$fIn1,
				"i2:s"=>\$fIn2,
				"o:s"=>\$fOut,
				"d:s"=>\$PMDepth,
				) or &USAGE;
&USAGE unless ($fIn1 and $fIn2 and $fOut);


open (IN1,$fIn1) or die $!;
my %hash1;
while (<IN1>) {
	chomp;
	next if (/^$/);
	my ($query_gene,$subject_ViralRef,@alignment_score)=split /\t/,$_;
	if ($subject_ViralRef=~/.ali_faa/){
		$subject_ViralRef =~ s/.ali_faa//g;
		}
	$hash1{$query_gene}=$subject_ViralRef;
}
close(IN1);


open (IN2,$fIn2) or die $!;
my %hash2;
my %hash3;
my %hash4;
while (<IN2>) {
	chomp;
	next if (/^$/);
	if ($_=~/^Phage_cluster/){
		my @parser_gene_cluster=split /\|/,$_;
		my $cluster_name=$parser_gene_cluster[0];
		my $gene_name_text=$parser_gene_cluster[2];
		my $gene_name_num=$parser_gene_cluster[3];		
		$hash2{$cluster_name}{$gene_name_text}=$gene_name_num;
		}else{
		my @parser_gene_uncluster=split /\|/,$_;
		my $uncluster_name=$parser_gene_uncluster[0];
		my $unlcuster_gene_decri=$parser_gene_uncluster[2];	
		$uncluster_name =~ s/gi\_(\d+)\_ref\_([A-Z]+)\_(\d+)\.(\d)\_/gi\|$1\|ref\|$2\_$3\.$4\|/g;
		$hash3{$uncluster_name}=$unlcuster_gene_decri;
#		print "$uncluster_name\t$unlcuster_gene_decri\n";die;
		}
	}
close (IN2);

open (OUT,">$fOut") or die $!;	
foreach my $query_gene (keys %hash1) {
	my $subject_ViralRef=$hash1{$query_gene};
	if ($subject_ViralRef=~/^Phage_cluster/){
		foreach my $gene_name_text (keys %{$hash2{$subject_ViralRef}}) {
			next if ($gene_name_text =~ /^$/);
			my @gene_name_text_set=split /;/,$gene_name_text;
			for (my $i=0;$i<@gene_name_text_set;$i++) {
				my ($gene_name_format,$num)=split /:/,$gene_name_text_set[$i];
				last if (($gene_name_format=~/protease/)||($gene_name_format=~/chaperone/));
				if ((($gene_name_format =~ /major capsid protein/) || ($gene_name_format=~/terminase large unit/) || ($gene_name_format=~/portal/) || ($gene_name_format=~/tail/) || ($gene_name_format=~/coat/) || ($gene_name_format=~/virion formation/) || ($gene_name_format=~/spike/))){
					print OUT "$query_gene\t$subject_ViralRef\n";
					last;
					}
				}
			}	
		}
	if ($subject_ViralRef!~/^Phage_cluster/){
		my $unlcuster_gene_decri=$hash3{$subject_ViralRef};
		next if ($unlcuster_gene_decri=~/^$/);
		if ((($unlcuster_gene_decri=~/major capsid protein/) || ($unlcuster_gene_decri=~/terminase large unit/) || ($unlcuster_gene_decri=~/portal/) || ($unlcuster_gene_decri=~/tail/) || ($unlcuster_gene_decri=~/coat/) || ($unlcuster_gene_decri=~/virion formation/) || ($unlcuster_gene_decri=~/spike/)) && ($unlcuster_gene_decri!~/protease/) && ($unlcuster_gene_decri!~/chaperone/)){
			print OUT "$query_gene\t$subject_ViralRef\n";
			}
		}
	}
		
close(OUT);








#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################

# ------------------------------------------------------------------
# sub function
# ------------------------------------------------------------------
sub ABSOLUTE_DIR{ #$pavfile=&ABSOLUTE_DIR($pavfile);
	my $cur_dir=`pwd`;chomp($cur_dir);
	my ($in)=@_;
	my $return="";
	if(-f $in){
		my $dir=dirname($in);
		my $file=basename($in);
		chdir $dir;$dir=`pwd`;chomp $dir;
		$return="$dir/$file";
	}elsif(-d $in){
		chdir $in;$return=`pwd`;chomp $return;
	}else{
		warn "Warning just for file and dir\n";
		exit;
	}
	chdir $cur_dir;
	return $return;
}

sub GetTime {
	my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst)=localtime(time());
	return sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}


sub USAGE {#
	my $usage=<<"USAGE";
Program:
Version: $version
Contact:Yuan ZhengWen <yuanzw\@biomarker.com.cn> 
Description:
Usage:
  Options:
  -i1 <file> the extracted list
  -i2 <file> the complete list with certain information
  -o  <file>     
  -h         Help

USAGE
	print $usage;
	exit;
}


