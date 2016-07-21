use Class::Struct;
struct Author => {
    name  => '$',
    email => '$',
};

#Store data#
chdir "e:/data/M1/logs" or die $!;
chdir "./${ARGV[0]}" or die $!;
open(LOGFILE, "< ./git_log.log") or die "$!";



#main
$Merge_Flag = 1;
$flag = 0;
$count = 0;
$project = $ARGV[0];
@authors= ();
$type = "N";
$i = 0;

open(OUT, "> ./sha_bug.csv") or die "$!";
while( $line = <LOGFILE> ){
#while( $line = <STDIN> ){
	chomp($line);
	if($line =~ m|^commit|){
		if($Merge_Flag == 0){
            if($flag == 1){
                $flag = 0;
                $i++;
    			print OUT $sha,"\t",$project,"\n";
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
    if ( $line =~ /bug[# \t]*[0-9]+/i ||
         $line =~ /pr[# \t]*[0-9]+/i ||
         $line =~ /show\_bug\.cgi\?id=[0-9]+/i ||
         $line =~ /\[[0-9]+\]/ ||
         $line =~ /\b(fix(e[ds])?|bugs?|defects?|patch)\b/i ){
             $flag = 1;
         }
}
if($Merge_Flag == 0){
    if($flag == 1){
            $i++;
			print OUT $sha,"\t",$project,"\n";
    }
}

print $i,"\n";

close(OUT);
close(LOGFILE);
