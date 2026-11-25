#!/usr/bin/perl -w
use strict;
use File::Copy;

system("cls");

########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%40s%15s\n","*","DEVELOPED BY : Saiful Islam","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################
my $mainxml = "$ARGV[0]";

if(!(-e $mainxml))
{
	print "$mainxml is missing\n";
	exit(0);
}
else
{
	print "Duplicate ID for $mainxml are:\n\n";
}

open(INPUT,"<${mainxml}");

my (@myids,@mydupids);
my %elements;
my $i=0;

while(<INPUT>)
{
	s/<\!--(.*?)-->//g;
	if(/<(.*?) id\=\"(.*?)\"/s)
	{
		my $term = "<$1";
		my $id = "\"$2\"";
		if((grep(/\Q${id}\E/, @myids)))
		{
			push(@mydupids,"$term id\=$id");
			$elements{$term} = "$i";
			$i++;
		}
		else
		{
			push(@myids,$id);
		}
	}
}
close(INPUT);

$mainxml =~ s/.xml//;
open(LOG,">$mainxml.log");
print LOG "Duplicate ID for \"$mainxml\.xml\" are:\n\n";
foreach my $entry(@mydupids)
{
	print "$entry\n";
	print LOG "$entry\n";
}

print "\n\n\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\n\n";

my @xmlelem;
foreach my $entry(sort keys %elements)
{
	chomp($entry);
	push(@xmlelem,"$entry");
	#print "$entry => $elements{$entry}\n";
}

my $totelem;
foreach my $entry(@xmlelem)
{
	print "$entry\n";
	$totelem++;
}

print "\n\n\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\n\n";

print "Do you want to renumber IDs (y/n)?";
my $rep = getc();
chomp($rep);
getc();

my ($m,$l)=(0,0);
$i=1;
my @oldids;
my ($iids,$temp);

if ($rep eq "y")
{
	print "Enter Chapter no.: ";
	my $chn = <STDIN>; 
	chomp($chn);
	print LOG "\n\n-------------------------------";

	copy("${mainxml}.xml","${mainxml}-in.xml");
	foreach my $entry(@xmlelem)
	{
		print LOG "\n$entry\n";
		print LOG "******************************\n";
		$oldids[$l++] = $entry;

		$temp = "eqn" if((grep(/\Qdisp\E/, $entry)));
		$temp = "eqn" if((grep(/\Qmath\E/, $entry)));
		$temp = "fig" if((grep(/\Qfig\E/, $entry)));
		$temp = "sec" if((grep(/\Qsec\E/, $entry)));
		$temp = "bib" if((grep(/\Qref\E/, $entry)));
		$temp = "bib" if((grep(/\Qcitation\E/, $entry)));

		open(INPUT,"<${mainxml}-in.xml");
		open(OUTPUT,">${mainxml}-New.xml");
		while(my $line = <INPUT>)
		{
			if ((grep(/\Q${entry} \E/, $line)))
			{
				if($i<=9)
				{
					$line =~ s/id\=\"(.*?)\"/id\=\"c0$chn-$temp-000$i\"/s;
					$iids = "c0$chn-000$i => $1";
					print LOG "c0$chn-000$i => $1\n";
					$i++;
				}
				elsif(($i>9)&($i<=99))
				{
					$line =~ s/id\=\"(.*?)\"/id\=\"c0$chn-$temp-00$i\"/s;
					$iids = "c0$chn-00$i => $1";
					print LOG "c0$chn-00$i => $1\n";
					$i++;
				}
				else
				{
					$line =~ s/id\=\"(.*?)\"/id\=\"c0$chn-$temp-0$i\"/s;
					$iids = "c0$chn-0$i => $1";
					print LOG "c0$chn-0$i => $1\n";
					$i++;
				}
				$oldids[$l++] = $iids;
			}
			print OUTPUT $line;
		}
		close(INPUT);
		close(OUTPUT);
		$i=1;
		if($m<$totelem)
		{
			$m++;
			unlink("${mainxml}-in.xml");
			system("ren ${mainxml}-New.xml ${mainxml}-in.xml");
		}
	}
	print "Congrats! renumbering Done!!!\n";
	system("ren ${mainxml}-in.xml ${mainxml}-New.xml");
	print "\n\n\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\n\n";
		#foreach my $entry(@oldids)
		#{
			#print "$entry\n";
		#}
}
else
{
	print "Bye!!!\n";
	exit(0);
}


exit(0);
