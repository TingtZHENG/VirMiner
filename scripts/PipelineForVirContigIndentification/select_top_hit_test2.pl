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
my ($fIn,$fIn2,$fOut,$PMDepth);
GetOptions(
				"help|?" =>\&USAGE,
				"i:s"=>\$fIn,
				"o:s"=>\$fOut,
				"d:s"=>\$PMDepth,
				) or &USAGE;
&USAGE unless ($fIn and $fOut);
open (IN,$fIn) or die $!;
open OUT,">$fOut" or die $!;
#$/=">";
my %hash1;
my %hash2;
my $query = '';
while (<IN>) {
	chomp;
	my($protein_hit,$subject_id,$identity,$align_length,$mismatch,$gap,$p_start,$p_end,$subject_start,$subject_end,$evalue,$bit_score)= split /\s+/,$_;
		if ($query ne $protein_hit) {
			$query = $protein_hit;
			print OUT "$query\t$subject_id\t$identity\t$align_length\t$mismatch\t$gap\t$p_start\t$p_end\t$subject_start\t$subject_end\t$evalue\t$bit_score\n";
		}
	next;
    }

#    $query .= $_;
#}


close OUT;

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
  -i <file> fasta file
  -o<file>     
  -h         Help

USAGE
	print $usage;
	exit;
}
