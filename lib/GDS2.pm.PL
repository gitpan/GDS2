#!/lsi/soft/CFR/bin/perl -w
use strict;
use warnings;
$|++;
print << "EOP";
========================================================
By default this GDS2 module will try to compile and use
C code so as to speed up gds2 reading. This code is new
and relatively untested.
========================================================

EOP

print "Do you want to use Inline::C code? (Y/n): ";

my $response = <STDIN>;
if ($response =~ m/^[nN]/)
{
    $response = 'no';
    print "\nMaking version of GDS2.pm with C code off....";
}
else
{
    $response = 'yes';
    print "\nMaking version of GDS2.pm with C code on....";
}

rename "lib/GDS2.pm","lib/GDS2.pm.original";
open(OLD,"<lib/GDS2.pm.original") or die "Unable to read lib/GDS2.pm.original $!";
open(NEW,">lib/GDS2.pm") or die "Unable to create lib/GDS2.pm $!";
while (<OLD>)
{
    if ($response eq 'yes')
    {
        s/FALSE/TRUE/ if (m/^\s+use constant USE_C /);
        s/^#+// if (m/#INLINEC/);
    }
    if ($response eq 'no')
    {
        s/TRUE/FALSE/ if (m/^\s+use constant USE_C /);
        s/^/#/ if (m/#INLINEC/ && (! m/^#/));
    }
    print NEW;
}
close OLD;
close NEW;
unlink "lib/GDS2.pm.original";
print "Done.\n";

