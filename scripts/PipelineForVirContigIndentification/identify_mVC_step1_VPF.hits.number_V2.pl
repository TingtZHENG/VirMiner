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
my ($fIn1,$fIn2,$fIn3,$fOut,$PMDepth);
GetOptions(
				"help|?" =>\&USAGE,
				"i1:s"=>\$fIn1,
				"i2:s"=>\$fIn2,
				"i3:s"=>\$fIn3,
				"o:s"=>\$fOut,
#				"d:s"=>\$PMDepth,
				) or &USAGE;
&USAGE unless ($fIn1 and $fIn2 and $fIn3 and $fOut);
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

my %VPF_gene;
open (IN2,$fIn2) or die $!;
while (<IN2>) {
	chomp;
	next if (/^$/);
	my($gene_id,$VPF_id,$evalue)=split /\t/,$_;
	$VPF_gene{$gene_id}=$VPF_id;
	}
close(IN2);

my %contig_gene_filter;
open (IN3,$fIn3) or die $!;
while (<IN3>) {
chomp;
next if (/^$/);
next if (/^#/);
my($contig_id,$prediction_method,$type,$start,$end,$dot,$strand_type,$info,$gene_id)=split /\t/,$_;
my @gene_id_format=split /\s+/,$gene_id;
my $gene_id_reformat=$gene_id_format[0]."_".$gene_id_format[1];
if (exists $hash{$contig_id} && exists $VPF_gene{$gene_id_reformat}){
	$contig_gene_filter{$gene_id}=$contig_id;
	}
}
close (IN3);


open (OUT,">$fOut") or die $!;		
foreach my $contig_ID (keys %hash){
	my @contig_VPF_number=();
	foreach my $gene_id (keys %contig_gene_filter){
		my $contig_id=$contig_gene_filter{$gene_id};
		if ($contig_ID eq $contig_id){
			push @contig_VPF_number,$gene_id;
			}
		}
	my $contig_VPF_count=scalar(@contig_VPF_number);
	print OUT "$contig_ID\t$contig_VPF_count\n";
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
Description: get the number of genes annotated to viral protein familes on each contig
Usage:
  Options:
  -i1 <file> the list of contig longer than 5kb
  -i2 <file> top hits of hmmalignment results 
  -i3 <file> gene GFF file
  -i4 <file> the number of genes annotated to viral protein familes on each contig   
  -h         Help

USAGE
	print $usage;
	exit;
}
