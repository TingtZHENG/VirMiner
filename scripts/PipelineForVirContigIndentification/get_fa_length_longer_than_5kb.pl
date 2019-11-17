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
my ($fIn,$fIn2,$fOut1,$fOut2,$PMDepth);
GetOptions(
				"help|?" =>\&USAGE,
				"i:s"=>\$fIn,
				"o1:s"=>\$fOut1,
				"o2:s"=>\$fOut2,
				"d:s"=>\$PMDepth,
				) or &USAGE;
&USAGE unless ($fIn and $fOut1 and $fOut2);
open (IN,$fIn) or die $!;
open OUT1,">$fOut1" or die $!;
open OUT2,">$fOut2" or die $!;
$/=">";
my %hash1;
my %hash2;
#my $seq = '';
while (<IN>) {
	if( /(.*?)\n(.*)/ms){
		my $desc = $1;
        my $seq = $2;
        $seq =~ s/\s+//g;
		chomp($seq);
		my $len=length($seq);
		print OUT2 "$desc\t$len\n";
		if ($len >5000)
		{
			print OUT1 "$desc\n";
			}
	}
}
	close IN;
	close OUT1;
	close OUT2;
#





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
Contact:Tingting Zheng <tingting.zheng\@connect.hku.hk> 
Description:
Usage:
  Options:
  -i <file> fasta file of the assembled contigs
  -o1 <file> the contig IDs of contigs longer than 5kb
  -o2 <file> the contig length of all the contigs   
  -h         Help

USAGE
	print $usage;
	exit;
}


