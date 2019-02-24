#!/usr/bin/perl -w

use strict;

my $version=1.05;
use Getopt::Long;

my %opts;

if($ARGV[0] eq "-v" or $ARGV[0] eq "--help"){
	print STDERR "$0, Version $version\n";
	exit;
}

&command if(@ARGV<1);

GetOptions(\%opts,"i=s","f=s","r=s","o=s","a=s","q:s","c:s","l:s","p","v","h");

if (!(defined $opts{i} || defined $opts{f} and defined $opts{r}) and !defined $opts{o} || defined $opts{h}) {	   
	&PrintUsage;
}

my $file1 = $opts{'i'}; #Single Reads file
my $file2 = $opts{'f'}; #forward fastq file
my $file3 = $opts{'r'}; #reverse fastq file
my $file4 = $opts{'o'}; #Output prefix
my $qCutOff = (defined $opts{c})?$opts{c}:20; #quality_threshold
my $format = (defined $opts{q})?$opts{q}:33;  #Default:33
my $lenCut = (defined $opts{l})?$opts{l}:30; #Default:30
my $adapter = (defined $opts{a})?$opts{a}:"ATCGGAAGAGC"; #Default:Tru-Seq Adapter

my ($size1,$size2,$trimStart1,$trimStart2,$id1,$seq1,$qual1,$id2,$seq2,$qual2,@qual1,@qual2,$total_length1,$total_length2,$single_length1,$single_length2,$total_length_trimmed1,$total_length_trimmed2,$trimCount1,$trimCount2,$len1,$len2,$length1,$length2,$input,$high1,$high2,$high3,$high4,%hash,$pos,$pos1,$pos2,$adp,$dup_num);
$total_length1 = $total_length2 = $total_length_trimmed1 = $total_length_trimmed2 = $single_length1 = $single_length2 = 0;
my $oldtime = time();

my $cmd =$ARGV[0];
my %cmd_hash =(adapter=>\&adapter,quality=>\&quality,adp_dup=>\&adp_dup,adp_qual=>\&adp_qual,duplication=>\&duplication,all=>\&all);

if(($ARGV[0] eq "adapter") or ($ARGV[0] eq "quality") or ($ARGV[0] eq "adp_dup") or ($ARGV[0] eq "adp_qual") or ($ARGV[0] eq "all") or ($ARGV[0] eq "duplication")){
	&{$cmd_hash{$cmd}};
}else{
	&command;
}

#########################adapter#########################################
sub adapter {
	
	open STAT,">$file4.stat.xls";
	
	if(defined $opts{p}){
		print STAT "Progrom,Parameters,Input and Output information:\n";
		print STAT "$0 adapter -f $file2 -r $file3 -a $adapter -l $lenCut -p -o $file4\n";
		print STAT "Input file:$file2 and $file3\n";
		print STAT "Adapter sequence: $adapter\n";
		print STAT "Output file: $file4"."_1.fastq and $file4"."_2.fastq\n";
		print STAT "Output stat file: $file4"."_report.xls\n\n";
	}else{
		print STAT "$0 adapter -i $file1 -c $qCutOff -q $format -a $adapter -l $lenCut -o $file4\n";
		print STAT "Input file:$file1\n";
		print STAT "Adapter sequence: $adapter\n";
		print STAT "Output file: $file4.fastq\n";
		print STAT "Output stat file: $file4"."_report.xls\n\n";
	}
	
	if(defined $opts{p}){
		open IN1,"$file2" || die $!;
		open IN2,"$file3" || die $!;
		open OUT1,">$file4"."_1.fastq" || die $!;
		open OUT2,">$file4"."_2.fastq" || die $!;
		
		while(!eof(IN1) && !eof(IN2)){
			$id1 = <IN1>; $seq1 = <IN1>; <IN1>; $qual1 = <IN1>; $input++;
			$id2 = <IN2>; $seq2 = <IN2>; <IN2>; $qual2 = <IN2>;
			chomp ($id1,$seq1,$qual1,$id2,$seq2,$qual2);
			
			if($seq1 =~ m/$adapter/ && $seq2 =~ m/$adapter/){
				$pos1 = index($seq1,$adapter);
				$pos2 = index($seq2,$adapter);
				if($pos1 < $lenCut or $pos2 < $lenCut){
					$adp++;
					next;
				}else{
					$seq1 = substr($seq1,0,$pos1 - 2);
					$qual1 = substr($qual1,0,$pos1 - 2);
					$seq2 = substr($seq2,0,$pos2 - 2);
					$qual2 = substr($qual2,0,$pos2 - 2); 
					print OUT1 "$id1\n$seq1\n+\n$qual1\n";
					print OUT2 "$id2\n$seq2\n+\n$qual2\n";
				}
			}elsif($seq1 =~ m/$adapter/){
				$pos1 = index($seq1,$adapter);
				if($pos1 < $lenCut){
					$adp++;
					next;
				}else{
					$seq1 = substr($seq1,0,$pos1 - 2);
					$qual1 = substr($qual1,0,$pos1 - 2);
					print OUT1 "$id1\n$seq1\n+\n$qual1\n";
					print OUT2 "$id2\n$seq2\n+\n$qual2\n";
				}
			}elsif($seq2 =~ m/$adapter/){
				$pos2 = index($seq2,$adapter);
				if($pos2 < $lenCut){
					$adp++;
					next;
				}else{
					$seq2 = substr($seq2,0,$pos2 - 2);
					$qual2 = substr($qual2,0,$pos2 - 2);
					print OUT1 "$id1\n$seq1\n+\n$qual1\n";
					print OUT2 "$id2\n$seq2\n+\n$qual2\n";
				}
			}else{
				print OUT1 "$id1\n$seq1\n+\n$qual1\n";
				print OUT2 "$id2\n$seq2\n+\n$qual2\n";
			}
		}
		close IN1;
		close IN2;
		close OUT1;
		close OUT2;
			
	}else{
		open IN,"$file1" || die $!;
		open OUT,">$file4"."_1.fastq" || die $!;
		while(!eof(IN)){
			$id1 = <IN>; $seq1 = <IN>; <IN>; $qual1 = <IN>; $input++;
			chomp ($id1,$seq1,$qual1);
			if($seq1 =~ m/$adapter/){
				$pos = index($seq1,$adapter);
				if($pos < $lenCut){
					$adp++;
					next;
				}else{
					$seq1 = substr($seq1,0,$pos - 2);
					$qual1 = substr($qual1,0,$pos - 2);
					print OUT "$id1\n$seq1\n+\n$qual1\n";
				}
			}else{
				print OUT "$id1\n$seq1\n+\n$qual1\n";
			}
		}
		close IN;
		close OUT;
		
	}
	
	my $oo = time() - $oldtime;
	
	
	my $reads = $input - $adp;
	my $percentage = int($reads/$input*10000)/100;
	
	if(defined $opts{p}){
		print STAT "Name\tTotal_Reads\tValid_Data\tPercentage\n";
		print STAT "$file2\t$input\t$reads\t$percentage%\n";
		print STAT "$file2\t$input\t$reads\t$percentage%\n";
		print STAT "\nTime consumption is $oo";
	}else{
		print STAT "Name\tTotal_Reads\tValid_Data\tPercentage\n";
		print STAT "$file1\t$input\t$reads\t$percentage%\n";
		print STAT "\nTime consumption is $oo sec.";
	}
	
	close STAT;
}

#########################quality#########################################
sub quality {
	open STAT,">$file4.stat.xls";

	if(defined $opts{p}){
		print STAT "Progrom,Parameters,Input and Output information:\n";
		print STAT "$0 quality -f $file2 -r $file3 -c $qCutOff -q $format -l $lenCut -p -o $file4\n";
		print STAT "Input file:$file2 and $file3\n";
		print STAT "Low quality threshold:$qCutOff\n";
		print STAT "Input file format:$format\n";
		print STAT "Output file: $file4.$qCutOff"."_1.fastq and $file4.$qCutOff"."_2.fastq\n";
		print STAT "Output stat file: $file4.stat.xls\n\n";
	}else{
		print STAT "$0 quality -i $file1 -c $qCutOff -q $format -l $lenCut -o $file4\n";
		print STAT "Input file:$file1\n";
		print STAT "Low quality threshold:$qCutOff\n";
		print STAT "Input file format:$format\n";;
		print STAT "Output file: $file4.$qCutOff.fastq\n";
		print STAT "Output stat file: $file4.stat.xls\n\n";
	}
	
	if(defined $opts{p}){  #Paired-End Format
		open IN1,"$file2" || die $!;
		open IN2,"$file3" || die $!;
		open OUT1,">$file4.$qCutOff"."_1.fastq" || die $!;
		open OUT2,">$file4.$qCutOff"."_2.fastq" || die $!;
		open OUT3,">$file4"."_single_1.fastq" || die $!;
		open OUT4,">$file4"."_single_2.fastq" || die $!;
		
		while(!eof(IN1) && !eof(IN2)){
			$id1 = <IN1>; $seq1 = <IN1>; <IN1>; $qual1 = <IN1>; $input++;
			$id2 = <IN2>; $seq2 = <IN2>; <IN2>; $qual2 = <IN2>;
			chomp ($id1,$seq1,$qual1,$id2,$seq2,$qual2);
			$length1 =	length $seq1;
			$length2 = length $seq2;
			$total_length1 = $total_length1 + $length1;
			$total_length2 = $total_length2 + $length2;
			
			##Remove lower bases:
			@qual1 = split (//, $qual1); @qual2 = split (//, $qual2);
			$trimCount1 = $trimCount2 = $trimStart1 = $trimStart2 = 0;
			
			for(my $i = $#qual1; $i > 0; $i--) {
				my $val1 = ord($qual1[$i]) - $format;
				if($val1 < $qCutOff) {
					$trimCount1++;
				}else{
					last;
				}
			}
			
			for(my $i = 0;$i < $#qual1; $i++) {
				my $val1 = ord($qual1[$i]) - $format;
				if($val1 < $qCutOff) {
					$trimStart1++;
				}else{
					last;
				}
			}
			
			for(my $i=$#qual2; $i>0; $i--) {
				my $val2 = ord($qual2[$i]) - $format;
				if($val2 < $qCutOff) {
					$trimCount2++;
				}else{
					last;
				}
			}
			
			for(my $i = 0;$i < $#qual2; $i++) {
				my $val2 = ord($qual2[$i]) - $format;
				if($val2 < $qCutOff) {
					$trimStart2++;
				}else{
					last;
				}
			}
			
			$size1 = $length1 - $trimStart1 - $trimCount1;
			$qual1 = substr($qual1,$trimStart1,$size1);
			$seq1 = substr($seq1,$trimStart1,$size1);
			
			$size2 = $length2 - $trimStart2 - $trimCount2;
			$qual2 = substr($qual2,$trimStart2,$size2);
			$seq2 = substr($seq2,$trimStart2,$size2);
			
			$len1 = length $seq1;
			$len2 = length $seq2;
			
			if(($len1 >= $lenCut) && ($len2 >= $lenCut)){
				print OUT1 "$id1\n$seq1\n+\n$qual1\n";
				print OUT2 "$id2\n$seq2\n+\n$qual2\n";
				$total_length_trimmed1 = $total_length_trimmed1 + $len1;
				$total_length_trimmed2 = $total_length_trimmed2 + $len2;
				$high1++; $high2++;
			}elsif($len1 >= $lenCut){
				print OUT3 "$id1\n$seq1\n+\n$qual1\n";
				$high3++;$single_length1 = $single_length1 + $len1;
			}elsif($len2 >= $lenCut){
				print OUT4 "$id2\n$seq2\n+\n$qual2\n";
				$high4++;$single_length2 = $single_length2 + $len2;
			}
		}
		close IN1;
		close IN2;
		close OUT1;
		close OUT2;
		close OUT3;
		close OUT4;
		
	}else{ #Single Format
		open IN1,"$file1" || die $!;
		open OUT1,">$file4.$qCutOff.fastq" || die $!;
		while(!eof(IN1)){
			$id1 = <IN1>; $seq1 = <IN1>; <IN1>; $qual1 = <IN1>; $input++;
			chomp ($id1,$seq1,$qual1);
			
			$length1 = length $seq1;
			$total_length1 = $total_length1 + $length1;
			
			##Remove lower bases:
			@qual1 = split (//, $qual1);
			$trimCount1 = $trimStart1 = 0;
			
			for(my $i=$#qual1; $i>0; $i--) {
				my $val = ord($qual1[$i]) - $format;
				if($val < $qCutOff) {
					$trimCount1++;
				}else{
					last;
				}
			}
			
			for(my $i = 0;$i < $#qual1; $i++) {
				my $val = ord($qual1[$i]) - $format;
				if($val < $qCutOff) {
					$trimStart1++;
				}else{
					last;
				}
			}
			
			$size1 = $length1 - $trimStart1 - $trimCount1;
			$qual1 = substr($qual1,$trimStart1,$size1);
			$seq1 = substr($seq1,$trimStart1,$size1);
			$len1 = length $seq1;
			
			if($len1 >= $lenCut){
				print OUT1 "$id1\n$seq1\n+\n$qual1\n";
				$total_length_trimmed1 = $total_length_trimmed1 + $len1;
				$high1++;
			}
		}
		close IN1;
		close OUT1;
	}
	
	if(defined $opts{p}){
		my $rata_trimmed1 = int(10000*$total_length_trimmed1/$total_length1)/100;
		my $rata_trimmed2 = int(10000*$total_length_trimmed2/$total_length2)/100;
		my $single1 = int(10000*$single_length1/$total_length1)/100;
		my $single2 = int(10000*$single_length2/$total_length2)/100;
	
		print STAT "Remove lower bases information:\n";
		print STAT "Name\tTotal_Reads\tTotal_bases\tHigh_quility_reads\tHigh_quility_bases\tSingle_Reads\tSingle_bases\n";
		print STAT "$file2\t$input\t$total_length1\t$high1\t$total_length_trimmed1($rata_trimmed1%)\t$high3\t$single_length1($single1%)\n";
		print STAT "$file3\t$input\t$total_length2\t$high2\t$total_length_trimmed2($rata_trimmed2%)\t$high4\t$single_length2($single2%)\n\n";
		
	}else{
		my $rata_trimmed1 = int(10000*$total_length_trimmed1/$total_length1)/100;
		
		print STAT "Remove lower bases information:\n";
		print STAT "Total reads: $input\n";
		print STAT "Total bases: $total_length1\n";
		print STAT "High quility reads: $high1\n";
		print STAT "Total bases after trimming: $total_length_trimmed1($rata_trimmed1%)\n\n";
	}
	
	my $oo = time() - $oldtime;
	$oo = int(100*$oo/60)/100;
	print STAT "All completed successfully!\n\nTime consumption is $oo min";
	close STAT;
}

#########################duplication#########################################
sub duplication {
	
	open STAT,">$file4.stat.xls";
	
	if(defined $opts{p}){
		print STAT "Progrom,Parameters,Input and Output information:\n";
		print STAT "$0 duplication -f $file2 -r $file3 -l $lenCut -p -o $file4\n";
		print STAT "Input file:$file2 and $file3\n";
		print STAT "Output file: $file4.dup"."_1.fastq and $file4.dup"."_2.fastq\n";
		print STAT "Output stat file: $file4.stat.xls\n\n";
	}else{
		print STAT "$0 duplication -i $file1 -l $lenCut -o $file4\n";
		print STAT "Input file:$file1\n";
		print STAT "Output file: $file4.dup.fastq\n";
		print STAT "Output stat file: $file4.stat.xls\n\n";
	}
	
	if(defined $opts{p}){  #Paired-End Format
		open IN1,"$file2" || die $!;
		open IN2,"$file3" || die $!;
		open OUT1,">$file4.dup"."_1.fastq" || die $!;
		open OUT2,">$file4.dup"."_2.fastq" || die $!;
		
		while(!eof(IN1) && !eof(IN2)){
			$id1 = <IN1>; $seq1 = <IN1>; <IN1>; $qual1 = <IN1>; $input++;
			$id2 = <IN2>; $seq2 = <IN2>; <IN2>; $qual2 = <IN2>;
			chomp ($id1,$seq1,$qual1,$id2,$seq2,$qual2);
			
			##Remove duplication:
			my $dup = substr($seq1,0,$lenCut).substr($seq2,0,$lenCut);
			$hash{$dup}++;
			if($hash{$dup} == 1){
				print OUT1 "$id1\n$seq1\n+\n$qual1\n";
				print OUT2 "$id2\n$seq2\n+\n$qual2\n";
			}else{
					$dup_num++;
					next;
			}
		}
		close IN1;
		close IN2;
		close OUT1;
		close OUT2;
		
	}else{ #Single Format
		open IN1,"$file1" || die $!;
		open OUT1,">$file4.dup.fastq" || die $!;
		while(!eof(IN1)){
			$id1 = <IN1>; $seq1 = <IN1>; <IN1>; $qual1 = <IN1>; $input++;
			chomp ($id1,$seq1,$qual1);
			
			##Remove duplication:
			my $dup = substr($seq1,0,$lenCut);
			$hash{$dup}++;
			if($hash{$dup} == 1){
				print OUT1 "$id1\n$seq1\n+\n$qual1\n";
			}else{
					$dup_num++;
					next;
			}
		}
					
		close IN1;
		close OUT1;
	}
	
	my $dup_rate = int(10000*$dup_num/$input)/100;
	
	print STAT "Duplication information:\n";
	print STAT "Total reads: $input\n";
	print STAT "Duplicate reads: $dup_num\n";
	print STAT "Duplication: $dup_rate%\n\n";
		
	undef %hash;
		
	my $oo = time() - $oldtime;
	$oo = int(100*$oo/60)/100;
	print STAT "All completed successfully!\n\nTime consumption is $oo min";
	close STAT;
}

#########################adp_qual#########################################
sub adp_qual {
	open STAT,">$file4.stat.xls";

	if(defined $opts{p}){
		print STAT "Progrom,Parameters,Input and Output information:\n";
		print STAT "$0 adp_qual -f $file2 -r $file3 -c $qCutOff -q $format -a $adapter -l $lenCut -p -o $file4\n";
		print STAT "Input file:$file2 and $file3\n";
		print STAT "Low quality threshold:$qCutOff\n";
		print STAT "Input file format:$format\n";
		print STAT "Adapter sequence: $adapter\n";
		print STAT "Output file: $file4"."_1.fastq and $file4"."_2.fastq\n";
		print STAT "Output stat file: $file4.stat.xls\n\n";
	}else{
		print STAT "$0 adp_qual -i $file1 -c $qCutOff -q $format -a $adapter -l $lenCut -o $file4\n";
		print STAT "Input file:$file1\n";
		print STAT "Low quality threshold:$qCutOff\n";
		print STAT "Input file format:$format\n";
		print STAT "Adapter sequence: $adapter\n";
		print STAT "Output file: $file4.fastq\n";
		print STAT "Output stat file: $file4.stat.xls\n\n";
	}
	
	if(defined $opts{p}){  #Paired-End Format
		open IN1,"$file2" || die $!;
		open IN2,"$file3" || die $!;
		open OUT1,">$file4"."_1.fastq" || die $!;
		open OUT2,">$file4"."_2.fastq" || die $!;
		open OUT3,">$file4"."_single_1.fastq" || die $!;
		open OUT4,">$file4"."_single_2.fastq" || die $!;
		
		while(!eof(IN1) && !eof(IN2)){
			$id1 = <IN1>; $seq1 = <IN1>; <IN1>; $qual1 = <IN1>; $input++;
			$id2 = <IN2>; $seq2 = <IN2>; <IN2>; $qual2 = <IN2>;
			chomp ($id1,$seq1,$qual1,$id2,$seq2,$qual2);
			$length1 =	length $seq1;
			$length2 = length $seq2;
			$total_length1 = $total_length1 + $length1;
			$total_length2 = $total_length2 + $length2;
			
			
			##Remove adapter:
			if($seq1 =~ m/$adapter/ && $seq2 =~ m/$adapter/){
				$pos1 = index($seq1,$adapter);
				$pos2 = index($seq2,$adapter);
				if($pos1 < $lenCut or $pos2 < $lenCut){
					$adp++;
					next;
				}else{
					$seq1 = substr($seq1,0,$pos1 - 2);
					$qual1 = substr($qual1,0,$pos1 - 2);
					$seq2 = substr($seq2,0,$pos2 - 2);
					$qual2 = substr($qual2,0,$pos2 - 2); 
				}
			}elsif($seq1 =~ m/$adapter/){
				$pos1 = index($seq1,$adapter);
				if($pos1 < $lenCut){
					$adp++;
					next;
				}else{
					$seq1 = substr($seq1,0,$pos1 - 2);
					$qual1 = substr($qual1,0,$pos1 - 2);
				}
			}elsif($seq2 =~ m/$adapter/){
				$pos2 = index($seq2,$adapter);
				if($pos2 < $lenCut){
					$adp++;
					next;
				}else{
					$seq2 = substr($seq2,0,$pos2 - 2);
					$qual2 = substr($qual2,0,$pos2 - 2);
				}
			}
			
			##Remove lower bases:
			@qual1 = split (//, $qual1); @qual2 = split (//, $qual2);
			$trimCount1 = $trimCount2 = $trimStart1 = $trimStart2 = 0;
			
			for(my $i=$#qual1; $i>0; $i--) {
				my $val1 = ord($qual1[$i]) - $format;
				if($val1 < $qCutOff) {
					$trimCount1++;
				}else{
					last;
				}
			}
			
			for(my $i = 0;$i < $#qual1; $i++) {
				my $val1 = ord($qual1[$i]) - $format;
				if($val1 < $qCutOff) {
					$trimStart1++;
				}else{
					last;
				}
			}
			
			for(my $i=$#qual2; $i>0; $i--) {
				my $val2 = ord($qual2[$i]) - $format;
				if($val2 < $qCutOff) {
					$trimCount2++;
				}else{
					last;
				}
			}
			
			for(my $i = 0;$i < $#qual2; $i++) {
				my $val2 = ord($qual2[$i]) - $format;
				if($val2 < $qCutOff) {
					$trimStart2++;
				}else{
					last;
				}
			}
			
			$size1 = $length1 - $trimStart1 - $trimCount1;
			$qual1 = substr($qual1,$trimStart1,$size1);
			$seq1 = substr($seq1,$trimStart1,$size1);
			
			$size2 = $length2 - $trimStart2 - $trimCount2;
			$qual2 = substr($qual2,$trimStart2,$size2);
			$seq2 = substr($seq2,$trimStart2,$size2);
			
			$len1 = length $seq1;
			$len2 = length $seq2;
			
			if(($len1 >= $lenCut) && ($len2 >= $lenCut)){
				print OUT1 "$id1\n$seq1\n+\n$qual1\n";
				print OUT2 "$id2\n$seq2\n+\n$qual2\n";
				$total_length_trimmed1 = $total_length_trimmed1 + $len1;
				$total_length_trimmed2 = $total_length_trimmed2 + $len2;
				$high1++; $high2++;
			}elsif($len1 >= $lenCut){
				print OUT3 "$id1\n$seq1\n+\n$qual1\n";
				$high3++;$single_length1 = $single_length1 + $len1;
			}elsif($len2 >= $lenCut){
				print OUT4 "$id2\n$seq2\n+\n$qual2\n";
				$high4++;$single_length2 = $single_length2 + $len2;
			}
		}
		close IN1;
		close IN2;
		close OUT1;
		close OUT2;
		close OUT3;
		close OUT4;
		
	}else{ #Single Format
		open IN1,"$file1" || die $!;
		open OUT1,">$file4.fastq" || die $!;
		while(!eof(IN1)){
			$id1 = <IN1>; $seq1 = <IN1>; <IN1>; $qual1 = <IN1>; $input++;
			chomp ($id1,$seq1,$qual1);
			
			$length1 = length $seq1;
			$total_length1 = $total_length1 + $length1;
			
			#Remove adapter:
			if($seq1 =~ m/$adapter/){
				$pos = index($seq1,$adapter);
				if($pos < $lenCut){
					$adp++;
					next;
				}else{
					$seq1 = substr($seq1,0,$pos - 2);
					$qual1 = substr($qual1,0,$pos - 2);
				}
			}
			
			##Remove lower bases:
			@qual1 = split (//, $qual1);
			$trimCount1 = $trimStart1 = 0;
			
			for(my $i=$#qual1; $i>0; $i--) {
				my $val = ord($qual1[$i]) - $format;
				if($val < $qCutOff) {
					$trimCount1++;
				}else{
					last;
				}
			}
			
			for(my $i = 0;$i < $#qual1; $i++) {
				my $val = ord($qual1[$i]) - $format;
				if($val < $qCutOff) {
					$trimStart1++;
				}else{
					last;
				}
			}
			
			$size1 = $length1 - $trimStart1 - $trimCount1;
			$qual1 = substr($qual1,$trimStart1,$size1);
			$seq1 = substr($seq1,$trimStart1,$size1);
			$len1 = length $seq1;
			
			if($len1 >= $lenCut){
				print OUT1 "$id1\n$seq1\n+\n$qual1\n";
				$total_length_trimmed1 = $total_length_trimmed1 + $len1;
				$high1++;
			}
		}
		close IN1;
		close OUT1;
	}
	
	if(defined $opts{p}){
		my $rata_trimmed1 = int(10000*$total_length_trimmed1/$total_length1)/100;
		my $rata_trimmed2 = int(10000*$total_length_trimmed2/$total_length2)/100;
		my $single1 = int(10000*$single_length1/$total_length1)/100;
		my $single2 = int(10000*$single_length2/$total_length2)/100;
		my $reads = $input - $adp;
		my $percentage = int(10000*$reads/$input)/100;
	
		print STAT "Remove adpter information:\n";
		print STAT "Name\tTotal_Reads\tValid_Data\tPercentage\n";
		print STAT "$file2\t$input\t$reads\t$percentage%\n";
		print STAT "$file3\t$input\t$reads\t$percentage%\n\n";
		
		print STAT "Remove lower bases information:\n";
		print STAT "Name\tTotal_Reads\tTotal_bases\tHigh_quility_reads\tHigh_quility_bases\tSingle_Reads\tSingle_bases\n";
		print STAT "$file2\t$input\t$total_length1\t$high1\t$total_length_trimmed1($rata_trimmed1%)\t$high3\t$single_length1($single1%)\n";
		print STAT "$file3\t$input\t$total_length2\t$high2\t$total_length_trimmed2($rata_trimmed2%)\t$high4\t$single_length2($single2%)\n\n";
		
	}else{
		my $rata_trimmed1 = int(10000*$total_length_trimmed1/$total_length1)/100;
		my $reads = $input - $adp;
		my $percentage = int(10000*$reads/$input)/100;
		
		print STAT "Remove adpter information:\n";
		print STAT "Name\tTotal_Reads\tValid_Data\tPercentage\n";
		print STAT "$file1\t$input\t$reads\t$percentage%\n\n";
		
		print STAT "Remove lower bases information:\n";
		print STAT "Total reads: $input\n";
		print STAT "Total bases: $total_length1\n";
		print STAT "High quility reads: $high1\n";
		print STAT "Total bases after trimming: $total_length_trimmed1($rata_trimmed1%)\n\n";
	}
	
	my $oo = time() - $oldtime;
	$oo = int(100*$oo/60)/100;
	print STAT "All completed successfully!\n\nTime consumption is $oo min";
	close STAT;
}

#########################adp_dup#########################################
sub adp_dup {
	
	open STAT,">$file4.stat.xls";
	
	if(defined $opts{p}){
		print STAT "Progrom,Parameters,Input and Output information:\n";
		print STAT "$0 adp_dup -f $file2 -r $file3 -a $adapter -l $lenCut -p -o $file4\n";
		print STAT "Input file:$file2 and $file3\n";
		print STAT "Adapter sequence: $adapter\n";
		print STAT "Output file: $file4"."_1.fastq and $file4"."_2.fastq\n";
		print STAT "Output stat file: $file4.stat.xls\n\n";
	}else{
		print STAT "$0 adp_dup -i $file1 -a $adapter -l $lenCut -o $file4\n";
		print STAT "Input file:$file1\n";
	  print STAT "Adapter sequence: $adapter\n";
		print STAT "Output file: $file4.fastq\n";
		print STAT "Output stat file: $file4.stat.xls\n\n";
	}
	
	if(defined $opts{p}){  #Paired-End Format
		open IN1,"$file2" || die $!;
		open IN2,"$file3" || die $!;
		open OUT1,">$file4"."_1.fastq" || die $!;
		open OUT2,">$file4"."_2.fastq" || die $!;
		open OUT3,">$file4"."_single_1.fastq" || die $!;
		open OUT4,">$file4"."_single_2.fastq" || die $!;
		
		while(!eof(IN1) && !eof(IN2)){
			$id1 = <IN1>; $seq1 = <IN1>; <IN1>; $qual1 = <IN1>; $input++;
			$id2 = <IN2>; $seq2 = <IN2>; <IN2>; $qual2 = <IN2>;
			chomp ($id1,$seq1,$qual1,$id2,$seq2,$qual2);
			$length1 =	length $seq1;
			$length2 = length $seq2;
			$total_length1 = $total_length1 + $length1;
			$total_length2 = $total_length2 + $length2;
			
			
			##Remove adapter:
			if($seq1 =~ m/$adapter/ && $seq2 =~ m/$adapter/){
				$pos1 = index($seq1,$adapter);
				$pos2 = index($seq2,$adapter);
				if($pos1 < $lenCut or $pos2 < $lenCut){
					$adp++;
					next;
				}else{
					$seq1 = substr($seq1,0,$pos1 - 2);
					$qual1 = substr($qual1,0,$pos1 - 2);
					$seq2 = substr($seq2,0,$pos2 - 2);
					$qual2 = substr($qual2,0,$pos2 - 2); 
				}
			}elsif($seq1 =~ m/$adapter/){
				$pos1 = index($seq1,$adapter);
				if($pos1 < $lenCut){
					$adp++;
					next;
				}else{
					$seq1 = substr($seq1,0,$pos1 - 2);
					$qual1 = substr($qual1,0,$pos1 - 2);
				}
			}elsif($seq2 =~ m/$adapter/){
				$pos2 = index($seq2,$adapter);
				if($pos2 < $lenCut){
					$adp++;
					next;
				}else{
					$seq2 = substr($seq2,0,$pos2 - 2);
					$qual2 = substr($qual2,0,$pos2 - 2);
				}
			}
			
			$len1 = length $seq1;
			$len2 = length $seq2;
			
			if(($len1 >= $lenCut) && ($len2 >= $lenCut)){
				
				##Remove duplication:
				my $dup = substr($seq1,0,$lenCut).substr($seq2,0,$lenCut);
				$hash{$dup}++;
				if($hash{$dup} == 1){
					print OUT1 "$id1\n$seq1\n+\n$qual1\n";
					print OUT2 "$id2\n$seq2\n+\n$qual2\n";
					$total_length_trimmed1 = $total_length_trimmed1 + $len1;
					$total_length_trimmed2 = $total_length_trimmed2 + $len2;
					$high1++; $high2++;
				}else{
					$dup_num++;
					next;
				}
			}elsif($len1 >= $lenCut){
				print OUT3 "$id1\n$seq1\n+\n$qual1\n";
				$high3++;$single_length1 = $single_length1 + $len1;
			}elsif($len2 >= $lenCut){
				print OUT4 "$id2\n$seq2\n+\n$qual2\n";
				$high4++;$single_length2 = $single_length2 + $len2;
			}
		}
		close IN1;
		close IN2;
		close OUT1;
		close OUT2;
		close OUT3;
		close OUT4;
		
	}else{ #Single Format
		open IN1,"$file1" || die $!;
		open OUT1,">$file4.fastq" || die $!;
		while(!eof(IN1)){
			$id1 = <IN1>; $seq1 = <IN1>; <IN1>; $qual1 = <IN1>; $input++;
			chomp ($id1,$seq1,$qual1);
			
			$length1 = length $seq1;
			$total_length1 = $total_length1 + $length1;
			
			#Remove adapter:
			if($seq1 =~ m/$adapter/){
				$pos = index($seq1,$adapter);
				if($pos < $lenCut){
					$adp++;
					next;
				}else{
					$seq1 = substr($seq1,0,$pos - 2);
					$qual1 = substr($qual1,0,$pos - 2);
				}
			}
			
			$len1 = length $seq1;
			
			if($len1 >= $lenCut){
				##Remove duplication:
				my $dup = substr($seq1,0,$lenCut);
				$hash{$dup}++;
				if($hash{$dup} == 1){
					print OUT1 "$id1\n$seq1\n+\n$qual1\n";
				}else{
					$dup_num++;
					next;
				}
			}
		}
		close IN1;
		close OUT1;
	}
	
	if(defined $opts{p}){
		my $rata_trimmed1 = int(10000*$total_length_trimmed1/$total_length1)/100;
		my $rata_trimmed2 = int(10000*$total_length_trimmed2/$total_length2)/100;
		my $single1 = int(10000*$single_length1/$total_length1)/100;
		my $single2 = int(10000*$single_length2/$total_length2)/100;
		my $reads = $input - $adp;
		my $percentage = int(10000*$reads/$input)/100;
		my $dup_rate = int(10000*$dup_num/$reads)/100;
	
		print STAT "Remove adpter information:\n";
		print STAT "Name\tTotal_Reads\tValid_Data\tPercentage\n";
		print STAT "$file2\t$input\t$reads\t$percentage%\n";
		print STAT "$file3\t$input\t$reads\t$percentage%\n\n";
		
		print STAT "Duplication information:\n";
		print STAT "Total reads: $reads\n";
		print STAT "Duplicate reads: $dup_num\n";
		print STAT "Duplication: $dup_rate%\n\n";
		
	}else{
		my $rata_trimmed1 = int(10000*$total_length_trimmed1/$total_length1)/100;
		my $reads = $input - $adp;
		my $percentage = int(10000*$reads/$input)/100;
		my $dup_rate = int(10000*$dup_num/$reads)/100;
		
		print STAT "Remove adpter information:\n";
		print STAT "Name\tTotal_Reads\tValid_Data\tPercentage\n";
		print STAT "$file1\t$input\t$reads\t$percentage%\n\n";
		
		print STAT "Duplication information:\n";
		print STAT "Total reads: $reads\n";
		print STAT "Duplicate reads: $dup_num\n";
		print STAT "Duplication: $dup_rate%\n\n";
	}
		
	undef %hash;
	
	my $oo = time() - $oldtime;
	$oo = int(100*$oo/60)/100;
	print STAT "All completed successfully!\n\nTime consumption is $oo min";
	close STAT;
}

#########################all#########################################
sub all {
	
	open STAT,">$file4.stat.xls";
	
	if(defined $opts{p}){
		print STAT "Progrom,Parameters,Input and Output information:\n";
		print STAT "$0 all -f $file2 -r $file3 -c $qCutOff -q $format -a $adapter -l $lenCut -p -o $file4\n";
		print STAT "Input file:$file2 and $file3\n";
		print STAT "Low quality threshold:$qCutOff\n";
		print STAT "Input file format:$format\n";
		print STAT "Adapter sequence: $adapter\n";
		print STAT "Output file: $file4.$qCutOff"."_1.fastq and $file4.$qCutOff"."_2.fastq\n";
		print STAT "Output stat file: $file4.stat.xls\n\n";
	}else{
		print STAT "$0 all -i $file1 -c $qCutOff -q $format -a $adapter -l $lenCut -o $file4\n";
		print STAT "Input file:$file1\n";
		print STAT "Low quality threshold:$qCutOff\n";
		print STAT "Input file format:$format\n";
		print STAT "Adapter sequence: $adapter\n";
		print STAT "Output file: $file4.$qCutOff.fastq\n";
		print STAT "Output stat file: $file4.stat.xls\n\n";
	}
	
	if(defined $opts{p}){  #Paired-End Format
		open IN1,"$file2" || die $!;
		open IN2,"$file3" || die $!;
		open OUT1,">$file4"."_1.fastq" || die $!;
		open OUT2,">$file4"."_2.fastq" || die $!;
		open OUT3,">$file4"."_single_1.fastq" || die $!;
		open OUT4,">$file4"."_single_2.fastq" || die $!;
		
		while(!eof(IN1) && !eof(IN2)){
			$id1 = <IN1>; $seq1 = <IN1>; <IN1>; $qual1 = <IN1>; $input++;
			$id2 = <IN2>; $seq2 = <IN2>; <IN2>; $qual2 = <IN2>;
			chomp ($id1,$seq1,$qual1,$id2,$seq2,$qual2);
			$length1 =	length $seq1;
			$length2 = length $seq2;
			$total_length1 = $total_length1 + $length1;
			$total_length2 = $total_length2 + $length2;
			
			
			##Remove adapter:
			if($seq1 =~ m/$adapter/ && $seq2 =~ m/$adapter/){
				$pos1 = index($seq1,$adapter);
				$pos2 = index($seq2,$adapter);
				if($pos1 < $lenCut or $pos2 < $lenCut){
					$adp++;
					next;
				}else{
					$seq1 = substr($seq1,0,$pos1 - 2);
					$qual1 = substr($qual1,0,$pos1 - 2);
					$seq2 = substr($seq2,0,$pos2 - 2);
					$qual2 = substr($qual2,0,$pos2 - 2); 
				}
			}elsif($seq1 =~ m/$adapter/){
				$pos1 = index($seq1,$adapter);
				if($pos1 < $lenCut){
					$adp++;
					next;
				}else{
					$seq1 = substr($seq1,0,$pos1 - 2);
					$qual1 = substr($qual1,0,$pos1 - 2);
				}
			}elsif($seq2 =~ m/$adapter/){
				$pos2 = index($seq2,$adapter);
				if($pos2 < $lenCut){
					$adp++;
					next;
				}else{
					$seq2 = substr($seq2,0,$pos2 - 2);
					$qual2 = substr($qual2,0,$pos2 - 2);
				}
			}
			
			##Remove lower bases:
			@qual1 = split (//, $qual1); @qual2 = split (//, $qual2);
			$trimCount1 = $trimCount2 = $trimStart1 = $trimStart2 = 0;
			
			for(my $i=$#qual1; $i>0; $i--) {
				my $val1 = ord($qual1[$i]) - $format;
				if($val1 < $qCutOff) {
					$trimCount1++;
				}else{
					last;
				}
			}
			
			for(my $i = 0;$i < $#qual1; $i++) {
				my $val1 = ord($qual1[$i]) - $format;
				if($val1 < $qCutOff) {
					$trimStart1++;
				}else{
					last;
				}
			}
			
			for(my $i=$#qual2; $i>0; $i--) {
				my $val2 = ord($qual2[$i]) - $format;
				if($val2 < $qCutOff) {
					$trimCount2++;
				}else{
					last;
				}
			}
			
			for(my $i = 0;$i < $#qual2; $i++) {
				my $val2 = ord($qual2[$i]) - $format;
				if($val2 < $qCutOff) {
					$trimStart2++;
				}else{
					last;
				}
			}
			
			$size1 = $length1 - $trimStart1 - $trimCount1;
			$qual1 = substr($qual1,$trimStart1,$size1);
			$seq1 = substr($seq1,$trimStart1,$size1);
			
			$size2 = $length2 - $trimStart2 - $trimCount2;
			$qual2 = substr($qual2,$trimStart2,$size2);
			$seq2 = substr($seq2,$trimStart2,$size2);
			
			$len1 = length $seq1;
			$len2 = length $seq2;
			
			if(($len1 >= $lenCut) && ($len2 >= $lenCut)){
				
				##Remove duplication:
				my $dup = substr($seq1,0,$lenCut).substr($seq2,0,$lenCut);
				$hash{$dup}++;
				if($hash{$dup} == 1){
					print OUT1 "$id1\n$seq1\n+\n$qual1\n";
					print OUT2 "$id2\n$seq2\n+\n$qual2\n";
					$total_length_trimmed1 = $total_length_trimmed1 + $len1;
					$total_length_trimmed2 = $total_length_trimmed2 + $len2;
					$high1++; $high2++;
				}else{
					$dup_num++;
					next;
				}
			}elsif($len1 >= $lenCut){
				print OUT3 "$id1\n$seq1\n+\n$qual1\n";
				$high3++;$single_length1 = $single_length1 + $len1;
			}elsif($len2 >= $lenCut){
				print OUT4 "$id2\n$seq2\n+\n$qual2\n";
				$high4++;$single_length2 = $single_length2 + $len2;
			}
		}
		close IN1;
		close IN2;
		close OUT1;
		close OUT2;
		close OUT3;
		close OUT4;
		
	}else{ #Single Format
		open IN1,"$file1" || die $!;
		open OUT1,">$file4.$qCutOff.fastq" || die $!;
		while(!eof(IN1)){
			$id1 = <IN1>; $seq1 = <IN1>; <IN1>; $qual1 = <IN1>; $input++;
			chomp ($id1,$seq1,$qual1);
			
			$length1 = length $seq1;
			$total_length1 = $total_length1 + $length1;
			
			#Remove adapter:
			if($seq1 =~ m/$adapter/){
				$pos = index($seq1,$adapter);
				if($pos <= $lenCut){
					$adp++;
					next;
				}else{
					$seq1 = substr($seq1,0,$pos - 2);
					$qual1 = substr($qual1,0,$pos - 2);
				}
			}
			
			##Remove lower bases:
			@qual1 = split (//, $qual1);
			$trimCount1 = $trimStart1 = 0;
			
			for(my $i=$#qual1; $i>0; $i--) {
				my $val = ord($qual1[$i]) - $format;
				if($val < $qCutOff) {
					$trimCount1++;
				}else{
					last;
				}
			}
			
			for(my $i = 0;$i < $#qual1; $i++) {
				my $val = ord($qual1[$i]) - $format;
				if($val < $qCutOff) {
					$trimStart1++;
				}else{
					last;
				}
			}
			
			$size1 = $length1 - $trimStart1 - $trimCount1;
			$qual1 = substr($qual1,$trimStart1,$size1);
			$seq1 = substr($seq1,$trimStart1,$size1);
			$len1 = length $seq1;
			
			if($len1 >= $lenCut){
				##Remove duplication:
				my $dup = substr($seq1,0,$lenCut);
				$hash{$dup}++;
				if($hash{$dup} == 1){
					print OUT1 "$id1\n$seq1\n+\n$qual1\n";
					$total_length_trimmed1 = $total_length_trimmed1 + $len1;
					$high1++;
				}else{
					$dup_num++;
					next;
				}
			}
		}
		close IN1;
		close OUT1;
	}
	
	if(defined $opts{p}){
		my $rata_trimmed1 = int(10000*$total_length_trimmed1/$total_length1)/100;
		my $rata_trimmed2 = int(10000*$total_length_trimmed2/$total_length2)/100;
		my $single1 = int(10000*$single_length1/$total_length1)/100;
		my $single2 = int(10000*$single_length2/$total_length2)/100;
		my $reads = $input - $adp;
		my $percentage = int(10000*$reads/$input)/100;
		my $dup_rate = int(10000*$dup_num/$reads)/100;
	
		print STAT "Remove adpter information:\n";
		print STAT "Name\tTotal_Reads\tValid_Data\tPercentage\n";
		print STAT "$file2\t$input\t$reads\t$percentage%\n";
		print STAT "$file3\t$input\t$reads\t$percentage%\n\n";
		
		print STAT "Remove lower bases information:\n";
		print STAT "Name\tTotal_Reads\tTotal_bases\tHigh_quility_reads\tHigh_quility_bases\tSingle_Reads\tSingle_bases\n";
		print STAT "$file2\t$input\t$total_length1\t$high1\t$total_length_trimmed1($rata_trimmed1%)\t$high3\t$single_length1($single1%)\n";
		print STAT "$file3\t$input\t$total_length2\t$high2\t$total_length_trimmed2($rata_trimmed2%)\t$high4\t$single_length2($single2%)\n\n";
		
		print STAT "Duplication information:\n";
		print STAT "Total reads: $high1\n";
		print STAT "Duplicate reads: $dup_num\n";
		print STAT "Duplication: $dup_rate%\n\n";
		
	}else{
		my $rata_trimmed1 = int(10000*$total_length_trimmed1/$total_length1)/100;
		my $reads = $input - $adp;
		my $percentage = int(10000*$reads/$input)/100;
		my $dup_rate = int(10000*$dup_num/$reads)/100;
		
		print STAT "Remove adpter information:\n";
		print STAT "Name\tTotal_Reads\tValid_Data\tPercentage\n";
		print STAT "$file1\t$input\t$reads\t$percentage%\n\n";
		
		print STAT "Remove lower bases information:\n";
		print STAT "Total reads: $input\n";
		print STAT "Total bases: $total_length1\n";
		print STAT "High quility reads: $high1\n";
		print STAT "Total bases after trimming: $total_length_trimmed1($rata_trimmed1%)\n\n";
		
		print STAT "Duplication information:\n";
		print STAT "Total reads: $high1\n";
		print STAT "Duplicate reads: $dup_num\n";
		print STAT "Duplication: $dup_rate%\n\n";
	}
	
	
	undef %hash;
	
	my $oo = time() - $oldtime;
	$oo = int(100*$oo/60)/100;
	print STAT "All completed successfully!\n\nTime consumption is $oo min";
	close STAT;
}

#########################Sub Script#########################################
sub PrintUsage {

	print STDERR <<'END';

Usage for single: $0 $command -i s_1_IDX1_1.fastq -o s_1_IDX1
      for Paired: $0 $command -f s_1_IDX1_1.fastq -r s_1_IDX1_2.fastq -p -o s_1_IDX1
      
      $command	<str>	: adpter,quality,adp_qual and duplication

Options: 
	-i	<str>	: Fastq file (Single)
	-f	<str>	: Forward fastq file (Paired-End)
	-r	<str>	: Reverse fastq file (Paired-End)
	-a	<str>	: Adapter sequence (Default: GATCGGAAGA)
	-c	<Ns>	: Discard sequences lower than N quality. (Default: 20)
	-q	<Ns>	: Quality format 33/64 (Default: 33)
	-l	<Ns>	: Discard sequences shorter than N nucleotides. (Default: 30)
	-o	<str>	: Output prefix
	-p       	: Paired-End Model (Default: Single)
	-v       	: Prints version of the program
	-h       	: Prints this usage summary


END
	exit(1);

}


#########################Sub Script#########################################
sub command {
	print STDERR <<'END';
	
	Usage: piplineForQC.pl Command
	
	Command:

		adapter      => Remove apapter sequence.
		quality      => Remove low base quality reads.
		duplication  => Remove duplication reads.
		adp_dup      => Remove adapter and duplication reads.
		adp_qual     => Remove adapter and filter low base quality reads.
		all          => Remove adapter, filter low base quality  and remove duplication reads.
	
END
	exit(1);

} 
