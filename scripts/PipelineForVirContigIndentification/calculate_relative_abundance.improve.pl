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
my ($fIn1,$fIn2,$fOut,$sample_name);
GetOptions(
				"help|?" =>\&USAGE,
				"i1:s"=>\$fIn1,
				"i2:s"=>\$fIn2,
				"o:s"=>\$fOut,
				"n:s"=>\$sample_name,
				) or &USAGE;
&USAGE unless ($fIn1 and $fIn2 and $sample_name and $fOut);

my $extract_sample_name=$sample_name."_qc_1.fastq";
my $total_reads;
my %hash;
open (IN1,$fIn1) or die $!;
while (<IN1>) {
	chomp;
	next if (/^$/);
	my ($file_name,$reads_count)=split /\t/,$_;
	if ($file_name eq $extract_sample_name){
		$total_reads=$reads_count*2;
		}
	}
close(IN1);


open (IN2,$fIn2) or die $!;
open (OUT,">$fOut") or die $!;
while (<IN2>) {
	chomp;
	next if (/^$/);
	my ($contig_ID,$mapped_reads)=split /\t/,$_;
	my $relative_abundance=$mapped_reads/$total_reads;
	print OUT "$contig_ID\t$mapped_reads\t$relative_abundance\n";
}
close(IN2);

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


