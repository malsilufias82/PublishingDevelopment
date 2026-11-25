#!/usr/bin/perl -w
use strict;

system("cls");

########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%40s%15s\n","*","DEVELOPED BY : Saiful Islam","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################

# This program is designed to convert TeX input reference file into .bib file

# Input Fields are as belows:
####################################################################################

# Type -- article, book
# 	 article  ---->   author, year, title, journal, volume, number, pages
#	 book     ---->   author, year, title, pages, publisher
#	 inbook     ---->   author, year, title, booktitle, volume, pages   #### In:
# author
# year
# title
# journal
# volume
# number
# pages
# publisher
# booktitle

####################################################################################
my $filename = "$ARGV[0]";

############################### variable declarations ##############################
my ($type,$author,$bibauthor,$year,$title,$journal,$volume,$number,$pages,$publisher,$booktitle);
my ($filestr,$bibentry,$bibID,$temp,$cnt,$clrgrp);
my (@filearr,@authors);

$clrgrp = qr{\{(?: (?> [^{}]+ )|(??{ $clrgrp }))*\}}x;
####################################################################################


&readfile();
&extractline();

############################### FUNCTIONS DEFINITIONS ##############################
sub readfile()
{
	open(INFILE,"<$filename");
	my @Data=<INFILE>;
	close(INFILE);
	push(@filearr,@Data);
    $filestr=join("",@filearr);
    $filestr =~ s/\r*\n/\n/g;
}
####################################################################################
sub extractline()
{
	open(TEMPFILE,">tempfile.txt");
	while($filestr =~ s/\\noindent ([^\n]+)/<entries>$1<\/entries>/s)
	{
		$bibentry = $1;
		#print TEMPFILE "<entries>$bibentry<\/entries>\n\n";

		$bibentry =~ s/  / /g;
		$bibentry =~ s/ \}/\} /g;
		$bibentry =~ s/\{ /\{/g;
		$bibentry =~ s/\\textit\{\}//g;
		$bibentry =~ s/ $//g;

		######################################## BIB TYPE ############################################
		if(($bibentry =~ /\`\`(.*?)([\.\?])\'\'/s)&&($bibentry !~ /paper/s)&&($bibentry !~ /Press/s))
		{
			$type = "article";
		}
		elsif($bibentry =~ /In\: \\textit/s)
		{
			$type = "inbook";
		}
		elsif(($bibentry =~ /\\textit($clrgrp)/s)||($bibentry =~ /paper/s)||($bibentry =~ /Press/s))
		{
			$type = "book";
		}
		################################# bibID, Author and Year #####################################
		if(($bibentry =~ /^(.*?)\. ([0-9][0-9][0-9][0-9])\./s)||($bibentry =~ /^(.*?)\. \`\`/s))
		{
			$author = $1;
			$bibauthor = $author;
			$author =~ s/^([a-zA-Z]+), ([A-Z])\./$1 $2\./s;
			$author =~ s/, and /, /g;
			$author =~ s/ and / /g;
			@authors = split(/, /,$author);
			$bibID = "";
			foreach my $myentry (@authors) {
				$myentry =~ s/([a-zA-Z]+) ([A-Z])\./$1/g;
				$myentry =~ s/([A-Z])\. ([a-zA-Z]+)/$2/g;
				$myentry =~ s/([A-Z])\-//g;
				$myentry =~ s/([A-Z])\.//g;
				$myentry =~ s/\. //g;
				$myentry =~ s/ //g;
				$bibID = $bibID."$myentry";
			}
			if($bibentry =~ /^(.*?)\. ([0-9][0-9][0-9][0-9])\./s)
			{
				$year = $2;
				$bibID = $bibID."$2";

				$bibentry =~ s/^(.*?)\. ([0-9][0-9][0-9][0-9])\./\@$type\{$bibID,\nauthor = \{$bibauthor\},\nyear = \{$year\},\n/s;
			}
			@authors = "";
		}
		######################################## TITLE ############################################
		if($type eq "article")
		{
			if($bibentry =~ /\`\`(.*?)([\,\.\?])\'\'/s)
			{
				$title = $1;
				$bibentry =~ s/ \`\`(.*?)([\,\.\?])\'\'/title = \{$title\},\n/s;
			}
			if($bibentry =~ /\\textit($clrgrp)/s)
			{
				$journal = $1;
				$journal =~ s/^\{//s;
				$journal =~ s/\}$//s;
				$bibentry =~ s/ \\textit($clrgrp)/journal = \{$journal\},\n/s;
				$bibentry =~ s/\\textit($clrgrp)/journal = \{$journal\},\n/s;
			}
		}
		elsif($type eq "book")
		{
			if($bibentry =~ /\`\`(.*?)([\,\.\?])\'\' (.*?)$/s)
			{
				$title = $1;
				$publisher = $3;
				$bibentry =~ s/ \`\`(.*?)([\,\.\?])\'\' (.*?)$/journal = \{$title\},\npublisher = \{$publisher\},\n/s;
			}
			elsif($bibentry =~ /\\textit($clrgrp)\. (.*?)\./s)
			{
				$title = $1;
				$publisher = $2;
				$bibentry =~ s/ \\textit($clrgrp)\. (.*?)\./journal = $title,\npublisher = $publisher,\n/s;
				$bibentry =~ s/\\textit($clrgrp)\. (.*?)\./journal = $title,\npublisher = $publisher,\n/s;
			}
			elsif($bibentry =~ /\\textit($clrgrp) (.*?)\./s)
			{
				$title = $1;
				$publisher = $2;
				$bibentry =~ s/ \\textit($clrgrp) (.*?)\./journal = $title,\npublisher = $publisher,\n/s;
				$bibentry =~ s/\\textit($clrgrp) (.*?)\./journal = $title,\npublisher = $publisher,\n/s;
			}
		}
		elsif($type eq "inbook")
		{
			if($bibentry =~ /\`\`(.*?)([\,\.\?])\'\'/s)
			{
				$title = $1;
				$bibentry =~ s/ \`\`(.*?)([\,\.\?])\'\'/title = \{$title\},\n/s;
			}
			if($bibentry =~ /In\: \\textit($clrgrp)/s)
			{
				$booktitle = $1;
				$booktitle =~ s/^\{//s;
				$booktitle =~ s/\}$//s;
				$bibentry =~ s/ \\textit($clrgrp)/booktitle = \{$booktitle\},\n/s;
				$bibentry =~ s/\\textit($clrgrp)/booktitle = \{$booktitle\},\n/s;
			}
		}
		######################################## VOLUME and NUMBER ############################################
		if($bibentry =~ /([0-9]+)\(([0-9]+)\)\:/s)
		{
			$volume = $1;
			$number = $2;
			$bibentry =~ s/ ([0-9]+)\(([0-9]+)\)\:/volume = \{$volume\},\n number = \{$number\}/s;
		}
		elsif($bibentry =~ /([0-9]+)\:/s)
		{
			$volume = $1;
			$bibentry =~ s/ ([0-9]+)\:/volume = \{$volume\},\n/s;
		}
		elsif($bibentry =~ /([a-zA-Z][a-zA-Z])\:/s)
		{
			$volume = $1;
			$bibentry =~ s/ ([a-zA-Z][a-zA-Z])\:/volume = \{$volume\},\n/s;
		}
		######################################## PAGES ############################################
		if(($bibentry =~ /([0-9]+)\-\-([0-9]+)\./s)||($bibentry =~ /([0-9]+)\-([0-9]+)\./s))
		{
			$pages = "$1--$2";
			$bibentry =~ s/ ([0-9]+)\-\-([0-9]+)\./pages = \{$pages\},\n/s;
			$bibentry =~ s/ ([0-9]+)\-([0-9]+)\./pages = \{$pages\},\n/s;
		}
		###########################################################################################
		$bibentry =~ s/,$/\n\}/s;
		print TEMPFILE "$bibentry";
		print TEMPFILE "\n***************************************\n\n";
	}
	close(TEMPFILE);
}
####################################################################################
####################################################################################
sub writefile()
{
	open(OUTFILE,">newbib.bib");
	print OUTFILE "$filestr\n";
	close(OUTFILE);
}