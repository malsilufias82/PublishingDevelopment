#!/usr/bin/perl -w
use warnings;
use Encode qw(encode_utf8);
use HTTP::Request;
use JSON::MaybeXS qw(encode_json);
#use REST::Client;
use MIME::Base64;
use LWP::UserAgent; # [Welcho] Add this

my $username = '';
my $password = '';

my $url = 'https://testapi.com/webapi/AddData';
#my $header = ['Content-Type' => 'application/json; charset=UTF-8'];
my $header = {Accept => 'application/json', Authorization => 'Basic ' . encode_base64($username . ':' . $password)};
my $data = {GroupName=> 'City', Member=> 'New York'};
my $encoded_data = encode_utf8(encode_json($data));
my $r = HTTP::Request->new('POST', $url, $header, $encoded_data);

# [Welcho] comment this print $r->responseContent();

#[Welcho]
my $ua = LWP::UserAgent->new();
my $res = $ua->request($r);
print $res->decoded_content;