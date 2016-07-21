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

my $sth_select = $sth->prepare("select view2_max.filename, CAST (view2_max.contribution as float) / view2_sum.contribution, view2_max.project from view2_sum,view2_max where view2_max.filename = view2_sum.filename and view2_max.project = view2_sum.project");
my $sth_insert = $sth->prepare("INSERT INTO view2_per_ND(filename, contribution, project) VALUES(?, ?, ?)");

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


$sth->disconnect;