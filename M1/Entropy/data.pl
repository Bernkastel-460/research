use strict;
use Switch;
use DBI;

my $d = "test";
my $DB_HOST = "localhost";
my $u = "postgres";

my $dbn = DBI->connect("dbi:Pg:dbname=$d;host=$DB_HOST",$u,"")
          or die "$!\n Error :failed to connect to DB.\n";

my $sth_select = $dbn->prepare("select distinct filename FROM list");

my $java = 0;
my $js = 0;
my $h = 0;
my $c = 0;
my $groovy = 0;
my $py = 0;
my $pl = 0;
my $rb = 0;

$sth_select->execute;
while (my @data = $sth_select->fetchrow_array) {
    my $filename;
    my $author;
    my $project;   
    my $contribution;
    $filename = shift(@data);

    if($filename =~ /\.js$/){
        $js++;
    }elsif($filename =~ /\.java$/){
        $java++;
    }elsif($filename =~ /\.h$/){
        $h++;
    }elsif($filename =~ /\.c$/){
        $c++;
    }elsif($filename =~ /\.groovy$/){
        $groovy++;
    }elsif($filename =~ /\.py$/){
        $py++;
    }elsif($filename =~ /\.pl$/){
        $pl++;
    }elsif($filename =~ /\.rb$/){
        $rb++;
    }else{
        print $filename,"\n";
    }
}

print "js $js\n";
print "java $java\n";
print "h $h\n";
print "c $c\n";
print "groovy $groovy\n";
print "py $py\n";
print "pl $pl\n";
print "rb $rb\n";

$sth_select->finish;

$dbn->disconnect;