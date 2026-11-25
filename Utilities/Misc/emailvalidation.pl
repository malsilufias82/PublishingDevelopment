#!/usr/bin/perl

# my $email = "john.doe\@acme.org";
my $email = "saiful-malsi_lufias\@yahoo.co.in";

# if ($email =~ /^([a-zA-Z][\w\_\.]{6,15})\@([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,4})$/) {
if ($email =~ /^([a-zA-Z][\w\_\.\-]+)\@([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,4})$/) {
    print "Valid email\n";
} else {
    print "Not valid email\n";
}