if(@ARGV<1){
    print "Usage perl $0 <.rpsblast> <database [COG as default]>\n";
    exit;
}

@temp=split(/\./,$ARGV[0]);
$file_name=$temp[0];

if(@ARGV==1){
    $ARGV[1]="COG";
}

# print "$ARGV[1]\n";
open IN,$ARGV[0] or die "";
while(<IN>){
    chomp;
    if(/^Query=/){
        #print "$_\n";
        $id=$_;
        $id=~s/Query=//;
#         print "$id\n";
		@temp2=split(/\s+/,$id); 
		$id=$temp2[1];
# 		 print "$id\n";
       	$flag=0;
        next;
    }
    if(/>gnl\|CDD.+($ARGV[1]\d+)/ and $flag==0){
        $info=$_;
        $fun=$1;
#         print "$1\n";
        for($k=1;$k<=5;$k++){
            $_=<IN>;
            chomp;
            s/^\s+/ /g;
            $info.=$_;
#             print "$info\n";
        }
        
#         print "$info\n";
        $info=~/\[(.+)\]/;\
#         print "$1\n";
        print "$id\t$fun\t$1\n";
        $flag=1;
    }
}
close IN;