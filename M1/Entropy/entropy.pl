use DBI;
use Switch;

my $d = "test";
my $DB_HOST = "localhost";
my $u = "postgres";


my $dbh = DBI->connect("dbi:Pg:dbname=$d;host=$DB_HOST",$u,"")
          or die "$!\n Error :failed to connect to DB.\n";
my $sth_count = $dbh->prepare("select max(id), project FROM test group by project");
#my $sth_count = $dbh->prepare("select max(id), project FROM test where project = 'elasticsearch' group by project");
my $sth_list = $dbh->prepare("SELECT filename from list where project = ? group by filename, project order by filename");
#my $sth_list = $dbh->prepare("SELECT filename from entropy where project = 'elasticsearch' and entropy = 1.0 order by filename");
my $sth_Con = $dbh->prepare("SELECT sum(add + delete) from test where filename = ? and id >= ? and project = ? group by filename, name, project");
my $sth_SUMcon = $dbh->prepare("SELECT sum(add + delete) from test where filename = ? and id >= ? and project = ? group by filename, project");
my $sth_insert = $dbh->prepare("INSERT INTO Entropy(filename, entropy, project) VALUES(?, ?, ?)");

my $period = 0.30;

$sth_count->execute;
while (my @preid = $sth_count->fetchrow_array) {
    ($id,$project) = @preid;
    $id = int($id * $period);
    
    print $id,"\t",$project,"\n";
    $sth_list->execute($project);
    while(my @pre = $sth_list->fetchrow_array ){
        my @data;
        my $filename;
        my $Con;
        my $SUMcon;
        my $H = 0;
        my $n = 0;
        
        $filename = shift(@pre);
        
        $sth_SUMcon->execute($filename, $id, $project);
        @data = $sth_SUMcon->fetchrow_array;     
        $SUMcon = shift(@data);
              
        $sth_Con->execute($filename, $id, $project);
        while(my @data = $sth_Con->fetchrow_array ){
            my $p;
            my $lp;
            
            $Con = shift(@data);
            $p = $Con / $SUMcon;
            $lp = log($p) / log(2);
            $H += $p * $lp;
            $n++;
            #print "$filename\t$p\t$lp\t$Con\t$SUMcon\n";
        }
        #print "$H\n";
        $H *= -1;
        if($n != 1){
            $ln = log($n) / log(2);
            $H = $H / $ln;
        }
        if($H > 0 && $H < 0.1){
            print $filename,"\t",$H,"\t",$project,"\n";
        }
        $sth_insert->execute($filename, $H, $project);
    }
    print "complete $project\n";
}

$sth_count->finish;
$sth_list->finish;
$sth_Con->finish;
$sth_SUMcon->finish;
$sth_insert->finish;

$dbh->disconnect;