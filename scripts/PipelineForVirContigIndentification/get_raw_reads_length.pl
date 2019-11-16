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
my ($fIn,$fOut,$PMDepth);
GetOptions(
				"help|?" =>\&USAGE,
				"i:s"=>\$fIn,
#				"i2:s"=>\$fIn2,
				"o:s"=>\$fOut,
				"d:s"=>\$PMDepth,
				) or &USAGE;
&USAGE unless ($fIn and $fOut);

open (OUT,">$fOut") or die $!;
open (IN,$fIn) or die $!;
$/="^@";
#my %hash2;
while (<IN>) {
	chomp;
	next if (/^$/);
	my @each_seq=split /\n/,$_;
	my $reads_length=length($each_seq[1]);
	print OUT $reads_length;
}
close(IN);
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


