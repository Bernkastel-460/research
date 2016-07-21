use DBI;
use Switch;

my $d = "test";
my $DB_HOST = "localhost";
my $u = "postgres";


my $dbh = DBI->connect("dbi:Pg:dbname=$d;host=$DB_HOST",$u,"")
          or die "$!\n Error :failed to connect to DB.\n";
my $sth_count = $dbh->prepare("select max(id), project FROM test group by project");
my $sth_list = $dbh->prepare("SELECT filename from Entropy where project = ? and entropy > 0 and entropy <= 0.1 order by entropy");
my $sth_Con = $dbh->prepare("SELECT sum(add + delete) from test where filename = ? and id >= ? and project = ? group by filename, name, project");
my $sth_SUMcon = $dbh->prepare("SELECT sum(add + delete) from test where filename = ? and id >= ? and project = ? group by filename, project");
my $sth_insert = $dbh->prepare("INSERT INTO PreEntropy(filename, pre_entropy, project, period) VALUES(?, ?, ?, ?)");

my $period = 0.65;

$sth_count->execute;
while (my @preid = $sth_count->fetchrow_array) {
    ($maxid,$project) = @preid;
    for($period = 0.35; $period <= 0.65 ; $period += 0.10){
        $p = 1 - $period;
        $id = int($maxid * $p);

        $sth_list->execute($project);
        while(my @pre = $sth_list->fetchrow_array ){
            my @data;
            my $filename;
            my $Con;
            my $SUMcon;
            my $H = 0;
            my $n = 0;
            my $flag = 0;
            
            $filename = shift(@pre);
            
            $sth_SUMcon->execute($filename, $id, $project);
            @data = $sth_SUMcon->fetchrow_array;
            $SUMcon = shift(@data);
            
            $sth_Con->execute($filename, $id, $project);
            while(my @data = $sth_Con->fetchrow_array ){
                my $p;
                my $lp;
                $flag = 1;
                    
                $Con = shift(@data);
                $p = $Con / $SUMcon;
                $lp = log($p) / log(2);
                $H += $p * $lp;
                $n++;

            }
            if($flag == 1){
                $H *= -1;
                if($n != 1){
                    $ln = log($n) / log(2);
                    $H = $H / $ln;
                }
                #print $filename,"\t",$H,"\t",$project,"\t",$p,"\n";
                $sth_insert->execute($filename, $H, $project, $period);
            }else{
                $H = -1;
                $sth_insert->execute($filename, $H, $project, $period);
            }

        }
        print "complete $project $period $id\n";
    }
}

$sth_count->finish;
$sth_list->finish;
$sth_Con->finish;
$sth_SUMcon->finish;
$sth_insert->finish;

$dbh->disconnect;