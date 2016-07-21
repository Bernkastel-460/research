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
$New_Author_Flag = 1;
@authors= ();

open(OUT, "> ./sha_author.csv") or die "$!";

while( $line = <LOGFILE> ){
	chomp($line);
	if($line =~ m|^commit|){
		if($Merge_Flag == 0){
			print OUT $sha,"\t",$name,"\t",${ARGV[0]},"\n";
		}
		$sha = $line;
		substr($sha,0,7) = ""; 
		$Merge_Flag = 0;
	}
	if($line =~ m|^Merge:|){
		$Merge_Flag = 1;
	}
	if($line =~ m|^Author:|){
		$author = $line;
		substr($author,0,8) = "";
		($name,$email) = split(/</, $author);
		substr($name,-1,1) = "";
		substr($email,-1,1) = "";

		for ( $i = 0; $i <= $#authors; $i++ ){
			if ( index($authors[$i]->name, "$name") >= 0 ){
				$New_Author_Flag = 0;
				if ( index($authors[$i]->email, "$email") == -1 ){
					$authors[$i]->email($authors[$i]->email . "$email/");
				}
			}elsif( index($authors[$i]->email, "$email") >= 0 ){
				$name = $authors[$i]->name;
				$New_Author_Flag = 0;
			}
		}
		if($New_Author_Flag == 1){
			$a = new Author();
			$a->name("$name");
			$a->email("$email");
			push(@authors, $a);
		}

	}
}
if($Merge_Flag == 0){
			print OUT $sha,"\t",$name,"\t",${ARGV[0]},"\n";
}
close(OUT);
close(LOGFILE);
