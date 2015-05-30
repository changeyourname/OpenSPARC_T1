#!/usr/bin/perl
# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: bin2ascii.pl
# Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
# 
# The above named program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License version 2 as published by the Free Software Foundation.
# 
# The above named program is distributed in the hope that it will be 
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public
# License along with this work; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
# 
# ========== Copyright Header End ============================================
eval 'exec $PERL_CMD -S $0 ${1+"$@"}'
if 0;

#####################################################################
## Source      : bin2ascii.pl
##
## Description : Read a binary file and produce ascii
##		 files {bin*.dat} which can be read by readmemh
##		 
## Usage       : bin2ascii.pl [-nstripes <num-stripes]  [-stsize stripe-size>]
##			[-offset <DRAM-Address>]
##			<source-bin> <ascii-file-base> 
##
#######################################################################

use FileHandle;
use Getopt::Long;
use Fcntl 'SEEK_SET';
use strict;

my $usage = "Usage : bin2ascii [-nstripes <num-stripes>] [-stsize <stripe_width>]\n\t[-mdatawidth <Model Data Width>] [-offset <DRAM Address>]\n\t[-littleEnd]\n\t<source-elf> <ascii-file-basename>\n" .
	"\t\t-nstripes:    Number of separate models or output files\n" .
	"\t\t-stsize:      Width in Bytes of each stripe\n" .
	"\t\t-littleEnd:   Data within a stripe is little-endian\n" .
	"\t\t-mdatawidth:  Width of model memory element (multiple of stsize)\n" .
	"\t\t-offset:      Offset in the binary file to start converting\n\n";

my $numPartitions = 2;
my $stripeSize = 2;
my $littleEnd = 0;
my $dramOffset = 0;
my $dramOffsetText = "";
my $modelDataWidth = 1;
my $sourceFile = "";
my $asciiFileBase = "";

my $getoptResults = GetOptions(
	'nstripes=i' => \$numPartitions,
	'stsize=i' => \$stripeSize,
#	'offset=o' => \$dramOffset,
	'offset=s' => \$dramOffsetText, #  Will have to specify decimal arg.
					# xilinx perl doesn't support 'o'
	'littleEnd' => \$littleEnd,
	'mdatawidth=i' => \$modelDataWidth);

die $usage if (!$getoptResults || @ARGV < 2);

die "Error: partitions < 1 \n\n$usage" if ($numPartitions < 1);
die "Error: size < 1\n\n$usage"        if ($stripeSize < 1);

if ($dramOffsetText ne "") {
    $dramOffset = oct($dramOffsetText);
}

#  Left-over arguments after getOptions finishes
$sourceFile = @ARGV[0];
$asciiFileBase = @ARGV[1];


my $inFH;
my @outFH;
my $thisFH;
my $buffer;
my $n;
my $count;
my $char1;
my $i;

print "Source File:  $sourceFile\n";
print "Dest File(s): $asciiFileBase\[0-9\].dat\n";
print "Num Partitions:  $numPartitions\n";
print "Stripe size (B): $stripeSize\n";
print "Little-endian:   $littleEnd\n";
print "Model data width: $modelDataWidth  * Stripe size (B)\n";
print "DRAM Offset:  $dramOffset\n";
print "\n";

$inFH = new FileHandle "$sourceFile", "r";

#  Open Input File
die "Unable to open $sourceFile\n" unless (defined $inFH);
binmode $inFH;

# Open Output files:
for ($i=0; $i <$numPartitions; $i++) {
    my $asciiFileName = sprintf("%s%02d.dat", $asciiFileBase, $i);
    $outFH[$i] = new FileHandle "> $asciiFileName";
    die "Unable to open $asciiFileName\n" unless (defined $outFH[$i]);

    $thisFH = $outFH[$i];
    print $thisFH ("\@00000000\n");
}



sysseek( $inFH, $dramOffset, SEEK_SET );

my $pNum = 0;
my $stripeByte = 0;
my $dataNum = 0;
my @dataBuffers;   # Indexed by [fileno][dataNum]

$thisFH = $outFH[$pNum];

while ( ($n = read( $inFH, $buffer, 1 )) != 0 ) {
    $char1 = ord $buffer;
    if ($littleEnd) {
	$dataBuffers[$pNum][$dataNum] = sprintf ("%.2x", $char1) .
	    $dataBuffers[$pNum][$dataNum];
    }
    else {
	$dataBuffers[$pNum][$dataNum] .= sprintf ("%.2x", $char1);
    }

    $stripeByte++;

    if ($stripeByte >= $stripeSize) {
	if ($dataNum >= $modelDataWidth - 1) {
	    for ($i=$modelDataWidth-1; $i >= 0; $i--) {
		printf $thisFH ("%s", $dataBuffers[$pNum][$i]);
		$dataBuffers[$pNum][$i] = "";
	    }
	    printf $thisFH ("\n");
	}

	$stripeByte = 0;
	$pNum++;
	$thisFH = $outFH[$pNum];

	if ($pNum >= $numPartitions) {
	    $pNum = 0;
	    $thisFH = $outFH[$pNum];

	    $dataNum++;
	    if ($dataNum >= $modelDataWidth) {
		$dataNum = 0;
	    }
	}
    }
}

close $inFH;
for ($i=0; $i <$numPartitions; $i++) {
    close $outFH[$i];
}

