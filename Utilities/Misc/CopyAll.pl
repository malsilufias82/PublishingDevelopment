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
#my $myfolder = "$ARGV[0]";
print "Enter Path: ";
my $myfolder = <STDIN>; 
chomp($myfolder);

my $myoutdir = "D:\\Manas\\Dart-Naming\\FOR-Archiving";
my $myartdir = "${myoutdir}/ART";
my $myappdir = "${myoutdir}/APPLICATIONS";
my $mypdfdir = "${myoutdir}/PDF";

rmtree($myoutdir);
mkdir($myoutdir);
mkdir($myartdir);
mkdir($myappdir);
mkdir($mypdfdir);

my (@dirlist,@mydir,@myfiles,@mypdffiles);
my $i=1;

opendir(DIR,$myfolder);
while(my $entry = readdir(DIR))
{
	#next if($entry =~ /\.rsrc|\.\.|\./);
	next if($entry =~ /\.rsrc/);
	next if($entry =~ /\.\./);
	next if($entry =~ /\./);
	push(@dirlist,$entry);
}

foreach my $entry(@dirlist)
{
	if($entry =~ /ch([0-9]+)|bmmatter|fmmatter/)
	{
		push(@mydir,$entry);
	}
}

foreach my $entry(@mydir)
{
	my $childdir = "${myartdir}/${entry}";
	mkdir($childdir);

	find sub { push(@myfiles, $File::Find::name)}, "$myfolder\\$entry";
	foreach my $entry1(@myfiles)
	{
		if($entry1 =~ /\.(tex|indd|xml|qxd|docx|doc|cfg)$/)
		{
			copy("$entry1","${myappdir}");
		}
		if($entry1 =~ /\.(eps|jpg|jpeg|ai|psd|tif|pdf)$/)
		{
			copy("$entry1","${childdir}");
		}
	}
	@myfiles="";
	finddepth(sub { rmdir $_ if -d }, $myartdir);
}

find sub { push(@mypdffiles, $File::Find::name)}, "$myfolder\\pdf";
foreach my $entry(@mypdffiles)
{
	if($entry =~ /\.pdf$/)
	{
		copy("$entry","${mypdfdir}");
	}
}

print "CONGRATS!!! Copying Done....";
