$n = 1;
$search = url;

$file = 'name.txt';
open (OUT, ">$file") or die "$!";

while ( $line = <> ){
	if ($line =~ m|"$search"|){
		if($line =~ m|"https://api.github.com/repos/| ){
			print "$n:$line";
			$n++;
			$url = $line;
			substr($url, 0, 43) = "";
			substr($url, -3, 3) = "\n";
			$url =~ /(\/(.+)\n)/;
			$url = $1;
			substr($url, 0, 1) = "";
			print OUT "$url";
		}
	} 
}
close(OUT);
