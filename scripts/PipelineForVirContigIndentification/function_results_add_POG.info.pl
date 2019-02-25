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

my %contig_gene_filter;
open (IN1,$fIn1) or die $!;
while (<IN1>) {
		chomp;
		next if (/^$/);
		next if (/^#/);
		my($contig_id_info,$prediction_method,$type,$start,$end,$dot,$strand_type,$info,$gene_id)=split /\t/,$_;
		my @gene_id_format=split /\s+/,$gene_id;
		my $gene_id_reformat=$gene_id_format[0]."_".$gene_id_format[1];
		my @contig_id_parser=split /\s+/,$contig_id_info;
		my $contig_id=$contig_id_parser[0];
		$contig_gene_filter{$gene_id_reformat}=$contig_id;
		}
close(IN1);


my %POG_highVQ;
open (IN2,$fIn2) or die $!;
while (<IN2>) {
        chomp;
        next if (/^$/);
        $_ =~ s/\r//g;
        $_ =~ s/\n//g;	
        $POG_highVQ{$_}=0;
	}
close (IN2);	


my %POG_highVQ_gene;
open (IN3,$fIn3) or die $!;
while (<IN3>) {
	chomp;
	my($gene_id,$POG_accession,$evalue)=split /\t/,$_;
	$POG_accession =~ s/^>//g;
	if (exists $POG_highVQ{$POG_accession}){
		$POG_highVQ_gene{$gene_id}=$POG_accession;
			}
}	

close (IN3);

my %hash;
open (IN4,$fIn4) or die $!;
while (<IN4>) {
	chomp;
	my($contig_ID,@variants_info)=split /\t/,$_;
	$hash{$contig_ID}=\@variants_info;
	}	

close (IN4);

open (OUT,">$fOut") or die $!;
foreach my $contig_ID (keys %hash){
	my @contig_POG_gene=();
	foreach my $gene_id (keys %POG_highVQ_gene){
		my $contig_id=$contig_gene_filter{$gene_id};
		if ($contig_ID eq $contig_id){
			push @contig_POG_gene,$gene_id;
			}
		}
	my $contig_POG_gene_count=scalar(@contig_POG_gene);
	my @variants_info=@{$hash{$contig_ID}};
	print OUT "$contig_ID\t";
	print OUT "$contig_POG_gene_count\t";
	print OUT join "\t", @variants_info;
	print OUT "\n";
	
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
