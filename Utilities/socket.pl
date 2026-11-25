#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Socket;


system("cls");
########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%47s%8s\n","*","DEVELOPED BY : Saiful Islam (Wiley Books)","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################


################################# VARIABLE DECLARATIONS ######################################
my ($filename,$jobID);
my($host,$hostlogin,$hostpasswd,$loginpath,$script);

# use port 7890 as default
my $port = shift || 7890;
my $proto = getprotobyname('tcp');
$host = "apollo.aptaracorp.com";  # Host IP running the server
$hostlogin = "wileybooks";
$hostpasswd = "123456";
##############################################################################################

print "Enter the job name with Path: ";
$filename = <STDIN>;
chomp($filename);

$jobID = basename($filename);

print "PROCESSING.....\n\n";


my $command="mkdir $jobID";
&sendcmd($command);
sleep(10);
$command="cd $jobID && alttxt $filename";
&sendcmd($command);


sub sendcmd {
    my ($mycommand)=@_;
    my $sockaddr = 'S n a4 x8';
    my ($name, $aliases, $type, $len,$thisport,$thatport,$thisaddr,$proto,$port);
    $port=512;
    ($name, $aliases, $proto) = getprotobyname('tcp');
    ($name, $aliases, $type, $len, $thisaddr) = gethostbyname($host);
    $thisport = pack($sockaddr, &AF_INET, 0, $thisaddr);
    $thatport = pack($sockaddr, &AF_INET, $port, $thisaddr);
    
    socket(S, &PF_INET, &SOCK_STREAM, $proto) || die "cannot create socket\n";
    connect(S,$thatport) || die "cannot connect socket\n";
    
# Set socket to write after each print
    select(S);
    $| = 1;
    select(STDOUT);
#
# Send command
#

	printf S "0\0%s\0%s\0%s\0", $hostlogin,$hostpasswd,$mycommand;
#
# Read responses from server and print them out 
#
    while ( $_ = <S> ) {
	printf ("$_");
    };
    close(S);
}



# print "\nDONE.....\n";

# /nea8/PowerManage/WILEY-PT-SIN/JWST916