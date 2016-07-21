use Class::Struct;
struct Author => {
    name  => '$',
    email => '$',
};

#Store data#
chdir "/c/Users/山内/Desktop/test" or die $!;
chdir "./${ARGV[0]}" or die $!;
open(LOGFILE, "< ./git_log_-p.log") or die "$!";


#main
$Merge_Flag = 1;
$New_Author_Flag = 1;
@authors= ();

open(OUT, "> ./sha_filename.csv") or die "$!";

while( $line = <LOGFILE> ){
	chomp($line);
	if($line =~ m|^commit|){
		if($Merge_Flag == 0){
			print OUT $sha,"\t",$Old_Filename,"\t",$New_Filename,"\t",${ARGV[0]},"\n";
		}
		$sha = $line;
		substr($sha,0,7) = ""; 
		$Merge_Flag = 0;
	}
	if($line =~ m|^Merge:|){
		$Merge_Flag = 1;
	}
	if($line =~ m|^\-\-\-|){
		$Old_Filename = $line;
		substr($Old_Filename,0,6) = "";
	}
	if($line =~ m|^\+\+\+|){
		$New_Filename = $line;
		substr($New_Filename,0,6) = "";
	}
}
if($Merge_Flag == 0){
	print OUT $sha,"\t",$New_Filename,"\t",${ARGV[0]},"\n";
}
close(OUT);
close(LOGFILE);
