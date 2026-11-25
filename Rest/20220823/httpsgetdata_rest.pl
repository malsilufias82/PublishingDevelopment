#!/usr/bin/perl -w
use strict;
use REST::Client;


=gett
#The basic use case
my $client = REST::Client->new();
$client->GET('http://example.com/dir/file.xml');

# print $client->responseContent();
############################################
## Store the data received in a variable and will generate a file in html format
my $filestr = $client->responseContent();

# open(OUTFILE, ">getcontent.html");
# print OUTFILE "$filestr";
# close(OUTFILE);
############################################

#A host can be set for convienience
$client->setHost('http://example.com');
$client->PUT('/dir/file.xml', '<example>new content</example>');
# if( $client->responseCode() eq '200' ){
#     print "Updated\n";
# }
my $responsecode = $client->responseCode();
if( $responsecode eq '200' ){
    print "$responsecode\n";
}

#custom request headers may be added
$client->addHeader('CustomHeader', 'Value');
  
#response headers may be gathered
print $client->responseHeader('ResponseHeader');

#X509 client authentication
$client->setCert('/path/to/ssl.crt');
$client->setKey('/path/to/ssl.key');
  
#add a CA to verify server certificates
$client->setCa('/path/to/ca.file');
  
#you may set a timeout on requests, in seconds
$client->setTimeout(10);
  
#options may be passed as well as set
$client = REST::Client->new({
        host    => 'https://example.com',
        # cert    => '/path/to/ssl.crt',
        # key     => '/path/to/ssl.key',
        # ca      => '/path/to/ca.file',
        timeout => 10,
    });
$client->GET('/dir/file', {CustomHeader => 'Value'});
  
# Requests can be specificed directly as well
$client->request('GET', '/dir/file', 'request body content', {CustomHeader => 'Value'});

# Requests can optionally automatically follow redirects and auth, defaults to
# false 
$client->setFollow(1);
 
#It is possible to access the L<LWP::UserAgent> object REST::Client is using to
#make requests, and set advanced options on it, for instance:
$client->getUseragent()->proxy(['http'], 'http://proxy.example.com/');
  
# request responses can be written directly to a file 
$client->setContentFile( "FileName" );
 
# or call back method
$client->setContentFile( \&callback_method );
# see LWP::UserAgent for how to define callback methods

=cut