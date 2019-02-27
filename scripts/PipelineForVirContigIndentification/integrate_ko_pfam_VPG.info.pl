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

my %ko_annotation;
open (IN2,$fIn2) or die $!;
while (<IN2>) {
	chomp;
	next if (/^$/);
	my($contig_id,@ko_info)=split /\t/,$_;
	$ko_annotation{$contig_id}=\@ko_info;
	}
close(IN2);


my %pfam_annotation;
open (IN3,$fIn3) or die $!;
while (<IN3>) {
	chomp;
	next if (/^$/);
	my($contig_id,@pfam_info)=split /\t/,$_;
	$pfam_annotation{$contig_id}=\@pfam_info;
	}
close(IN3);


my %VPG_annotation;
open (IN4,$fIn4) or die $!;
while (<IN4>) {
	chomp;
	next if (/^$/);
	my($contig_id,@VPG_info)=split /\t/,$_;
	$VPG_annotation{$contig_id}=\@VPG_info;
	}
close(IN4);



		
open (OUT,">$fOut") or die $!;		
foreach my $contig_ID (keys %hash){
	my @ko_info=@{$ko_annotation{$contig_ID}};
	my $all_gene_count=$ko_info[1];
	my $ko_count=$ko_info[0];
	my $ko_percentage=$ko_info[2];
	my @pfam_info=@{$pfam_annotation{$contig_ID}};
	my $pfam_count=$pfam_info[0];
	my $pfam_percentage=$pfam_info[2];
	my @VPG_info=@{$VPG_annotation{$contig_ID}};
	my $VPG_count=$VPG_info[0];
	my $VPG_percentage;
	if ($all_gene_count ne 0){
		$VPG_percentage=$VPG_count/$all_gene_count;
	}else{
		$VPG_percentage=0;
		}
	print OUT "$contig_ID\t";
	print OUT "$all_gene_count\t";
	print OUT "$VPG_count\t";
	print OUT "$VPG_percentage\t";
	print OUT "$ko_count\t";
	print OUT "$ko_percentage\t";
	print OUT "$pfam_count\t";
	print OUT "$pfam_percentage\n";
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
Description:combine KO, Pfam and viral protein family annotation results to generate metrics table
Usage:
  Options:
  -i1 <file> the list of contig longer than 5kb
  -i2 <file> the number and percentage of predicted genes annotated to KO on each contig
  -i3 <file> the number and percentage of predicted genes annotated to Pfam on each contig
  -i4 <file> the number of predicted genes annotated to viral protein families on each contig
  -o  <file> the metrcis table including functional annotation information   
  -h         Help

USAGE
	print $usage;
	exit;
}
