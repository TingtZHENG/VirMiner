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
my ($fIn1,$fIn2,$fOut);
GetOptions(
				"help|?" =>\&USAGE,
				"i1:s"=>\$fIn1,
				"i2:s"=>\$fIn2,
#				"i3:s"=>\$fIn3,
#				"i4:s"=>\$fIn4,
				"o:s"=>\$fOut,
#				"o2:s"=>\$fOut2,
#				"d:s"=>\$PMDepth,
				) or &USAGE;
&USAGE unless ($fIn1 and $fIn2 and $fOut);

my %hash1;
open (IN1,$fIn1) or die $!;
while (<IN1>) {
	chomp; 
	next if (/^$/);
	my @POG_header_parser=split /\s+/,$_;
	my $POG_header_complete=$_;
	my $POG_header_format=join(' ', $POG_header_parser[0],$POG_header_parser[1]);
	$hash1{$POG_header_format}=$POG_header_complete;
	}

close(IN1);


my %hash2;
open (OUT,">$fOut") or die $!;	
open (IN2,$fIn2) or die $!;
while (<IN2>) {
	chomp;
	next if (/^$/);
	my ($query_name,$POG_subject_name,$e_value)=split /\t/,$_;
	if (exists $hash1{$POG_subject_name}) {
		my $POG_header_complete=$hash1{$POG_subject_name};
		print OUT "$query_name\t$POG_header_complete\n";
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
Contact:Zheng Tingting <tingting.zheng\@hku.hk> 
Description:
Usage:
  Options:  
  -i1 <file> the file for virus-specific POG information
  -i2 <file> hits from psi-blast result
  -o <file> extracted best hits for each gene
  -o2 <file> file for gene mapped to virus-specific POG (phage orthologous groups)   
  -h         Help

USAGE
	print $usage;
	exit;
}
