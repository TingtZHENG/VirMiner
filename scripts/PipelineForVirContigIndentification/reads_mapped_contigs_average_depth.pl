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
my ($fIn1,$fIn2,$fOut,$PMDepth);
GetOptions(
				"help|?" =>\&USAGE,
				"i1:s"=>\$fIn1,
				"i2:s"=>\$fIn2,
				"o:s"=>\$fOut,
				"d:s"=>\$PMDepth,
				) or &USAGE;
&USAGE unless ($fIn1 and $fIn2 and $fOut);
open (IN1,$fIn1) or die $!;
#$/=">"; #∞¥">"∂¡»°
my %hash1;
while (<IN1>) {
	chomp;
	next if (/^$/);
	my ($contig_ID,$contig_len,$reads_count)=split /\s+/,$_;
	my @contig_len_info=split /_/,$contig_len;
	my $contig_length=$contig_len_info[1];
	$hash1{$contig_ID}=$contig_length;
}
close(IN1);

open (IN2,$fIn2) or die $!;
open (OUT,">$fOut") or die $!;
$/="\n"; #∞¥ªª––∑˚∂¡»°
while (<IN2>) {
	chomp; #»•µÙ∂¡»°µƒ√ø“ª––ƒ©Œ≤µƒªª––∑˚
	next if (/^$/);
	my ($contig_id,$mapped_reads_num)=split /\t/,$_;
	my $contig_length=$hash1{$contig_id};
	my $average_depth=$mapped_reads_num/$contig_length;
	print OUT "$contig_id\t$mapped_reads_num\t$average_depth\n";

	
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
Contact:Tingting Zheng <tingting.zheng\@connect.hku.hk> 
Description:
Usage:
  Options:
  -i1 <file> contig length file
  -i2 <file> the number of mappable reads on each contig
  -o  <file> the average depth of each contig    
  -h         Help

USAGE
	print $usage;
	exit;
}
