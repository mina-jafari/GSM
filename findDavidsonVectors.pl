#!/usr/bin/perl

################################################################################
## Mina Jafari, May 2016                                                       #
## Purpose: This script searches for all the paragsm files in the directory and#
## subdirectories. It finds the converged Dvidson vectors. The output is saved #
## in a file named ????????.csv.
################################################################################

use strict;
use warnings;

my $counter = 0;
my $path = shift || '.';
my @directories;
use Cwd;
my $pwd = getcwd();
my $outFile = "DavidsonVectors.csv";
my @outPuts;

traverse($path);

for my $j (@directories)
{
    my @output;
    chdir "$j";
    $j =~ s/\//-/g;
    $j .= ",";
    open FILE, 'paragsm0001' or die $!;
    my $i = 0;
    while (<FILE>)
    {
        if ($_ =~ /updating vector:/)
        {
            push @output, $j;
            $i += 1;
            if ($i % 3 != 0)
            {
                tr/\n/,/ for $_;
                #$_ .= ",";
            }
            my @temp = split (':', $_);
            push @output, $temp[2];
        }
    }
    close FILE;
    #tr/\n/,/ for @output;
    push @outPuts, @output;
    #print @output;
    chdir "$pwd";
    #print @outPuts;
}

#writes to the file
if (-e $outFile) 
{
    print "An output file with the same name already exists. 
Output of this run will be appended to the existing file.\n";
    sleep 5;
}
open FILE, ">>", "$outFile" or die "can't open \n";
#print FILE "\n\n";
print FILE "directory, vector1, vector2, vector3";
print FILE "\n";
for my $k (@outPuts)
{
    print FILE $k;
    #print "\n\n";
}
close (FILE);

#definition of traverse subroutine
sub traverse 
{
    my ($thing) = @_; 
    if ($thing =~ m/paragsm0001/)
    {   
        $counter++;
        #saves the path of the directories containing gradient files to
        #@directories array
        my $slashes = ($thing =~ tr/\///) - 1;
        my @directory = split /\//, $thing;
        my @dir2 = @directory[1..$slashes];
        my $dir3 = join '/', @dir2;
        push @directories, $dir3;
    }   

    return if not -d $thing;
    opendir my $dh, $thing or die;
    while (my $sub = readdir $dh) 
    {   
        next if $sub eq '.' or $sub eq '..';
        traverse("$thing/$sub");
    }   
    close $dh;
}
