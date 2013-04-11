#!/usr/local/bin/perl
# Execute a bash script with html arguments.
# First argument is name of script to execute, the rest are arguments to the script.

use CGI qw(:standard);
print header();

#print @ARGV;
# To get the numerical result (in most cases, the error code) of the command use the $res variable...
my $input = param("input");
#my $input = "blah";
system("echo '$input' > output.txt");
#print $res;


# To get the string output result of the command, just look at the file in C:/output...
open(SYS_OUT, "output.txt") or die "Could not open the output";
my $output = join "", <SYS_OUT>;
close SYS_OUT;
$output =~ s/\n/\n<BR>/g;
print $output;

#print <>;

print end_html();