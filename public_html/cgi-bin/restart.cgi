#!/usr/local/bin/perl
#
# Restart models selected from list generator.

use CGI qw(:standard);
print header();


# parse and store intput to array
@input  = param("input");
@input2 = param("input2"); 

system(">fromStep.list");
system(">fromStart.list");

print("<center></br></br></br></br></br><b>The following models should be restarted from the last backup:</b></br></br>");

# sequentially execute command with array elements
foreach $i (1 .. $#input)
{
	print("$input[$i]</br>");
	system("./$input[0] $input[$i]");
}


print("</br></br></br><b>The following models should be restarted from the beginning:</b></br></br>");

foreach $i (1 .. $#input2)
{
	print("$input2[$i]</br>");
	system("./$input2[0] $input2[$i]");
}

print("</br></br></br><form><input type=\"button\" value=\"Home\" onclick=\"window.location.href='http://uoregon.edu/~fernande'\"></form></center>");

print end_html();