#!/usr/bin/perl -w
use strict;
use File::Copy;
use File::Basename;
use POSIX qw(strftime);

system("cls");

print "Enter Path of TeX file: ";
my $mytpath = <STDIN>;
chomp($mytpath);

############ Separating file name and path of file from the input ####################
my $infilename = basename($mytpath);
$infilename =~ s/\.tex//s;
my $mypath = $mytpath;
$mypath =~ s/\\$infilename\.tex//s;
##########################################
my $ofile = "$mypath\\$infilename.xml";
my $tfile = &read_file($mytpath);
#####################################################################################

sub read_file
{
	my $input=$_[0];
	if(!-e $input)
	{
		print("Result=Error\n");
		exit(0);
	}
	open(INFILE, "$input");
	my @filearr=<INFILE>;
	close(INFILE);
	my $filestr=join("",@filearr);
	return $filestr;
}
my ($jobname,$ISBNnum,$datestring,$pos,$fmtitle,$Data,$texgrp,$outputfile,$inputfile,$fpgno,$cno,$cnolabel,$ctitle,$prelims,$seclabel,$figlabel,$tablabel,$biblabel,$citlabel,$notelabel,$featlabel,$eqnlabel,$listlabel,$cnt,$i,$xref);
my (@saveseclabel,@savefiglabel,@savetablabel,@savebiblabel,@savenotelabel,@saveeqnlabel,@savelistlabel,@featurelabel);
$texgrp = qr{\{(?: (?> [^{}]+ )|(??{ $texgrp }))*\}}x;

$cno = $1 if($tfile =~ m/\\setcounter\{chapter\}\{([0-9]+)\}/s);
$cno++;
$pos = $cno;
$pos++;
$pos = $pos*10;
$fpgno = $1 if($tfile =~ m/\\setcounter\{page\}\{([0-9]+)\}/s);
$ctitle = $2 if($tfile =~ m/\\chapter([^\{]*)($texgrp)\{\}\{\}/s);
$ctitle =~ s/^\{(.*?)\}$/$1/;
$datestring = strftime "%Y-%m-%d", localtime;
$fmtitle = "Service Management and Marketing";
$jobname = "gronroos";
$ISBNnum = "9781118921449";
if($cno<=9)
{
	$cnolabel = "c0$cno";
}
elsif(($cno>9)&($cno<=99))
{
	$cnolabel = "c$cno";
}

&write_prelims();
&misc_change();
&fig_change();
&tab_change();
&sec_change();
&list_change();
&math_change();
&last_change();
&entity_change();

###################################### FUNCTIONS ###############################
sub write_prelims()
{
	if($tfile=~/^(.*?)\\begin\{epigraph\}/s)
	{
		$tfile =~ s/(\w+) \n-/$1 -/g;
		$tfile =~ s/\\&/&amp\;/g;
		$tfile =~ s/\{&amp\;\}/&amp\;/g;
		$tfile =~ s/([a-zA-Z]+)-([a-zA-Z]+)/$1&hyphen\;$2/g;
		$tfile =~ s/([a-zA-Z]+)-([a-zA-Z]+)/$1&hyphen\;$2/g;
		$tfile =~ s/ -([a-zA-Z]+)/ &hyphen\;$1/g;
		$tfile =~ s/--/&ndash\;/g;
		$tfile =~ s/---/&mdash\;/g;
		$tfile =~ s/^(.*?)\\begin\{epigraph\}/\\begin\{epigraph\}/s;
		$prelims = "<?xml version=\"1.0\" encoding=\"US-ASCII\"?>\n<\!DOCTYPE component PUBLIC \"-\/\/JWS\/\/DTD WileyML 20110801 Vers 3Gv2.0\/\/EN\" \"file:C:\\Users\\wiley.xml\\Documentum\\XML%20Applications\\he\\WileyML3Gv20XMLApp\\Wileyml3gv20-flat.dtd\">\n<component xmlns:dctm=\"http:\/\/www.documentum.com\" type=\"bookChapter\" version=\"2.0\" xml:id=\"$jobname$ISBNnum$cnolabel\" xml:lang=\"en\" dctm:obj_status=\"Default\" dctm:obj_id=\"0901bd6f8364fe33\" dctm:version_label=\"CURRENT\" xmlns:wiley=\"http:\/\/www.wiley.com\/namespaces\/wiley\/wiley\" xmlns:cms=\"http:\/\/cms.wiley.com\" xmlns=\"http:\/\/www.wiley.com\/namespaces\/wiley\">\n<header>\n<publicationMeta level=\"product\">\n<publisherInfo>\n<publisherName>John Wiley &amp\; Sons, Inc.<\/publisherName>\n<publisherLoc>Hoboken, NJ, USA<\/publisherLoc>\n<\/publisherInfo>\n<isbn type=\"printPaper-13\">$ISBNnum<\/isbn>\n<idGroup>\n<id type=\"publisherDivision\" value=\"GE\"\/>\n<\/idGroup>\n<titleGroup>\n<title sort=\"\U$fmtitle\E\" type=\"main\">\U$fmtitle\E<\/title>\n<\/titleGroup>\n<copyright ownership=\"publisher\">Copyright &copy\; 2016, 2013, 2010, 2007, 2004, 2000, 1996 John Wiley &amp\; Sons, Inc. All rights reserved.<\/copyright>\n<numberingGroup>\n<numbering number=\"4\" type=\"edition\">4th Edition Binder Ready Version<\/numbering>\n<\/numberingGroup>\n<creators>\n<creator creatorRole=\"author\" xml:id=\"$cnolabel-cr-0001\">\n<personName>\n<givenNames>Gr&ouml\;nroos<\/givenNames>\n<familyName>Christian<\/familyName>\n<\/personName>\n<\/creator>\n<\/creators>\n<subjectInfo>\n<subject href=\"http:\/\/psi.wiley.com\/subject\/EC20, ECZ0, BA12\">XXXXXXXXXXXXX<\/subject>\n<\/subjectInfo>\n<\/publicationMeta>\n<publicationMeta level=\"unit\" position=\"$pos\" type=\"chapter\">\n<idGroup>\n<id type=\"unit\" value=\"$jobname$ISBNnum$cnolabel\"\/>\n<id type=\"file\" value=\"$jobname$ISBNnum$cnolabel\"\/>\n<\/idGroup>\n<eventGroup>\n<event agent=\"Aptara\" date=\"$datestring\" type=\"xmlCreated\"\/>\n<\/eventGroup>\n<numberingGroup>\n<numbering type=\"main\">$cno<\/numbering>\n<\/numberingGroup>\n<objectNameGroup>\n<objectName elementName=\"feature\">EXAMPLE<\/objectName>\n<\/objectNameGroup>\n<attributeValueGroup>\n<attributeValue attribute=\"type\" element=\"term\" value=\"glossary\"\/>\n<\/attributeValueGroup>\n<\/publicationMeta>\n<contentMeta>\n<titleGroup>\n<title sort=\"\U$ctitle\E\" type=\"main\">$ctitle<\/title>\n<\/titleGroup>\n<\/contentMeta>\n<\/header>\n<body sectionsNumbered=\"no\" xml:id=\"$cnolabel-body-0001\">\n";
	}
	$tfile = $prelims.$tfile;
	open(OUTFILE, "> $mypath\\$infilename-in.xml");
	print OUTFILE $tfile;
	close(OUTFILE);
}

#####################################################################
sub misc_change()
{
	$inputfile = "$mypath\\${infilename}-in.xml";
	$tfile = &read_file($inputfile);

	$tfile =~ s/  / /g;
	$tfile =~ s/\} \n/\} /g;
	$tfile =~ s/\) \n/\) /g;
	$tfile =~ s/([a-zA-Z]+)-\\break ([a-zA-Z]+)/$1$2/g;
	$tfile =~ s/\\hfill\\break//g;
	$tfile =~ s/\\break//g;
	$tfile =~ s/\\leftskip(\d+)pt//g;
	$tfile =~ s/\\leftskip-(\d+)pt//g;
	$tfile =~ s/\\rightskip(\d+)pt//g;
	$tfile =~ s/\\rightskip-(\d+)pt//g;
	$tfile =~ s/\{\\def\\spreadoutfactor{(\d+)\}\\spreadout($texgrp)\}/<sp>$2<\/sp>/g;
	$tfile =~ s/\{\\def\\spreadoutfactor{\.(\d+)\}\\spreadout($texgrp)\}/<sp>$2<\/sp>/g;
	$tfile =~ s/\{\\def\\spreadoutfactor{-(\d+)\}\\spreadout($texgrp)\}/<sp>$2<\/sp>/g;
	$tfile =~ s/\{\\def\\spreadoutfactor{-\.(\d+)\}\\spreadout($texgrp)\}/<sp>$2<\/sp>/g;
	$tfile =~ s/<sp>\{//g;
	$tfile =~ s/\}<\/sp>//g;
	$tfile =~ s/\\vspace\*\{-(.*?)\}\n/\n/g;
	$tfile =~ s/\\vspace\*\{(.*?)\}\n/\n/g;
	$tfile =~ s/\\vspace\*\{(.*?)\}//g;
	$tfile =~ s/\\vspace\*\{-(.*?)\}//g;
	$tfile =~ s/\\vspace\{(.*?)\}//g;
	$tfile =~ s/\\vspace\{-(.*?)\}//g;
	$tfile =~ s/\\hspace\*\{-(.*?)\}\n//g;
	$tfile =~ s/\\hspace\*\{(.*?)\}//g;
	$tfile =~ s/\\enlargethispage\{(.*?)\}//g;
	$tfile =~ s/\\vadjust\{(.*?)\}//g;
	$tfile =~ s/\\looseness-1//g;
	$tfile =~ s/\\looseness1//g;
	$tfile =~ s/\\pagebreak//g;
	$tfile =~ s/\\clearpage//g;
	$tfile =~ s/\\abc\\vs\{(.*?)\}//g;
	$tfile =~ s/ \n\{/ \{/g;
	$tfile =~ s/\\begin\{epigraph\}([^\{]*)($texgrp)([^\\]*)\\end\{epigraph\}/<blockquote>$2<\/blockquote>/s;
	$tfile =~ s/<blockquote>\{\\it (.*?)\}<\/blockquote>/<section type=\"opening\" xml\:id=\"$cnolabel-sec-0001\">\n<p><blockFixed type=\"quotation\"><p>$1<\/p><\/blockFixed><\/p>\n<\/section>/s;
	$tfile =~ s/(\w+) \n(\w+)/$1 $2/g;
	$tfile =~ s/(\w+)\n(\w+)/$1 $2/g;
	$tfile =~ s/\n\(/\(/g;
	$tfile =~ s/\' \n(\w+)/\' $1/g;
	$tfile =~ s/, \n(\w+)/, $1/g;
	$tfile =~ s/\. \n(\w+)/\. $1/g;
	$tfile =~ s/\: \n(\w+)/\: $1/g;
	$tfile =~ s/\{\\itshape /\\textit\{/g;
	$tfile =~ s/\{\\bfseries /\\textbf\{/g;
	$tfile =~ s/\{\\bf /\\textbf\{/g;
	$tfile =~ s/\{\\it /\\textit\{/g;
	$tfile =~ s/\{\\hit /\\textit\{/g;
	$tfile =~ s/\{\\rm /\\textrm\{/g;
	$tfile =~ s/\\textrm($texgrp)/<txtr>$1<\/txtr>/g;
	$tfile =~ s/<txtr>\{//g;
	$tfile =~ s/\}<\/txtr>//g;
	$tfile =~ s/\\textit($texgrp)/<i>$1<\/i>/g;
	$tfile =~ s/<i>\{(.*?)\}<\/i>/<i>$1<\/i>/g;
	$tfile =~ s/\\textbf($texgrp)/<b>$1<\/b>/g;
	$tfile =~ s/<b>\{(.*?)\}<\/b>/<b>$1<\/b>/g;
	$tfile =~ s/[%]+//g;
	$tfile =~ s/\n{3,}/\n\n/g;
	$tfile =~ s/\n\n\\item/\n\\item/g;
	$tfile =~ s/\\ / /g;
	$tfile =~ s/\; \n([a-zA-Z])/\; $1/g;
	$tfile =~ s/\. \n([a-zA-Z])/\. $1/g;
	$tfile =~ s/, \n</, </g;
	$tfile =~ s/\. \n</\. </g;
	$tfile =~ s/\{\\&\} \n/\{\\&\} /g;
	$tfile =~ s/\\hbox($texgrp)/<hb>$1<\/hb>/g;
	$tfile =~ s/\\h($texgrp)/<hb>$1<\/hb>/g;
	$tfile =~ s/<hb>\{//g;
	$tfile =~ s/\}<\/hb>//g;
	$tfile =~ s/\\hbox//g;
	$tfile =~ s/\\vbox($texgrp)/<vb>$1<\/vb>/g;
	$tfile =~ s/<vb>\{//g;
	$tfile =~ s/\}<\/vb>//g;

	$outputfile = "$mypath\\${infilename}-New.xml";
	open(OUTFILE,">${outputfile}");
	print OUTFILE $tfile;
	close(OUTFILE);
	unlink("$inputfile");
	rename($outputfile,$inputfile);
}

sub fig_change()
{
	$inputfile = "$mypath\\${infilename}-in.xml";
	$tfile = &read_file($inputfile);

	$cnt =1;
	$i = 0;
	while($tfile=~/\\begin\{figure\}/s)
	{
		if($cnt<=9)
		{
			$figlabel = "$cnolabel-fig-000$cnt";
			$cnt++;
		}
		elsif(($cnt>9)&($cnt<=99))
		{
			$figlabel = "$cnolabel-fig-00$cnt";
			$cnt++;
		}
		else
		{
			$figlabel = "$cnolabel-fig-0$cnt";
			$cnt++;
		}
		$savefiglabel[$i++] = $figlabel;
		$tfile =~ s/\\begin\{figure\}(.*?)\n/<figure xml\:id=\"$figlabel\">\n/s;
		$tfile =~ s/.eps\} \{/.eps\}\{/s;
		$tfile =~ s/\\figcaption($texgrp)/<caption>$1<\/caption>/g;
		$tfile =~ s/ \\figcaption($texgrp)/<caption>$1<\/caption>/g;
		$tfile =~ s/\\xfig\{(.*?)\}($texgrp)/<mediaResource alt=\"$1\" cms:chunk=\"yes\" copyright=\"John Wiley &amp\; Sons, Inc.\" eRights=\"yes\" href=\"urn\:x-wiley\:$ISBNnum\:media\:$jobname$ISBNnum$cnolabel\:$1\" pRights=\"yes\"\/>\n<caption>$2<\/caption>/s;
		$tfile =~ s/.eps\"/\"/g;
		$tfile =~ s/<caption>\{(.*?)\}<\/caption>/<caption>$1<\/caption>/s;
		$tfile =~ s/\\figsource($texgrp)/<source>$1<\/source>/s;
		$tfile =~ s/<source>\{(.*?)\}<\/source>/<source>$1<\/source>/s;
		$tfile =~ s/\\fignote($texgrp)/<note>$1<\/note>/s;
		$tfile =~ s/<note>\{(.*?)\}<\/note>/<note>$1<\/note>/s;
		$tfile =~ s/\\label\{(.*?)\}//gs;
		$tfile =~ s/\\end\{figure\}/<\/figure>/s;
		$tfile =~ s/<\/caption>([^<]*)<\/figure>/<\/caption>\n<\/figure>/gs;
		$tfile =~ s/\">([^<]*)<mediaResource/\">\n<mediaResource/gs;
	}

	$outputfile = "$mypath\\${infilename}-New.xml";
	open(OUTFILE,">${outputfile}");
	print OUTFILE $tfile;
	close(OUTFILE);
	unlink("$inputfile");
	rename($outputfile,$inputfile);
}

##################################################################################################
sub tab_change()
{
	$inputfile = "$mypath\\${infilename}-in.xml";
	$tfile = &read_file($inputfile);

	my ($totcol,$temp);
	$cnt =1;
	$i = 0;
	while($tfile=~/\\begin\{table\}/s)
	{
		if($cnt<=9)
		{
			$tablabel = "$cnolabel-tab-000$cnt";
			$cnt++;
		}
		elsif(($cnt>9)&($cnt<=99))
		{
			$tablabel = "$cnolabel-tab-00$cnt";
			$cnt++;
		}
		else
		{
			$tablabel = "$cnolabel-tab-0$cnt";
			$cnt++;
		}
		$savetablabel[$i++] = $tablabel;

		if($tfile=~/\\begin\{table\}(.*?)\\end\{table\}/s)
		{
			$Data = $1;
			$tfile =~ s/\\begin\{table\}/<tabular copyright=\"John Wiley &amp\; Sons, Inc.\" eRights=\"yes\" pRights=\"yes\" xml:id=\"$tablabel\">\n/s;
			$tfile =~ s/\\TABLE \{/\\TABLE\{/s;
			$tfile =~ s/\\TABLE($texgrp)/<title type=\"main\">$1<\/title>/s;
			$tfile =~ s/<title type=\"main\">\{(.*?)\}<\/title>/<title type=\"main\">$1<\/title>/s;
			$tfile =~ s/\">([^<]*)<title/\">\n<title/gs;

			$temp = "";
			my $m=1;
			$totcol = 0;
			while($Data =~ /\\RRtab/g)
			{
				$totcol++;
				$temp = $temp."\n<colspec align=\"left\" colname=\"col$m\" colnum=\"$m\"/>";
				$m++;
			}

			#print "Table $i -> Total column -> $totcol\n";
			$tfile =~ s/\{\\fontfamily{\\(\w+)}\\fontsize{(.*?)}{(.*?)}\\selectfont\\begin{tabular\*\}/\{\\begin{tabular\*\}/s;
			$tfile =~ s/\{\\begin{tabular\*\}\{\\textwidth\}($texgrp)/<table frame=\"topbot\">\n<tgroup cols=\"$totcol\">$temp\n<tbody>\n<row>\n<entry colname=\"colXXX\" valign=\"top\">/s;
			$tfile =~ s/\\(\w{3})rule\n//s;
			$tfile =~ s/\\(\w{3})rule //s;
			$tfile =~ s/\\bottomrule\n//s;
			$tfile =~ s/\\bottomrule //s;
			$tfile =~ s/<tabular copyright=\"John Wiley &amp\; Sons, Inc.\" eRights=\"yes\" pRights=\"yes\" xml:id=\"$tablabel\">([^<]*)/<tabular copyright=\"John Wiley &amp\; Sons, Inc.\" eRights=\"yes\" pRights=\"yes\" xml:id=\"$tablabel\">\n/s;
			$tfile =~ s/\\end\{tabular\*\}\}\n\{\}\n//s;
			$tfile =~ s/\\end\{tabular\*\}\}\n\{\}//s;
			$tfile =~ s/\\end\{tabular\*\}\}\{\}\n//s;
			$tfile =~ s/\\end\{table\}/<\/tabular>/s;
			$tfile =~ s/\n\n<\/tabular>/\n<\/tabular>/s;
			$tfile =~ s/\n<\/tabular>/<\/tabular>/s;
			$tfile =~ s/\\\\\[(\d+)pt\]\n/<\/entry>\n<\/row>\n<row>\n<entry colname=\"colXXX\" valign=\"top\">/g;
			$tfile =~ s/\\\\\[(\d+)\.(\d+)pt\]\n/<\/entry>\n<\/row>\n<row>\n<entry colname=\"colXXX\" valign=\"top\">/g;
			$tfile =~ s/\\\\\n/<\/entry>\n<\/row>\n<row>\n<entry colname=\"colXXX\" valign=\"top\">/g;
			$tfile =~ s/<tbody>\n<row>\n<entry colname=\"colXXX\" valign=\"top\">\n/<tbody>\n<row>\n<entry colname=\"colXXX\" valign=\"top\">/s;
			$tfile =~ s/\& /<\/entry>\n<entry colname=\"colXXX\" valign=\"top\">/g;
			$tfile =~ s/<entry colname=\"colXXX\" valign=\"top\">\n/<entry colname=\"colXXX\" valign=\"top\">/g;

			while($tfile=~/<row>(.*?)<\/row>/s)
			{
				my $rowdata = $1;
				my $colnum = 1;
				while($rowdata =~ /<entry colname=\"colXXX\" valign=\"top\">/s)
				{
					$rowdata =~ s/<entry colname=\"colXXX\" valign=\"top\">/<entry colname=\"col$colnum\" valign=\"top\">/s;
					$colnum++;
					if($colnum > $totcol)
					{
						last;
					}
				}
				$tfile =~ s/<row>(.*?)<\/row>/<Xrow>$rowdata<\/row>/s;
			}
		}
	}
	$tfile =~ s/<Xrow>/<row>/g;
	$tfile =~ s/<row>\n<entry colname=\"col([0-9]+)\" valign=\"top\"> <\/tabular>/<\/tbody>\n<\/tabular>/g;
	$tfile =~ s/<row>\n<entry colname=\"colXXX\" valign=\"top\"> <\/tabular>/<\/tbody>\n<\/tabular>/g;
	$tfile =~ s/<entry colname=\"col([0-9]+)\" valign=\"top\">\{/<entry colname=\"col$1\" valign=\"top\">/g;
	$tfile =~ s/<entry colname=\"col([0-9]+)\" valign=\"top\">\{/<entry colname=\"col$1\" valign=\"top\">/g;
	$tfile =~ s/\} <\/entry>/<\/entry>/g;
	$tfile =~ s/\}<\/entry>/<\/entry>/g;
	$tfile =~ s/ <\/entry>/<\/entry>/g;
	$tfile =~ s/\\multicolumn\{(\d+)\}\{\@\{\}([l|c|r])\@\{\}\}\{//g;

	$outputfile = "$mypath\\${infilename}-New.xml";
	open(OUTFILE,">${outputfile}");
	print OUTFILE $tfile;
	close(OUTFILE);
	unlink("$inputfile");
	rename($outputfile,$inputfile);
}
##################################################################################################	
sub sec_change()
{
	$inputfile = "$mypath\\${infilename}-in.xml";
	$tfile = &read_file($inputfile);

	while($tfile=~/\\section([^\{]*)($texgrp)/s)
	{
		$tfile =~ s/\\section\{Notes\}//s;
		$tfile =~ s/\\section\{Further Reading\}//s;
		$tfile =~ s/\\section([^\{]*)($texgrp)/\n<\/section>\n<section xml:id=\"\" role=\"1\">\n<title type=\"main\">\U$2\E<\/title>\n/s;
		$tfile =~ s/<section xml:id=\"\" role=\"1\">\n<title type=\"main\">\{(.*?)\}<\/title>\n/<section xml:id=\"\" role=\"1\">\n<title type=\"main\">$1<\/title>\n<p>/s;
		$tfile =~ s/\\subsection([^\{]*)($texgrp)/\n<\/section>\n<section xml:id=\"\" role=\"2\">\n<title type=\"main\">$2<\/title>\n/s;
		$tfile =~ s/<section xml:id=\"\" role=\"2\">\n<title type=\"main\">\{(.*?)\}<\/title>\n/<section xml:id=\"\" role=\"2\">\n<title type=\"main\">$1<\/title>\n<p>/s;
		$tfile =~ s/\\subsubsection([^\{]*)($texgrp)/\n<\/section>\n<section xml:id=\"\" role=\"3\">\n<title type=\"main\">$2<\/title>\n/s;
		$tfile =~ s/<section xml:id=\"\" role=\"3\">\n<title type=\"main\">\{(.*?)\}<\/title>\n/<section xml:id=\"\" role=\"3\">\n<title type=\"main\">$1<\/title>\n<p>/s;
	}
	$tfile =~ s/\\begin\{summary\}\n\n\\boxhead\{Summary\}\n/\n<\/section>\n<section xml:id=\"\" role=\"1\">\n<title type=\"main\">Summary<\/title>\n/s;
	$tfile =~ s/\\end\{summary\}/<\/section>/s;

	$cnt =2;
	$saveseclabel[0] = "$cnolabel-sec-0001";
	$i = 1;
	while($tfile=~/<section xml:id=\"\"/s)
	{
		if($cnt<=9)
		{
			$seclabel = "$cnolabel-sec-000$cnt";
			$cnt++;
		}
		elsif(($cnt>9)&($cnt<=99))
		{
			$seclabel = "$cnolabel-sec-00$cnt";
			$cnt++;
		}
		else
		{
			$seclabel = "$cnolabel-sec-0$cnt";
			$cnt++;
		}
		$saveseclabel[$i++] = $seclabel;

		$tfile =~ s/<section xml:id=\"\"/<Xsection xml:id=\"$seclabel\"/s;
	}
	$tfile =~ s/<Xsection/<section/g;
	$tfile =~ s/<p>\n/<p>/g;
	$tfile =~ s/<\/title>\n\n\n/<\/title>/g;
	$tfile =~ s/<\/title>\n\n/<\/title>/g;
	$tfile =~ s/<\/title>\\/<\/title>\n\\/g;
	$tfile =~ s/<\/title>(\w+)/<\/title>\n$1/g;
	$tfile =~ s/\\begin\{framed\}//s;
	$tfile =~ s/\\end\{framed\}//s;
	$tfile =~ s/\n{3}<\/section>/<\/section>/g;
	$tfile =~ s/\n{2}<\/section>/\n<\/section>/g;
	$tfile =~ s/ <\/section>/<\/p>\n<\/section>/g;
	$tfile =~ s/\.<\/section>/\.<\/p>\n<\/section>/g;
	$tfile =~ s/<\/section><\/section>/<\/section>/s;
	$tfile =~ s/<\/section>\n<\/section>/<\/section>/s;

	$outputfile = "$mypath\\${infilename}-New.xml";
	open(OUTFILE,">${outputfile}");
	print OUTFILE $tfile;
	close(OUTFILE);
	unlink("$inputfile");
	rename($outputfile,$inputfile);
}


sub list_change()
{
	$inputfile = "$mypath\\${infilename}-in.xml";
	$tfile = &read_file($inputfile);


	if($tfile =~ /\\begin\{Enotes\}(.*?)\\end\{Enotes\}/s)
	{
		$Data = $1;
		$Data =~ s/\\item\[([0-9]+)\.\]/\\notesitem\[$1\.\]/g;
		$cnt =1;
		$i = 0;
		while($Data =~ /\\notesitem\[(\d+)\.\]/s)
		{
			if($cnt<=9)
			{
				$notelabel = "$cnolabel-note-000$cnt";
				$cnt++;
			}
			elsif(($cnt>9)&($cnt<=99))
			{
				$notelabel = "$cnolabel-note-00$cnt";
				$cnt++;
			}
			else
			{
				$notelabel = "$cnolabel-note-0$cnt";
				$cnt++;
			}
			$savenotelabel[$i++] = $notelabel;

			$Data =~ s/\] \n/\] /g;
			$Data =~ s/\]\n/\] /g;
			$Data =~ s/\\notesitem\[(\d+)\.\] (.*?)\n/<note xml\:id=\"$notelabel\">$2<\/note>\n/s;
		}
		$tfile =~ s/\\begin\{Enotes\}\{([0-9]+)\.\}(.*?)\\end\{Enotes\}/<noteGroup onlyChannels=\"notWileyPlusLS\" xml\:id=\"$cnolabel-ntgp-0001\">\n<title type=\"main\">ENDNOTES<\/title>\n$Data\n<\/noteGroup>/s;
		$tfile =~ s/\n\n<\/noteGroup>/\n<\/noteGroup>/s;
		$tfile =~ s/<title type=\"main\">ENDNOTES<\/title>\n\{(\d+)\.\}\n<note/<title type=\"main\">ENDNOTES<\/title>\n<note/s;
		$tfile =~ s/<section xml\:id=\"$cnolabel-sec-([0-9]+)\" role=\"1\">\n<title type=\"main\">Notes<\/title>\n<noteGroup/<noteGroup/s;
	}

	################################################################################
	while($tfile=~/\\begin\{BL\}(.*?)\\end\{BL\}/s)
	{
		$tfile =~ s/\\begin\{BL\}/<list style=\"bulleted\">/s;
		$tfile =~ s/\\end\{BL\}/<\/list>/s;
		$tfile =~ s/\\item (.*?)\n/<listItem>$1<\/listItem>\n/s;
		$tfile =~ s/\\item (.+?)\n/<listItem>$1<\/listItem>\n/s;
		$tfile =~ s/\\item ([a-zA-Z0-9]+) (.*?)\n/<listItem>$1 $2<\/listItem>\n/s;
	}	
	while($tfile=~/\\begin\{figBL\}(.*?)\\end\{figBL\}/s)
	{
		$tfile =~ s/\\begin\{figBL\}/<list style=\"bulleted\">/s;
		$tfile =~ s/\\end\{figBL\}/<\/list>/s;
		$tfile =~ s/\\item (.*?)\n/<listItem>$1<\/listItem>\n/s;
		$tfile =~ s/\\item (.+?)\n/<listItem>$1<\/listItem>\n/s;
		$tfile =~ s/\\item ([a-zA-Z0-9]+) (.*?)\n/<listItem>$1 $2<\/listItem>\n/s;
	}	

	while($tfile=~/\\begin\{NLh\}\{(\d+)\.\}(.*?)\\end\{NLh\}/s)
	{
		$tfile =~ s/\\begin\{NLh\}\{(\d+)\.\}/<list style=\"1\">/s;
		$tfile =~ s/\\end\{NLh\}/<\/list>/s;
		$tfile =~ s/\\item\[(\d+)\.\] (.*?)\n/<listItem>$2<\/listItem>\n/s;
		$tfile =~ s/\\item\[(\d+)\.\] (.+?)\n/<listItem>$2<\/listItem>\n/s;
		$tfile =~ s/\\item\[(\d+)\.\] ([a-zA-Z0-9]+) (.*?)\n/<listItem>$2 $3<\/listItem>\n/s;
	}	

	while($tfile=~/\\begin\{figNLh\}\{(\d+)\.\}(.*?)\\end\{figNLh\}/s)
	{
		$tfile =~ s/\\begin\{figNLh\}\{(\d+)\.\}/<list style=\"1\">/s;
		$tfile =~ s/\\end\{figNLh\}/<\/list>/s;
		$tfile =~ s/\\item\[(\d+)\.\] (.*?)\n/<listItem>$2<\/listItem>\n/s;
		$tfile =~ s/\\item\[(\d+)\.\] (.+?)\n/<listItem>$2<\/listItem>\n/s;
		$tfile =~ s/\\item\[(\d+)\.\]\n(.*?)\n/<listItem>$2<\/listItem>\n/g;
		$tfile =~ s/\\item\[(\d+)\.\] \n(.*?)\n/<listItem>$2<\/listItem>\n/g;
		$tfile =~ s/\\item\[(\d+)\.\] ([a-zA-Z0-9]+) (.*?)\n/<listItem>$2 $3<\/listItem>\n/s;
	}	

	while($tfile=~/\\begin\{boxNLh\}\{(\d+)\.\}(.*?)\\end\{boxNLh\}/s)
	{
		$tfile =~ s/\\begin\{boxNLh\}\{(\d+)\.\}/<list style=\"1\">/s;
		$tfile =~ s/\\end\{boxNLh\}/<\/list>/s;
		$tfile =~ s/\\item\[(\d+)\.\] (.*?)\n/<listItem>$2<\/listItem>\n/s;
		$tfile =~ s/\\item\[(\d+)\.\] (.+?)\n/<listItem>$2<\/listItem>\n/s;
		$tfile =~ s/\\item\[(\d+)\.\] ([a-zA-Z0-9]+) (.*?)\n/<listItem>$2 $3<\/listItem>\n/s;
	}	
	$tfile =~ s/\\item\[(\d+)\.\] (.*?)\n/<listItem>$2<\/listItem>\n/s;
	$tfile =~ s/<\/listItem>\n\n<listItem>/<\/listItem>\n<listItem>/g;
	$tfile =~ s/\n\n<\/list>/\n<\/list>/g;

	$cnt =1;
	$i = 0;
	while($tfile=~/<list style=\"(.*?)\">/s)
	{
		if($cnt<=9)
		{
			$listlabel = "$cnolabel-list-000$cnt";
			$cnt++;
		}
		elsif(($cnt>9)&($cnt<=99))
		{
			$listlabel = "$cnolabel-list-00$cnt";
			$cnt++;
		}
		else
		{
			$listlabel = "$cnolabel-list-0$cnt";
			$cnt++;
		}
		$savelistlabel[$i++] = $listlabel;

		$tfile =~ s/<list style=\"(.*?)\">/<Xlist style=\"$1\" xml\:id=\"$listlabel\">/s;
	}
	$tfile =~ s/<Xlist/<list/g;


	###########################################################################################
	$tfile =~ s/\\begin\{thebibliography\}\{(\d+)\}/\\begin\{thebibliography\}/g;
	while($tfile =~ /\\begin\{thebibliography\}(.*?)\\end\{thebibliography\}/s)
	{
		$Data = $1;

		$cnt =1;
		$i = 0;
		while($Data =~ /\\bibitem\{\}/s)
		{
			if($cnt<=9)
			{
				$biblabel = "$cnolabel-bib-000$cnt";
				$citlabel = "$cnolabel-cit-000$cnt";
				$cnt++;
			}
			elsif(($cnt>9)&($cnt<=99))
			{
				$biblabel = "$cnolabel-bib-00$cnt";
				$citlabel = "$cnolabel-cit-00$cnt";
				$cnt++;
			}
			else
			{
				$biblabel = "$cnolabel-bib-0$cnt";
				$citlabel = "$cnolabel-cit-0$cnt";
				$cnt++;
			}
			$savebiblabel[$i++] = $biblabel;

			$Data =~ s/\\bibitem\{\}\n(.*?)\n/<bib xml\:id=\"$biblabel\"><citation type=\"journal\" xml\:id=\"$citlabel\">$1<\/citation><\/bib>\n/s;
			$Data =~ s/(\w+), ([A-Z])\.([A-Z])\.([A-Z])\./<author><familyName>$1<\/familyName>, <givenNames>$2.$3.$4.<\/givenNames><\/author>/g;
			$Data =~ s/(\w+), ([A-Z])\.([A-Z])\./<author><familyName>$1<\/familyName>, <givenNames>$2.$3.<\/givenNames><\/author>/g;
			$Data =~ s/(\w+), ([A-Z])\./<author><familyName>$1<\/familyName>, <givenNames>$2.<\/givenNames><\/author>/g;
			$Data =~ s/\((\d)(\d)(\d)(\d)\)/\(<pubYear year=\"$1$2$3$4\">$1$2$3$4<\/pubYear>\)/g;
			$Data =~ s/\((\d)(\d)(\d)(\d)([a-zA-Z])\)/\(<pubYear year=\"$1$2$3$4$5\">$1$2$3$4$5<\/pubYear>\)/g;
			$Data =~ s/<b>(\d+)<\/b>/<vol>$1<\/vol>/g;
			$Data =~ s/\((\d+)\)/\(<issue>$1<\/issue>\)/g;
			$Data =~ s/<i>(.*?)<\/i>/<journalTitle>$1<\/journalTitle>/g;
			$Data =~ s/(\d+)&ndash\;(\d+)/<pageFirst>$1<\/pageFirst>&ndash\;<pageLast>$2<\/pageLast>/g;
		}
		$tfile =~ s/<section xml\:id=\"$cnolabel-sec-([0-9]+)\" role=\"1\">\n<title type=\"main\">Further Reading<\/title>\n//s;
		$tfile =~ s/\\begin\{thebibliography\}(.*?)\\end\{thebibliography\}/<bibliography cited=\"no\" style=\"nameDate\" xml\:id=\"$cnolabel-bibl-0001\">\n<title type=\"main\">FURTHER READING<\/title>\n$Data\n<\/bibliography>/s;
		$tfile =~ s/\n\n<bib /\n<bib /g;
		$tfile =~ s/\n\n<\/bibliography>/\n<\/bibliography>/g;

	}
	###########################################################################################
			
	$outputfile = "$mypath\\${infilename}-New.xml";
	open(OUTFILE,">${outputfile}");
	print OUTFILE $tfile;
	close(OUTFILE);
	unlink("$inputfile");
	rename($outputfile,$inputfile);
}

sub math_change()
{
	$inputfile = "$mypath\\${infilename}-in.xml";
	$tfile = &read_file($inputfile);

	$tfile =~ s/\$\^\{(\d+)\}\$/<sup>$1<\/sup>/g;
	$tfile =~ s/\$\^\{\\mathrm\{(\d+)\\thinspace \}\}\$/<sup>$1<\/sup>/g;
	$tfile =~ s/\$\^\{\\mathrm\{(\d+)\}\}\$/<sup>$1<\/sup>/g;
	$tfile =~ s/\$\_\{(\d+)\}\$/<sub>$1<\/sub>/g;

	while($tfile =~ /<sup>([0-9]+)<\/sup>/s)
	{
		$xref = $1;
		$xref--;
		$tfile =~ s/<sup>([0-9]+)<\/sup>/<link href=\"urn\:x-wiley\:$ISBNnum\:xml-component\:$jobname$ISBNnum$cnolabel\:$savenotelabel[$xref]\"\/>/s;
	}
	
	$outputfile = "$mypath\\${infilename}-New.xml";
	open(OUTFILE,">${outputfile}");
	print OUTFILE $tfile;
	close(OUTFILE);
	unlink("$inputfile");
	rename($outputfile,$inputfile);
}

sub last_change()
{
	$inputfile = "$mypath\\${infilename}-in.xml";
	$tfile = &read_file($inputfile);
#	$tfile =~ s/\\label\{(.*?)\}\n//g;
#	$tfile =~ s/\\label\{(.*?)\}//g;

	while($tfile =~ /Figure $cno.([0-9]+)/s)
	{
		$xref = $1;
		$xref--;
		$tfile =~ s/Figure $cno\.([0-9]+)/Figure <link href=\"urn\:x-wiley\:$ISBNnum\:xml-component\:$jobname$ISBNnum$cnolabel\:$savefiglabel[$xref]"\/>/s;
		$tfile =~ s/Figure\~$cno\.([0-9]+)/Figure <link href=\"urn\:x-wiley\:$ISBNnum\:xml-component\:$jobname$ISBNnum$cnolabel\:$savefiglabel[$xref]"\/>/s;
	}

	while($tfile =~ /Section $cno.([0-9]+)/s)
	{
		$xref = $1;
		$xref--;
		$tfile =~ s/Section $cno\.([0-9]+)/Section <link href=\"urn\:x-wiley\:$ISBNnum\:xml-component\:$jobname$ISBNnum$cnolabel\:$saveseclabel[$xref]"\/>/s;
		$tfile =~ s/Section\~$cno\.([0-9]+)/Section <link href=\"urn\:x-wiley\:$ISBNnum\:xml-component\:$jobname$ISBNnum$cnolabel\:$saveseclabel[$xref]"\/>/s;
	}

	while($tfile =~ /section $cno.([0-9]+)/s)
	{
		$xref = $1;
		$xref--;
		$tfile =~ s/section $cno\.([0-9]+)/section <link href=\"urn\:x-wiley\:$ISBNnum\:xml-component\:$jobname$ISBNnum$cnolabel\:$saveseclabel[$xref]"\/>/s;
		$tfile =~ s/section\~$cno\.([0-9]+)/section <link href=\"urn\:x-wiley\:$ISBNnum\:xml-component\:$jobname$ISBNnum$cnolabel\:$saveseclabel[$xref]"\/>/s;
	}

	while($tfile =~ /Table $cno.([0-9]+)/s)
	{
		$xref = $1;
		$xref--;
		$tfile =~ s/Table $cno\.([0-9]+)/Table <link href=\"urn\:x-wiley\:$ISBNnum\:xml-component\:$jobname$ISBNnum$cnolabel\:$savetablabel[$xref]"\/>/s;
		$tfile =~ s/Table\~$cno\.([0-9]+)/Table <link href=\"urn\:x-wiley\:$ISBNnum\:xml-component\:$jobname$ISBNnum$cnolabel\:$savetablabel[$xref]"\/>/s;
	}

	if($tfile =~ /<list style=\"1\" xml\:id=\"c([0-9]+)-([a-zA-Z]+)-([0-9]+)\">(.*?)<\/list>/s)
	{
		while($tfile =~ /\\item\[([0-9]+)\.\]/s)
		{
			$tfile =~ s/\\item\[([0-9]+)\.\] (.*?)\n/<listItem>$2<\/listItem>\n/s;
		}
	}

	while($tfile =~ /\\begin\{casestudy\}(.*?)\\end\{casestudy\}/s)
	{
		$tfile =~ s/\\begin\{casestudy\}/<feature xml\:id=\"\">\n<titleGroup>\n<title type=\"featureName\">CASE STUDY<\/title>\n/s;
		$tfile =~ s/\\casehead\{CASE STUDY\}//s;
		$tfile =~ s/\\boxsubhead($texgrp)/<featuretitle type=\"main\">$1<\/featuretitle>/s;
		$tfile =~ s/<featuretitle type=\"main\">\{/<title type=\"main\">/s;
		$tfile =~ s/\}<\/featuretitle>/<\/title>\n<\/titleGroup>/s;
		$tfile =~ s/\\end\{casestudy\}/<\/feature>/s;
		$tfile =~ s/<title type=\"featureName\">CASE STUDY<\/title>([^<]*)<title type=\"main\">/<title type=\"featureName\">CASE STUDY<\/title>\n<title type=\"main\">/gs;

	}

	$cnt =1;
	$i = 0;
	while($tfile=~/<feature xml:id=\"\"/s)
	{
		if($cnt<=9)
		{
			$featlabel = "$cnolabel-fea-000$cnt";
			$cnt++;
		}
		elsif(($cnt>9)&($cnt<=99))
		{
			$featlabel = "$cnolabel-fea-00$cnt";
			$cnt++;
		}
		else
		{
			$featlabel = "$cnolabel-fea-0$cnt";
			$cnt++;
		}
		$featurelabel[$i++] = $featlabel;

		$tfile =~ s/<feature xml:id=\"\"/<Xfeature xml:id=\"$featlabel\"/s;
	}
	$tfile =~ s/<Xfeature /<feature /g;
	$tfile =~ s/<\/feature>([^<]*)<feature xml:id=\"c(\d+)-fea-(\d+)\">\n<titleGroup>\n<title type=\"featureName\">CASE STUDY<\/title>//s;

	$tfile =~ s/\\begin\{extract\}/<blockFixed type=\"quotation\">\n<p>/g;
	$tfile =~ s/\\end\{extract\}/<\/p>\n<\/blockFixed>/g;
	$tfile =~ s/\\begin\{boxextract\}/<blockFixed type=\"quotation\">\n<p>/g;
	$tfile =~ s/\\end\{boxextract\}/<\/p>\n<\/blockFixed>/g;

	
	$tfile =~ s/\n{3}<noteGroup/<noteGroup/s;
	$tfile =~ s/\n{2}<noteGroup/<noteGroup/s;
	$tfile =~ s/<\/list>\n<noteGroup/<\/list><\/p>\n<\/section>\n<noteGroup/s;
	$tfile =~ s/<p>\n<list/<p><list/g;
	$tfile =~ s/(\w+)\.\n\n(\w+)/$1\.<\/p>\n<p>$2/g;
	$tfile =~ s/(\w+)\. \n\n(\w+)/$1\.<\/p>\n<p>$2/g;
	$tfile =~ s/>\.\n\n(\w+)/>\.<\/p>\n<p>$1/g;
	$tfile =~ s/>\. \n\n(\w+)/>\.<\/p>\n<p>$1/g;
	$tfile =~ s/(\w+)\.\n\n/$1\.<\/p>\n/g;
	$tfile =~ s/\n\n(\w+)/\n<p>$1/g;
	$tfile =~ s/\n\n<list/\n<list/g;
	$tfile =~ s/<p>\n/<p>/g;
	$tfile =~ s/<link (.*?)\/>\n<p>/<link $1\/><\/p>\n<p>/g;
	$tfile =~ s/<\/i>\n<p>/<\/i><\/p>\n<p>/g;
	$tfile =~ s/<\/i>\n<\/p>/<\/i><\/p>/g;
	$tfile =~ s/\.\n<\/p>/\.<\/p>/g;
	$tfile =~ s/\\thispagestyle\{plain\}//s;
	$tfile =~ s/\\end\{document\}/\n<\/body>\n<\/component>/s;
			
	$outputfile = "$mypath\\${infilename}-New.xml";
	open(OUTFILE,">${outputfile}");
	print OUTFILE $tfile;
	close(OUTFILE);
	unlink("$inputfile");
	rename($outputfile,$inputfile);
}

sub entity_change()
{
	$inputfile = "$mypath\\${infilename}-in.xml";
	$tfile = &read_file($inputfile);

#	$tfile = enttity::entityrep($tfile);

	$tfile =~ s/\\circ /&circ\;/g;
	$tfile =~ s/\\dot /&dot\;/g;
	$tfile =~ s/\\grave /&grave\;/g;
	$tfile =~ s/\\macr /&macr\;/g;
	$tfile =~ s/\\ogon /&ogon\;/g;
	$tfile =~ s/\\ring /&ring\;/g;
	$tfile =~ s/\\tilde /&tilde\;/g;
	$tfile =~ s/\\alpha /&alpha\;/g;
	$tfile =~ s/\\beta /&beta\;/g;
	$tfile =~ s/\\gamma /&gamma\;/g;
	$tfile =~ s/\\Gamma /&Gamma\;/g;
	$tfile =~ s/\\delta /&delta\;/g;
	$tfile =~ s/\\Delta /&Delta\;/g;
	$tfile =~ s/\\epsi /&epsi\;/g;
	$tfile =~ s/\\epsiv /&epsiv\;/g;
	$tfile =~ s/\\epsis /&epsis\;/g;
	$tfile =~ s/\\zeta /&zeta\;/g;
	$tfile =~ s/\\eta /&eta\;/g;
	$tfile =~ s/\\theta /&theta\;/g;
	$tfile =~ s/\\Theta /&Theta\;/g;
	$tfile =~ s/\\thetav /&thetav\;/g;
	$tfile =~ s/\\iota /&iota\;/g;
	$tfile =~ s/\\kappa /&kappa\;/g;
	$tfile =~ s/\\kappav /&kappav\;/g;
	$tfile =~ s/\\lambda /&lambda\;/g;
	$tfile =~ s/\\Lambda /&Lambda\;/g;
	$tfile =~ s/\\mu /&mu\;/g;
	$tfile =~ s/\\nu /&nu\;/g;
	$tfile =~ s/\\xi /&xi\;/g;
	$tfile =~ s/\\Xi /&Xi\;/g;
	$tfile =~ s/\\pi /&pi\;/g;
	$tfile =~ s/\\piv /&piv\;/g;
	$tfile =~ s/\\Pi /&Pi\;/g;
	$tfile =~ s/\\rho /&rho\;/g;
	$tfile =~ s/\\rhov /&rhov\;/g;
	$tfile =~ s/\\sigma /&sigma\;/g;
	$tfile =~ s/\\Sigma /&Sigma\;/g;
	$tfile =~ s/\\sigmav /&sigmav\;/g;
	$tfile =~ s/\\tau /&tau\;/g;
	$tfile =~ s/\\upsi /&upsi\;/g;
	$tfile =~ s/\\Upsi /&Upsi\;/g;
	$tfile =~ s/\\phis /&phis\;/g;
	$tfile =~ s/\\Phi /&Phi\;/g;
	$tfile =~ s/\\phiv /&phiv\;/g;
	$tfile =~ s/\\chi /&chi\;/g;
	$tfile =~ s/\\psi /&psi\;/g;
	$tfile =~ s/\\Psi /&Psi\;/g;
	$tfile =~ s/\\omega /&omega\;/g;
	$tfile =~ s/\\Omega /&Omega\;/g;
	$tfile =~ s/\\times /&times\;/g;
	$tfile =~ s/\\ast /&ast\;/g;
	$tfile =~ s/\\larr /&larr\;/g;
	$tfile =~ s/\\rarr /&rarr\;/g;
	$tfile =~ s/\\uarr /&uarr\;/g;
	$tfile =~ s/\\darr /&darr\;/g;
	$tfile =~ s/\\cap /&cap\;/g;
	$tfile =~ s/\\cong /&cong\;/g;
	$tfile =~ s/\\conint /&conint\;/g;
	$tfile =~ s/\\cup /&cup\;/g;
	$tfile =~ s/\\equiv /&equiv\;/g;
	$tfile =~ s/\\exist /&exist\;/g;
	$tfile =~ s/\\forall /&forall\;/g;
	$tfile =~ s/\\ge /&ge\;/g;
	$tfile =~ s/\\infin /&infin\;/g;
	$tfile =~ s/\\int /&int\;/g;
	$tfile =~ s/\\lang /&lang\;/g;
	$tfile =~ s/\\lArr /&lArr\;/g;
	$tfile =~ s/\\le /&le\;/g;
	$tfile =~ s/\\minus /&minus\;/g;
	$tfile =~ s/\\nabla /&nabla\;/g;
	$tfile =~ s/\\ne /&ne\;/g;
	$tfile =~ s/\\ni /&ni\;/g;
	$tfile =~ s/\\Prime /&Prime\;/g;
	$tfile =~ s/\\prop /&prop\;/g;
	$tfile =~ s/\\radic /&radic\;/g;
	$tfile =~ s/\\rang /&rang\;/g;
	$tfile =~ s/\\rArr /&rArr\;/g;
	$tfile =~ s/\\sim /&sim\;/g;
	$tfile =~ s/\\bond /&bond\;/g;
	$tfile =~ s/\\dbond /&dbond\;/g;
	$tfile =~ s/\\tbond /&tbond\;/g;
	$tfile =~ s/\\ctdot /&ctdot\;/g;
	$tfile =~ s/\\rlhar /&rlhar\;/g;
	$tfile =~ s/\{\\aa\}/&aring\;/g;
	$tfile =~ s/\\c\{([a-z])\}/&$1cedil\;/g;
	$tfile =~ s/\\\'\{\\i\}/&iacute\;/g;
	$tfile =~ s/([a-zA-Z]+)\'\; /$1&rsquo\;\; /g;
	$tfile =~ s/([a-zA-Z]+)\'\. /$1&rsquo\;\. /g;
	$tfile =~ s/([a-zA-Z]+)\' /$1&rsquo\; /g;
	$tfile =~ s/ \`([a-zA-Z]+)/ &lsquo\;$1/g;
	$tfile =~ s/\'([a-zA-Z])/&apos\;$1/g;
	$tfile =~ s/\\"{([a-zA-Z])}/&$1uml\;/g;
	$tfile =~ s/\\'{([a-zA-Z])}/&$1acute\;/g;
	$tfile =~ s/\\`{([a-zA-Z])}/&$1grave\;/g;
	$tfile =~ s/{\\&}/&amp\;/g;
	$tfile =~ s/(\w+) \n</$1 </g;
	$tfile =~ s/. \n</. </g;
	$tfile =~ s/> \n/> /g;
	$tfile =~ s/\; \n([a-zA-Z])/\; $1/g;
	$tfile =~ s/\. \n([a-zA-Z])/\. $1/g;
#	$tfile =~ s/\\item\[(\d+)\.\] (.+?)\n/<listItem>$2<\/listItem>\n/g;
#	$tfile =~ s/\\item\[(\d+)\.\] ([a-zA-Z0-9]+) (.*?)\n/<listItem>$2 $3<\/listItem>\n/g;
	$tfile =~ s/<\/i> <i>//g;
	$tfile =~ s/ \n<i>/ <i>/g;
	$tfile =~ s/<\/b> <b>//g;
	$tfile =~ s/\{\}//g;

	####################################################
	$tfile =~ s/\{\\circ\}/&circ\;/g;
	$tfile =~ s/\{\\dot\}/&dot\;/g;
	$tfile =~ s/\{\\grave\}/&grave\;/g;
	$tfile =~ s/\{\\macr\}/&macr\;/g;
	$tfile =~ s/\{\\ogon\}/&ogon\;/g;
	$tfile =~ s/\{\\ring\}/&ring\;/g;
	$tfile =~ s/\{\\tilde\}/&tilde\;/g;
	$tfile =~ s/\{\\alpha\}/&alpha\;/g;
	$tfile =~ s/\{\\beta\}/&beta\;/g;
	$tfile =~ s/\{\\gamma\}/&gamma\;/g;
	$tfile =~ s/\{\\Gamma\}/&Gamma\;/g;
	$tfile =~ s/\{\\delta\}/&delta\;/g;
	$tfile =~ s/\{\\Delta\}/&Delta\;/g;
	$tfile =~ s/\{\\epsi\}/&epsi\;/g;
	$tfile =~ s/\{\\epsiv\}/&epsiv\;/g;
	$tfile =~ s/\{\\epsis\}/&epsis\;/g;
	$tfile =~ s/\{\\zeta\}/&zeta\;/g;
	$tfile =~ s/\{\\eta\}/&eta\;/g;
	$tfile =~ s/\{\\theta\}/&theta\;/g;
	$tfile =~ s/\{\\Theta\}/&Theta\;/g;
	$tfile =~ s/\{\\thetav\}/&thetav\;/g;
	$tfile =~ s/\{\\iota\}/&iota\;/g;
	$tfile =~ s/\{\\kappa\}/&kappa\;/g;
	$tfile =~ s/\{\\kappav\}/&kappav\;/g;
	$tfile =~ s/\{\\lambda\}/&lambda\;/g;
	$tfile =~ s/\{\\Lambda\}/&Lambda\;/g;
	$tfile =~ s/\{\\mu\}/&mu\;/g;
	$tfile =~ s/\{\\nu\}/&nu\;/g;
	$tfile =~ s/\{\\xi\}/&xi\;/g;
	$tfile =~ s/\{\\Xi\}/&Xi\;/g;
	$tfile =~ s/\{\\pi\}/&pi\;/g;
	$tfile =~ s/\{\\piv\}/&piv\;/g;
	$tfile =~ s/\{\\Pi\}/&Pi\;/g;
	$tfile =~ s/\{\\rho\}/&rho\;/g;
	$tfile =~ s/\{\\rhov\}/&rhov\;/g;
	$tfile =~ s/\{\\sigma\}/&sigma\;/g;
	$tfile =~ s/\{\\Sigma\}/&Sigma\;/g;
	$tfile =~ s/\{\\sigmav\}/&sigmav\;/g;
	$tfile =~ s/\{\\tau\}/&tau\;/g;
	$tfile =~ s/\{\\upsi\}/&upsi\;/g;
	$tfile =~ s/\{\\Upsi\}/&Upsi\;/g;
	$tfile =~ s/\{\\phis\}/&phis\;/g;
	$tfile =~ s/\{\\Phi\}/&Phi\;/g;
	$tfile =~ s/\{\\phiv\}/&phiv\;/g;
	$tfile =~ s/\{\\chi\}/&chi\;/g;
	$tfile =~ s/\{\\psi\}/&psi\;/g;
	$tfile =~ s/\{\\Psi\}/&Psi\;/g;
	$tfile =~ s/\{\\omega\}/&omega\;/g;
	$tfile =~ s/\{\\Omega\}/&Omega\;/g;
	$tfile =~ s/\{\\times\}/&times\;/g;
	$tfile =~ s/\{\\ast\}/&ast\;/g;
	$tfile =~ s/\{\\larr\}/&larr\;/g;
	$tfile =~ s/\{\\rarr\}/&rarr\;/g;
	$tfile =~ s/\{\\uarr\}/&uarr\;/g;
	$tfile =~ s/\{\\darr\}/&darr\;/g;
	$tfile =~ s/\{\\cap\}/&cap\;/g;
	$tfile =~ s/\{\\cong\}/&cong\;/g;
	$tfile =~ s/\{\\conint\}/&conint\;/g;
	$tfile =~ s/\{\\cup\}/&cup\;/g;
	$tfile =~ s/\{\\equiv\}/&equiv\;/g;
	$tfile =~ s/\{\\exist\}/&exist\;/g;
	$tfile =~ s/\{\\forall\}/&forall\;/g;
	$tfile =~ s/\{\\ge\}/&ge\;/g;
	$tfile =~ s/\{\\infin\}/&infin\;/g;
	$tfile =~ s/\{\\int\}/&int\;/g;
	$tfile =~ s/\{\\lang\}/&lang\;/g;
	$tfile =~ s/\{\\lArr\}/&lArr\;/g;
	$tfile =~ s/\{\\le\}/&le\;/g;
	$tfile =~ s/\{\\minus\}/&minus\;/g;
	$tfile =~ s/\{\\nabla\}/&nabla\;/g;
	$tfile =~ s/\{\\ne\}/&ne\;/g;
	$tfile =~ s/\{\\ni\}/&ni\;/g;
	$tfile =~ s/\{\\Prime\}/&Prime\;/g;
	$tfile =~ s/\{\\prop\}/&prop\;/g;
	$tfile =~ s/\{\\radic\}/&radic\;/g;
	$tfile =~ s/\{\\rang\}/&rang\;/g;
	$tfile =~ s/\{\\rArr\}/&rArr\;/g;
	$tfile =~ s/\{\\sim\}/&sim\;/g;
	$tfile =~ s/\{\\bond\}/&bond\;/g;
	$tfile =~ s/\{\\dbond\}/&dbond\;/g;
	$tfile =~ s/\{\\tbond\}/&tbond\;/g;
	$tfile =~ s/\{\\ctdot\}/&ctdot\;/g;
	$tfile =~ s/\{\\rlhar\}/&rlhar\;/g;
	####################################################

	####################################################
	$tfile =~ s/\\circ\\/&circ\;/g;
	$tfile =~ s/\\dot\\/&dot\;/g;
	$tfile =~ s/\\grave\\/&grave\;/g;
	$tfile =~ s/\\macr\\/&macr\;/g;
	$tfile =~ s/\\ogon\\/&ogon\;/g;
	$tfile =~ s/\\ring\\/&ring\;/g;
	$tfile =~ s/\\tilde\\/&tilde\;/g;
	$tfile =~ s/\\alpha\\/&alpha\;/g;
	$tfile =~ s/\\beta\\/&beta\;/g;
	$tfile =~ s/\\gamma\\/&gamma\;/g;
	$tfile =~ s/\\Gamma\\/&Gamma\;/g;
	$tfile =~ s/\\delta\\/&delta\;/g;
	$tfile =~ s/\\Delta\\/&Delta\;/g;
	$tfile =~ s/\\epsi\\/&epsi\;/g;
	$tfile =~ s/\\epsiv\\/&epsiv\;/g;
	$tfile =~ s/\\epsis\\/&epsis\;/g;
	$tfile =~ s/\\zeta\\/&zeta\;/g;
	$tfile =~ s/\\eta\\/&eta\;/g;
	$tfile =~ s/\\theta\\/&theta\;/g;
	$tfile =~ s/\\Theta\\/&Theta\;/g;
	$tfile =~ s/\\thetav\\/&thetav\;/g;
	$tfile =~ s/\\iota\\/&iota\;/g;
	$tfile =~ s/\\kappa\\/&kappa\;/g;
	$tfile =~ s/\\kappav\\/&kappav\;/g;
	$tfile =~ s/\\lambda\\/&lambda\;/g;
	$tfile =~ s/\\Lambda\\/&Lambda\;/g;
	$tfile =~ s/\\mu\\/&mu\;/g;
	$tfile =~ s/\\nu\\/&nu\;/g;
	$tfile =~ s/\\xi\\/&xi\;/g;
	$tfile =~ s/\\Xi\\/&Xi\;/g;
	$tfile =~ s/\\pi\\/&pi\;/g;
	$tfile =~ s/\\piv\\/&piv\;/g;
	$tfile =~ s/\\Pi\\/&Pi\;/g;
	$tfile =~ s/\\rho\\/&rho\;/g;
	$tfile =~ s/\\rhov\\/&rhov\;/g;
	$tfile =~ s/\\sigma\\/&sigma\;/g;
	$tfile =~ s/\\Sigma\\/&Sigma\;/g;
	$tfile =~ s/\\sigmav\\/&sigmav\;/g;
	$tfile =~ s/\\tau\\/&tau\;/g;
	$tfile =~ s/\\upsi\\/&upsi\;/g;
	$tfile =~ s/\\Upsi\\/&Upsi\;/g;
	$tfile =~ s/\\phis\\/&phis\;/g;
	$tfile =~ s/\\Phi\\/&Phi\;/g;
	$tfile =~ s/\\phiv\\/&phiv\;/g;
	$tfile =~ s/\\chi\\/&chi\;/g;
	$tfile =~ s/\\psi\\/&psi\;/g;
	$tfile =~ s/\\Psi\\/&Psi\;/g;
	$tfile =~ s/\\omega\\/&omega\;/g;
	$tfile =~ s/\\Omega\\/&Omega\;/g;
	$tfile =~ s/\\times\\/&times\;/g;
	$tfile =~ s/\\ast\\/&ast\;/g;
	$tfile =~ s/\\larr\\/&larr\;/g;
	$tfile =~ s/\\rarr\\/&rarr\;/g;
	$tfile =~ s/\\uarr\\/&uarr\;/g;
	$tfile =~ s/\\darr\\/&darr\;/g;
	$tfile =~ s/\\cap\\/&cap\;/g;
	$tfile =~ s/\\cong\\/&cong\;/g;
	$tfile =~ s/\\conint\\/&conint\;/g;
	$tfile =~ s/\\cup\\/&cup\;/g;
	$tfile =~ s/\\equiv\\/&equiv\;/g;
	$tfile =~ s/\\exist\\/&exist\;/g;
	$tfile =~ s/\\forall\\/&forall\;/g;
	$tfile =~ s/\\ge\\/&ge\;/g;
	$tfile =~ s/\\infin\\/&infin\;/g;
	$tfile =~ s/\\int\\/&int\;/g;
	$tfile =~ s/\\lang\\/&lang\;/g;
	$tfile =~ s/\\lArr\\/&lArr\;/g;
	$tfile =~ s/\\le\\/&le\;/g;
	$tfile =~ s/\\minus\\/&minus\;/g;
	$tfile =~ s/\\nabla\\/&nabla\;/g;
	$tfile =~ s/\\ne\\/&ne\;/g;
	$tfile =~ s/\\ni\\/&ni\;/g;
	$tfile =~ s/\\Prime\\/&Prime\;/g;
	$tfile =~ s/\\prop\\/&prop\;/g;
	$tfile =~ s/\\radic\\/&radic\;/g;
	$tfile =~ s/\\rang\\/&rang\;/g;
	$tfile =~ s/\\rArr\\/&rArr\;/g;
	$tfile =~ s/\\sim\\/&sim\;/g;
	$tfile =~ s/\\bond\\/&bond\;/g;
	$tfile =~ s/\\dbond\\/&dbond\;/g;
	$tfile =~ s/\\tbond\\/&tbond\;/g;
	$tfile =~ s/\\ctdot\\/&ctdot\;/g;
	$tfile =~ s/\\rlhar\\/&rlhar\;/g;
	####################################################

	$outputfile = "$mypath\\${infilename}-New.xml";
	open(OUTFILE,">${outputfile}");
	print OUTFILE $tfile;
	close(OUTFILE);
	unlink("$inputfile");
#	rename($outputfile,$inputfile);
}

rename($outputfile,$ofile);
