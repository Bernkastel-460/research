use DBI;
use Switch;

my $d = "test";
my $DB_HOST = "localhost";
my $u = "postgres";


my $dbh = DBI->connect("dbi:Pg:dbname=$d;host=$DB_HOST",$u,"")
          or die "$!\n Error :failed to connect to DB.\n";

my $sth_count = $dbh->prepare("select max(id), project FROM test group by project");
my $sth_insert_E = $dbh->prepare("INSERT INTO exist(filename,project) VALUES(?, ?)");
my $sth_insert_D = $dbh->prepare("INSERT INTO pre_list(filename,project) VALUES(?, ?)");
my $sth_insert_R = $dbh->prepare("INSERT INTO list(filename,project) VALUES(?, ?)");
my $sth_exist = $dbh->prepare("select filename, project from (SELECT filename, sum(add) as sumadd, sum(delete) as sumdelete, project from test group by filename, project order by filename) tmp where sumadd <> sumdelete");
my $sth_list = $dbh->prepare("SELECT filename, project from test where id >= ? and project = ? group by filename, project");
my $sth_result = $dbh->prepare("SELECT filename, project from exist natural inner join pre_list order by filename");


my $period = 0.30;
my $id;

$sth_exist->execute;
while (my @exist = $sth_exist->fetchrow_array) {
    ($filename,$project) = @exist;
    $sth_insert_E->execute($filename,$project);
}

$sth_count->execute;
while (my @pre = $sth_count->fetchrow_array) {
    ($id,$project) = @pre;
    $id = int($id * $period);
    
    $sth_list->execute($id,$project);
    while( my @data = $sth_list->fetchrow_array ){
        ($filename,$project) = @data;
        $sth_insert_D->execute($filename,$project);
    }
}


$sth_result->execute;
while( (my @result = $sth_result->fetchrow_array) ){
    ($filename,$project) = @result;
    $sth_insert_R->execute($filename,$project);
}

$sth_count->finish;
$sth_insert_E->finish;
$sth_insert_D->finish;
$sth_insert_R->finish;
$sth_exist->finish;
$sth_list->finish;
$sth_result->finish;

$dbh->disconnect;