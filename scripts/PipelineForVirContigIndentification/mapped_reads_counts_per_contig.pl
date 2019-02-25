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
#				"i2:s"=>\$fIn2,
#				"i3:s"=>\$fIn3,
#				"i4:s"=>\$fIn4,
				"o:s"=>\$fOut,
#				"d:s"=>\$PMDepth,
				) or &USAGE;
&USAGE unless ($fIn1 and $fOut);

my %hash1;
open (IN1,$fIn1) or die $!;
while (<IN1>) {
		chomp;
		next if (/^$/);
		my ($reads_ID,$identity,$contig_ID)=split /\s+/,$_;
#		print $contig_ID;die;
		$hash1{$contig_ID}+=1;
		
		}
close(IN1);




open (OUT,">$fOut") or die $!;
foreach my $contig_ID (keys %hash1){
	my $count=$hash1{$contig_ID};
#	print "$contig_ID\t$count\n";die;
	print OUT "$contig_ID\t$count\n";	
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
