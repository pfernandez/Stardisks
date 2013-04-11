#!/usr/local/bin/perl
# Execute a bash script with html arguments.
# First argument is name of script to execute, the rest are arguments to the script.

use CGI qw(:standard);
print header();


# parse and store intput to array
@input = param("input");

system(">test.txt");
# sequentially execute command with array elements
foreach $i (1 .. $#input)
{
   system("./$input[0] $input[$i]");
}

print end_html();