use strict;
use Switch;
use DBI;

my $d = "stars100";
my $DB_HOST = "localhost";
my $u = "postgres";

my $filename;
my $author;
my $project;

my $dbn = DBI->connect("dbi:Pg:dbname=$d;host=$DB_HOST",$u,"")
          or die "$!\n Error :failed to connect to DB.\n";

my $sth_count = $dbn->prepare("select max(id) FROM authors WHERE project = ?");
my $sth_select = $dbn->prepare("select new, count(distinct name), project FROM authors NATURAL FULL OUTER JOIN diffs WHERE id > ? and project = ? GROUP BY diffs.new, project ORDER BY new");
my $sth_insert = $dbn->prepare("INSERT INTO view1(filename, author_count, project) VALUES(?, ?, ?)");

$sth_count->execute(${ARGV[0]});


my $i = 1;
my $n;
while (my @data = $sth_count->fetchrow_array) {
    while ( (my $d = shift(@data)) ){
        $n = int($d / 3);
    }
}

$sth_select->execute($n, ${ARGV[0]});
while (my @data = $sth_select->fetchrow_array) {
    while ( (my $d = shift(@data)) ){
        switch($i){
            case 1 {
                $filename = $d;
            }
            case 2 {
                $author = $d;
            }
            case 3 {
                $project = $d;
            }
        }
        $i++;
    }
    $i = 1;
    $sth_insert->execute($filename, $author, $project);
}

$sth_select->finish;
$sth_insert->finish;

$dbn->disconnect;