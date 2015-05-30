#!/usr/bin/perl
eval 'exec $PERL_CMD -S $0 ${1+"$@"}'
if 0;

#####################################################################
## Source      : fix_edk.pl
##
## Description : Read a binary file and produce ascii
##		 files {bin*.dat} which can be read by readmemh
##		 
## Usage       : fix_edk.pl
##
#######################################################################

use FileHandle;
use Getopt::Long;
use Fcntl 'SEEK_SET';
use strict;


my $xilinx_edk = $ENV{XILINX_EDK};
my $dv_root = $ENV{DV_ROOT};

#  Check Environment Variables
die "ERROR:  Environment Variable XILINX_EDK is not defined\n"
    unless (defined($xilinx_edk));

die "ERROR:  Environment Variable DV_ROOT is not defined\n"
    unless (defined($dv_root));

#  Check Environment Variables point to a valid place
die "ERROR:  Enivronment Variable XILINX_EDK does not point to a valid directory\n"
    unless (-d "$xilinx_edk");

die "ERROR:  Enivronment Variable DV_ROOT does not point to a valid directory\n"
    unless (-d "$dv_root");



# Code to fix the MicroBlaze FSL Read Problem.

my $driver_dir = "standalone_v2_00_a";
my $path_to_driver = "$xilinx_edk/sw/lib/bsp";
my $path_to_edk_proj = "$dv_root/design/sys/edk";

die "ERROR:  EDK driver directory does not exist:  \n" .
    "    $path_to_driver/$driver_dir\n"
    unless (-d "$path_to_driver/$driver_dir");

die "ERROR:  EDK project directory does not exist:  \n" .
    "    $path_to_edk_proj\n"
    unless (-d "$path_to_edk_proj");

mkdir "$path_to_edk_proj/bsp"
    unless (-d "$path_to_edk_proj/bsp");

print "fix_edk.pl:  Copying MicroBlaze Driver\n";
system "cp -rf $path_to_driver/$driver_dir $path_to_edk_proj/bsp";

print "fix_edk.pl:  Fixing MicroBlaze Driver\n";

my $file_to_fix = "$path_to_edk_proj/bsp/$driver_dir/src/microblaze/mb_interface.h";
system "mv -f $file_to_fix ${file_to_fix}.bak";

#  Open Input File
my $inFH = new FileHandle "${file_to_fix}.bak", "r";
die "Unable to open ${file_to_fix}.bak\n" unless (defined $inFH);

# Open Output File
my $outFH = new FileHandle "> $file_to_fix";
die "Unable to open $file_to_fix\n" unless (defined $outFH);

while (<$inFH>) {
    if (/define getfsl/) {
	s/"get\\t/"nop; get\\t/;
    }
    elsif (/define ngetfsl/) {
	s/"nget\\t/"nop; nget\\t/;
    }
    elsif (/define cgetfsl/) {
	s/"cget\\t/"nop; cget\\t/;
    }
    elsif (/define ncgetfsl/) {
	s/"ncget\\t/"nop; ncget\\t/;
    }

    print $outFH $_;
}

close $inFH;
close $outFH;

print "fix_edk.pl:  Done Fixing MicroBlaze Driver\n\n";


# Code to fix the Constraints in the FSL FIFO

# Check that FSL FIFO exists
my $fsl_name = "fsl_v20_v2_11_a";
my $path_to_fsl = "hw/XilinxProcessorIPLib/pcores/$fsl_name";
my $path_to_pcores = "design/sys/edk/pcores";

die "ERROR:  Can't find directory\n" .
    "    \$XILINX_EDK/$path_to_fsl\n"
    unless (-d "$xilinx_edk/$path_to_fsl");

die "ERROR:  Can't find directory\n" .
    "    \$DV_ROOT/$path_to_pcores\n"
    unless (-d "$dv_root/$path_to_pcores");

die "ERROR:  Directory  \$DV_ROOT/$path_to_pcores\n" .
    "    already exists!\n"
    if (-d "$dv_root/$path_to_pcores/$fsl_name");

print "fix_edk.pl:  Copying fsl pcore from EDK installation\n";
system "cp -r $xilinx_edk/$path_to_fsl $dv_root/$path_to_pcores";

$file_to_fix = "$dv_root/$path_to_pcores/$fsl_name/data/fsl_v20_v2_1_0.tcl";

system "mv $file_to_fix ${file_to_fix}.bak";

print "fix_edk.pl:  Fixing timing constraints on fsl pcore\n";

#  Open Input File
$inFH = new FileHandle "${file_to_fix}.bak", "r";
die "Unable to open ${file_to_fix}.bak\n"
    unless (defined $inFH);

# Open Output File
$outFH = new FileHandle "> $file_to_fix";
die "Unable to open $file_to_fix for Writing\n"
    unless (defined $outFH);

while (<$inFH>) {
    if (/TIMESPEC/  && /TS_ASYNC_FIFO/) {
	print $outFH "# ";
	print $outFH  $_;
    }
    else {
	print $outFH $_;
    }
}

close $inFH;
close $outFH;

print "fix_edk.pl:  Done fixing timing constraints on fsl pcore\n\n";

