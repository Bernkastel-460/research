use Class::Struct;
use Switch;
struct Author => {
    name  => '$',
    email => '$',
};

#Store data#
chdir "../../git_log" or die $!;
chdir "./${ARGV[0]}" or die $!;
open(LOGFILE, "< ./git_log_-p.log") or die "$!";
#@data = `git log -p -5`;

#main
$count = 0;
$Merge_Flag = 1;
$Diff_Flag = 1;
$i = 0;
$flag = 0;
@authors= ();
@Diff = ();
@block = ();

open(OUT, "> ./sha_diff.csv") or die "$!";

while( $line = <LOGFILE>){
#while( ($line = shift(@data)) ){
	chomp($line);
	if($line =~ m|^commit|){
		if($Merge_Flag == 0){
            &prepare;
            &output;
		}
		$sha = $line;
		substr($sha,0,7) = "";
		$Diff_Flag  = 0;
		$Merge_Flag = 0;
	}
	if($line =~ m|^Merge:|){
		$Merge_Flag = 1;
	}
    if($line =~ m|/dev/null|){
        if($line =~ m|^\+\+\+|){
            $New_Filename = $Old_Filename;
        }
        if($line =~ m|^\-\-\-|){
            if($Diff_Flag == 1){
                &prepare;
                &output;
                $Diff_Flag = 0;
            }
		$Old_Filename = "/dev/null";
		}
    }
	if($line =~ m|^\-\-\-\sa|){
        if($Diff_Flag == 1){
                &prepare;
                &output;
                $Diff_Flag = 0;
        }
		$Old_Filename = $line;
		substr($Old_Filename,0,6) = "";
	}
	if( ($line =~ m|^\+\+\+\sb|) || ($line =~ m|^\+\+\+\s"b|) ){
		$New_Filename = $line;
		substr($New_Filename,0,6) = "";
   	}
    if($Diff_Flag == 1){
		push(@Diff, substr($line, 0, 1));
		if($line =~ m|^\-|){
			$tmp = $old + $count + $Old_Count;
			push(@Old_Diff,$tmp);
			$Old_Count++;
		}elsif($line =~ m|^\+|){
			$tmp = $new + $count + $New_Count;
			push(@New_Diff,$tmp);
			$New_Count++;
		}else{
		$count++;
		}
	}
	if($line =~ m|^@@|){
        if($Diff_Flag == 1){
            &prepare;
        }
		$count = 0;
		($trash,$changes,$aa) = split(/@@/,$line);
		substr($changes,0,1) = "";
		($old ,$new) = split(/\s/,$changes);
		substr($old,0,1) = "";
		substr($new,0,1) = "";
		($old,$trash) = split(/,/,$old);
		($new,$trash) = split(/,/,$new);
		$Diff_Flag = 1;
		$Old_Count = 0;
		$New_Count = 0;
	}
    
}

if($Merge_Flag == 0){
    &output;
}

sub output {
    $Old_Filename =~ s/\t+//g;
    $New_Filename =~ s/\t+//g;
    print OUT $sha,"\t",$Old_Filename,"\t",$New_Filename,"\t";
    print OUT $num_b;
    for($i = 0; $i < $num_b ; $i++){
        print OUT "_",shift(@state),"_",shift(@old_min),"_",shift(@old_max),"_",shift(@new_min),"_",shift(@new_max);
    }
    print OUT "\t";
    print OUT ${ARGV[0]},"\n";
    $num_b = 0;
    @Old_Diff = ();
    @New_Diff = ();
    @old_max = ();
    @old_min = ();
    @new_max = ();
    @new_min = ();
    @state = ();
}

sub prepare{
    $b_flag = 0;
    for ( $i = 0; $i <= $#Diff; $i++ ){
        if(($Diff[$i-1] ne "-" && $Diff[$i-1] ne "+" ) && ($Diff[$i] eq "-" || $Diff[$i] eq "+")){
            $num_b++;
            $b_flag = 1;
        }
        if($Diff[$i] ne "-" && $Diff[$i] ne "+"){
            $b_flag = 0;
        }
        if($b_flag == 1){
            push(@block, $num_b);
            if($Diff[$i] eq "-"){
                push(@d, shift(@Old_Diff));
            }
            if($Diff[$i] eq "+"){
                push(@d, shift(@New_Diff));
            }
        }else{
            push(@block, 0);
            push(@d, " ");
        }
    }
    push(@block, 0);
    push(@d, " ");
    push(@Diff, " ");
    for ( $i = 0; $i <= $#Diff; $i++ ){
        $b_flag = 0;
        if($Diff[$i-1] ne "-" && $Diff[$i] eq "-"){
            push(@old_min, $d[$i]);
        }
        if($Diff[$i-1] ne "+" && $Diff[$i] eq "+"){
            push(@new_min, $d[$i]);
        }
        if($Diff[$i] eq "-" && $Diff[$i+1] ne "-"){
            push(@old_max, $d[$i]);
        }
        if($Diff[$i] eq "+" && $Diff[$i+1] ne "+"){
            push(@new_max, $d[$i]);
        }
        if($block[$i-1] != 0 && $block[$i] == 0){
            if(@old_min != $block[$i-1]){
                push(@old_min, 0);
                push(@old_max, 0);
                $b_flag = 1;
            }
            if(@new_min != $block[$i-1]){
                push(@new_min, 0);
                push(@new_max, 0);
                $b_flag = 2;
            }
            switch($b_flag){
                case 0 {
                    push(@state, "M")
                }
                case 1 {
                    push(@state, "A")
                }
                case 2 {
                    push(@state, "D")
                }
            }
        }
    }
    @d = ();
    @block = ();
    @Diff = ();
}

close(OUT);
close(LOGFILE);