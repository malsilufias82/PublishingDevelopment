#!/usr/bin/perl -w
use strict;

use HTTP::Request;
use HTTP::Headers;
use LWP::UserAgent;
# use HTTP::Request::Common;
use Cwd;

my $mycurrentdir=getcwd;

my $url = 'https://bms.in-beta.link/jobfeed';
my $ua  = LWP::UserAgent->new();
$ua->agent('Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/31.0');

# Location of local file
my $file_path = "$mycurrentdir/BMS_POST.xml";

# Make the POST request
my $response = $ua->post($url,
    Content_Type => 'application/xml',
    Content => [
        file => [$file_path],
    ],
);

# my $request = HTTP::Request::Common::POST($url,
    # Content_Type => 'text/xml',
    # Content => [
        # file => [$file_path],
    # ],
# );

###$request = HTTP::Request::Common::POST( $url, [ %data ] );
# my $response = $ua->request($request);

die "$url error: ", $response->status_line
	unless $response->is_success;
die "Weird content type at $url -- ", $response->content_type
	unless $response->content_type eq 'application/xml';

open(OUTFILE, ">postcontent.xml");
print OUTFILE $response->content;
close(OUTFILE);

# if( $response->content =~ m{AltaVista found ([0-9,]+) results} ) {
  ###The substring will be like "AltaVista found 2,345 results"
  # print "$word: $1\n";
# } else {
  # print "Couldn't find the match-string in the response\n";
# }