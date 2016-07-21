use strict;
use DBI;

my $d = "test";
my $DB_HOST = "localhost";
my $u = "postgres";

my $sha;
my $name;
my $filename;
my $add;
my $delete;
my $project;
my $id;
my $i = 1;

my $dbh = DBI->connect("dbi:Pg:dbname=$d;host=$DB_HOST",$u,"")
          or die "$!\n Error :failed to connect to DB.\n";
my $sth_insert = $dbh->prepare("INSERT INTO test(id, sha, name, filename, add, delete, project) VALUES(?, ?, ?, ?, ?, ?, ?)");
my $sth_number = $dbh->prepare("INSERT INTO number(sha, id, project) VALUES(?, ?, ?)");
my $sth_bug = $dbh->prepare("INSERT INTO bug(sha, project) VALUES(?, ?)");

chdir "e:/data/M1/logs" or die $!;
chdir "./${ARGV[0]}" or die $!;
#chdir "./jquery" or die $!;

open(LOGFILE, "< ./data.csv") or die "$!";
while(my $line = <LOGFILE> ){
	chomp($line);
    ($id,$sha,$name,$filename,$add,$delete,$project) = split(/\t/,$line);
    $sth_insert->execute($id, $sha, $name, $filename, $add, $delete, $project);
}
$sth_insert->finish;

open(LOGFILE, "< ./sha_bug.csv") or die "$!";
while(my $line = <LOGFILE> ){
	chomp($line);
    ($sha,$project) = split(/\t/,$line);
    $sth_bug->execute($sha, $project);
    $i++;
}
$sth_bug->finish;
close(LOGFILE);

$dbh->disconnect;