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

my $sth_select = $sth->prepare("select filename, sum(contribution), project from view2 group by filename, project");
my $sth_insert = $sth->prepare("INSERT INTO view2_sum(filename, contribution, project) VALUES(?, ?, ?)");
my $sth_select2 = $sth->prepare("select filename, max(contribution), project from view2 group by filename, project");
my $sth_insert2 = $sth->prepare("INSERT INTO view2_max(filename, contribution, project) VALUES(?, ?, ?)");

my $i = 1;

$sth_select->execute;

while (my @data = $sth_select->fetchrow_array) {
    while ( ($d = shift(@data)) ){
        switch($i){
          case 1 {
              $filename = $d;
          }
          case 2 {
              $contribution = $d;
          }
          case 3 {
              $project = $d;
          }
        }
      $i++;
    }
  $i = 1;
  
  $sth_insert->execute($filename,$contribution,$project);
 }
$sth_select->finish;
$sth_insert->finish;

$sth_select2->execute;

while (my @data = $sth_select2->fetchrow_array) {
    while ( ($d = shift(@data)) ){
        switch($i){
          case 1 {
              $filename = $d;
          }
          case 2 {
              $contribution = $d;
          }
          case 3 {
              $project = $d;
          }
        }
      $i++;
    }
  $i = 1;
  
  $sth_insert2->execute($filename,$contribution,$project);
 }
$sth_select2->finish;
$sth_insert2->finish;


$sth->disconnect;