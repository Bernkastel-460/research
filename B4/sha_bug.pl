use Class::Struct;
struct Author => {
    name  => '$',
    email => '$',
};

#Store data#
chdir "../../git_log" or die $!;
chdir "./${ARGV[0]}" or die $!;
open(LOGFILE, "< ./git_log_-p.log") or die "$!";


#main
$Merge_Flag = 1;
$flag = 0;
$count = 0;
@authors= ();
$type = "N";

open(OUT, "> ./sha_bug.csv") or die "$!";

while( $line = <LOGFILE> ){
	chomp($line);
	if($line =~ m|^commit|){
		if($Merge_Flag == 0){
            if($flag == 1){
    			print OUT $sha,"\t",${ARGV[0]},"\n";
            }
		}
		$sha = $line;
        $count = 0;
		$flag = 0;
        substr($sha,0,7) = ""; 
		$Merge_Flag = 0;
	}
	if($line =~ m|^Merge:|){
		$Merge_Flag = 1;
	}
	if($line =~ m|^Date:|){
        $count++;
	}
    if($count != 0){
        if($count == 3){
            if ( $line =~ /bug[# \t]*[0-9]+/i ||
                 $line =~ /pr[# \t]*[0-9]+/i ||
                 $line =~ /show\_bug\.cgi\?id=[0-9]+/i ||
                 $line =~ /\[[0-9]+\]/ ||
                 $line =~ /\b(fix(e[ds])?|bugs?|defects?|patch)\b/i ){
                     $flag = 1;
            }
        }
        $count++;
    }
}
if($Merge_Flag == 0){
    if($flag == 1){
			print OUT $sha,"\t",${ARGV[0]},"\n";
    }
}
close(OUT);
close(LOGFILE);
