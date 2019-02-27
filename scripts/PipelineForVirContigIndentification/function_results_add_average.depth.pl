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
my ($fIn1,$fIn2,$fOut,$Sample_name);
GetOptions(
				"help|?" =>\&USAGE,
				"i1:s"=>\$fIn1,
				"i2:s"=>\$fIn2,
				"o:s"=>\$fOut,
				"s:s"=>\$Sample_name,
				) or &USAGE;
&USAGE unless ($fIn1 and $fIn2 and $fOut);
my %hash1;
open (IN1,$fIn1) or die $!;
while (<IN1>) {
	chomp;
	next if (/^$/);
	my($contig_ID,$mapped_reads,$average_depth)= split /\t/,$_;
	$hash1{$contig_ID}=$average_depth;
}
close(IN1);


open (IN2,$fIn2) or die $!;
open OUT,">$fOut" or die $!;
while (<IN2>) {
	chomp;
	next if (/^$/);
	my ($contig_ID,@contig_len_mVC_KO_pfam_info)=split /\t/,$_;
	if (exists $hash1{$contig_ID}){
		my $average_depth=$hash1{$contig_ID};
		print OUT "$contig_ID\t";
		print OUT "$average_depth\t";
		print OUT join "\t",@contig_len_mVC_KO_pfam_info;
		print OUT "\n";
		}else{
		print OUT "$contig_ID\t";
		print OUT "0\t";
		print OUT join "\t",@contig_len_mVC_KO_pfam_info;
		print OUT "\n";
		}
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
Contact:Tingting Zheng <tingting.zheng\@hku.hk> 
Description: add average depth into the metrics table
Usage:
  Options:
  -i <file> the file contained average depth information
  -o <file> metrics table including the features for each contig: contig length, viral protein families, KO, Pfam and viral hallmark.    
  -h         Help

USAGE
	print $usage;
	exit;
}
