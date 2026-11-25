#!/usr/bin/perl -w
use strict;
use File::Path;
use File::Copy;
use File::Basename;
use File::Find;

system("cls");

########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%40s%15s\n","*","DEVELOPED BY : Saiful Islam","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################
my $myfolder = "$ARGV[0]";
my $mydesdir = "MYScan";
my $myoutdir = "${myfolder}/${mydesdir}";

rmtree($myoutdir);
mkdir($myoutdir);

opendir(DIR,${myfolder});
my ($mainfile,$mainfilename,$chfile,$entry,$line,$childfile);
my ($i,$k,$m)=(0,0,0);
my (@templist,@dirlist,@childtexfile,@includefiles,@unusedfiles);

while($chfile = readdir(DIR))
{	
	if($chfile =~ /.tex$|.TeX$|.TEX$|.Tex$/s)
	{
		open(PTEXFILE,"<$myfolder/$chfile");
		while(<PTEXFILE>) 
		{
			if (/\\documentclass|\\documentstyle/s) 
			{
				$mainfile = $chfile;
				$mainfilename = $mainfile;
				$mainfilename =~ s/(.*?)\.tex/$1/s;
				#print "$mainfilename\n";
			}
		}
		close(PTEXFILE);
	}
}
closedir(DIR);


find sub { push(@dirlist, $File::Find::name)}, @ARGV;

$i=0;
my @allfile;

foreach my $tmpfile (@dirlist)
{
	$tmpfile=~s/\Q$myfolder\E//;
	$tmpfile=~s/^\///;
	#print "$tmpfile\n";
	$allfile[$i] = $tmpfile;
	$i++;
}


########################## Appending child files contents into its Master file ###############################

open(PTEXFILE,"<${myfolder}/$mainfile");
open(CPTFILE,">${myoutdir}/$mainfile");
open(LOG,">$myoutdir/notused.log");

print LOG "MAIN FILE is: $mainfile\n\n";

while($line = <PTEXFILE>)
{
	$line=~ s/^([\t ]*)\\includeonly\{(.*?)\}/%\\includeonly\{$2\}/s;
	$line=~ s/\\input\{(.*?).tex\}/\\input $1.tex/s;
	$line=~ s/\\include\{(.*?).tex\}/\\input $1.tex/s;

	my $data= $line;

	if($data =~ s/\\input (.*?)//s)
	{
		push(@includefiles,$data);
	}

	if($data =~ s/\\includegraphics([^\{]*){(.+?)}//s)
	{
		push(@includefiles,$2);
	}
	push(@includefiles, "$1.bib") if ($data=~s/\\bibliography{(.+?)}//);
	push(@includefiles, "$1.bst") if ($data=~s/\\bibliographystyle{(.+?)}//);

	if($line =~ /\\input (.*?)\.tex/s)
	{
		my $chname = "$1";
		my $chfilename = "$1\.tex";
		$childfile = "${myfolder}/${chfilename}";
		#print "$childfile\n";

		if(-e ${childfile})
		{	
			print "\nAppending file $chfilename into $mainfile\n\n";
			print CPTFILE  "\n\n%%%% $chfilename starts here %%%%\n\n";

			open(CHTEXFILE,"<${childfile}");
			while(<CHTEXFILE>)
			{
				print CPTFILE $_;
			}
			close(CHTEXFILE);
			$line=~ s/\\input\{(.*?)\.tex\}|\\input (.*?)\.tex|\\include\{(.*?)\.tex\}/\n%%%% $chfilename ends here %%%%\n\n/s;
			print LOG "$chfilename contents are appended in $mainfile\n";
		}
		else
		{
			print "WARNING: $chfilename is MISSING!!!\n";
			print LOG "WARNING: $chfilename is MISSING!!!\n";
		}
	}
	print CPTFILE $line;
}
close(CPTFILE);
close(PTEXFILE);



##########Below codes are listing the filenames and directories ###############

my (@myfile,@mydirname);
$i=0;
$m=0;

foreach $entry (@allfile)
{
	chomp($entry);
	my $mysearch = "${myfolder}/${entry}";
	if((-e $mysearch) && (!(-d $mysearch))) 
	{
		next if($entry =~ /.(.*?)\~$/s);
		next if($entry =~ /${mainfilename}/s);
		$myfile[$i] = $entry;
		$i++;
		#print "$entry is a file\n";
	}
	else
	{
		next if($entry eq $mydesdir);
		$mydirname[$m] = $entry;
		$m++;
		#print "\n\n\t****$entry is a folder****\n\n";
	}
}
###########################################################################################################

=begin comment
############################## BELOW COMMAND WILL PRINT LIST OF FILES IN LOG FILES #############################
print LOG "\n\n*********************************\n";
print LOG "LIST OF FILES\n";
print LOG "*********************************\n";

foreach $entry (@myfile)
{
	chomp($entry);
	next if($entry =~ /\.(DS_Store|aux|dvi|log|fls|blg|cls|bbl|out|bib|bst|brf|gz)$/);
	if($entry =~ /\.tex$/)
	{
		push(@childtexfile,$entry);
	}
	print LOG "$entry\n";
}

print LOG "\n\n*********************************\n";
print LOG "LIST OF DIRECTORIES\n";
print LOG "*********************************";

foreach $entry (@mydirname)
{
	chomp($entry);
	next if($entry eq $mydesdir);
	#print "$entry\n";
	print LOG "$entry\n";
}

print LOG "\n\n*********************************\n";
print LOG "LIST OF TeX FILES\n";
print LOG "*********************************\n";

$i=0;
foreach $entry (@childtexfile)
{
	my $mysearch = "${myfolder}/${entry}";
	if(-e $mysearch)
	{
		print LOG "$entry\n";
	}
}

=cut

###This will search whether the file are called in tex file or not#######

print LOG "\n***********************************\n";
print LOG "Following items are not used\n";
print LOG "***********************************\n";

$i=0;
foreach $entry (@myfile)
{
	next if((grep(/\Q${entry}\E/, @includefiles)));
	next if(($entry =~ /\.(DS_Store|aux|dvi|log|fls|blg|cls|bbl|out|bib|bst|brf|gz)$/));
	print LOG "$entry\n";
	$unusedfiles[$i] = $entry;
	$i++;
}

=begin comment
print LOG "\n***********************************\n";
print LOG "Following items are used\n";
print LOG "***********************************\n";

foreach $entry (@includefiles)
{
	chomp($entry);
	print LOG "$entry\n";
}
=cut

print "\n\nProcess Completed!!!";
print "\n\nSee the log file for detail information...";
sleep(1);
print "\n\nPress ENTER key to exit...";
getc();
system("start notepad ${myoutdir}/notused.log");
####################### END ###########################################
