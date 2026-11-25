### This program is designed, developed and maintained by Mr. Saiful Islam #######

#!/usr/bin/perl -w
use strict;
use mmconv;
use enttity;
#use saif;

system("cls");

my $file = "math.xml";
open (INPUT, "< $file") or die "Can't open for read: ";
open (OUTPUT, "> math.tmp") or die "Can't open for read: ";

my $line;
my $cond = 0;

while(<INPUT>)
{	
	if(/<math>/)
	{
		$cond = 0;
		s/<math>/\$/g;
	}

	if(/<math display = \'block\'>|<math display=\'block\'>/)
	{
		$cond = 1;
		s/<math display = \'block\'>|<math display=\'block\'>/\\[/g;
	}

	if(/<\/math>/)
	{
		if($cond == 0)
		{
			s/<\/math>/\$/g;
		}
		if($cond == 1)
		{
			s/<\/math>/\\]/g;
		}
	}

	$line = $_;

	$line = mmconv::space($line);

	print OUTPUT "$line";
#	print $line;
}

close (INPUT);
close (OUTPUT);

###################################################################################################

open (INPUT, "< math.tmp") or die "Can't open for read: ";
open (OUTPUT, "> math.txt") or die "Can't open for read: ";

while(<INPUT>)
{	
	$line = $_;

	$line = enttity::entityrep($line);
#	$line = saif::entittyrep($line);


	print OUTPUT "$line";
}
close (INPUT);
close (OUTPUT);
#unlink("math.tmp");

###################################################################################################

###################################################################################################

open (INPUT, "< math.txt") or die "Can't open for read: ";
open (OUTPUT, "> math.tex") or die "Can't open for read: ";

while(<INPUT>)
{	
	$line = $_;

	$line = mmconv::math($line);
	print OUTPUT "$line";
}
close (INPUT);
close (OUTPUT);

###################################################################################################
