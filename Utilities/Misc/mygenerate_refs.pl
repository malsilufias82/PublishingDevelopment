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


################## VARIABLES DECLARATIONS ######################################
my (@oldids,@mydupids,@missids);
my %newids;
my ($totids,$firstid,$lastid,$filename,$totmisids,$refid,$shownid,$actid);
my ($m,$w,$i,$cnt)=(0,0,1,1);
###############################################################################

open(INPUT,"<${mainxml}");
while(<INPUT>)
{
	s/<\!--(.*?)-->//g;
	if(/<ce:bib-reference id\=\"(.*?)\"/s)
	{
		my $id = "\"$1\"";
		if((grep(/\Q${id}\E/, @oldids)))
		{
			push(@mydupids,$1);
		}
		else
		{
			push(@oldids,$1);
		}
		$cnt++;
	}
}
close(INPUT);

$totids = @oldids;
$firstid = @oldids[$[];
$lastid = $oldids[$#oldids];
$filename = $mainxml;
$filename =~ s/\.xml//;

&step1_chkmissref_n_saveoldnewref();

open(LOG,">${filename}.log");
print LOG "Total ID = $totids,\t First ID = $firstid,\t Last ID = $lastid\n";
print LOG "\n\n\#\#\#\#\#\#\#\#\#\# Missing IDs are \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\n";

foreach my $entry(@missids)
{
	print LOG "$entry\n";
}

print LOG "\n\n\#\#\#\#\#\#\#\#\#\# New IDs are \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\n";

printf LOG ("%5s%10s\n","New","Old");
printf LOG ("%s%11s\n","-------","-------");

foreach my $entry(sort keys %newids)
{
	print LOG "$entry => $newids{$entry}\n";
}
close(LOG);

&step2_delmissrefcit();
&step3_regenrefnum();
&step4_changecitenum();
&step5_change_ndash_cite();

################################### Functions ##################################################

sub step1_chkmissref_n_saveoldnewref()
{
	open(INPUT,"<${mainxml}");
	while(<INPUT>)
	{
		if(/<ce:bib-reference id\=\"(.*?)\"/s)
		{
			if($i<=9)
			{
				my $sbids = "bib000$i";
				if (!(grep(/\Q${sbids}\E/, @oldids)))
				{
					push(@missids,$sbids);
				}
				$newids{$sbids} = "$oldids[$w]";
				$w++;
				$i++;
			}
			elsif(($i>9)&($i<=99))
			{
				my $sbids = "bib00$i";
				if (!(grep(/\Q${sbids}\E/, @oldids)))
				{
					push(@missids,$sbids);
				}
				$newids{$sbids} = "$oldids[$w]";
				$w++;
				$i++;
			}
			else
			{
				my $sbids = "bib0$i";
				if (!(grep(/\Q${sbids}\E/, @oldids)))
				{
					push(@missids,$sbids);
				}
				$newids{$sbids} = "$oldids[$w]";
				$w++;
				$i++;
			}
		}
	}
	close(INPUT);
}
#################################################################################################
sub step2_delmissrefcit()
{
	$m=1;
	$totmisids = 1;
	foreach my $entry(@missids)
	{
		$totmisids++;
	}	
	copy("${filename}.xml","${filename}-in.xml");
	foreach my $entry(@missids)
	{
		open(INPUT,"<${filename}-in.xml");
		open(OUTPUT,">${filename}-New.xml");
		while(my $line = <INPUT>)
		{
			if($line =~ /<ce\:cross-ref id\=\"(.*?)\" refid=\"$entry\">\[([0-9]+)\]<\/ce\:cross-ref>/s)
			{
				$line =~ s/<ce\:cross-ref id\=\"(.*?)\" refid=\"$entry\">\[([0-9]+)\]<\/ce\:cross-ref>//s;
			}
			if($line =~ /$entry/s)
			{
				$line =~ s/ $entry / /s;
				$line =~ s/$entry //s;
			    $line =~ s/ $entry//s;
 			    $line =~ s/<ce\:cross-refs id\=\"(.*?)\" refid\=\"(.*?)\">\[(.*?)\]<\/ce\:cross-refs>/<ce\:cross-refs id\=\"$1\" refid\=\"$2\">\[\]<\/ce\:cross-refs>/s;
			}
			print OUTPUT $line;
		}
		close(INPUT);
		close(OUTPUT);
		if($m<=$totmisids)
		{
			$m++;
			unlink("${filename}-in.xml");
			system("ren ${filename}-New.xml ${filename}-in.xml");
		}
	}
	#system("ren ${filename}-in.xml ${filename}-New.xml");
}
#################################################################################################
sub step3_regenrefnum()
{
	$i=1;
	$w=1;
	$m=1;
	open(INPUT,"<${filename}-in.xml");
	open(OUTPUT,">${filename}-New.xml");
	while(my $line = <INPUT>)
	{
		if($line =~ /<ce:bib-reference id\=\"(.*?)\"/s)
		{
			if($i<=9)
			{
				$line =~ s/<ce:bib-reference id\=\"(.*?)\"/<ce:bib-reference id\=\"bib000$i\"/s;
			}
			elsif(($i>9)&($i<=99))
			{
				$line =~ s/<ce:bib-reference id\=\"(.*?)\"/<ce:bib-reference id\=\"bib00$i\"/s;
			}
			else
			{
				$line =~ s/<ce:bib-reference id\=\"(.*?)\"/<ce:bib-reference id\=\"bib00$i\"/s;
			}
			$i++;
		}
		if($line =~ /<ce:label>\[(\d+)\]<\/ce:label>/s)
		{
			$line =~ s/<ce:label>\[(\d+)\]<\/ce:label>/<ce:label>\[$w\]<\/ce:label>/s;
			$w++;
		}
		if($line =~ /<sb:reference id\=\"sbref(\d+)\">/s)
		{
			if($m<=9)
			{
				$line =~ s/<sb:reference id\=\"sbref(\d+)\">/<sb:reference id\=\"sbref000$m\">/s;
			}
			elsif(($m>9)&($m<=99))
			{
				$line =~ s/<sb:reference id\=\"sbref(\d+)\">/<sb:reference id\=\"sbref00$m\">/s;
			}
			else
			{
				$line =~ s/<sb:reference id\=\"sbref(\d+)\">/<sb:reference id\=\"sbref0$m\">/s;
			}
			$m++;
		}
		print OUTPUT $line;
	}
	close(INPUT);
	close(OUTPUT);
	unlink("${filename}-in.xml");
}
#################################################################################################
sub step4_changecitenum()
{
	system("ren ${filename}-New.xml ${filename}-in.xml");
	open(INPUT,"<${filename}-in.xml");
	open(OUTPUT,">${filename}-New.xml");
	while(my $line = <INPUT>)
	{
		if($line =~ /<ce:cross-ref id\=\"(.*?)\" refid=\"bib(.*?)\">\[([0-9]+)\]<\/ce:cross-ref>/s)
		{
			$refid = "bib$2";
			$shownid = $3;
			$cnt = 1;
			foreach my $entry(sort keys %newids)
			{
				#print LOG "$entry => $newids{$entry}\n";
				if($refid eq $newids{$entry})
				{
					$actid = $entry;
					$shownid = $cnt;
				}
				$cnt++;
			}
			$line =~ s/<ce:cross-ref id\=\"(.*?)\" refid=\"bib(.*?)\">\[([0-9]+)\]<\/ce:cross-ref>/<ce:cross-ref id\=\"$1\" refid=\"$actid\">\[$shownid\]<\/ce:cross-ref>/s;
		}
		###############################################################################
		if($line =~ /<ce:cross-refs id\=\"(.*?)\" refid\=\"bib(.*?)\">\[(.*?)\]<\/ce:cross-refs>/s)
		{
			$refid = "bib$2";
			my @refids = split(/ /, $refid);
			$cnt = 1;
			$actid ="";
			$shownid = "";
			foreach my $entry(@refids)
			{
				foreach my $entry1(sort keys %newids)
				{
					if($entry eq $newids{$entry1})
					{
						$actid = "$actid"." $entry1";
						if($entry1 =~ /bib000([0-9])/s)
						{
							$cnt = $entry1;
							$cnt =~ s/bib000([0-9])/$1/;
						}
						elsif($entry1 =~ /bib00([0-9])([0-9])/s)
						{
							$cnt = $entry1;
							$cnt =~ s/bib00([0-9])([0-9])/$1$2/;
						}
						elsif($entry1 =~ /bib0([0-9])([0-9])([0-9])/s)
						{
							$cnt = $entry1;
							$cnt =~ s/bib0([0-9])([0-9])([0-9])/$1$2$3/;
						}
						$shownid = "$shownid".",$cnt";
					}
				}
			}
			$actid =~ s/^ (.*?)$/$1/;
			$shownid =~ s/^,(.*?)$/$1/;
			$line =~ s/<ce:cross-refs id\=\"(.*?)\" refid\=\"bib(.*?)\">\[(.*?)\]<\/ce:cross-refs>/<ce:cross-refs id\=\"$1\" refid\=\"$actid\">\[$shownid\]<\/ce:cross-refs>/s;
		}
		###############################################################################
		print OUTPUT $line;
	}
	close(INPUT);
	close(OUTPUT);
	unlink("${filename}-in.xml");
}
#################################################################################################
sub step5_change_ndash_cite()
{
	system("ren ${filename}-New.xml ${filename}-in.xml");
	open(INPUT,"<${filename}-in.xml");
	open(OUTPUT,">${filename}-New.xml");
	while(my $line = <INPUT>)
	{
		if($line =~ /<ce:cross-refs id\=\"(.*?)\" refid\=\"bib(.*?)\">\[(.*?)\]<\/ce:cross-refs>/s)
		{
			my $mytemp;
			$shownid = $3;
			#my @shownids = split(/,/, $shownid);
			#$mytemp = join ',' => sort { $a <=> $b } @shownids;
			$shownid =~ s/(?<!\d)(\d+)(?:,((??{$++1})))(?:,((??{$++1})))+(?!\d)/$1&ndash\;$+/g;

			$line =~ s/<ce:cross-refs id\=\"(.*?)\" refid\=\"bib(.*?)\">\[(.*?)\]<\/ce:cross-refs>/<ce:cross-refs id\=\"$1\" refid\=\"bib$2\">\[$shownid\]<\/ce:cross-refs>/s;
		}
		print OUTPUT $line;
	}
	close(INPUT);
	close(OUTPUT);
	unlink("${filename}-in.xml");
}
