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
my ($fIn1,$fIn2,$fIn3,$fOut);
GetOptions(
				"help|?" =>\&USAGE,
				"i1:s"=>\$fIn1,
#				"i2:s"=>\$fIn2,
#				"i3:s"=>\$fIn3,
#				"i4:s"=>\$fIn4,
#				"i5:s"=>\$fIn5,
				"o:s"=>\$fOut,
#				"d:s"=>\$PMDepth,
				) or &USAGE;
&USAGE unless ($fIn1 and $fOut);
open (IN1,$fIn1) or die $!;
open OUT,">$fOut" or die $!;
#$/="\n";
#my $flag=""
while (<IN1>) {
chomp;
if (/^Query=/)
{
my $query=$_;
print OUT $query;
print OUT "\n";
$_=<IN1>;
next if($_ !~ /^>/);
}
if (/^>/){
	my $hit = $_;
	print OUT $hit;
	print OUT "\t";
	$_=<IN1>;
	next if ($_ !~ /Expect/);
	}
	if (/Expect =(.*),   Method/)
	{
	my $score=$1;
	print OUT $score;
	print OUT "\n";
	}
	}

close(IN1);
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
Description: extract hits information from psiblast alignment output file
Usage:
  Options:
  -i1 <file> psiblast alignment output file
  -o <file> hits information of psiblast alignment results    
  -h         Help

USAGE
	print $usage;
	exit;
}
