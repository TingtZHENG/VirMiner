if(@ARGV!=1){
        print "perl $0 <.sam>  \n";
        exit;
}
use Data::Dumper;


open IN,$ARGV[0] or die "";
while(<IN>){
        chomp;
		if(/^\@/){
			next;
		}
		@temp=split;
		if($temp[2]=~/\*/ or $temp[5]=~/\*/){
			print "$temp[0]\t0\tNA\tNA\tNA\n";
			next;
		}
		$_=$temp[5];
# 		print "$_\n";
		$sum=0;
		$t_match=0;
		while(/\d+\w/g){
# 			print "$&\n";
			$p=$&;
			
			if($p=~/M/){
				$match=$`;
				$sum+=$match;
				$t_match+=$match;
# 				print "$match\n";
			}elsif($p=~/S/){
				$sub=$`;
				$sum+=$sub;
# 				print "$sub\n";
			}elsif($p=~/I/){
				$ins=$`;
				$sum+=$ins;
# 				print "$ins\n";
			}elsif($p=~/D/){
				$del=$`;
				$sum+=$del;
# 				print "$del\n";
			}
		}
# 		print "$t_match\t$sum\n";
		print "$temp[0]\t",$t_match/$sum,"\t$temp[2]\t$t_match\t$sum\t",,"\n";
}