use strict;
use Switch;
use DBI;

my $d = "test";
my $DB_HOST = "localhost";
my $u = "postgres";



my $dbn = DBI->connect("dbi:Pg:dbname=$d;host=$DB_HOST",$u,"")
          or die "$!\n Error :failed to connect to DB.\n";

my $sth_count = $dbn->prepare("select max(id), project FROM test group by project");
my $sth_select = $dbn->prepare("select tmp.filename, modify, tmp.project from list natural inner join (select filename, count(*) as modify, bug.project from bug inner join test on bug.sha = test.sha where id < ? and bug.project = ? group by filename, bug.project) tmp order by filename");
my $sth_insert = $dbn->prepare("INSERT INTO bug_modify(filename, modify, project) VALUES(?, ?, ?)");

my $period = 0.30;

$sth_count->execute;
while (my @pre = $sth_count->fetchrow_array) {
    my $id;
    my $project;
    
    ($id,$project) = @pre;
    $id = int($id * $period);
    
    $sth_select->execute($id,$project);
    while (my @data = $sth_select->fetchrow_array) {
        my $filename;
        my $count;
       
        ($filename,$count,$project) = @data;
        if($count eq ''){
            $count = 0;
        }
        #print $filename,"\t",$count,"\t",$project,"\n";
        $sth_insert->execute($filename,$count,$project);
    }
}

$sth_count->finish;
$sth_select->finish;
$sth_insert->finish;

$dbn->disconnect;