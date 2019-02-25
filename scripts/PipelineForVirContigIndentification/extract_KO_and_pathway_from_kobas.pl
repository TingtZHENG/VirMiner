if(@ARGV!=1){
        print "Usage:perl $0  <.kobas> \n";
        exit;
}

use Data::Dumper;

$/="////";
open IN,$ARGV[0] or die "";
while(<IN>){
	chomp;
	s/^\n//;
	if(/^Query/){
# 		print ">$_<\n";
		@temp=split(/\n/,$_);
		$KO="NA";
		$path="";
		for($i=0;$i<@temp;$i++){
			if($temp[$i]=~/^Query:/){
				@temp2=split(/\s+/,$temp[$i]);
				$id=$temp2[1];
			}
			if($temp[$i]=~/^KO:/){
				@temp2=split(/\s+/,$temp[$i]);
				$KO=$temp2[1];
				next;
			}
			if($temp[$i]=~/ko/){
# 				print "$temp[$i]\n";
				@temp2=split(/\s+/,$temp[$i]);
				$temp[$i]=~s/^(Pathway:){0,1}\s+//g;
				$temp[$i]=~s/KEGG PATHWAY\s+//g;
				$temp[$i]=~s/\t/:/g;
				$path.="$temp[$i];";
# 				print ">>>$temp[$i]<<<\n";
			}
		}
		print "$id\t$KO\t$path\n";
	}
	
}