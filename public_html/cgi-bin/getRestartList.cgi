#!/usr/local/bin/perl
# Execute a bash script with html arguments.
# First argument is name of script to execute, the rest are arguments to the script.


use CGI qw(:standard);
#print header(); # will not allow redirect


# parse and store intput to array
@input = param("input");

open (file, '>/home1/fernande/public_html/stardisks/possibleRestarts.html');
print file "<html><body><h2>Scanning files... try checking back in a few minutes. :)</h2><p>It's okay to leave this page or close your browser while you wait. You can either hit refresh or return to this address to see if it's ready.</p></body></html>";
close (file); 

system("ssh -f PaulFernandez\@dynamo.uoregon.edu '~/./generateRestartList.sh $input[0] $input[1] $input[2] $input[3] > restarts.out'");

print redirect('http://uoregon.edu/~fernande/stardisks/possibleRestarts.html');

print end_html();
