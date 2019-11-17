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
$/=">"; #∞¥">"∂¡»°
my %hash1;
my %hash2;
while (<IN1>) {
	chomp;
	next if (/^$/);
	my ($ID_info,$seq)=split /\n/,$_;
	my @ID_parser=split /\s+/,$ID_info;
	my $ID=$ID_parser[0];
	$hash1{$ID}=$seq;
}
close(IN1);
#print OUT Dumper %hash1;
open (IN2,$fIn2) or die $!;
open (OUT,">$fOut") or die $!;
$/="\n"; 
while (<IN2>) {
	chomp; 
	next if (/^$/);
	next if (/^Sample_name/);
	my @contig_info=split /\t/,$_;
	my $viral_contig_id=$contig_info[0];
	$hash2{$viral_contig_id}=0;

	
}
#print Dumper %hash2;
close(IN2);

foreach my $key (sort keys %hash2) {
if (exists($hash1{$key})) {
	my $match_seq=$hash1{$key};
	print OUT ">$key";
	print OUT "\n";
	print OUT $match_seq;
	print OUT "\n";
	}
}
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
  -i1 <file> fasta file of the assembled contig
  -i2 <file> the table of identified viral contigs
  -o  <file> the sequences of identified viral contigs
  -h         Help

USAGE
	print $usage;
	exit;
}


