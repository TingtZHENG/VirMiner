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
my ($fIn1,$fIn2,$fIn3,$fIn4,$fOut,$PMDepth);
GetOptions(
				"help|?" =>\&USAGE,
				"i1:s"=>\$fIn1,
				"i2:s"=>\$fIn2,
				"i3:s"=>\$fIn3,
				"i4:s"=>\$fIn4,
				"o:s"=>\$fOut,
#				"d:s"=>\$PMDepth,
				) or &USAGE;
&USAGE unless ($fIn1 and $fIn2 and $fIn3 and $fIn4 and $fOut);
open (IN1,$fIn1) or die $!;
#$/=">"; #∞¥">"∂¡»°
my %hash;
while (<IN1>) {
	chomp($_);
	$_ =~ s/\r//g;
	$_ =~ s/\n//g;
	next if (/^$/);
	$hash{$_}=0;
	
}
close(IN1);

my %contig_gene_count;
open (IN2,$fIn2) or die $!;
while (<IN2>) {
	chomp;
	next if (/^$/);
	my($contig_id,$gene_count)=split /\t/,$_;
	$contig_gene_count{$contig_id}=$gene_count;
	}
close(IN2);


my %KO_gene;
open (IN3,$fIn3) or die $!;
while (<IN3>) {
	chomp;
	next if (/^$/);
	my($gene_id,$KO_accession,$KO_info)=split /\t/,$_;
	if ($KO_accession !~ /^$/ && $KO_accession ne "NA"){
		$KO_gene{$gene_id}=$KO_accession;
		}
	}
close(IN3);

my %contig_gene_filter;
open (IN4,$fIn4) or die $!;
while (<IN4>) {
		chomp;
		next if (/^$/);
		next if (/^#/);
		my($contig_id,$prediction_method,$type,$start,$end,$dot,$strand_type,$info,$gene_id)=split /\t/,$_;
		my @gene_id_format=split /\s+/,$gene_id;
		my $gene_id_reformat=$gene_id_format[0]."_".$gene_id_format[1];
		if (exists $KO_gene{$gene_id_reformat} && exists $hash{$contig_id} && exists $contig_gene_count{$contig_id}){
			$contig_gene_filter{$gene_id}=$contig_id;
			}
		}
close (IN4);
		
open (OUT,">$fOut") or die $!;		
foreach my $contig_ID (keys %hash){
#	print OUT "$contig_ID\n";
	my @contig_KO_gene=();
	foreach my $gene_id (keys %contig_gene_filter){
		my $contig_id=$contig_gene_filter{$gene_id};
		if ($contig_ID eq $contig_id){
			push @contig_KO_gene,$gene_id;
			}
		}
	if (exists $contig_gene_count{$contig_ID}){
		my $contig_KO_gene_count=scalar(@contig_KO_gene);
		my $gene_count=$contig_gene_count{$contig_ID};
		my $KO_gene_proportion=$contig_KO_gene_count/$gene_count;
		print OUT "$contig_ID\t$contig_KO_gene_count\t$gene_count\t$KO_gene_proportion\n";
		}else{
		print OUT "$contig_ID\t0\t0\t0\n";
		}
}
close (OUT);
	

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
Contact:Tingting Zheng <tingting.zheng\@hku.hk> 
Description: Get the number of genes annotated to KO (or Pfam) on each contig
Usage:
  Options:
  -i1 <file> the list of contig longer than 5kb
  -i2 <file> the number of predicted genes on each contig
  -i3 <file> the file contained the information that genes annotated to KO(or Pfam) database
  -i4 <file> gene GFF file
  -o  <file> The number and the percentage of predicted genes annotated to KO (or Pfam) groups on each contig   
  -h         Help

USAGE
	print $usage;
	exit;
}
