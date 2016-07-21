use strict;
use DBI;

my $d = "stars100";
my $DB_HOST = "localhost";
my $u = "postgres";

my $sha;
my $name;
my $date;
my $project;

my $dbh = DBI->connect("dbi:Pg:dbname=$d;host=$DB_HOST",$u,"")
          or die "$!\n Error :failed to connect to DB.\n";
my $sth_author = $dbh->prepare("INSERT INTO authors(sha, name, id, project) VALUES(?, ?, ?, ?)");
my $sth_diff = $dbh->prepare("INSERT INTO diffs(sha, old, new, diff, project) VALUES(?, ?, ?, ?, ?)");
#my $sth_date = $dbh->prepare("INSERT INTO date(sha, date, project) VALUES(?, ?, ?)");
my $sth_bug = $dbh->prepare("INSERT INTO bug_sha(sha, project) VALUES(?, ?)");

chdir "../../git_log" or die $!;
chdir "./${ARGV[0]}" or die $!;

my $i = 1;

open(LOGFILE, "< ./sha_author.csv") or die "$!";
while(my $line = <LOGFILE> ){
	chomp($line);
    ($sha,$name,$project) = split(/\t/,$line);
    $sth_author->execute($sha, $name, $i, $project);
    $i++;
}
$sth_author->finish;
close(LOGFILE);

open(LOGFILE, "< ./sha_diff.csv") or die "$!";
while(my $line = <LOGFILE> ){
	chomp($line);
    ($sha,my $old,my $new,my $diff,$project) = split(/\t/,$line);

    $sth_diff->execute($sha,$old,$new,$diff,$project);
}
$sth_diff->finish;
close(LOGFILE);

=pud
open(LOGFILE, "< ./sha_date.csv") or die "$!";
while(my $line = <LOGFILE> ){
	chomp($line);
    ($sha,$date,$project) = split(/\t/,$line);
    $sth_date->execute($sha,$date,$project);
}
$sth_date->finish;
close(LOGFILE);
=cut

open(LOGFILE, "< ./sha_bug.csv") or die "$!";
while(my $line = <LOGFILE> ){
	chomp($line);
    ($sha,$project) = split(/\t/,$line);
    $sth_bug->execute($sha,$project);
}
$sth_bug->finish;
close(LOGFILE);



$dbh->disconnect;