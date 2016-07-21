use strict;
use Switch;
use DBI;

my $d = "stars100";
my $DB_HOST = "localhost";
my $u = "postgres";

my $filename;
my $name;
my $project;
my $contribution;

my $sth = DBI->connect("dbi:Pg:dbname=$d;host=$DB_HOST",$u,"")
          or die "$!\n Error :failed to connect to DB.\n";

my $sth_select = $sth->prepare("select filename, name, sum(contribution), project from number_of_author group by filename, name, project");
my $sth_insert = $sth->prepare("INSERT INTO view2(filename, name, contribution, project) VALUES(?, ?, ?, ?)");

my $i = 1;

$sth_select->execute;

while (my @data = $sth_select->fetchrow_array) {
    while ( ($d = shift(@data)) ){
        switch($i){
          case 1 {
              $filename = $d;
          }
          case 2 {
              $name = $d;
          }
          case 3 {
              $contribution = $d;
          }
          case 4 {
              $project = $d;
          }
        }
      $i++;
    }
  $i = 1;
  
  $sth_insert->execute($filename,$name,$contribution,$project);
 }

$sth_select->finish;
$sth_insert->finish;


$sth->disconnect;