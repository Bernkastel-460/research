$n = 1;
$search = html_url;

$file = 'url.txt';
open (OUT, ">$file") or die "$!";

while ( $line = <> ){
	if ($line =~ m|"$search"|){
		print "$n:$line";
		$n++;
		$url = $line;
		if($n % 2 == 1){
			substr($url, 0, 19) = "";
			substr($url, -3, 3) = ".git\n";
			print OUT "$url";
		}
	} 
}
close(OUT);
