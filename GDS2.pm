package GDS2; 
{
require 5.004;
$GDS2::VERSION = '1.0'; 
## Note: '@ ( # )' used by the what command  E.g. what GDS2.pm
$GDS2::revision = '@(#) $RCSfile: GDS2.pm,v $ $Revision: 1.44 $ $Date: 2001-10-05 00:58:39-05 $';
use strict;
#use warnings; ## I think you need 5.6 to use this 
no strict qw( refs );

my $haveFlock=1; ## some systems still may not have this...manually change

my $OS='';
if (! defined $^O) 
{
    require Config;
    $OS = $Config::Config{'osname'} if ($Config::Config{'osname'} ne ''); ## silly way not to get -w warning...
}
else
{
    $OS = $^O;
}
my $isLittleEndian = 0;
$isLittleEndian = 1 if (($OS=~/win/i) || ($OS=~/vms/i)); ## mswin32 cygwin vms

if ($haveFlock)
{
use Fcntl q(:flock);  # import LOCK_* constants
}
use IO::File;

# POD documentation is sprinkled throughout the file in an 
# attempt at Literate Programming style (which Perl only party supports ...
# see http://www.literateprogramming.com/ )
# Search for the strings '=head' or run perldoc on this file.

# You can run this file through either pod2man or pod2html to produce 
# documentation in manual or html file format 

# Author: Ken Schumack (c) 1999,2000,2001.  All rights reserved.
# source code may be used and modified freely, but this copyright notice
# must remain attached to the file.  You may modify this module as you 
# wish, but if you create a modified version, please attach a note
# listing the modifications you have made, and send a copy to me at 
# KenSchumack@mediaone.net or Schumack@lsil.com
# 

################################################################################
## GDS2 STREAM RECORD DATATYPES
my $NO_DATA      = 0;
my $BIT_ARRAY    = 1;
my $INTEGER_2    = 2;
my $INTEGER_4    = 3;
my $REAL_4       = 4; ## NOT supported
my $REAL_8       = 5;
my $ACSII_STRING = 6;
################################################################################

################################################################################
## GDS2 STREAM RECORD TYPES 
use vars '$HEADER';
use vars '$BGNLIB';
use vars '$LIBNAME';
use vars '$UNITS';
use vars '$ENDLIB';
use vars '$BGNSTR';
use vars '$STRNAME';
use vars '$ENDSTR';
use vars '$BOUNDARY';
use vars '$PATH';
use vars '$SREF';
use vars '$AREF';
use vars '$TEXT';
use vars '$LAYER';
use vars '$DATATYPE';
use vars '$WIDTH';
use vars '$XY';
use vars '$ENDEL';
use vars '$SNAME';
use vars '$COLROW';
use vars '$TEXTNODE';
use vars '$NODE';
use vars '$TEXTTYPE';
use vars '$PRESENTATION';
use vars '$SPACING';
use vars '$STRING';
use vars '$STRANS';
use vars '$MAG';
use vars '$ANGLE';
use vars '$UINTEGER';
use vars '$USTRING';
use vars '$REFLIBS';
use vars '$FONTS';
use vars '$PATHTYPE';
use vars '$GENERATIONS';
use vars '$ATTRTABLE';
use vars '$STYPTABLE';
use vars '$STRTYPE';
use vars '$EFLAGS';
use vars '$ELKEY';
use vars '$LINKTYPE';
use vars '$LINKKEYS';
use vars '$NODETYPE';
use vars '$PROPATTR';
use vars '$PROPVALUE';
use vars '$BOX';
use vars '$BOXTYPE';
use vars '$PLEX';
use vars '$BGNEXTN';
use vars '$ENDEXTN';
use vars '$TAPENUM';
use vars '$TAPECODE';
use vars '$STRCLASS';
use vars '$RESERVED';
use vars '$FORMAT';
use vars '$MASK';
use vars '$ENDMASKS';
use vars '$LIBDIRSIZE';
use vars '$SRFNAME';
use vars '$LIBSECUR';

$HEADER        =  0;   ## 2-byte Signed Integer
$BGNLIB        =  1;   ## 2-byte Signed Integer
$LIBNAME       =  2;   ## ASCII String
$UNITS         =  3;   ## 8-byte Real
$ENDLIB        =  4;   ## no data present
$BGNSTR        =  5;   ## 2-byte Signed Integer
$STRNAME       =  6;   ## ASCII String
$ENDSTR        =  7;   ## no data present
$BOUNDARY      =  8;   ## no data present
$PATH          =  9;   ## no data present
$SREF          = 10;   ## no data present
$AREF          = 11;   ## no data present
$TEXT          = 12;   ## no data present
$LAYER         = 13;   ## 2-byte Signed Integer
$DATATYPE      = 14;   ## 2-byte Signed Integer
$WIDTH         = 15;   ## 4-byte Signed Integer
$XY            = 16;   ## 2-byte Signed Integer
$ENDEL         = 17;   ## no data present
$SNAME         = 18;   ## ASCII String
$COLROW        = 19;   ## 2 2-byte Signed Integer
$TEXTNODE      = 20;   ## no data present
$NODE          = 21;   ## no data present
$TEXTTYPE      = 22;   ## 2-byte Signed Integer
$PRESENTATION  = 23;   ## Bit Array
$SPACING       = 24;   ## discontinued
$STRING        = 25;   ## ASCII String
$STRANS        = 26;   ## Bit Array
$MAG           = 27;   ## 8-byte Real
$ANGLE         = 28;   ## 8-byte Real
$UINTEGER      = 29;   ## UNKNOWN User int, used only in Calma V2.0
$USTRING       = 30;   ## UNKNOWN User string, used only in Calma V2.0
$REFLIBS       = 31;   ## ASCII String
$FONTS         = 32;   ## ASCII String
$PATHTYPE      = 33;   ## 2-byte Signed Integer
$GENERATIONS   = 34;   ## 2-byte Signed Integer
$ATTRTABLE     = 35;   ## ASCII String
$STYPTABLE     = 36;   ## ASCII String "Unreleased feature"
$STRTYPE       = 37;   ## 2-byte Signed Integer "Unreleased feature"
$EFLAGS        = 38;   ## BIT_ARRAY  Flags for template and exterior data.  bits 15 to 0, l to r 0=template, 
                       ##   1=external data, others unused
$ELKEY         = 39;   ## INTEGER_4  "Unreleased feature"
$LINKTYPE      = 40;   ## UNKNOWN    "Unreleased feature"
$LINKKEYS      = 41;   ## UNKNOWN    "Unreleased feature"
$NODETYPE      = 42;   ## INTEGER_2  Nodetype specification. On Calma this could be 0 to 63, GDSII allows 0 to 255. 
                       ##   Of course a 2 byte integer allows up to 65535...
$PROPATTR      = 43;   ## INTEGER_2  Property number.
$PROPVALUE     = 44;   ## STRING     Property value. On GDSII, 128 characters max, unless an SREF, AREF, or NODE, 
                       ##   which may have 512 characters.
$BOX           = 45;   ## NO_DATA    The beginning of a BOX element.
$BOXTYPE       = 46;   ## INTEGER_2  Boxtype specification.
$PLEX          = 47;   ## INTEGER_4  Plex number and plexhead flag. The least significant bit of the most significant 
                       ##    byte is the plexhead flag.
$BGNEXTN       = 48;   ## INTEGER_4  Path extension beginning for pathtype 4 in Calma CustomPlus. In database units, 
                       ##    may be negative.
$ENDEXTN       = 49;   ## INTEGER_4  Path extension end for pathtype 4 in Calma CustomPlus. In database units, may be negative.
$TAPENUM       = 50;   ## INTEGER_2  Tape number for multi-reel stream file.
$TAPECODE      = 51;   ## INTEGER_2  Tape code to verify that the reel is from the proper set. 12 bytes that are 
                       ##   supposed to form a unique tape code.
$STRCLASS      = 52;   ## BIT_ARRAY  Calma use only. 
$RESERVED      = 53;   ## INTEGER_4  Used to be NUMTYPES per Calma GDSII Stream Format Manual, v6.0.
$FORMAT        = 54;   ## INTEGER_2  Archive or Filtered flag.  0: Archive 1: filtered
$MASK          = 55;   ## STRING     Only in filtered streams. Layers and datatypes used for mask in a filtered 
                       ##   stream file. A string giving ranges of layers and datatypes separated by a semicolon. 
                       ##   There may be more than one mask in a stream file.
$ENDMASKS      = 56;   ## NO_DATA    The end of mask descriptions.
$LIBDIRSIZE    = 57;   ## INTEGER_2  Number of pages in library director, a GDSII thing, it seems to have only been 
                       ##   used when Calma INFORM was creating a new library.
$SRFNAME       = 58;   ## STRING     Calma "Sticks"(c) rule file name.
$LIBSECUR      = 59;   ## INTEGER_2  Access control list stuff for CalmaDOS, ancient. INFORM used this when creating 
                       ##   a new library. Had 1 to 32 entries with group numbers, user numbers and access rights.
#################################################################################################

my @RecordTypeStrings=(
'HEADER',
'BGNLIB',
'LIBNAME',
'UNITS',
'ENDLIB',
'BGNSTR',
'STRNAME',
'ENDSTR',
'BOUNDARY',
'PATH',
'SREF',
'AREF',
'TEXT',
'LAYER',
'DATATYPE',
'WIDTH',
'XY',
'ENDEL',
'SNAME',
'COLROW',
'TEXTNODE',
'NODE',
'TEXTTYPE',
'PRESENTATION',
'SPACING',
'STRING',
'STRANS',
'MAG',
'ANGLE',
'UINTEGER',
'USTRING',
'REFLIBS',
'FONTS',
'PATHTYPE',
'GENERATIONS',
'ATTRTABLE',
'STYPTABLE',
'STRTYPE',
'EFLAGS',
'ELKEY',
'LINKTYPE',
'LINKKEYS',
'NODETYPE',
'PROPATTR',
'PROPVALUE',
'BOX',
'BOXTYPE',
'PLEX',
'BGNEXTN',
'ENDEXTN',
'TAPENUM',
'TAPECODE',
'STRCLASS',
'RESERVED',
'FORMAT',
'MASK',
'ENDMASKS',
'LIBDIRSIZE',
'SRFNAME',
'LIBSECUR',
);

###################################################
my %RecordTypeData=(
'HEADER'       => $INTEGER_2,
'BGNLIB'       => $INTEGER_2,
'LIBNAME'      => $ACSII_STRING,
'UNITS'        => $REAL_8,
'ENDLIB'       => $NO_DATA,
'BGNSTR'       => $INTEGER_2,
'STRNAME'      => $ACSII_STRING,
'ENDSTR'       => $NO_DATA,
'BOUNDARY'     => $NO_DATA,
'PATH'         => $NO_DATA,
'SREF'         => $NO_DATA,
'AREF'         => $NO_DATA,
'TEXT'         => $NO_DATA,
'LAYER'        => $INTEGER_2,
'DATATYPE'     => $INTEGER_2,
'WIDTH'        => $INTEGER_4,
'XY'           => $INTEGER_4,
'ENDEL'        => $NO_DATA,
'SNAME'        => $ACSII_STRING,
'COLROW'       => $INTEGER_2,
'TEXTNODE'     => $NO_DATA,
'NODE'         => $NO_DATA,
'TEXTTYPE'     => $INTEGER_2,
'PRESENTATION' => $BIT_ARRAY,
'SPACING'      => -1, #$INTEGER_4, discontinued
'STRING'       => $ACSII_STRING,
'STRANS'       => $BIT_ARRAY,
'MAG'          => $REAL_8,
'ANGLE'        => $REAL_8,
'UINTEGER'     => -1, #$INTEGER_4, no longer used
'USTRING'      => -1, #$ACSII_STRING, no longer used
'REFLIBS'      => $ACSII_STRING,
'FONTS'        => $ACSII_STRING,
'PATHTYPE'     => $INTEGER_2,
'GENERATIONS'  => $INTEGER_2, #$INTEGER_2,
'ATTRTABLE'    => $ACSII_STRING, #$ACSII_STRING,
'STYPTABLE'    => $ACSII_STRING, #$ACSII_STRING, unreleased feature
'STRTYPE'      => $INTEGER_2, #$INTEGER_2, unreleased feature
'EFLAGS'       => $BIT_ARRAY, #$BIT_ARRAY,
'ELKEY'        => $INTEGER_4, #$INTEGER_4, unreleased feature
'LINKTYPE'     => $INTEGER_2, #unreleased feature
'LINKKEYS'     => $INTEGER_4, #unreleased feature
'NODETYPE'     => $INTEGER_2, 
'PROPATTR'     => $INTEGER_2,
'PROPVALUE'    => $ACSII_STRING,
'BOX'          => $NO_DATA, #$NO_DATA,
'BOXTYPE'      => $INTEGER_2, #$INTEGER_2,
'PLEX'         => $INTEGER_4, #$INTEGER_4,
'BGNEXTN'      => $INTEGER_4,
'ENDEXTN'      => $INTEGER_4,
'TAPENUM'      => $INTEGER_2,
'TAPECODE'     => $INTEGER_2,
'STRCLASS'     => -1,
'RESERVED'     => $INTEGER_4,
'FORMAT'       => $INTEGER_2,
'MASK'         => $ACSII_STRING,
'ENDMASKS'     => $NO_DATA, #$NO_DATA,
'LIBDIRSIZE'   => -1, #$INTEGER_2
'SRFNAME'      => $ACSII_STRING, #$ACSII_STRING,
'LIBSECUR'     => -1, #$INTEGER_2,
);

# This is the default class for the GDS2 object to use when all else fails.
$GDS2::DefaultClass = 'GDS2' unless defined $GDS2::DefaultClass;
my $StrSpace='';
my $ElmSpace='';
my $G_fudge=0.00001; ## to take care of floating point representation problems

=pod
=head1 NAME

GDS2 - GDS2 stream module


=head1 Description

This is GDS2, a module for quickly creating programs to read and/or write GDS2 files.

Send feedback/suggestions to
KenSchumack@mediaone.net or Schumack@lsil.com


=head1 Create Method

=cut

################################################################################

=head2 new - open gds2 file

  usage:
  my $gds2File  = new GDS2(-fileName => "filename.gds2"); ## to read 
  my $gds2File2 = new GDS2(-fileName => ">filename.gds2"); ## to write

=cut

sub new
{
    my($class,%arg) = @_;
    my $self = {};
    bless $self,$class || ref $class || $GDS2::DefaultClass;
    my $fileName = $arg{'-fileName'};
    if (! defined $fileName)
    {
        die "new expects a gds2 file name. Missing -fileName => 'name' $!";
    }
    my $resolution = $arg{'-resolution'};
    if (! defined $resolution)
    {
        $resolution=1000;
    }
    die "new expects a positive integer resolution. ($resolution) $!" if (($resolution <= 0)||($resolution =~ m|\.|));
    my $lockMode = LOCK_SH;   ## default
    my $openModStr = substr($fileName,0,2);  ### looking for > or >>
    $openModStr =~ s|^\s+||;
    $openModStr =~ s|[^\+>]+||g;
    my $openModeNum = O_RDONLY;
    if ($openModStr =~ m|^\+|)
    {
        warn("Ignoring '+' in open mode"); ## not handling this yet...
        $openModStr =~ s|\++||;
    }
    if ($openModStr eq '>')
    {
        $openModeNum = O_WRONLY|O_CREAT;
        $lockMode = LOCK_EX;
        $fileName =~ s|^$openModStr||;
    }
    elsif ($openModStr eq '>>')
    {
        $openModeNum = O_WRONLY|O_APPEND;
        $lockMode = LOCK_EX;
        $fileName =~ s|^$openModStr||;
    }
    my $fileHandle = new IO::File;
    $fileHandle -> open("$fileName",$openModeNum) or die "Unable to open $fileName because $!";
    if ($haveFlock)
    {
        flock($fileHandle,$lockMode) or die "File lock on $fileName failed because $!";
    }
    $self -> {'FileHandle'} = $fileHandle;
    $self -> {'FileName'}   = $fileName; ## the gds2 filename
    $self -> {'EOLIB'}      = 0;         ## end of library flag
    $self -> {'HEADER'}     = -1;        ## in header flag
    $self -> {'INDATA'}     = 0;         ## in data flag
    $self -> {'Length'}     = 0;         ## length of data
    $self -> {'DataType'}   = -1;        ## one of 7 gds datatypes
    $self -> {'UUnits'}     = 0;         ## for gds2 file
    $self -> {'DBUnits'}    = 0;         ## for gds2 file
    $self -> {'Record'}     = '';        ## the whole record as found in gds2 file
    $self -> {'RecordType'} = -1;
    $self -> {'DataIndex'}  = 0;
    $self -> {'RecordData'} = ('');
    $self -> {'CurrentDataList'} = '';
    $self -> {'InStr'}      = 0;         ##flag for write error checking
    $self -> {'InElm'}      = 0;         ##flag for write error checking
    $self -> {'Resolution'} = $resolution;
    $self;
}
################################################################################

=head2 close - close gds2 file

  usage:
  $gds2File -> close;

=cut

sub close
{
    my $self = shift;
    close $self -> {'FileHandle'};
}
################################################################################

################################################################################

=head1 High Level Write Methods

=cut

################################################################################

=head2 printInitLib() - Does all the things needed to start a library

   usage:
     $gds2File -> printInitLib(-name => "testlib"); ##writes HEADER,BGNLIB,LIBNAME,and UNITS records
     ## defaults to current date for library date and 1e-3 and 1e-9 for units

   note:
     remember to close library with printEndlib()

=cut

sub printInitLib
{
    my($self,%arg) = @_;
    my $libName = $arg{'-name'};
    if (! defined $libName)
    {
        die "printInitLib expects a library name. Missing -name => 'name' $!";
    }
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $mon++;
    $year += 1900;
    $self -> printGds2Record(-type => 'HEADER',-data => 3);
    $self -> printGds2Record(-type => 'BGNLIB',-data => [$year,$mon,$mday,$hour,$min,$sec,$year,$mon,$mday,$hour,$min,$sec]);
    $self -> printGds2Record(-type => 'LIBNAME',-data => $libName);
    $self -> printGds2Record(-type => 'UNITS',-data => [0.001,1e-9]);
}
################################################################################

=head2 printBgnstr - Does all the things needed to start a structure definition

   usage:
    $gds2File -> printBgnstr(-name => "nand3"); ## writes BGNSTR and STRNAME records

   note:
     remember to close with printEndstr()

=cut

sub printBgnstr
{
    my($self,%arg) = @_;
    my ($csec,$cmin,$chour,$cmday,$cmon,$cyear,$cwday,$cyday,$cisdst);
    my ($msec,$mmin,$mhour,$mmday,$mmon,$myear,$mwday,$myday,$misdst);

    my $strName = $arg{'-name'};
    if (! defined $strName)
    {
        die "bgnStr expects a structure name. Missing -name => 'name' $!";
    }
    my $createTime = $arg{'-createTime'};
    if (defined $createTime)
    {
        ($csec,$cmin,$chour,$cmday,$cmon,$cyear,$cwday,$cyday,$cisdst) = localtime($createTime);
    }
    else
    {
        ($csec,$cmin,$chour,$cmday,$cmon,$cyear,$cwday,$cyday,$cisdst) = localtime(time);
    }
    $cmon++;

    my $modTime = $arg{'-modTime'};
    if (defined $modTime)
    {
        ($msec,$mmin,$mhour,$mmday,$mmon,$myear,$mwday,$myday,$misdst) = localtime($modTime);
    }
    else
    {
        ($msec,$mmin,$mhour,$mmday,$mmon,$myear,$mwday,$myday,$misdst) = localtime(time);
    }
    $mmon++;

    $self -> printGds2Record(-type => 'BGNSTR',-data => [$cyear,$cmon,$cmday,$chour,$cmin,$csec,$myear,$mmon,$mmday,$mhour,$mmin,$msec]);
    $self -> printGds2Record(-type => 'STRNAME',-data => $strName);
}
################################################################################

=head2 printPath - prints a gds2 path

  usage: 
    $gds2File -> printPath(
                    -layer=>#,
                    -dataType=>#, ##optional
                    -pathType=>#,
                    -width=>#.#,
                    -xy=>\@array);

  note:
    layer defaults to 0 if -layer not used
    pathType defaults to 0 if -pathType not used
      pathType 0 = square end
               1 = round end
               2 = square - extended 1/2 width
    width defaults to 0.0 if -width not used

=cut

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#  <path>::= PATH [ELFLAGS] [PLEX] LAYER DATATYPE [PATHTYPE] [WIDTH] XY
sub printPath
{
    my($self,%arg) = @_;
    my $resolution = $self -> {'Resolution'};
    my $layer = $arg{'-layer'};
    if (! defined $layer)
    {
        $layer=0;
    }
    my $dataType = $arg{'-dataType'};
    if (! defined $dataType)
    {
        $dataType=0;
    }
    my $pathType = $arg{'-pathType'};
    if (! defined $pathType)
    {
        $pathType=0;
    }
    my $width = $arg{'-width'};
    if ((! defined $width)||($width <= 0))
    {
        $width=0;
    }
    my $xy = $arg{'-xy'}; ## $xy should be a reference to an array
    if (! defined $xy)
    {
        die "printPath expects an xy array reference. Missing -xy => \\\@array $!";
    }
    $self -> printGds2Record(-type => 'PATH');
    $self -> printGds2Record(-type => 'LAYER',-data => $layer);
    $self -> printGds2Record(-type => 'DATATYPE',-data => $dataType);
    $self -> printGds2Record(-type => 'PATHTYPE',-data => $pathType) if ($pathType);
    $self -> printGds2Record(-type => 'WIDTH',-data => $width) if ($width);
    my @xyTmp=(); ##don't pollute array passed in
    for(my $i=0;$i<=$#$xy;$i++) ## e.g. 3.4 in -> 3400 out
    {
        if ($xy -> [$i] >= 0) { push @xyTmp,int((($xy -> [$i])*$resolution)+$G_fudge);}
        else                  { push @xyTmp,int((($xy -> [$i])*$resolution)-$G_fudge);}
    }
    $self -> printGds2Record(-type => 'XY',-data => \@xyTmp);
    $self -> printGds2Record(-type => 'ENDEL');
}
################################################################################

=head2 printBoundary - prints a gds2 boundary

  usage: 
    $gds2File -> printBoundary(
                    -layer=>#,
                    -dataType=>#,
                    -xy=>\@array);

  note:
    layer defaults to 0 if -layer not used
    dataType defaults to 0 if -dataType not used

=cut

#  <boundary>::= BOUNDARY [ELFLAGS] [PLEX] LAYER DATATYPE XY
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
sub printBoundary
{
    my($self,%arg) = @_;
    my $resolution = $self -> {'Resolution'};
    my $layer = $arg{'-layer'};
    if (! defined $layer)
    {
        $layer=0;
    }
    my $dataType = $arg{'-dataType'};
    if (! defined $dataType)
    {
        $dataType=0;
    }
    my $xy = $arg{'-xy'}; ## $xy should be a reference to an array
    if (! defined $xy)
    {
        die "printBoundary expects an xy array reference. Missing -xy => \\\@array $!";
    }
    $self -> printGds2Record(-type => 'BOUNDARY');
    $self -> printGds2Record(-type => 'LAYER',-data => $layer);
    $self -> printGds2Record(-type => 'DATATYPE',-data => $dataType);
    if (my $numPoints=$#$xy+1 < 6)
    {
        die "printBoundary expects an xy array of at leasts 3 coordinates $!";
    }
    for(my $i=0;$i<=$#$xy;$i++) ## e.g. 3.4 in -> 3400 out
    {
        if ($xy -> [$i] >= 0) {$xy -> [$i] = int((($xy -> [$i])*$resolution)+$G_fudge);}
        else                  {$xy -> [$i] = int((($xy -> [$i])*$resolution)-$G_fudge);}
    }
    my @xyTmp=(); ##don't pollute array passed in
    for(my $i=0;$i<=$#$xy;$i++) ## e.g. 3.4 in -> 3400 out
    {
        if ($xy -> [$i] >= 0) {push @xyTmp,int((($xy -> [$i])*$resolution)+$G_fudge);}
        else                  {push @xyTmp,int((($xy -> [$i])*$resolution)-$G_fudge);}
    }
    ## gds expects square to have 5 coords (closure)
    if (($xy -> [0] != ($xy -> [($#$xy - 1)])) && ($xy -> [1] != ($xy -> [$#$xy])))
    {
        if ($xy -> [0] >= 0) {push @xyTmp,int((($xy -> [0])*$resolution)+$G_fudge);}
        else                 {push @xyTmp,int((($xy -> [0])*$resolution)-$G_fudge);}
        if ($xy -> [1] >= 0) {push @xyTmp,int((($xy -> [1])*$resolution)+$G_fudge);}
        else                 {push @xyTmp,int((($xy -> [1])*$resolution)-$G_fudge);}
    }
    $self -> printGds2Record(-type => 'XY',-data => \@xyTmp);
    $self -> printGds2Record(-type => 'ENDEL');
}
################################################################################

=head2 printSref - prints a gds2 Structure REFerence

  usage: 
    $gds2File -> printSref(
                    -name=>string,  ## Name of structure
                    -angle=>#.#,    ## Default is 0.0
                    -mag=>#.#,      ## Default is 1.0
                    -xy=>\@array,
                 );

  note:
    best not to specify angle or mag if not needed

=cut

#<SREF>::= SREF [ELFLAGS] [PLEX] SNAME [<strans>] XY
#  <strans>::=   STRANS [MAG] [ANGLE]
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
sub printSref
{
    my($self,%arg) = @_;
    my $useSTRANS=0;
    my $resolution = $self -> {'Resolution'};
    my $sname = $arg{'-name'};
    if (! defined $sname)
    {
        die "printSref expects a name string. Missing -name => 'text' $!";
    }
    my $xy = $arg{'-xy'}; ## $xy should be a reference to an array
    if (! defined $xy)
    {
        die "printSref expects an xy array reference. Missing -xy => \\\@array $!";
    }
    $self -> printGds2Record(-type => 'SREF');
    $self -> printGds2Record(-type => 'SNAME',-data => $sname);
    my $reflect = $arg{'-reflect'};
    if ((! defined $reflect)||($reflect <= 0))
    {
        $reflect=0;
    }
    else
    {
        $reflect=1;
        $useSTRANS=1;
    }
    my $mag = $arg{'-mag'};
    if ((! defined $mag)||($mag <= 0))
    {
        $mag=0;
    }
    else
    {
        $useSTRANS=1;
    }
    my $angle = $arg{'-angle'};
    if (! defined $angle)
    {
        $angle=0;
    }
    else
    { 
        $angle=posAngle($angle);
        $useSTRANS=1;
    }
    if ($useSTRANS)
    {
        my $data=$reflect.'000000000000000'; ## 16 'bit' string
        $self -> printGds2Record(-type => 'STRANS',-data => $data);
        $self -> printGds2Record(-type => 'MAG',-data => $mag)if ($mag);
        $self -> printGds2Record(-type => 'ANGLE',-data => $angle)if ($angle);
    }
    my @xyTmp=(); ##don't pollute array passed in
    for(my $i=0;$i<=$#$xy;$i++) ## e.g. 3.4 in -> 3400 out
    {
        if ($xy -> [$i] >= 0) {push @xyTmp,int((($xy -> [$i])*$resolution)+$G_fudge);}
        else                  {push @xyTmp,int((($xy -> [$i])*$resolution)-$G_fudge);}
    }
    $self -> printGds2Record(-type => 'XY',-data => \@xyTmp);
    $self -> printGds2Record(-type => 'ENDEL');
}
################################################################################

=head2 printAref - prints a gds2 Array REFerence

  usage: 
    $gds2File -> printAref(
                    -name=>string,  ## Name of structure
                    -columns=>#,    ## Default is 1
                    -rows=>#,       ## Default is 1
                    -angle=>#.#,    ## Default is 0.0
                    -mag=>#.#,      ## Default is 1.0
                    -xy=>\@array,
                 );

  note:
    best not to specify angle or mag if not needed

=cut

#<AREF>::= AREF [ELFLAGS] [PLEX] SNAME [<strans>] COLROW XY
#  <strans>::= STRANS [MAG] [ANGLE]
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
sub printAref
{
    my($self,%arg) = @_;
    my $useSTRANS=0;
    my $resolution = $self -> {'Resolution'};
    my $sname = $arg{'-name'};
    if (! defined $sname)
    {
        die "printAref expects a sname string. Missing -name => 'text' $!";
    }
    my $xy = $arg{'-xy'}; ## $xy should be a reference to an array
    if (! defined $xy)
    {
        die "printAref expects an xy array reference. Missing -xy => \\\@array $!";
    }
    $self -> printGds2Record(-type => 'AREF');
    $self -> printGds2Record(-type => 'SNAME',-data => $sname);
    my $reflect = $arg{'-reflect'};
    if ((! defined $reflect)||($reflect <= 0))
    {
        $reflect=0;
    }
    else
    {
        $reflect=1;
        $useSTRANS=1;
    }
    my $mag = $arg{'-mag'};
    if ((! defined $mag)||($mag <= 0))
    {
        $mag=0;
    }
    else
    {
        $useSTRANS=1;
    }
    my $angle = $arg{'-angle'};
    if (! defined $angle)
    {
        $angle=0;
    }
    else
    {
        $angle=posAngle($angle);
        $useSTRANS=1;
    }
    if ($useSTRANS)
    {
        my $data=$reflect.'000000000000000'; ## 16 'bit' string
        $self -> printGds2Record(-type => 'STRANS',-data => $data);
        $self -> printGds2Record(-type => 'MAG',-data => $mag)if ($mag);
        $self -> printGds2Record(-type => 'ANGLE',-data => $angle)if ($angle);
    }
    my $columns = $arg{'-columns'};
    if ((! defined $columns)||($columns <= 0))
    {
        $columns=1;
    }
    else
    {
        $columns=int($columns);
    }
    my $rows = $arg{'-rows'};
    if ((! defined $rows)||($rows <= 0))
    {
        $rows=1;
    }
    else
    {
        $rows=int($rows);
    }
    $self -> printGds2Record(-type => 'COLROW',-data => [$columns,$rows]);
    my @xyTmp=(); ##don't pollute array passed in
    for(my $i=0;$i<=$#$xy;$i++) ## e.g. 3.4 in -> 3400 out
    {
        if ($xy -> [$i] >= 0) {push @xyTmp,int((($xy -> [$i])*$resolution)+$G_fudge);}
        else                  {push @xyTmp,int((($xy -> [$i])*$resolution)-$G_fudge);}
    }
    $self -> printGds2Record(-type => 'XY',-data => \@xyTmp);
    $self -> printGds2Record(-type => 'ENDEL');
}
################################################################################

=head2 printText - prints a gds2 Text

  usage: 
    $gds2File -> printText(
                    -string=>string,
                    -textType=>#,   ## Default is 0
                    -font=>#,       ## 0-3
                    -top, or -middle, -bottom,     ##optional vertical presentation
                    -left, or -center, or -right,  ##optional horizontal presentation
                    -xy=>\@array,
                    -x=>#.#,        ## optional way of passing in x value
                    -y=>#.#,        ## optional way of passing in y value
                    -angle=>#.#,    ## Default is 0.0
                    -mag=>#.#,      ## Default is 1.0
                    -reflect=>#,    ## Default is 0
                 );

  note:
    best not to specify reflect, angle or mag if not needed

=cut

#<text>::= TEXT [ELFLAGS] [PLEX] LAYER <textbody>
#  <textbody>::= TEXTTYPE [PRESENTATION] [PATHTYPE] [WIDTH] [<strans>] XY STRING
#    <strans>::= STRANS [MAG] [ANGLE]
################################################################################
sub printText
{
    my($self,%arg) = @_;
    my $useSTRANS=0;
    my $string = $arg{'-string'};
    if (! defined $string)
    {
        die "printText expects a string. Missing -string => 'text' $!";
    }
    my $resolution = $self -> {'Resolution'};
    my $x = $arg{'-x'};
    my $y = $arg{'-y'};
    my $xy = $arg{'-xy'};
    if (defined $xy)
    {
        $x = $xy -> [0];
        $y = $xy -> [1];
    }

    my $x2 = $arg{'-x'};
    if (defined $x2)
    {
        $x = $x2;
    }
    if (! defined $x)
    {
        die "printText expects a x coord. Missing -xy=>\@array or -x => 'num' $!";
    }
    if ($x>=0) {$x = int(($x*$resolution)+$G_fudge);}
    else       {$x = int(($x*$resolution)-$G_fudge);}

    my $y2 = $arg{'-x'};
    if (defined $y2)
    {
        $y = $y2;
    }
    if (! defined $y)
    {
        die "printText expects a y coord. Missing -xy=>\@array or -y => 'num' $!";
    }
    if ($y>=0) {$y = int(($y*$resolution)+$G_fudge);}
    else       {$y = int(($y*$resolution)-$G_fudge);}

    my $layer = $arg{'-layer'};
    if (! defined $layer)
    {
        $layer=0;
    }
    my $textType = $arg{'-textType'};
    if (! defined $textType)
    {
        $textType=0;
    }
    my $reflect = $arg{'-reflect'};
    if ((! defined $reflect)||($reflect <= 0))
    {
        $reflect=0;
    }
    else
    {
        $reflect=1;
        $useSTRANS=1;
    }

    my $font = $arg{'-font'};
    if ((! defined $font) || ($font < 0) || ($font > 3))
    {
        $font=0;
    }
    $font = sprintf("%02d",$font);

    my $vertical;
    my $top = $arg{'-top'};
    my $middle = $arg{'-middle'};
    my $bottom = $arg{'-bottom'};
    if    (defined $top)    {$vertical = '00';}
    elsif (defined $bottom) {$vertical = '10';}
    else                    {$vertical = '01';} ## middle
    my $horizontal; 
    my $left   = $arg{'-left'};
    my $center = $arg{'-center'};
    my $right  = $arg{'-right'};
    if    (defined $left)  {$horizontal = '00';}
    elsif (defined $right) {$horizontal = '10';}
    else                   {$horizontal = '01';} ## center
    my $presString = "0000000000$font$vertical$horizontal";


    my $mag = $arg{'-mag'};
    if ((! defined $mag)||($mag <= 0))
    {
        $mag=0;
    }
    else
    {
        $useSTRANS=1;
    }
    my $angle = $arg{'-angle'};
    if (! defined $angle)
    {
        $angle=0;
    }
    else
    {
        $angle=posAngle($angle);
        $useSTRANS=1;
    }
    $self -> printGds2Record(-type=>'TEXT');
    $self -> printGds2Record(-type=>'LAYER',-data=>$layer);
    $self -> printGds2Record(-type=>'TEXTTYPE',-data=>$textType);
    $self -> printGds2Record(-type => 'PRESENTATION',-data => $presString) if (defined $font || defined $top || defined $middle || defined $bottom || defined $bottom || defined $left || defined $center || defined $right);
    if ($useSTRANS)
    {
        my $data=$reflect.'000000000000000'; ## 16 'bit' string
        $self -> printGds2Record(-type=>'STRANS',-data=>$data);
        $self -> printGds2Record(-type=>'MAG',-data=>$mag)if ($mag);
        $self -> printGds2Record(-type=>'ANGLE',-data=>$angle)if ($angle);
    }
    $self -> printGds2Record(-type=>'XY',-data=>[$x,$y]);
    $self -> printGds2Record(-type=>'STRING',-data=>$string);
    $self -> printGds2Record(-type=>'ENDEL');
}
################################################################################

=head1 Low Level Generic Write Methods

=cut

################################################################################

=head2  saveGds2Record() - low level method to create a gds2 record given record type 
  and data (if required). Data of more than one item should be given as a list.
  
  NOTE: THIS ONLY USES GDS2 OBJECT TO GET RESOLUTION
  
  usage:
    saveGds2Record(
            -type=>string,
            -data=>data_If_Needed, ##optional for some types
            -scale=>#.#,           ##optional number to scale data to. I.E -scale=>0.5 #default is NOT to scale
            -snap=>#.#,            ##optional number to snap data to I.E. -snap=>0.005 #default is 1 resolution unit, typically 0.001
    );

  examples:
    my $gds2File = new GDS2(-fileName => ">$fileName");
    my $record = $gds2File -> saveGds2Record(-type=>'header',-data=>3);
    $gds2FileOut -> printGds2Record(-type=>'record',-data=>$record);
   

=cut

sub saveGds2Record
{
    my ($self,%arg) = @_;
    my $record='';

    my $type = $arg{'-type'};
    if (! defined $type)
    {
        die "saveGds2Record expects a type name. Missing -type => 'name' $!";
    }
    else
    {
        $type = uc $type;
    }

    my $saveEnd=$\;
    $\='';

    my @data = $arg{'-data'};
    my $dataString = $arg{'-asciiData'};
    die "saveGds2Record can not handle both -data and -asciiData options $!" if ((defined $dataString)&&((defined $data[0])&&($data[0] ne '')));

    my $data = '';
    if ($type eq 'RECORD') ## special case...
    {
        return $data[0];
    }
    else
    {
        my $numDataElements = 0;
        my $resolution = $self -> {'Resolution'};

        my $scale = $arg{'-scale'};
        if (! defined $scale)
        {
            $scale=1;
        }
        if ($scale <= 0)
        {
            die "saveGds2Record expects a positive scale -scale => $scale $!";
        }

        my $snap = $arg{'-snap'};
        if (! defined $snap) ## default is one resolution unit
        {
            $snap = 1;
        }
        else
        {
            $snap = $snap*$resolution; ## i.e. 0.001 -> 1
        }
        if ($snap < 1)
        {
            die "saveGds2Record expects a snap >= 1/resolution -snap => $snap $!";
        }

        if ((defined $data[0])&&($data[0] ne ''))
        {
            $data = $data[0];
            $numDataElements = @$data;
            if ($numDataElements) ## passed in anonymous array
            {
                @data = @$data; ## deref
            }
            else
            {
                $numDataElements = @data;
            }
        }

        my $recordDataType = $RecordTypeData{$type};
        if (defined $dataString)
        {
            $dataString=~s|^\s+||; ## clean-up
            $dataString=~s|\s+$||;
            $dataString=~s|\s+| |g if ($dataString !~ m|'|); ## don't compress spaces in strings...
            $dataString=~s|'$||; #for strings
            $dataString=~s|^'||; #for strings
            if (($recordDataType == $BIT_ARRAY)||($recordDataType == $ACSII_STRING))
            {
                $data = $dataString;
            }
            else
            {
                $dataString=~s|\s*[\s,;:/\\]+\s*| |g; ## incase commas etc... (non-std) were added by hand
                @data = split(' ',$dataString);
                $numDataElements = @data;
                if ($recordDataType == $INTEGER_4)
                {
                    my @xyTmp=();
                    for(my $i=0;$i<$numDataElements;$i++) ## e.g. 3.4 in -> 3400 out
                    {
                        if ($data[$i]>=0) {push @xyTmp,int((($data[$i])*$resolution)+$G_fudge);}
                        else              {push @xyTmp,int((($data[$i])*$resolution)-$G_fudge);}
                    }
                    @data=@xyTmp;
                }
            }
        }
        my $byte;
        my $length = 0;
        if ($recordDataType == $BIT_ARRAY)
        {
            $length = 2;
        }
        elsif ($recordDataType == $INTEGER_2)
        {
            $length = 2 * $numDataElements;
        }
        elsif ($recordDataType == $INTEGER_4)
        {
            $length = 4 * $numDataElements;
        }
        elsif ($recordDataType == $REAL_8)
        {
            $length = 8 * $numDataElements;
        }
        elsif ($recordDataType == $ACSII_STRING)
        {
            my $slen = length $data;
            $length = $slen + ($slen % 2); ## needs to be an even number
        }

        my $recordLength = pack 'S',($length + 4); #1 2 bytes for length 3rd for recordType 4th for dataType
        $record .= $recordLength;
        my $recordType = pack 'C',$$type;  ## evals to GDS2::BGNSTR etc...
        $record .= $recordType;

        my $dataType   = pack 'C',$RecordTypeData{$type};
        $record .= $dataType;

        if ($recordDataType == $BIT_ARRAY)     ## bit array 
        {
            my $bitLength = $length * 8;
            $record .= pack("B$bitLength",$data);
        }
        elsif ($recordDataType == $INTEGER_2)  ## 2 byte signed integer
        {
            foreach my $num (@data)
            {
                $record .= pack('s',$num);
            }
        }
        elsif ($recordDataType == $INTEGER_4)  ## 4 byte signed integer
        {
            foreach my $num (@data)
            {
                $num = scaleNum($num,$scale) if ($scale != 1);
                $num = snapNum($num,$snap) if ($snap != 1);
                $record .= pack('i',$num);
            }
        }
        elsif ($recordDataType == $REAL_8)  ## 8 byte real
        {
            foreach my $num (@data)
            {
                my $real = $num;
                my $negative = 0;
                if($num < 0.0) 
                {
                    $negative = 1;
                    $real = 0 - $num;
                }

                my $exponent = 0;
                while($real >= 1.0) 
                {
                    $exponent++;
                    $real = ($real / 16.0);
                }

                if ($real != 0) 
                {
                    while($real < 0.0625) 
                    {
                        --$exponent;
                        $real = ($real * 16.0);
                    }
                }

                if($negative) { $exponent += 192; }
                else          { $exponent += 64; }
                $record .= pack('C',$exponent);

                for (my $i=1; $i<=7; $i++) 
                {
                    if ($real>=0) {$byte = int(($real*256.0)+$G_fudge);}
                    else          {$byte = int(($real*256.0)-$G_fudge);}
                    $record .= pack('C',$byte);
                    $real = $real * 256.0 - ($byte + 0.0);
                }
            }
        }
        elsif ($recordDataType == $ACSII_STRING)  ## ascii string (null padded)
        {
            $record .= pack("a$length",$data);
        }
    }
    $\=$saveEnd;
    $record;
}
################################################################################

=head2  printGds2Record() - low level method to print a gds2 record given record type 
  and data (if required). Data of more than one item should be given as a list.

  usage:
    printGds2Record(
            -type=>string,
            -data=>data_If_Needed, ##optional for some types
            -scale=>#.#,           ##optional number to scale data to. I.E -scale=>0.5 #default is NOT to scale
            -snap=>#.#,            ##optional number to snap data to I.E. -snap=>0.005 #default is 1 resolution unit, typically 0.001
    );

  examples:
    my $gds2File = new GDS2(-fileName => ">$fileName");

    $gds2File -> printGds2Record(-type=>'header',-data=>3);
    $gds2File -> printGds2Record(-type=>'bgnlib',-data=>[99,12,1,22,33,0,99,12,1,22,33,9]);
    $gds2File -> printGds2Record(-type=>'libname',-data=>"testlib");
    $gds2File -> printGds2Record(-type=>'units',-data=>[0.001, 1e-9]);
    $gds2File -> printGds2Record(-type=>'bgnstr',-data=>[99,12,1,22,33,0,99,12,1,22,33,9]);
    ...
    $gds2File -> printGds2Record(-type=>'endstr');
    $gds2File -> printGds2Record(-type=>'endlib');

  Note: the special record type of 'record' can be used to copy a complete record
  just read in:
    while (my $record = $gds2FileIn -> readGds2Record()) 
    {
        $gds2FileOut -> printGds2Record(-type=>'record',-data=>$record);
    }

=cut

sub printGds2Record
{
    my ($self,%arg) = @_;

    my $type = $arg{'-type'};
    if (! defined $type)
    {
        die "printGds2Record expects a type name. Missing -type => 'name' $!";
    }
    else
    {
        $type = uc $type;
    }

    my $fh = $self -> {'FileHandle'};
    my $saveEnd=$\;
    $\='';

    my @data = $arg{'-data'};
    my $dataString = $arg{'-asciiData'};
    die "printGds2Record can not handle both -data and -asciiData options $!" if ((defined $dataString)&&((defined $data[0])&&($data[0] ne '')));

    my $data = '';
    if ($type eq 'RECORD') ## special case...
    {
        print($fh $data[0]);
    }
    else
    {
        my $numDataElements = 0;
        my $resolution = $self -> {'Resolution'};

        my $scale = $arg{'-scale'};
        if (! defined $scale)
        {
            $scale=1;
        }
        if ($scale <= 0)
        {
            die "printGds2Record expects a positive scale -scale => $scale $!";
        }

        my $snap = $arg{'-snap'};
        if (! defined $snap) ## default is one resolution unit
        {
            $snap = 1;
        }
        else
        {
            $snap = int(($snap*$resolution)+0.000001); ## i.e. 0.001 -> 1
        }
        if ($snap < 1)
        {
            die "printGds2Record expects a snap >= 1/resolution -snap => $snap $!";
        }

        if ((defined $data[0])&&($data[0] ne ''))
        {
            $data = $data[0];
            $numDataElements = @$data;
            if ($numDataElements) ## passed in anonymous array
            {
                @data = @$data; ## deref
            }
            else
            {
                $numDataElements = @data;
            }
        }

        my $recordDataType = $RecordTypeData{$type};
        if (defined $dataString)
        {
            $dataString=~s|^\s+||; ## clean-up
            $dataString=~s|\s+$||;
            $dataString=~s|\s+| |g if ($dataString !~ m|'|); ## don't compress spaces in strings...
            $dataString=~s|'$||; #for strings
            $dataString=~s|^'||; #for strings
            if (($recordDataType == $BIT_ARRAY)||($recordDataType == $ACSII_STRING))
            {
                $data = $dataString;
            }
            else
            {
                $dataString=~s|\s*[\s,;:/\\]+\s*| |g; ## incase commas etc... (non-std) were added by hand
                @data = split(' ',$dataString);
                $numDataElements = @data;
                if ($recordDataType == $INTEGER_4)
                {
                    my @xyTmp=();
                    for(my $i=0;$i<$numDataElements;$i++) ## e.g. 3.4 in -> 3400 out
                    {
                        if ($data[$i]>=0) {push @xyTmp,int((($data[$i])*$resolution)+$G_fudge);}
                        else              {push @xyTmp,int((($data[$i])*$resolution)-$G_fudge);}
                    }
                    @data=@xyTmp;
                }
            }
        }
        my $byte;
        my $length = 0;
        if ($recordDataType == $BIT_ARRAY)
        {
            $length = 2;
        }
        elsif ($recordDataType == $INTEGER_2)
        {
            $length = 2 * $numDataElements;
        }
        elsif ($recordDataType == $INTEGER_4)
        {
            $length = 4 * $numDataElements;
        }
        elsif ($recordDataType == $REAL_8)
        {
            $length = 8 * $numDataElements;
        }
        elsif ($recordDataType == $ACSII_STRING)
        {
            my $slen = length $data;
            $length = $slen + ($slen % 2); ## needs to be an even number
        }

        my $recordLength = pack 'S',($length + 4); #1 2 bytes for length 3rd for recordType 4th for dataType
        print($fh $recordLength);
        my $recordType = pack 'C',$$type;  ## evals to GDS2::BGNSTR etc...
        print($fh $recordType);

        my $dataType   = pack 'C',$RecordTypeData{$type};
        print($fh $dataType);

        if ($recordDataType == $BIT_ARRAY)     ## bit array 
        {
            my $bitLength = $length * 8;
            print($fh pack("B$bitLength",$data));
        }
        elsif ($recordDataType == $INTEGER_2)  ## 2 byte signed integer
        {
            foreach my $num (@data)
            {
                print($fh pack('s',$num));
            }
        }
        elsif ($recordDataType == $INTEGER_4)  ## 4 byte signed integer
        {
            foreach my $num (@data)
            {
                $num = scaleNum($num,$scale) if ($scale != 1);
                $num = snapNum($num,$snap) if ($snap != 1);
                print($fh pack('i',$num));
            }
        }
        elsif ($recordDataType == $REAL_8)  ## 8 byte real
        {
            foreach my $num (@data)
            {
                my $real = $num;
                my $negative = 0;
                if($num < 0.0) 
                {
                    $negative = 1;
                    $real = 0 - $num;
                }

                my $exponent = 0;
                while($real >= 1.0) 
                {
                    $exponent++;
                    $real = ($real / 16.0);
                }

                if ($real != 0) 
                {
                    while($real < 0.0625) 
                    {
                        --$exponent;
                        $real = ($real * 16.0);
                    }
                }

                if($negative) { $exponent += 192; }
                else          { $exponent += 64; }
                print($fh pack('C',$exponent));

                for (my $i=1; $i<=7; $i++) 
                {
                    if ($real>=0) {$byte = int(($real*256.0)+$G_fudge);}
                    else          {$byte = int(($real*256.0)-$G_fudge);}
                    print($fh pack('C',$byte));
                    $real = $real * 256.0 - ($byte + 0.0);
                }
            }
        }
        elsif ($recordDataType == $ACSII_STRING)  ## ascii string (null padded)
        {
            print($fh pack("a$length",$data));
        }
    }
    $\=$saveEnd;
}
################################################################################

=head2 printRecord - prints a record just read 

  usage:
    gds2File -> printRecord(
                  -data => $record 
                );

=cut

sub printRecord
{
    my ($self,%arg) = @_;
    my $record = $arg{'-data'};
    if (! defined $record)
    {
        die "printGds2Record expects a data record. Missing -data => \$record $!";
    }
    my $type = $arg{'-type'};
    if (defined $type)
    {
        die "printRecord does not take -type. Perhaps you meant to use printGds2Record? $!";
    }
    $self -> printGds2Record(-type=>'record',-data=>$record);
}
################################################################################

################################################################################

=head1 Low Level Generic Read Methods

=cut

################################################################################

=head2 readGds2Record - reads record header and data section

  usage:
  while ($gds2File -> readGds2Record)
  {
      if ($gds2File -> returnRecordTypeString eq 'LAYER')
      {
          $layersFound[$gds2File -> layer] = 1;
      }
  }

=cut

sub readGds2Record 
{
    my $self = shift;
    $self -> readGds2RecordHeader();
    $self -> readGds2RecordData();
    $self -> {'Record'};
}
################################################################################

=head2 readGds2RecordHeader - only reads gds2 record header section

=cut

sub readGds2RecordHeader
{
    my $self = shift;
    $self -> skipGds2RecordData() if (($self -> {'HEADER'} >= 0) && (! $self -> {'INDATA'})) ;
    $self -> {'Record'} = '';
    $self -> {'RecordType'} = -1;
    $self -> {'HEADER'} = 1;
    $self -> {'INDATA'} = 0;
    return if $self -> {'EOLIB'}; ## no sense reading null padding..
    my $data;
    if (read($self -> {'FileHandle'},$data,2))
    {
        $data = reverse $data if ($isLittleEndian);
        $self -> {'Record'} .= $data;
        $self -> {'Length'} = unpack 'S',$data; 
    }
    else
    {
        return 0;
    }

    if (read($self -> {'FileHandle'},$data,1))
    {
        $data = reverse $data if ($isLittleEndian);
        $self -> {'Record'} .= $data;
        $self -> {'RecordType'} = unpack 'C',$data; 
        $self -> {'EOLIB'} = 1 if (($self -> {'RecordType'}) == $ENDLIB);

        $StrSpace = ''   if (($self -> {'RecordType'}) == $ENDSTR);
        $StrSpace = '  ' if (($self -> {'RecordType'}) == $BGNSTR);

        $ElmSpace = '  ' if ((($self -> {'RecordType'}) == $TEXT) || (($self -> {'RecordType'}) == $PATH) || 
                             (($self -> {'RecordType'}) == $BOUNDARY) || (($self -> {'RecordType'}) == $SREF) || 
                             (($self -> {'RecordType'}) == $AREF));
        $ElmSpace = ''   if (($self -> {'RecordType'}) == $ENDEL);
    }
    else
    {
        return 0;
    }

    if (read($self -> {'FileHandle'},$data,1))
    {
        $data = reverse $data if ($isLittleEndian);
        $self -> {'Record'} .= $data;
        $self -> {'DataType'} = unpack 'C',$data; 
    }
    else
    {
        return 0;
    }
    return 1;
}
################################################################################

=head2 readGds2RecordData - only reads record data section

  slightly faster if you just want a certain thing...
  usage:
  while ($gds2File -> readGds2RecordHeader) 
  {
      if ($gds2File -> returnRecordTypeString eq 'LAYER')
      {
          $gds2File -> readGds2RecordData;
          $layersFound[$gds2File -> returnLayer] = 1;
      }
  }

=cut

sub readGds2RecordData
{
    my $self = shift;
    $self -> readGds2RecordHeader() if ($self -> {'HEADER'} <= 0);
    $self -> {'HEADER'} = 0;
    $self -> {'INDATA'} = 1;
    my $resolution = $self -> {'Resolution'};
    my $bytesLeft = $self -> {'Length'} - 4; ## 4 should have been just read by readGds2RecordHeader

    $self -> {'RecordData'} = ('');
    $self -> {'CurrentDataList'} = '';
    my $data;
    if ($self -> {'DataType'} == $BIT_ARRAY)     ## bit array 
    {
        $self -> {'DataIndex'}=0;
        read($self -> {'FileHandle'},$data,$bytesLeft);
        $data = reverse $data if ($isLittleEndian);
        my $bitsLeft = $bytesLeft * 8;
        $self -> {'Record'} .= $data;
        $self -> {'RecordData'}[0] = unpack "B$bitsLeft",$data;
        $self -> {'CurrentDataList'} = ($self -> {'RecordData'}[0]);
    }
    elsif ($self -> {'DataType'} == $INTEGER_2)  ## 2 byte signed integer
    {
        my $tmpListString = ''; 
        my $i = 0;
        while ($bytesLeft)
        {
            read($self -> {'FileHandle'},$data,2);
            $data = reverse $data if ($isLittleEndian);
            $self -> {'Record'} .= $data;
            $self -> {'RecordData'}[$i] = unpack 's',$data;
            $tmpListString .= ',';
            $tmpListString .= $self -> {'RecordData'}[$i];
            $i++;
            $bytesLeft -= 2;
        }
        $self -> {'DataIndex'} = $i - 1;
        $self -> {'CurrentDataList'} = $tmpListString;
    }
    elsif ($self -> {'DataType'} == $INTEGER_4)  ## 4 byte signed integer
    {
        my $tmpListString = ''; 
        my $i = 0;
        while ($bytesLeft)
        {
            read($self -> {'FileHandle'},$data,4);
            $data = reverse $data if ($isLittleEndian);
            $self -> {'Record'} .= $data;
            $self -> {'RecordData'}[$i] = unpack 'i',$data;
            $tmpListString .= ',';
            $tmpListString .= $self -> {'RecordData'}[$i];
            $i++;
            $bytesLeft -= 4;
        }
        $self -> {'DataIndex'} = $i - 1;
        $self -> {'CurrentDataList'} = $tmpListString;
    }
    elsif ($self -> {'DataType'} == $REAL_4)  ## 4 byte real
    {
        die "4-byte reals are not supported $!";
    }
    elsif ($self -> {'DataType'} == $REAL_8)  ## 8 byte real
    {
        my $tmpListString = ''; 
        my $i = 0;
        while ($bytesLeft)
        {
            read($self -> {'FileHandle'},$data,1); ## sign bit and 7 exponent bits
            $data = reverse $data if ($isLittleEndian);
            $self -> {'Record'} .= $data;
            my $negative = unpack 'B',$data; ## sign bit
            my $exponent = unpack 'C',$data;
            if ($negative)
            {
                $exponent -= 192; ## 128 + 64
            }
            else
            {
                $exponent -= 64;
            }

            read($self -> {'FileHandle'},$data,7); ## mantissa bits
            $self -> {'Record'} .= $data;
            my $mantdata = unpack 'b*',$data;

            my $mantissa = 0.0;
            for(my $i=0; $i<7; $i++)
            {
                my $byteString = substr($mantdata,($i*8),8);
                my $byte = pack 'b*',$byteString;
                $byte = unpack 'C',$byte;
                $mantissa += $byte / (256.0**($i+1));
            }
            my $real = $mantissa * (16**$exponent);
            $real = (0 - $real) if ($negative);
            if ($RecordTypeStrings[$self -> {'RecordType'}] eq 'UNITS')
            {
                $self -> {'UUnits'} = $real if ($self -> {'UUnits'} == 0);
                $self -> {'DBUnits'} = $real if ($self -> {'DBUnits'} == 0);
            }
            else
            {
                $real = int(($real+($self -> {'UUnits'}/$resolution))/$self -> {'UUnits'})*$self -> {'UUnits'} if ($self -> {'UUnits'} != 0); ## "rounds" off
            }
            $self -> {'RecordData'}[$i] = $real;
            $tmpListString .= ',';
            $tmpListString .= $self -> {'RecordData'}[$i];
            $i++;
            $bytesLeft -= 8;
        }
        $self -> {'DataIndex'} = $i - 1;
        $self -> {'CurrentDataList'} = $tmpListString;
    }
    elsif ($self -> {'DataType'} == $ACSII_STRING)  ## ascii string (null padded)
    {
        $self -> {'DataIndex'} = 0;
        read($self -> {'FileHandle'},$data,$bytesLeft);
        $self -> {'Record'} .= $data;
        $self -> {'RecordData'}[0] = unpack "a$bytesLeft",$data;
        $self -> {'RecordData'}[0] =~ s|\0||g; ## take off ending nulls
        $self -> {'CurrentDataList'} = ($self -> {'RecordData'}[0]);
    }
    $self -> {'Record'};
}
################################################################################

=head1 Low Level Generic Evaluation Methods

=cut

################################################################################

=head2 returnRecordType - returns current (read) record type as integer

  usage:
  if ($gds2File -> returnRecordType == 6)
  {
      print "found STRNAME";
  }

=cut

sub returnRecordType
{
    my $self = shift;
    $self -> {'RecordType'};
}
################################################################################

=head2 returnRecordTypeString - returns current (read) record type as string

  usage:
  if ($gds2File -> returnRecordTypeString eq 'LAYER')
  {
      code goes here...
  }

=cut

sub returnRecordTypeString
{
    my $self = shift;
    $RecordTypeStrings[($self -> {'RecordType'})];
}
################################################################################

=head2 returnRecordAsString - returns current (read) record as a string

  usage:
  while ($gds2File -> readGds2Record) 
  {
      print $gds2File -> returnRecordAsString;
  }

=cut

sub returnRecordAsString()
{
    my $self = shift;
    my $string = '';
    $string .= $StrSpace if ($self -> {'RecordType'} != $BGNSTR);
    $string .= $ElmSpace if (!(($self -> {'RecordType'} == $TEXT) || ($self -> {'RecordType'} == $PATH) || 
                               ($self -> {'RecordType'} == $BOUNDARY) || ($self -> {'RecordType'} == $SREF) || 
                               ($self -> {'RecordType'} == $AREF)));
    $string .= $RecordTypeStrings[$self -> {'RecordType'}];
    my $i = 0;
    while ($i <= $self -> {'DataIndex'})
    {
        if ($self -> {'DataType'} == $BIT_ARRAY)
        {
            $string .= '  '.$self -> {'RecordData'}[$i];
        }
        elsif ($self -> {'DataType'} == $INTEGER_2)
        {
            $string .= '  '.$self -> {'RecordData'}[$i];
        }
        elsif ($self -> {'DataType'} == $INTEGER_4)
        {
            $string .= '  '.$self -> {'RecordData'}[$i]*($self -> {'UUnits'});
        }
        elsif ($self -> {'DataType'} == $REAL_8)
        {
            $string .= '  '.$self -> {'RecordData'}[$i];
        }
        elsif ($self -> {'DataType'} == $ACSII_STRING)
        {
            $string .= "  '".$self -> {'RecordData'}[$i]."'";
        }
        $i++;
    }
    $string;
}
################################################################################

=head1 Low Level Specific Write Methods

=cut

################################################################################

=head2 printAngle - prints ANGLE record

  usage:
    gds2File -> printAngle(-num=>#.#);

=cut

sub printAngle
{
    my($self,%arg) = @_;
    my $angle = $arg{'-num'};
    $angle=0 if (! defined $angle);
    $angle=posAngle($angle);
    $self -> printGds2Record(-type => 'ANGLE',-data => $angle)if ($angle);
}
################################################################################

=head2 printAttrtable - prints ATTRTABLE record

  usage:
    gds2File -> printAttrtable(-string=>$string);

=cut

sub printAttrtable
{
    my($self,%arg) = @_;
    my $string = $arg{'-string'};
    if (! defined $string)
    {
        die "printAttrtable expects a string. Missing -string => 'text' $!";
    }
    $self -> printGds2Record(-type => 'ATTRTABLE',-data => $string);
}
################################################################################

=head2 printBgnextn - prints BGNEXTN record

  usage:
    gds2File -> printBgnextn(-num=>#.#);

=cut

sub printBgnextn
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printBgnextn expects a extension number. Missing -num => #.# $!";
    }
    my $resolution = $self -> {'Resolution'};
    if ($num >= 0) {$num = int(($num*$resolution)+$G_fudge);}
    else           {$num = int(($num*$resolution)-$G_fudge);}
    $self -> printGds2Record(-type => 'BGNEXTN',-data => $num);
}
################################################################################

=head2 printBgnlib - prints BGNLIB record

=cut

sub printBgnlib
{
    my $self = shift;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $mon++;
    $year += 1900;
    $self -> printGds2Record(-type=>'BGNLIB',-data=>[$year,$mon,$mday,$hour,$min,$sec,$year,$mon,$mday,$hour,$min,$sec]);
}
################################################################################

=head2 printBox - prints BOX record

  usage:
    gds2File -> printBox;

=cut

sub printBox
{
    my $self = shift;
    $self -> printGds2Record(-type => 'BOX');
}
################################################################################

=head2 printBoxtype - prints BOXTYPE record

  usage:
    gds2File -> printBoxtype(-num=>#);

=cut

sub printBoxtype
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printBoxtype expects a number. Missing -num => # $!";
    }
    $self -> printGds2Record(-type => 'BOXTYPE',-data => $num);
}
################################################################################

=head2 printColrow - prints COLROW record

  usage:
    gds2File -> printBoxtype(-columns=>#, -rows=>#);

=cut

sub printColrow
{
    my($self,%arg) = @_;
    my $columns = $arg{'-columns'};
    if ((! defined $columns)||($columns <= 0))
    {
        $columns=1;
    }
    else
    {
        $columns=int($columns);
    }
    my $rows = $arg{'-rows'};
    if ((! defined $rows)||($rows <= 0))
    {
        $rows=1;
    }
    else
    {
        $rows=int($rows);
    }
    $self -> printGds2Record(-type => 'COLROW',-data => [$columns,$rows]);
}
################################################################################

=head2 printDatatype - prints DATATYPE record

  usage:
    gds2File -> printDatatype(-num=>#);

=cut

sub printDatatype
{
    my($self,%arg) = @_;
    my $dataType = $arg{'-num'};
    if (! defined $dataType)
    {
        $dataType=0;
    }
    $self -> printGds2Record(-type => 'DATATYPE',-data => $dataType);
}
################################################################################

sub printEflags
{
    my $self = shift;
    die "EFLAGS type not supported $!";
}
################################################################################

=head2 printElkey - prints ELKEY record

  usage:
    gds2File -> printElkey(-num=>#);

=cut

sub printElkey
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printElkey expects a number. Missing -num => #.# $!";
    }
    $self -> printGds2Record(-type => 'ELKEY',-data => $num);
}
################################################################################

=head2 printEndel - closes an element definition 

=cut

sub printEndel
{
    my $self = shift;
    $self -> printGds2Record(-type => 'ENDEL');
}
################################################################################

=head2 printEndextn - prints path end extension record

  usage:
    gds2File printEndextn -> (-num=>#.#);

=cut

sub printEndextn
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printEndextn expects a extension number. Missing -num => #.# $!";
    }
    my $resolution = $self -> {'Resolution'};
    if ($num >= 0) {$num = int(($num*$resolution)+$G_fudge);}
    else           {$num = int(($num*$resolution)-$G_fudge);}
    $self -> printGds2Record(-type => 'ENDEXTN',-data => $num);
}
################################################################################

=head2 printEndlib - closes a library definition

=cut

sub printEndlib
{
    my $self = shift;
    $self -> printGds2Record(-type => 'ENDLIB');
}
################################################################################

=head2 printEndstr - closes a structure definition

=cut

sub printEndstr
{
    my $self = shift;
    $self -> printGds2Record(-type => 'ENDSTR');
}
################################################################################

=head2 printEndmasks - prints a ENDMASKS 

=cut

sub printEndmasks
{
    my $self = shift;
    $self -> printGds2Record(-type => 'ENDMASKS');
}
################################################################################

=head2 printFonts - prints a FONTS record

  usage:
    gds2File -> printFonts(-string=>'names_of_font_files');

=cut

sub printFonts
{
    my($self,%arg) = @_;
    my $string = $arg{'-string'};
    if (! defined $string)
    {
        die "printFonts expects a string. Missing -string => 'text' $!";
    }
    $self -> printGds2Record(-type => 'FONTS',-data => $string);
}
################################################################################

sub printFormat
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printFormat expects a number. Missing -num => #.# $!";
    }
    $self -> printGds2Record(-type => 'FORMAT',-data => $num);
}
################################################################################

sub printGenerations
{
    my $self = shift;
    $self -> printGds2Record(-type => 'GENERATIONS');
}
################################################################################

=head2 printHeader - Prints a rev 3 header

  usage:
    gds2File -> printHeader(
                  -num => #  ## optional, defaults to 3. valid revs are 0,3,4,5,and 600
                );

=cut

sub printHeader
{
    my($self,%arg) = @_;
    my $rev = $arg{'-num'};
    if (! defined $rev)
    {
        $rev=3;
    }
    $self -> printGds2Record(-type=>'HEADER',-data=>$rev);
}
################################################################################

=head2 printLayer - prints a LAYER number 

  usage:
    gds2File -> printLayer(
                  -num => #  ## optional, defaults to 0. 
                );

=cut

sub printLayer
{
    my($self,%arg) = @_;
    my $layer = $arg{'-num'};
    if (! defined $layer)
    {
        $layer=0;
    }
    $self -> printGds2Record(-type => 'LAYER',-data => $layer);
}
################################################################################

sub printLibdirsize
{
    my $self = shift;
    $self -> printGds2Record(-type => 'LIBDIRSIZE');
}
################################################################################

=head2 printLibname - Prints library name

  usage:
    printLibname(-name=>$name);

=cut

sub printLibname
{
    my($self,%arg) = @_;
    my $libName = $arg{'-name'};
    if (! defined $libName)
    {
        die "printLibname expects a library name. Missing -name => 'name' $!";
    }
    $self -> printGds2Record(-type => 'LIBNAME',-data => $libName);
}
################################################################################

sub printLibsecur
{
    my $self = shift;
    $self -> printGds2Record(-type => 'LIBSECUR');
}
################################################################################

sub printLinkkeys
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printLinkkeys expects a number. Missing -num => #.# $!";
    }
    $self -> printGds2Record(-type => 'LINKKEYS',-data => $num);
}
################################################################################

sub printLinktype
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printLinktype expects a number. Missing -num => #.# $!";
    }
    $self -> printGds2Record(-type => 'LINKTYPE',-data => $num);
}
################################################################################

=head2 printPathtype - prints a PATHTYPE number 

  usage:
    gds2File -> printPathtype(
                  -num => #  ## optional, defaults to 0. 
                );

=cut

sub printPathtype
{
    my($self,%arg) = @_;
    my $pathType = $arg{'-num'};
    $pathType=0 if (! defined $pathType);
    $self -> printGds2Record(-type => 'PATHTYPE',-data => $pathType) if ($pathType);
}
################################################################################

=head2 printMag - prints a MAG number 

  usage:
    gds2File -> printMag(
                  -num => #.#  ## optional, defaults to 0.0 
                );

=cut

sub printMag
{
    my($self,%arg) = @_;
    my $mag = $arg{'-num'};
    $mag=0 if ((! defined $mag)||($mag <= 0));
    $self -> printGds2Record(-type => 'MAG',-data => $mag)if ($mag);
}
################################################################################

sub printMask
{
    my($self,%arg) = @_;
    my $string = $arg{'-string'};
    if (! defined $string)
    {
        die "printMask expects a string. Missing -string => 'text' $!";
    }
    $self -> printGds2Record(-type => 'MASK',-data => $string);
}
################################################################################

sub printNode
{
    my $self = shift;
    $self -> printGds2Record(-type => 'NODE');
}
################################################################################

=head2 printNodetype - prints a NODETYPE number 

  usage:
    gds2File -> printNodetype(
                  -num => #  
                );

=cut

sub printNodetype
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printNodetype expects a number. Missing -num => # $!";
    }
    $self -> printGds2Record(-type => 'NODETYPE',-data => $num);
}
################################################################################

sub printPlex
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printPlex expects a number. Missing -num => #.# $!";
    }
    $self -> printGds2Record(-type => 'PLEX',-data => $num);
}
################################################################################

=head2 printPresentation - prints a text presentation record

  usage:
    gds2File -> printPresentation(
                  -font => #,  ##optional, defaults to 0, valid numbers are 0-3
                  -top, ||-middle, || -bottom, ## vertical justification
                  -left, ||-center, || -right, ## horizontal justification
                );

  example:
    gds2File -> printPresentation(-font=>0,-top,-left);

=cut

sub printPresentation
{
    my($self,%arg) = @_;
    my $font = $arg{'-font'};
    if ((! defined $font) || ($font < 0) || ($font > 3))
    {
        $font=0;
    }
    $font = sprintf("%02d",$font);

    my $vertical;
    my $top = $arg{'-top'};
    my $middle = $arg{'-middle'};
    my $bottom = $arg{'-bottom'};
    if    (defined $top)    {$vertical = '00';}
    elsif (defined $bottom) {$vertical = '10';}
    else                    {$vertical = '01';} ## middle
    my $horizontal; 
    my $left   = $arg{'-left'};
    my $center = $arg{'-center'};
    my $right  = $arg{'-right'};
    if    (defined $left)  {$horizontal = '00';}
    elsif (defined $right) {$horizontal = '10';}
    else                   {$horizontal = '01';} ## center

    my $bitstring = "0000000000$font$vertical$horizontal";
    $self -> printGds2Record(-type => 'PRESENTATION',-data => $bitstring);
}
################################################################################

=head2 printPropattr - prints a property id number 

  usage:
    gds2File -> printPropattr( -num => # );

=cut

sub printPropattr
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printPropattr expects a number. Missing -num => # $!";
    }
    $self -> printGds2Record(-type => 'PROPATTR',-data => $num);
}
################################################################################

=head2 printPropvalue - prints a property value string

  usage:
    gds2File -> printPropvalue( -string => $string );

=cut

sub printPropvalue
{
    my($self,%arg) = @_;
    my $string = $arg{'-string'};
    if (! defined $string)
    {
        die "printPropvalue expects a string. Missing -string => 'text' $!";
    }
    $self -> printGds2Record(-type => 'PROPVALUE',-data => $string);
}
################################################################################

sub printReflibs
{
    my($self,%arg) = @_;
    my $string = $arg{'-string'};
    if (! defined $string)
    {
        die "printReflibs expects a string. Missing -string => 'text' $!";
    }
    $self -> printGds2Record(-type => 'REFLIBS',-data => $string);
}
################################################################################

sub printReserved
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printReserved expects a number. Missing -num => #.# $!";
    }
    $self -> printGds2Record(-type => 'RESERVED',-data => $num);
}
################################################################################

=head2 printSname - prints a SNAME string

  usage:
    gds2File -> printSname( -name => $cellName );

=cut

sub printSname
{
    my($self,%arg) = @_;
    my $string = $arg{'-name'};
    if (! defined $string)
    {
        die "printSname expects a cell name. Missing -name => 'text' $!";
    }
    $self -> printGds2Record(-type => 'SNAME',-data => $string);
}
################################################################################

sub printSpacing
{
    my $self = shift;
    die "SPACING type not supported $!";
}
################################################################################

sub printSrfname
{
    my $self = shift;
    $self -> printGds2Record(-type => 'SRFNAME');
}
################################################################################

=head2 printSname - prints a STRANS record

  usage:
    gds2File -> printStrans( -reflect );

=cut

sub printStrans
{
    my($self,%arg) = @_;
    my $reflect = $arg{'-reflect'};
    if ((! defined $reflect)||($reflect <= 0))
    {
        $reflect=0;
    }
    else
    {
        $reflect=1;
    }
    my $data=$reflect.'000000000000000'; ## 16 'bit' string
    $self -> printGds2Record(-type => 'STRANS',-data => $data);
}
################################################################################

sub printStrclass
{
    my $self = shift;
    $self -> printGds2Record(-type => 'STRCLASS');
}
################################################################################

=head2 printString - prints a STRING record

  usage:
    gds2File -> printSname( -string => $text );

=cut

sub printString
{
    my($self,%arg) = @_;
    my $string = $arg{'-string'};
    if (! defined $string)
    {
        die "printText expects a string. Missing -string => 'text' $!";
    }
    $self -> printGds2Record(-type => 'STRING',-data => $string);
}
################################################################################

=head2 printStrname - prints a structure name string

  usage:
    gds2File -> printStrname( -name => $cellName );

=cut

sub printStrname
{
    my($self,%arg) = @_;
    my $strName = $arg{'-name'};
    if (! defined $strName)
    {
        die "printStrname expects a structure name. Missing -name => 'name' $!";
    }
    $self -> printGds2Record(-type => 'STRNAME',-data => $strName);
}
################################################################################

sub printStrtype
{
    my $self = shift;
    die "STRTYPE type not supported $!";
}
################################################################################

sub printStyptable
{
    my($self,%arg) = @_;
    my $string = $arg{'-string'};
    if (! defined $string)
    {
        die "printStyptable expects a string. Missing -string => 'text' $!";
    }
    $self -> printGds2Record(-type => 'STYPTABLE',-data => $string);
}
################################################################################

sub printTapecode
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printTapecode expects a number. Missing -num => #.# $!";
    }
    $self -> printGds2Record(-type => 'TAPECODE',-data => $num);
}
################################################################################

sub printTapenum
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printTapenum expects a number. Missing -num => #.# $!";
    }
    $self -> printGds2Record(-type => 'TAPENUM',-data => $num);
}
################################################################################

sub printTextnode
{
    my $self = shift;
    $self -> printGds2Record(-type => 'TEXTNODE');
}
################################################################################

=head2 printPropattr - prints a text type number 

  usage:
    gds2File -> printTexttype( -num => # );

=cut

sub printTexttype
{
    my($self,%arg) = @_;
    my $num = $arg{'-num'};
    if (! defined $num)
    {
        die "printTexttype expects a number. Missing -num => # $!";
    }
    $num = 0 if ($num < 0);
    $self -> printGds2Record(-type => 'TEXTTYPE',-data => $num);
}
################################################################################

sub printUinteger
{
    my $self = shift;
    die "UINTEGER type not supported $!";
}
################################################################################

=head2 printUnits - Prints units record.

  Defaults to 1e-3 and 1e-9

=cut

sub printUnits
{
    my $self = shift;
    $self -> printGds2Record(-type => 'UNITS',-data => [0.001,1e-9]);
}
################################################################################

sub printUstring
{
    my $self = shift;
    die "USTRING type not supported $!";
}
################################################################################

=head2 printPropattr - prints a width number 

  usage:
    gds2File -> printWidth( -num => # );

=cut

sub printWidth
{
    my($self,%arg) = @_;
    my $width = $arg{'-num'};
    if ((! defined $width)||($width <= 0))
    {
        $width=0;
    }
    $self -> printGds2Record(-type => 'WIDTH',-data => $width) if ($width);
}
################################################################################

=head2 printXy - prints an XY array 

  usage:
    gds2File -> printXy( -xy => \@array );

=cut

sub printXy
{
    my($self,%arg) = @_;
    my $xy = $arg{'-xy'}; ## $xy should be a reference to an array
    if (! defined $xy)
    {
        die "printXy expects an xy array reference. Missing -xy => \\\@array $!";
    }
    my $resolution = $self -> {'Resolution'};
    my @xyTmp=(); ##don't pollute array passed in
    for(my $i=0;$i<=$#$xy;$i++) ## e.g. 3.4 in -> 3400 out
    {
        if ($xy -> [$i] >= 0) {push @xyTmp,int((($xy -> [$i])*$resolution)+$G_fudge);}
        else                  {push @xyTmp,int((($xy -> [$i])*$resolution)-$G_fudge);}
    }
    $self -> printGds2Record(-type => 'XY',-data => \@xyTmp);
}
################################################################################


################################################################################

=head1 Low Level Specific Evaluation Methods

=cut

################################################################################

=head2 returnLayer - returns layer # if record is LAYER else returns -1

  usage:
    $layersFound[$gds2File -> returnLayer] = 1;

=cut

sub returnLayer
{
    my $self = shift;
    ## 2 byte signed integer
    if ($self -> isLayer) { $self -> {'RecordData'}[0]; }
    else { -1; }
}
################################################################################

=head2 returnString - return string if record type is STRING else ''

=cut

sub returnString
{
    my $self = shift;
    if ($self -> isString) { $self -> {'RecordData'}[0]; }
    else { ''; }
}
################################################################################

=head2 returnStrname - return string if record type is STRNAME else ''

=cut

sub returnStrname
{
    my $self = shift;
    if ($self -> isStrname) { $self -> {'RecordData'}[0]; }
    else { ''; }
}
################################################################################

################################################################################

=head1 Low Level Specific Boolean Methods

=cut

################################################################################

=head2 isAref - return 0 or 1 depending on whether current record is an aref

=cut

sub isAref
{
    my $self = shift;
    if ($self -> {'RecordType'} == $AREF) { 1; }
    else { 0; }
}
################################################################################

=head2 isBgnlib - return 0 or 1 depending on whether current record is a bgnlib

=cut

sub isBgnlib
{
    my $self = shift;
    if ($self -> {'RecordType'} == $BGNLIB) { 1; }
    else { 0; }
}
################################################################################

=head2 isBgnstr - return 0 or 1 depending on whether current record is a bgnstr

=cut

sub isBgnstr
{
    my $self = shift;
    if ($self -> {'RecordType'} == $BGNSTR) { 1; }
    else { 0; }
}
################################################################################

=head2 isBoundary - return 0 or 1 depending on whether current record is a boundary

=cut

sub isBoundary
{
    my $self = shift;
    if ($self -> {'RecordType'} == $BOUNDARY) { 1; }
    else { 0; }
}
################################################################################

=head2 isDatatype - return 0 or 1 depending on whether current record is datatype

=cut

sub isDatatype
{
    my $self = shift;
    if ($self -> {'RecordType'} == $DATATYPE) { 1; }
    else { 0; }
}
################################################################################

=head2 isEndlib - return 0 or 1 depending on whether current record is endlib 

=cut

sub isEndlib
{
    my $self = shift;
    if ($self -> {'RecordType'} == $ENDLIB) { 1; }
    else { 0; }
}
################################################################################

=head2 isEndel - return 0 or 1 depending on whether current record is endel

=cut

sub isEndel
{
    my $self = shift;
    if ($self -> {'RecordType'} == $ENDEL) { 1; }
    else { 0; }
}
################################################################################

=head2 isEndstr - return 0 or 1 depending on whether current record is endstr 

=cut

sub isEndstr
{
    my $self = shift;
    if ($self -> {'RecordType'} == $ENDSTR) { 1; }
    else { 0; }
}
################################################################################


=head2 isHeader - return 0 or 1 depending on whether current record is a header

=cut

sub isHeader
{
    my $self = shift;
    if ($self -> {'RecordType'} == $HEADER) { 1; }
    else { 0; }
}
################################################################################

=head2 isLibname - return 0 or 1 depending on whether current record is a libname

=cut

sub isLibname
{
    my $self = shift;
    if ($self -> {'RecordType'} == $LIBNAME) { 1; }
    else { 0; }
}
################################################################################

=head2 isPath - return 0 or 1 depending on whether current record is a path

=cut

sub isPath
{
    my $self = shift;
    if ($self -> {'RecordType'} == $PATH) { 1; }
    else { 0; }
}
################################################################################

=head2 isSref - return 0 or 1 depending on whether current record is an sref

=cut

sub isSref
{
    my $self = shift;
    if ($self -> {'RecordType'} == $SREF) { 1; }
    else { 0; }
}
################################################################################

=head2 isSrfname - return 0 or 1 depending on whether current record is an srfname

=cut

sub isSrfname
{
    my $self = shift;
    if ($self -> {'RecordType'} == $SRFNAME) { 1; }
    else { 0; }
}
################################################################################

=head2 isText - return 0 or 1 depending on whether current record is a text

=cut

sub isText
{
    my $self = shift;
    if ($self -> {'RecordType'} == $TEXT) { 1; }
    else { 0; }
}
################################################################################

=head2 isUnits - return 0 or 1 depending on whether current record is units 

=cut

sub isUnits
{
    my $self = shift;
    if ($self -> {'RecordType'} == $UNITS) { 1; }
    else { 0; }
}
################################################################################

=head2 isLayer - return 0 or 1 depending on whether current record is layer

=cut

sub isLayer
{
    my $self = shift;
    if ($self -> {'RecordType'} == $LAYER) { 1; }
    else { 0; }
}
################################################################################

=head2 isStrname - return 0 or 1 depending on whether current record is strname 

=cut

sub isStrname
{
    my $self = shift;
    if ($self -> {'RecordType'} == $STRNAME) { 1; }
    else { 0; }
}
################################################################################

=head2 isWidth - return 0 or 1 depending on whether current record is width 

=cut

sub isWidth
{
    my $self = shift;
    if ($self -> {'RecordType'} == $WIDTH) { 1; }
    else { 0; }
}
################################################################################

=head2 isXy - return 0 or 1 depending on whether current record is xy 

=cut

sub isXy
{
    my $self = shift;
    if ($self -> {'RecordType'} == $XY) { 1; }
    else { 0; }
}
################################################################################

=head2 isSname - return 0 or 1 depending on whether current record is sname

=cut

sub isSname
{
    my $self = shift;
    if ($self -> {'RecordType'} == $SNAME) { 1; }
    else { 0; }
}
################################################################################

=head2 isColrow - return 0 or 1 depending on whether current record is colrow

=cut

sub isColrow
{
    my $self = shift;
    if ($self -> {'RecordType'} == $COLROW) { 1; }
    else { 0; }
}
################################################################################

=head2 isTextnode - return 0 or 1 depending on whether current record is a textnode

=cut

sub isTextnode
{
    my $self = shift;
    if ($self -> {'RecordType'} == $TEXTNODE) { 1; }
    else { 0; }
}
################################################################################

=head2 isNode - return 0 or 1 depending on whether current record is a node

=cut

sub isNode
{
    my $self = shift;
    if ($self -> {'RecordType'} == $NODE) { 1; }
    else { 0; }
}
################################################################################

=head2 isTexttype - return 0 or 1 depending on whether current record is a texttype

=cut

sub isTexttype
{
    my $self = shift;
    if ($self -> {'RecordType'} == $TEXTTYPE) { 1; }
    else { 0; }
}
################################################################################

=head2 isPresentation - return 0 or 1 depending on whether current record is a presentation

=cut

sub isPresentation
{
    my $self = shift;
    if ($self -> {'RecordType'} == $PRESENTATION) { 1; }
    else { 0; }
}
################################################################################

=head2 isSpacing - return 0 or 1 depending on whether current record is a spacing

=cut

sub isSpacing
{
    my $self = shift;
    if ($self -> {'RecordType'} == $SPACING) { 1; }
    else { 0; }
}
################################################################################

=head2 isString - return 0 or 1 depending on whether current record is a string

=cut

sub isString
{
    my $self = shift;
    if ($self -> {'RecordType'} == $STRING) { 1; }
    else { 0; }
}
################################################################################

=head2 isStrans - return 0 or 1 depending on whether current record is a strans

=cut

sub isStrans
{
    my $self = shift;
    if ($self -> {'RecordType'} == $STRANS) { 1; }
    else { 0; }
}
################################################################################

=head2 isMag - return 0 or 1 depending on whether current record is a mag

=cut

sub isMag
{
    my $self = shift;
    if ($self -> {'RecordType'} == $MAG) { 1; }
    else { 0; }
}
################################################################################

=head2 isAngle - return 0 or 1 depending on whether current record is a angle 

=cut

sub isAngle
{
    my $self = shift;
    if ($self -> {'RecordType'} == $ANGLE) { 1; }
    else { 0; }
}
################################################################################

=head2 isUinteger - return 0 or 1 depending on whether current record is a uinteger

=cut

sub isUinteger
{
    my $self = shift;
    if ($self -> {'RecordType'} == $UINTEGER) { 1; }
    else { 0; }
}
################################################################################

=head2 isUstring - return 0 or 1 depending on whether current record is a ustring

=cut

sub isUstring
{
    my $self = shift;
    if ($self -> {'RecordType'} == $USTRING) { 1; }
    else { 0; }
}
################################################################################

=head2 isReflibs - return 0 or 1 depending on whether current record is a reflibs

=cut

sub isReflibs
{
    my $self = shift;
    if ($self -> {'RecordType'} == $REFLIBS) { 1; }
    else { 0; }
}
################################################################################

=head2 isFonts - return 0 or 1 depending on whether current record is a fonts

=cut

sub isFonts
{
    my $self = shift;
    if ($self -> {'RecordType'} == $FONTS) { 1; }
    else { 0; }
}
################################################################################

=head2 isPathtype - return 0 or 1 depending on whether current record is a pathtype

=cut

sub isPathtype
{
    my $self = shift;
    if ($self -> {'RecordType'} == $PATHTYPE) { 1; }
    else { 0; }
}
################################################################################

=head2 isGenerations - return 0 or 1 depending on whether current record is a generations

=cut

sub isGenerations
{
    my $self = shift;
    if ($self -> {'RecordType'} == $GENERATIONS) { 1; }
    else { 0; }
}
################################################################################

=head2 isAttrtable - return 0 or 1 depending on whether current record is a attrtable

=cut

sub isAttrtable
{
    my $self = shift;
    if ($self -> {'RecordType'} == $ATTRTABLE) { 1; }
    else { 0; }
}
################################################################################

=head2 isStyptable - return 0 or 1 depending on whether current record is a styptable

=cut

sub isStyptable
{
    my $self = shift;
    if ($self -> {'RecordType'} == $STYPTABLE) { 1; }
    else { 0; }
}
################################################################################

=head2 isStrtype - return 0 or 1 depending on whether current record is a strtype

=cut

sub isStrtype
{
    my $self = shift;
    if ($self -> {'RecordType'} == $STRTYPE) { 1; }
    else { 0; }
}
################################################################################

=head2 isEflags - return 0 or 1 depending on whether current record is a eflags

=cut

sub isEflags
{
    my $self = shift;
    if ($self -> {'RecordType'} == $EFLAGS) { 1; }
    else { 0; }
}
################################################################################

=head2 isElkey - return 0 or 1 depending on whether current record is a elkey

=cut

sub isElkey
{
    my $self = shift;
    if ($self -> {'RecordType'} == $ELKEY) { 1; }
    else { 0; }
}
################################################################################

=head2 isLinktype - return 0 or 1 depending on whether current record is a linktype

=cut

sub isLinktype
{
    my $self = shift;
    if ($self -> {'RecordType'} == $LINKTYPE) { 1; }
    else { 0; }
}
################################################################################

=head2 isLinkkeys - return 0 or 1 depending on whether current record is a linkkeys

=cut

sub isLinkkeys
{
    my $self = shift;
    if ($self -> {'RecordType'} == $LINKKEYS) { 1; }
    else { 0; }
}
################################################################################

=head2 isNodetype - return 0 or 1 depending on whether current record is a nodetype

=cut

sub isNodetype
{
    my $self = shift;
    if ($self -> {'RecordType'} == $NODETYPE) { 1; }
    else { 0; }
}
################################################################################

=head2 isPropattr - return 0 or 1 depending on whether current record is a propattr

=cut

sub isPropattr
{
    my $self = shift;
    if ($self -> {'RecordType'} == $PROPATTR) { 1; }
    else { 0; }
}
################################################################################

=head2 isPropvalue - return 0 or 1 depending on whether current record is a propvalue

=cut

sub isPropvalue
{
    my $self = shift;
    if ($self -> {'RecordType'} == $PROPVALUE) { 1; }
    else { 0; }
}
################################################################################

=head2 isBox - return 0 or 1 depending on whether current record is a box

=cut

sub isBox
{
    my $self = shift;
    if ($self -> {'RecordType'} == $BOX) { 1; }
    else { 0; }
}
################################################################################

=head2 isBoxtype - return 0 or 1 depending on whether current record is a boxtype

=cut

sub isBoxtype
{
    my $self = shift;
    if ($self -> {'RecordType'} == $BOXTYPE) { 1; }
    else { 0; }
}
################################################################################

=head2 isPlex - return 0 or 1 depending on whether current record is a plex

=cut

sub isPlex
{
    my $self = shift;
    if ($self -> {'RecordType'} == $PLEX) { 1; }
    else { 0; }
}
################################################################################

=head2 isBgnextn - return 0 or 1 depending on whether current record is a bgnextn

=cut

sub isBgnextn
{
    my $self = shift;
    if ($self -> {'RecordType'} == $BGNEXTN) { 1; }
    else { 0; }
}
################################################################################

=head2 isEndextn - return 0 or 1 depending on whether current record is a endextn

=cut

sub isEndextn
{
    my $self = shift;
    if ($self -> {'RecordType'} == $ENDEXTN) { 1; }
    else { 0; }
}
################################################################################

=head2 isTapenum - return 0 or 1 depending on whether current record is a tapenum

=cut

sub isTapenum
{
    my $self = shift;
    if ($self -> {'RecordType'} == $TAPENUM) { 1; }
    else { 0; }
}
################################################################################

=head2 isTapecode - return 0 or 1 depending on whether current record is a tapecode

=cut

sub isTapecode
{
    my $self = shift;
    if ($self -> {'RecordType'} == $TAPECODE) { 1; }
    else { 0; }
}
################################################################################

=head2 isStrclass - return 0 or 1 depending on whether current record is a strclass

=cut

sub isStrclass
{
    my $self = shift;
    if ($self -> {'RecordType'} == $STRCLASS) { 1; }
    else { 0; }
}
################################################################################

=head2 isReserved - return 0 or 1 depending on whether current record is a reserved

=cut

sub isReserved
{
    my $self = shift;
    if ($self -> {'RecordType'} == $RESERVED) { 1; }
    else { 0; }
}
################################################################################

=head2 isFormat - return 0 or 1 depending on whether current record is a format

=cut

sub isFormat
{
    my $self = shift;
    if ($self -> {'RecordType'} == $FORMAT) { 1; }
    else { 0; }
}
################################################################################

=head2 isMask - return 0 or 1 depending on whether current record is a mask

=cut

sub isMask
{
    my $self = shift;
    if ($self -> {'RecordType'} == $MASK) { 1; }
    else { 0; }
}
################################################################################

=head2 isEndmasks - return 0 or 1 depending on whether current record is a endmasks

=cut

sub isEndmasks
{
    my $self = shift;
    if ($self -> {'RecordType'} == $ENDMASKS) { 1; }
    else { 0; }
}
################################################################################

=head2 isLibdirsize - return 0 or 1 depending on whether current record is a libdirsize

=cut

sub isLibdirsize
{
    my $self = shift;
    if ($self -> {'RecordType'} == $LIBDIRSIZE) { 1; }
    else { 0; }
}
################################################################################

=head2 isLibsecur - return 0 or 1 depending on whether current record is a libsecur

=cut

sub isLibsecur
{
    my $self = shift;
    if ($self -> {'RecordType'} == $LIBSECUR) { 1; }
    else { 0; }
}
################################################################################

################################################################################
## support functions

sub getRecordData
{
    my $self = shift;
    my $dt = $self -> {'DataType'};
    if ($dt==$NO_DATA)
    {
        return '';
    }
    elsif ($dt==$INTEGER_2 || $dt==$INTEGER_4 || $dt==$REAL_8)
    {
        my $stuff = $self -> {'CurrentDataList'};
        $stuff =~ s|^,||;
        return(split(/,/,$stuff));
    }
    elsif ($dt==$ACSII_STRING)
    {
        my $stuff = $self -> {'CurrentDataList'};
        $stuff =~ s|\0||g;
        return($stuff);
    }
    else ## bit_array
    {
        return ($self -> {'CurrentDataList'});
    }
}
################################################################################

sub readRecordTypeAndData
{
    my $self = shift;
    return ($RecordTypeStrings[$self -> {'RecordType'}],$self -> {'RecordData'});
}
################################################################################

sub skipGds2RecordData
{
    my $self = shift;
    $self -> readGds2RecordHeader() if ($self -> {'HEADER'} <= 0);
    $self -> {'HEADER'} = 0;
    $self -> {'INDATA'} = 1;
    my $bytesLeft = $self -> {'Length'} - 4; ## 4 should have been just read by readGds2RecordHeader
    my $data;
    read($self -> {'FileHandle'},$data,$bytesLeft);
    $self -> {'DataIndex'}=-1;
    return 1;
}
################################################################################

### return number of XY coords if XY record 
sub returnNumCoords
{
    my $self = shift;
    if ($self -> {'RecordType'} == $XY)  ## 4 byte signed integer
    {
        int(($self -> {'Length'} - 4) / 8);
    }
    else
    {
        0;
    }
}
################################################################################

sub roundNum
{
    my $self = shift;
    my $num = shift;
    my $places = shift;
    eval(sprintf("%.$places"."f\n",$num));
}
################################################################################

sub scaleNum($$)
{
    my $num=shift;
    my $scale=shift;
    die "1st number passed into scaleNum() must be an integer $!" if ($num !~ m|^-?\d+|);
    $num = $num * $scale;
    $num = int($num+0.5) if ($num =~ m|\.|);
    $num;
}
################################################################################

sub snapNum($$)
{
    my $num=shift;
    die "1st number passed into snapNum() must be an integer $!" if ($num !~ m|^-?\d+$|);
    my $snap=shift;
    my $snapLength = length("$snap");
    my $lean=1; ##init
    $lean = -1 if($num < 0);
    ## snap to grid..   
    my $littlePart=substr($num,-$snapLength,$snapLength);
    if($num<0)
    {
        $littlePart = -$littlePart;
    }
    $littlePart = int(($littlePart/$snap)+(0.5*$lean))*$snap;
    my $bigPart=substr($num,0,-$snapLength);
    if ($bigPart =~ m|^[-]?$|)
    {
        $bigPart=0;
    }
    else
    {
        $bigPart *= 10**$snapLength;
    }
    $num = $bigPart + $littlePart;
    $num;
}

sub DESTROY
{
    my $self = shift;
    #warn "DESTROYing $self";
}

################################################################################
## some vendor tools have trouble w/ negative angles and angles >= 360
## so we normalize to positive equivalent
################################################################################
sub posAngle($)
{
    my $angle = shift;
    $angle += 360.0 while ($angle < 0.0);
    $angle %= 360.0;
    $angle;
}

################################################################################
sub version() ## GDS2::version(); 
{
    return $GDS2::VERSION;
}

################################################################################
sub revision() ## GDS2::revision(); 
{
    return $GDS2::revision;
}


1;
}

################################################################################

__END__

=pod

=head1 Examples

  Layer change:
    here's a bare bones script to change all layer 59 to 66 given a file to
    read and a new file to create.
    #!/usr/local/bin/perl -w
    use strict;
    use lib "/lsi/home/ic/lib/perl";
    use GDS2;
    my $fileName1 = $ARGV[0];
    my $fileName2 = $ARGV[1];

    my $gds2File1 = new GDS2(-fileName => $fileName1);
    my $gds2File2 = new GDS2(-fileName => ">$fileName2");

    while (my $record = $gds2File1 -> readGds2Record) 
    {
        if ($gds2File1 -> returnLayer == 59)
        {
            $gds2File2 -> printLayer(-num=>66);
        }
        else
        {
            $gds2File2 -> printRecord(-data=>$record);
        }
    }


  Gds2 dump:
    here's a program to dump the contents of a stream file.
    #!/usr/local/bin/perl -w
    use lib "/lsi/home/ic/lib/perl";
    use GDS2;
    $\="\n";

    my $gds2File = new GDS2(-fileName=>$ARGV[0]);
    while ($gds2File -> readGds2Record) 
    {
        print $gds2File -> returnRecordAsString;
    }


  Create a complete GDS2 stream file from scratch:
    #!/usr/local/bin/perl -w
    use lib "/lsi/home/ic/lib/perl";
    use GDS2;
    my $gds2File = new GDS2(-fileName=>'>test.gds');
    $gds2File -> printInitLib(-name=>'testlib'); 
    $gds2File -> printBgnstr(-name=>'test');
    $gds2File -> printPath(
                    -layer=>6,
                    -pathType=>0,
                    -width=>2.4,
                    -xy=>[0,0, 10.5,0, 10.5,3.3],
                 );
    $gds2File -> printSref(
                    -name=>'contact',
                    -xy=>[4,5.5],
                 );
    $gds2File -> printAref(
                    -name=>'contact',
                    -columns=>2,
                    -rows=>3,
                    -xy=>[0,0],
                 );
    $gds2File -> printEndstr;
    $gds2File -> printBgnstr(-name => 'contact'); 
    $gds2File -> printBoundary(
                    -layer=>10,
                    -xy=>[0,0, 1,0, 1,1, 0,1],
                 );
    $gds2File -> printEndstr;
    $gds2File -> printEndlib();

=head1 GDS2 Stream Format 

 #########################################################################################
 # 
 # Gds2 stream format is composed of variable length records. The mininum
 # length record is 4 bytes. The 1st 2 btyes of a record contain a count (in 8 bit
 # bytes) of the total record length.  The 3rd byte of the header is the record
 # type. The 4th byte describes the type of data contained w/in the record. The
 # 5th through last bytes are data.
 # 
 # If the output file is a mag tape, then the records of the library are written
 # out in 2048-byte physical blocks. Records may overlap block boundaries.
 # For this reason I think gds2 is often padded with null bytes so that the 
 # file size ends up being a multiple of 2048.
 # 
 # A null word consists of 2 consecutive zero bytes. Use null words to fill the
 # space between:
 #     o the last record of a library and the end of its block
 #     o the last record of a tape in a mult-reel stream file.
 # 
 # DATA TYPE        VALUE  RECORD
 # ---------        -----  -----------------------
 # no data present     0   4bytes long
 #
 # Bit Array           1   2bytes long
 #
 # 2byte Signed Int    2  SMMMMMMM MMMMMMMM  -> S - sign ;  M - magnitude. 
 #                        Twos complement format, with the most significant byte first.
 #                        I.E.
 #                        0x0001 = 1
 #                        0x0002 = 2
 #                        0x0089 = 137
 #                        0xffff = -1
 #                        0xfffe = -2
 #                        0xff77 = -137
 # 
 # 4byte Signed Int    3  SMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM 
 #
 # 8byte Real          5  SEEEEEEE MMMMMMMM MMMMMMMM MMMMMMMM E-expon in excess-64 
 #                        MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM representation 
 #
 #                        Mantissa == pos fraction >=1/16 && <1 bit 8==1/2, 9==1/4 etc...
 #                        The first bit is the sign (1 = negative), the next 7 bits
 #                        are the exponent, you have to subtract 64 from this number to
 #                        get the real value. The next seven bytes are the mantissa in 
 #                        4 word floating point representation.
 #                
 #
 # string              6  odd length strings must be padded w/ null character and 
 #                        byte count++
 # 
 #########################################################################################


=head1 Backus-naur representation of GDS2 Stream Syntax

 ################################################################################
 #  <STREAM FORMAT>::= HEADER BGNLIB [LIBDIRSIZE] [SRFNAME] [LIBSECR]           #
 #                     LIBNAME [REFLIBS] [FONTS] [ATTRTABLE] [GENERATIONS]      #
 #                     [<FormatType>] UNITS {<structure>}* ENDLIB               #
 #                                                                              #
 #  <FormatType>::=    FORMAT | FORMAT {MASK}+ ENDMASKS                         #
 #                                                                              #
 #  <structure>::=     BGNSTR STRNAME [STRCLASS] {<element>}* ENDSTR            #
 #                                                                              #
 #  <element>::=       {<boundary> | <path> | <SREF> | <AREF> | <text> |        #
 #                      <node> | <box} {<property>}* ENDEL                      #
 #                                                                              #
 #  <boundary>::=      BOUNDARY [ELFLAGS] [PLEX] LAYER DATATYPE XY              #
 #                                                                              #
 #  <path>::=          PATH [ELFLAGS] [PLEX] LAYER DATATYPE [PATHTYPE]          #
 #                     [WIDTH] XY                                               #
 #                                                                              #
 #  <SREF>::=          SREF [ELFLAGS] [PLEX] SNAME [<strans>] XY                #
 #                                                                              #
 #  <AREF>::=          AREF [ELFLAGS] [PLEX] SNAME [<strans>] COLROW XY         #
 #                                                                              #
 #  <text>::=          TEXT [ELFLAGS] [PLEX] LAYER <textbody>                   #
 #                                                                              #
 #  <textbody>::=      TEXTTYPE [PRESENTATION] [PATHTYPE] [WIDTH] [<strans>] XY #
 #                     STRING                                                   #
 #                                                                              #
 #  <strans>::=        STRANS [MAG] [ANGLE]                                     #
 #                                                                              #
 #  <node>::=          NODE [ELFLAGS] [PLEX] LAYER NODETYPE XY                  #
 #                                                                              #
 #  <box>::=           BOX [ELFLAGS] [PLEX] LAYER BOXTYPE XY                    #
 #                                                                              #
 #  <property>::=      PROPATTR PROPVALUE                                       #
 ################################################################################


=head1 GDS2 Stream Record Datatypes

 ################################################################################
 NO_DATA       =  0;
 BIT_ARRAY     =  1;
 INTEGER_2     =  2;
 INTEGER_4     =  3;
 REAL_4        =  4; ## NOT supported, never really used
 REAL_8        =  5;
 ACSII_STRING  =  6;
 ################################################################################


=head1 GDS2 Stream Record Types 

 ################################################################################
 HEADER        =  0;   ## 2-byte Signed Integer
 BGNLIB        =  1;   ## 2-byte Signed Integer
 LIBNAME       =  2;   ## ASCII String
 UNITS         =  3;   ## 8-byte Real
 ENDLIB        =  4;   ## no data present
 BGNSTR        =  5;   ## 2-byte Signed Integer
 STRNAME       =  6;   ## ASCII String
 ENDSTR        =  7;   ## no data present
 BOUNDARY      =  8;   ## no data present
 PATH          =  9;   ## no data present
 SREF          = 10;   ## no data present
 AREF          = 11;   ## no data present
 TEXT          = 12;   ## no data present
 LAYER         = 13;   ## 2-byte Signed Integer
 DATATYPE      = 14;   ## 2-byte Signed Integer
 WIDTH         = 15;   ## 4-byte Signed Integer
 XY            = 16;   ## 4-byte Signed Integer
 ENDEL         = 17;   ## no data present
 SNAME         = 18;   ## ASCII String
 COLROW        = 19;   ## 2 2-byte Signed Integer <= 32767
 TEXTNODE      = 20;   ## no data present
 NODE          = 21;   ## no data present
 TEXTTYPE      = 22;   ## 2-byte Signed Integer
 PRESENTATION  = 23;   ## Bit Array. One word (2 bytes) of bit flags. Bits 11 and 
                       ##   12 together specify the font 00->font 0 11->font 3.
                       ##   Bits 13 and 14 specify the vertical presentation, 15
                       ##   and 16 the horizontal presentation. 00->'top/left' 01->
                       ##   middle/center 10->bottom/right bits 1-10 were reserved 
                       ##   for future use and should be 0.
 SPACING       = 24;   ## discontinued
 STRING        = 25;   ## ASCII String <= 512 characters
 STRANS        = 26;   ## Bit Array: 2 bytes of bit flags for graphic presentation
                       ##   The 1st (high order or leftmost) bit specifies
                       ##   reflection. If set then reflection across the X-axis
                       ##   is applied before rotation. The 14th bit flags 
                       ##   absolute mag, the 15th absolute angle, the other bits
                       ##   were reserved for future use and should be 0.
 MAG           = 27;   ## 8-byte Real
 ANGLE         = 28;   ## 8-byte Real
 UINTEGER      = 29;   ## UNKNOWN User int, used only in Calma V2.0
 USTRING       = 30;   ## UNKNOWN User string, used only in Calma V2.0
 REFLIBS       = 31;   ## ASCII String
 FONTS         = 32;   ## ASCII String
 PATHTYPE      = 33;   ## 2-byte Signed Integer
 GENERATIONS   = 34;   ## 2-byte Signed Integer
 ATTRTABLE     = 35;   ## ASCII String
 STYPTABLE     = 36;   ## ASCII String "Unreleased feature"
 STRTYPE       = 37;   ## 2-byte Signed Integer "Unreleased feature"
 EFLAGS        = 38;   ## BIT_ARRAY  Flags for template and exterior data.  
                       ## bits 15 to 0, l to r 0=template, 1=external data, others unused
 ELKEY         = 39;   ## INTEGER_4  "Unreleased feature"
 LINKTYPE      = 40;   ## UNKNOWN    "Unreleased feature"
 LINKKEYS      = 41;   ## UNKNOWN    "Unreleased feature"
 NODETYPE      = 42;   ## INTEGER_2  Nodetype specification. On Calma this could be 0 to 63,
                       ##   GDSII allows 0 to 255. Of course a 16 bit integer allows up to 65535...
 PROPATTR      = 43;   ## INTEGER_2  Property number.
 PROPVALUE     = 44;   ## STRING     Property value. On GDSII, 128 characters max, unless an 
                       ##   SREF, AREF, or NODE, which may have 512 characters.
 BOX           = 45;   ## NO_DATA    The beginning of a BOX element.
 BOXTYPE       = 46;   ## INTEGER_2  Boxtype specification.
 PLEX          = 47;   ## INTEGER_4  Plex number and plexhead flag. The least significant bit of 
                       ##   the most significant byte is the plexhead flag.
 BGNEXTN       = 48;   ## INTEGER_4  Path extension beginning for pathtype 4 in Calma CustomPlus. 
                       ##   In database units, may be negative.
 ENDEXTN       = 49;   ## INTEGER_4  Path extension end for pathtype 4 in Calma CustomPlus. In 
                       ##   database units, may be negative.
 TAPENUM       = 50;   ## INTEGER_2  Tape number for multi-reel stream file.
 TAPECODE      = 51;   ## INTEGER_2  Tape code to verify that the reel is from the proper set. 
                       ##   12 bytes that are supposed to form a unique tape code.
 STRCLASS      = 52;   ## BIT_ARRAY  Calma use only. 
 RESERVED      = 53;   ## INTEGER_4  Used to be NUMTYPES per Calma GDSII Stream Format Manual, v6.0.
 FORMAT        = 54;   ## INTEGER_2  Archive or Filtered flag.  0: Archive 1: filtered
 MASK          = 55;   ## STRING     Only in filtered streams. Layers and datatypes used for mask 
                       ##   in a filtered stream file. A string giving ranges of layers and datatypes
                       ##   separated by a semicolon. There may be more than one mask in a stream file.
 ENDMASKS      = 56;   ## NO_DATA    The end of mask descriptions.
 LIBDIRSIZE    = 57;   ## INTEGER_2  Number of pages in library director, a GDSII thing, it seems 
                       ##   to have only been used when Calma INFORM was creating a new library.
 SRFNAME       = 58;   ## STRING     Calma "Sticks"(c) rule file name.
 LIBSECUR      = 59;   ## INTEGER_2  Access control list stuff for CalmaDOS, ancient. INFORM used
                       ##   this when creating a new library. Had 1 to 32 entries with group 
                       ##   numbers, user numbers and access rights.


=cut

