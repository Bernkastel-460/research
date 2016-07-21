use DBI;
use Switch;

my $d = "test";
my $DB_HOST = "localhost";
my $u = "postgres";


my $dbh = DBI->connect("dbi:Pg:dbname=$d;host=$DB_HOST",$u,"")
          or die "$!\n Error :failed to connect to DB.\n";
my $sth_count = $dbh->prepare("select max(id), project FROM test group by project");
my $sth_list = $dbh->prepare("SELECT filename from Entropy where project = ? and entropy > 0 and entropy <= 0.1 order by entropy");
my $sth_select = $dbh->prepare("SELECT pre_entropy, period from preEntropy where filename = ? and project = ? order by period");
my $sth_entropy = $dbh->prepare("SELECT entropy, modify from entropy natural left outer join bug_modify where filename = ? and project = ?");
#my $sth_insert = $dbh->prepare("INSERT INTO PreEntropy(filename, pre_entropy, project, period) VALUES(?, ?, ?, ?)");

$MICount = 0;
$MDCount = 0;
$OverCount = 0;
$NCCount = 0;
$OtherCount = 0;
$MIMCount = 0;
$MDMCount = 0;
$OverMCount = 0;
$NCMCount = 0;
$OtherMCount = 0;
$FileCount = 0;

$sth_count->execute;
while (my @preid = $sth_count->fetchrow_array) {
    ($id,$project) = @preid;
    $sth_list->execute($project);
    while(my @pre = $sth_list->fetchrow_array ){
        my @Data;
        my @PreEntropy  = ();
        my $filename;
        my $H;
        $filename = shift(@pre);
        
        $sth_select->execute($filename, $project);
        while(@Data = $sth_select->fetchrow_array ){
            my $Entropy;
            ($H,$period) = @Data;

            @PreEntropy = (@PreEntropy, $H);
        }
       
        $sth_entropy->execute($filename, $project);
        @Data = $sth_entropy->fetchrow_array;
        ($H, $modify) = @Data;
        @PreEntropy = (@PreEntropy, $H);
        
        &Distinguish(@PreEntropy,$modify);
       
        $FileCount++;
    }
    print "complete $project $p \n";
}

print "Monotonic increse \t",$MIMCount,"/",$MICount,"(",$MIMCount/$MICount,")\n";
print "Monotonic decrese \t ",$MDMCount,"/",$MDCount,"  (",$MDMCount/$MDCount,")\n";
print "NoChange \t\t ",$NCMCount,"/",$NCCount,"  (",$NCMCount/$NCCount,")\n";
#print "Over \t\t\t ",$OverMCount,"/",$OverCount,"  (",$OverMCount/$OverCount,")\n";
print "Other \t\t\t ",$OtherMCount,"/",$OtherCount,"(",$OtherMCount/$OtherCount,")\n";
print "FileCount $FileCount \n";
close(OUT);

$sth_count->finish;
$sth_list->finish;
$sth_select->finish;
$sth_entropy->finish;
#$sth_insert->finish;

$dbh->disconnect;

sub Distinguish {
    my @data = @_;
    my $MonoIncFlag = 1;
    my $MonoDecFlag = 1;
    my $NoChangeFlag = 1;
    my $OverFlag = 0;
      for(my $i = 0; $i < $#data -1 ; $i++){
        if($data[$i] > $data[$i + 1]){
            $MonoIncFlag = 0;
        }
        if($data[$i] < $data[$i + 1]){
            $MonoDecFlag = 0;
        }
        if($data[$i] != $data[$i + 1]){
            $NoChangeFlag = 0;
        }
        if($data[$i] > 0.1){
            $OverFlag = 1;
        }
    }
            
    if($MonoIncFlag == 1 && $NoChangeFlag == 0){
        if($data[5] > 0){
            $MIMCount++;
        }
        $MICount++;       
    }
    if($MonoDecFlag == 1 && $NoChangeFlag == 0){
        if($data[5] > 0){
            $MDMCount++;
        }
        print join("\t",@data),"\n";
        $MDCount++;
    }
=pud
    if($OverFlag == 1 && $MonoDecFlag == 0){
        if($data[5] > 0){
            $OverMCount++;
        }
        $OverCount++;
    }
=cut
    if($NoChangeFlag == 1){
        if($data[5] > 0){
            $NCMCount++;
        }
        $NCCount++;
    }
    if($MonoIncFlag == 0 && $MonoDecFlag == 0 && $NoChangeFlag == 0){
        if($data[5] > 0){
            $OtherMCount++;
        }
        $OtherCount++;
    }

}