BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 3\n" unless $loaded;}
use GDS2;
sub ok 
{
    my ($n, $result, @info) = @_;
    if ($result) {
        print "ok $n\n";
    }
    else {
        print "not ok $n\n";
        print "# @info\n" if @info;
    }
}

$loaded = 1;
print "ok 1\n";

open(DUMPIN,"TEST.dump") or die "Unable to read TEST.dump because $!";
my $gds2FileOut = new GDS2(-fileName => ">testdump.gds");
my $dataString;
while (<DUMPIN>)
{
    my $line=$_;
    $line=~s|^\s+||; ## make following comparisions easier...
    next if (m|^#|); ## see # as here-to-line-end comment
    chomp $line;
    $line=~s|#.*||;
    $line=~s|$| |g;  ## for match below
    $dataString='';
    if ($line =~ m|^([a-z]+) (.*)|i)
    {
        my $type=$1;
        $dataString=$2 if (defined $2);
        $gds2FileOut -> printGds2Record(-type=>$type,-asciiData=>$dataString)
    }
    else
    {
        print "WARNING: Unable to parse '$line'\n";
    }
}
$gds2FileOut -> close;
close DUMPIN;

my $gds2File = new GDS2(-fileName => 'testdump.gds');
open(DUMPOUT,">dump.out") or die "Unable to create dump.out $!";
while ($gds2File -> readGds2Record) 
{
    print DUMPOUT $gds2File -> returnRecordAsString."\n";
}
close DUMPOUT;

my $good=1;
open(DUMPOUT,"dump.out") or die "Unable to read dump.out $!";
open(DUMPIN,"TEST.dump") or die "Unable to read TEST.dump because $!";
while (<DUMPIN>)
{
    chomp;
    my $line1=$_;
    my $line2 = <DUMPOUT>;
    chomp $line2;
    $good = 0 if ($line1 ne $line2);
}
close DUMPIN;
close DUMPOUT;
ok 2,$good==1,'problem with ascii dump.';

