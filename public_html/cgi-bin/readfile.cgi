#!/usr/local/bin/perl


use CGI qw(:standard);
print header();

open(SYS_OUT, "output.txt") or die "Could not open the output";
my $output = join "", <SYS_OUT>;
close SYS_OUT;
print $output;

print end_html();