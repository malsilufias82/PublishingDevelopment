#!/usr/bin/perl -w
use strict;
use warnings;
use feature 'say';
use LWP::UserAgent;
use HTML::Tree;

  my $url = 'https://berniesanders.com/issues/racial-justice/';
  my $ua  = LWP::UserAgent->new();
  $ua->agent(
    'Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Fire
+fox/31.0'
  );
  my $response = $ua->get($url);
  my $content  = $response->content;
  if ( $content =~ m/enemy/i ) {
    say "enemy found";
  }
  else {
    my $tree = HTML::Tree->new();
    $tree->parse($content);
    print $tree->as_text;
  }
