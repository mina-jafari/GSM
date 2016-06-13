#!/usr/bin/perl

################################################################################
# Mina Jafari, June 2015                                                       #
# Purpose: This script combines mutiple string files into one output file.     #
# There is no limit for the number of input files. The input files should be   #
# fed to the script using command line.                                        #
################################################################################

use warnings;
use strict;
use Tie::File;

my $outFile = "combined.xyz";
my $numOfAtoms = 0;
my @files = @ARGV;
my $currentEnergy = 0;
my $nextEnergy = 0;

if (!$ARGV[0] || !$ARGV[1])
{
    print STDERR "Usage: combine.pl <file1> <file2> <...>\n";
}
else
{
    print "Enter the name of output file <outfile.xyz>\n";
    $outFile = <STDIN>; # if (<STDIN>);   #This is a bug, user input should be
                                          #validated
    chomp $outFile;
    catenate();
    replaceEnergy($outFile);
}

sub catenate
{
    open FH, ">", $outFile or die "can't open output file\n";
    for my $i (@files)
    {
        open FILE, "<$i";
        $numOfAtoms = <FILE>;
        chomp $numOfAtoms;
        print FH $numOfAtoms, "\n";
        while (<FILE>)
        {
            chomp $_;
            print FH $_, "\n";
        }
        close(FILE);
    }
    close(FH);
}

sub replaceEnergy
{
    tie my @linesInFile, 'Tie::File', $outFile or die "$!\n";
    $currentEnergy = $linesInFile[((getNumOfNodes(0)-1)*($numOfAtoms+2)) + 1];
    my $lineCounter = ((getNumOfNodes(0))*($numOfAtoms+2)) + 1;
    my $i = 0;
    my $j = 1;
        for ($j=1; $j<(@files);)
        {
            for ($i=0; $i<getNumOfNodes($j);) 
            {
                $linesInFile[$lineCounter + $i*($numOfAtoms+2)] += $currentEnergy;
                $nextEnergy = $linesInFile[$lineCounter + $i*($numOfAtoms+2)];
                $i++;
            }
            $currentEnergy = $nextEnergy;
            $lineCounter += (getNumOfNodes($j)*($numOfAtoms+2));
            $j++;
        }
}

sub getNumOfNodes
{
    my $k = shift @_;
    my $nodes = 0;
    open FH, "<$files[$k]";
    while (my $line = <FH>)
    {
        ++$nodes if $line =~ /$numOfAtoms/;
    }
    close(FH);
    return $nodes;
}
