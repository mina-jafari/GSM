#!/usr/bin/perl

###############################################################################
# Mina Jafari, May 2015                                                       #
# Purpose: This script searches for all the string files in the directory you #
# have ran it and its subdirectories. It writes the name of the directory and #
# the output of "status" executable to a file named stringSummary.csv So you  #
# can open it with excel.                                                     #
###############################################################################

use strict;
use warnings;

my $counter = 0; 
my $path = shift || '.';
my @directories;
my @direc;
use Cwd;
my $pwd = getcwd();
my $outFile = "stringSummary.csv";
my @outPuts;
my @array;

traverse($path);

#save the output of status exe in the outPuts array and copies the files to
#local machine
#my $desDir = "141.211.71.1:Desktop/string"; #this should be entered manually
#my $num  = sprintf("%04d", 0001);
for my $j (@directories)
{
    chdir "$j";
    my $output = `./status`;
    $j =~ s/\//-/g;
#    system "scp -p stringfile.xyz0001 $desDir/$num-$j.xyz"; #uncomment to copy files
#    $num++;
    my @directory = split /\n/, $output;
    my $dir2 = $directory[1];
    $dir2 =~ s/ +/,/g;
    push @outPuts, $dir2;
    chdir "$pwd";
}

#combines the two arrays (outPuts and directories)
for my $i (0..$counter-1)
{
    push @array, $directories[$i];
    push @array, $outPuts[$i];
    $i++;
}

#writes to the file
if (-e $outFile) 
{
    print "An output file with the same name already exists. 
Output of this run will be appended to the existing file.\n";
    sleep 5;
}
open FILE, ">>", "$outFile" or die "can't open \n";
print FILE "\n\n";
print FILE "            RESULTS         ";
print FILE "\n\n";
for my $k (@array)
{
    print FILE $k, "\n";
    #print "\n\n";
}
close (FILE);

print("Total number of files = ", $counter, "\n");

#definition of traverse subroutine
sub traverse 
{
    my ($thing) = @_;
    if ($thing =~ m/stringfile.xyz0001$/)
    {
        $counter++;
        #saves the path to the directories containing stringfiles to
        #@directories array
        my $slashes = ($thing =~ tr/\///)-1;
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
