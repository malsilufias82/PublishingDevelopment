#!/usr/bin/perl -w
use strict;
use LWP;

my $browser = LWP::UserAgent->new;
my $url = 'https://www.w3schools.com/sql/sql_constraints.asp';

#Issue request, with an HTTP header
my $response = $browser->get($url,
  'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 7.0)',
);
die 'Error getting $url' unless $response->is_success;

print 'Content type is ', $response->content_type;
print 'Content is:';

open(OUTFILE, ">getcontent.html");
print OUTFILE $response->content;
close(OUTFILE);

# print $response->content;