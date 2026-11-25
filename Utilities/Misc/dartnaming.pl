#!/usr/bin/perl -w
use strict;
use File::Path;
use File::Copy;
use File::Find;

system("cls");

########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%40s%15s\n","*","DEVELOPED BY : Saiful Islam","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################
my $myfolder = "$ARGV[0]";
#my $myfolder = "D:/Saif(Dont'del)/MIsc/MIsc/linux-tutorial/Perl/Manas/Saif";
my $mydesdir = "FINAL";
my $myoutdir = "${myfolder}/${mydesdir}";

rmtree($myoutdir);
mkdir($myoutdir);

my (@dirlist,@fmmatter,@bmmatter);
my $i=1;

find sub { push(@dirlist, $File::Find::name)}, @ARGV;
#find sub { push(@dirlist, $File::Find::name)}, "$myfolder";


############################### FMMATTER ###################################################
foreach my $entry(@dirlist)
{
	$entry=~s/\Q$myfolder\E//;
    $entry=~s/^\///;
    $entry=~s/\.rsrc//;
	push(@fmmatter,$entry) if(($entry =~ /Frontendpaper.pdf/s));
}

foreach my $entry(@dirlist)
{
	push(@fmmatter,$entry) if(($entry =~ /ffirs.pdf|FMTOC.pdf/s));
}

foreach my $entry(@dirlist)
{
	push(@fmmatter,$entry) if(($entry =~ /ftoc.pdf/s));
}


foreach my $entry(@dirlist)
{
	push(@fmmatter,$entry) if(($entry =~ /fbetw.pdf/s));
}

foreach my $entry(@dirlist)
{
	push(@fmmatter,$entry) if(($entry =~ /fpref.pdf/s));
}

foreach my $entry(@dirlist)
{
	push(@fmmatter,$entry) if(($entry =~ /flast.pdf/s));
}

foreach my $entry(@fmmatter)
{
		copy("${myfolder}/$entry","${myoutdir}/c_0$i.pdf");
		$i++;
}
############################################################################################
	
############################### CHAPTERS ###################################################
foreach my $entry(@dirlist)
{
	if(($entry =~ /c([0-9]+).pdf|c([0-9]+)(.*?).pdf/s))
	{
		my $temp = $entry;
		if($i<=9)
		{
			$temp =~ s/c([0-9]+).pdf/c_0$i.pdf/;
			$temp =~ s/c([0-9]+)(.*?).pdf/c_0$i.pdf/;
		}
		else
		{
			$temp =~ s/c([0-9]+).pdf/c_$i.pdf/;
			$temp =~ s/c([0-9]+)(.*?).pdf/c_$i.pdf/;
		}
		copy("${myfolder}/$entry","${myoutdir}/$temp");
		#print "$temp\n";
		$i++;
	}
}
############################################################################################

############################### BMMATTERS ###################################################
foreach my $entry(@dirlist)
{
	push(@bmmatter,$entry) if(($entry =~ /(^BM(\w+).pdf$)|(^bm(\w+).pdf$)/s));

}
foreach my $entry(@dirlist)
{
	push(@bmmatter,$entry) if(($entry =~ /bindex.pdf/s));

}
foreach my $entry(@dirlist)
{
	push(@bmmatter,$entry) if(($entry =~ /Backendpaper.pdf/s));

}

foreach my $entry(@bmmatter)
{
		copy("${myfolder}/$entry","${myoutdir}/c_$i.pdf");
		$i++;
}
############################################################################################
