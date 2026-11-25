#!/usr/local/bin/perl -w

use strict;
use JSON;
use Encode 'decode';
use File::Copy;
use File::Path;
use File::Find qw(finddepth); 
use Digest::MD5;
use Time::HiRes;
use Cwd;
use File::Basename;
use List::MoreUtils qw( natatime part );
use Data::Dumper;

$ENV{PATH}  = '/usr/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/ccs/bin:/usr/ucb:/usr/openwin/bin:/usr/local/gts:/usr/local/bin:/usr/local/lib:/app/texlive/2013/bin/sparc-solaris:/usr/local/netpbm/bin:/usr/local/netpbm/lib:/usr/local/share/imagemagick/bin/:/usr/local/share/imagemagick/lib:/usr/local/share/ghostscript/bin/:/usr/local/teTeX/share/texmf-dist/dvips/aptara:/usr/local/share/ImageMagick-6.3.0/bin:/usr/local/share/ImageMagick-6.3.0/lib';
$ENV{MAGICK_HOME}='/usr/local/share/ImageMagick-6.3.0';
$ENV{LD_LIBRARY_PATH}='/usr/local/lib:/usr/lib:/lib:/usr/local/netpbm/lib:/usr/local/share/ImageMagick-6.3.0/lib:/usr/local/ghostscript/8.54/lib';

if(!$ARGV[0]) {
    print("Wrong command used, please follow as below:\nalttxt <LOCATION OF THE BOOK ON PoM>\n\n");
    exit(0);
}
# if(!$ARGV[1]) {
#     print("Wrong command used, please follow as below:\nalttxt <LOCATION OF THE BOOK ON PoM>\n\n");
#     exit(0);
# }
#$ENV{PATH}  = 'imagemagick;ghostscript';
my $mycurrentdir=$ARGV[0];
$mycurrentdir=~s/\/([A-Za-z0-9]+)$//g;
my $bookid=$1;
# print ("$mycurrentdir\t$bookid\n");
# exit (0);
# my $mycurrentdir=getcwd;
# my $mycurrentdir="/nea3/PowerManage/WILEY-STM-US";
# my $mycurrentdir="/nea8/PowerManage/WILEY-PT-SIN";
if(!-d "$mycurrentdir/$bookid") {
    print("ERROR: Please check <$mycurrentdir> folder <$bookid> doesn't exist!!!!!\n");
    exit(0);
}
&do_process();

sub do_process {
    my $chapNum="";
    my $chapName="";
    my $ImgID="";
    my $ImgName="";
    my $ImgPgNum="";
    my $elmno="";
    my $pgslno="";
    my $caption="NA";
    my $artoutfolder=getcwd;
    # my $artoutfolder="/nea3/wileybooks/aman";
    my $outdata="";
    # my %FigIDhash="";
    # my %blockFigIDhash="";
    rmtree ("$artoutfolder/art${bookid}") if(-d "$artoutfolder/art${bookid}");
    rmtree ("$artoutfolder/XML${bookid}") if(-d "$artoutfolder/XML${bookid}");
    mkdir "$artoutfolder/art${bookid}";
    # mkdir "$artoutfolder/XML${bookid}";
    print ("$artoutfolder/art${bookid}\n");
    my $outfilename="$artoutfolder/out${bookid}\.html";
    my $outChXmlfilename="";
    unlink "$outfilename" if(-e $outfilename);
    my $chapterpath="";
    my $chaptername="";
    print ("Processing. . . . . . . . . . . . . . . . . ");
    if(my @chapterlist=grep(/\-(c[0-9]+)/,my @temparr=<$mycurrentdir/$bookid/${bookid}-*>)) {
	foreach $chapterpath(@chapterlist) {
	    print (". . . ");
	    $chaptername=basename($chapterpath);
	    if(-e "$chapterpath/${chaptername}.xml") {
		$ImgPgNum="XXXX";
		# $outChXmlfilename="$artoutfolder/XML${bookid}/${chaptername}\.xml";
		my $chstr=&read_file("$chapterpath/${chaptername}.xml");
# 		$chstr=~s/<\?(.*?)\?>//g;
		# open(CHXMLOUT, "> $outChXmlfilename") or die "Can't open '$outChXmlfilename'\n";
		# print CHXMLOUT "$chstr";
		# close (CHXMLOUT);
		my $tempFigoutdata=&numFigure($chapterpath, $chaptername);
		$outdata.=$tempFigoutdata;
		my $tempBFoutdata=&unNumFigure($chapterpath, $chaptername);
		$outdata.=$tempBFoutdata;
	    }
	}
	print ("\n");
    }
my $finalfile="<\!DOCTYPE HTML>\n<html>\n<body>\n<font face\=\"Calibri\" size\=\"12\">\n<table cellspacing\=\"0\" border\=\"1\">\n<colgroup>\n<col width\=\"667\"\/>\n<col width\=\"761\"\/>\n<col width\=\"569\"\/>\n<col width\=\"599\"\/>\n<col width\=\"502\"\/>\n<col width\=\"1265\"\/>\n<col width\=\"298\"\/>\n<col width\=\"605\"\/>\n<col width\=\"605\"\/>\n<\/colgroup>\n<tr>\n<td height\=\"20\" align\=\"left\">ISBN:<\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"center\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\" valign\=\"middle\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<\/tr>\n<tr>\n<td height\=\"20\" align\=\"left\">Source Title:<\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"center\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\" valign\=\"middle\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<\/tr>\n<tr>\n<td height\=\"20\" align\=\"left\">Author:<\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"center\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\" valign\=\"middle\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<\/tr>\n<tr>\n<td height\=\"20\" align\=\"left\">Source Material:<\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"center\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\" valign\=\"middle\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<\/tr>\n<tr>\n<td height\=\"20\" align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"center\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\" valign\=\"middle\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<\/tr>\n<tr bgcolor\=\"#FFFF33\">\n<td><b>Chapter Number<\/b><\/td>\n<td><b>Chapter Name<\/b><\/td>\n<td><b>Page Number<\/b><\/td>\n<td><b>Image ID<\/b><\/td>\n<td><b>Image Name<\/b><\/td>\n<td><b>Caption<\/b><\/td>\n<td><b>Thumbnail Image<\/b><\/td>\n<td><b>Alt-Text<\/b><\/td>\n<td><b>Comments<\/b><\/td>\n<\/tr>\n$outdata\n<\/table>\n<\/font>\n<\/body>\n<\/html>";
    &write_file($finalfile, $outfilename);
    print ("Completed . . . . . \n");
}

sub write_file {
	my $xmlStr=$_[0];
	my $xmlFile=$_[1];
	open(XMLOUT, "> $xmlFile") or die "Can't open '$xmlFile'\n";
	print XMLOUT "$xmlStr";
	close (XMLOUT);
}


sub read_file {
	my $fileTxt="";
	my $input=$_[0];
	if(!-e "$input") {
		print("File not exists: $input\n");
		exit(0);
	}
	open(INPUT, "<$input");
	my @filearr=<INPUT>;
	close (INPUT);
	$fileTxt=join("",@filearr);
	return $fileTxt;
	# return @filearr;
}


sub numFigure{
    my $numchapterpath=$_[0];
    my $numchaptername=$_[1];
    my %FigIDhash;
    my $artoutfolder=getcwd;
    # my $artoutfolder="/nea3/wileybooks/aman";
    my $NumFigoutdata="";
    # print ("Figure***$numchapterpath/${numchaptername}.xml\n");
    # print ("Figure***$numchapterpath/${numchaptername}.aux\n");
    my $numchstr=&read_file("$numchapterpath/${numchaptername}.xml");
    $numchstr=~s/<\?(.*?)\?>//g;
    my $numchaux=&read_file("$numchapterpath/${numchaptername}.aux");
################################################################################
    # if ($numchaptername=~m/JWST947-c05/){
    # 	# print ("$numchaptername\n");
    # 	$numchaux=&read_file("${numchaptername}.aux");
    # }
################################################################################
    my $numchapNum="";
    my $numchapName="";
    $numchaptername=~m/\-c([0-9]+)/;
    $numchapNum=$1;
    $numchapNum=~s/^0//;
    # if($numchstr=~/<\/eventGroup>[^<]*<numberingGroup>[^<]*<numbering type=\"main\">([0-9]+)<\/numbering>/g) {
    # 	$numchapNum=$1;
    # }
    if($numchstr=~/<contentMeta>[^<]*<titleGroup>[^<]*[\<title type\=\"name\"\>0-9\<\/title\>]*[^<]*<title type=\"main\">(.*?)<\/title>/g) {
	$numchapName=$1;
    }
    # print ("$chapNum \t $ImgPgNum\n");
    # print ("$chapName \t $ImgPgNum\n");
    while($numchstr=~/<figure xml\:id\=\"([a-zA-Z0-9\-]*)\"[^>]*>[^<]*<mediaResource[^>]+href=\"urn:x-wiley:[A-Z0-9]+:media:[a-zA-Z0-9]+:([^\"]+)[^>]*>[^<]*<caption>(.*?)<\/caption>[^<]*<\/figure>/g) {
	my $numImgID="";
	my $numImgName="";
	my $numelmno="";
	my $numpgslno="";
	my $numcaption="NA";
	my $tempFigID=$1;
	$numcaption=$3;
	$numpgslno=$2;
	$numelmno=$numpgslno;
	$numelmno=~s/\-(.*?)//;
	print (". ");
	# print ("figure ID $tempFigID ****** $numpgslno\n");
	while ($numchaux=~/\\newlabel\{$tempFigID\}\{\{[0-9\.]*\}\{([0-9]+)\}/gs){
	    $FigIDhash{$numpgslno}=$1;
	    # my $tempchdvi=$2;
	    # print "Step.....1\t$tempFigID\t$FigIDhash{$numpgslno}\n";
		    }
	my $myepswd="";
	my $myepsht="";
	my $myresizewd="";
	if(-e "$numchapterpath/art/${numpgslno}.eps") {
	    # print("step 1....\n");
	    $numImgID="${numpgslno}.eps";
	    $numImgID=~m/f([^\.]+)/;
	    my $tempImgID=$1;
	    $tempImgID=~s/^0*//g;
	    $numImgName="Figure $numchapNum.$tempImgID";

		############### Figure Height and width calculation ###########################
		my $outstream=`/app/teTeX/scripts/perllibs/bin/exiftool $numchapterpath/art/${numpgslno}.eps`;
	    $myepsht=0;
	    $myepswd=0;
	    if($outstream=~/Image Height[^\n]+\:[^\n0-9]+([0-9]+)/) {
		$myepsht=$1;
	    }
	    if($outstream=~/Image Width[^\n]+\:[^\n0-9]+([0-9]+)/) {
		$myepswd=$1;
	    }
	    chop($myepswd,$myepsht);
	    $myresizewd=$myepswd * 100 /72 * 2;
	    $myepsht=$myepsht/12 * 20;
	    $myepswd=$myepswd/12 * 20;
	    # system("/app/ghostscript9.16/bin/gs -dSAFER -dBATCH -dNOPAUSE -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -sDEVICE=png16m  -dEPSCrop -r90x90 -sOutputFile=$artoutfolder/art${bookid}/${numpgslno}.png $numchapterpath/art/${numpgslno}.eps 1>/dev/null 2>/dev/null");
	    # system("/app/ghostscript9.16/bin/gs -dSAFER -dBATCH -dNOPAUSE -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -sDEVICE=tiff24nc  -dEPSCrop -r110x110 -sOutputFile=$artoutfolder/art${bookid}/${numpgslno}.tif $numchapterpath/art/${numpgslno}.eps");
	    if($myepswd > $myepsht) {
	    	system("/app/ghostscript9.16/bin/gs -dSAFER -dBATCH -dNOPAUSE -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -sDEVICE=png16m  -dEPSCrop -r110x110 -sOutputFile=$artoutfolder/art${bookid}/${numpgslno}.png $numchapterpath/art/${numpgslno}.eps 1>/dev/null 2>/dev/null");
	    } else {
	    	system("/app/ghostscript9.16/bin/gs -dSAFER -dBATCH -dNOPAUSE -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -sDEVICE=png16m  -dEPSCrop -r110x110 -sOutputFile=$artoutfolder/art${bookid}/${numpgslno}.png $numchapterpath/art/${numpgslno}.eps 1>/dev/null 2>/dev/null");
	    }
		########################################################
		
	    my $numImgPgNum="XXXX";
	    foreach my $tempLine(sort keys %FigIDhash){
		$numImgID=~s/.eps//g;
		if ($tempLine=~m/$numImgID/){
		    $numImgPgNum=$FigIDhash{$numImgID};
		}
	    }
	    # print ("$numImgPgNum\n");
	    $numImgID=~s/.eps//g;
	    my $tempoutdata="<tr>\n<td>$numchapNum<\/td>\n<td>$numchapName<\/td>\n<td>$numImgPgNum<\/td>\n<td>$numImgID\.eps<\/td>\n<td>$numImgName<\/td>\n<td>$numcaption<\/td>\n<td><img src\=\"art${bookid}\/${numImgID}\.png\"\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<\/tr>\n";
	    # print("$tempoutdata\n\n");
	    $NumFigoutdata.=$tempoutdata;
	}
	# print "$NumFigoutdata\n\n";
	$numchstr=~s/<figure xml\:id\=\"([a-zA-Z0-9\-]*)\"[^>]*>[^<]*<mediaResource[^>]+href=\"urn:x-wiley:[A-Z0-9]+:media:[a-zA-Z0-9]+:([^\"]+)[^>]*>[^<]*<caption>(.*?)<\/caption>[^<]*<\/figure>//;		
    }
    return $NumFigoutdata;
}


sub unNumFigure{
    my $Unumchapterpath=$_[0];
    my $Unumchaptername=$_[1];
    my %blockFigIDhash;
    my $artoutfolder=getcwd;
    # my $artoutfolder="/nea3/wileybooks/aman";
    my $UnumFigoutdata="";
    # print ("Block Fixed***$Unumchapterpath/${Unumchaptername}.xml\n");
    # print ("Block Fixed***$Unumchapterpath/${Unumchaptername}.aux\n");
    my $Unumchstr=&read_file("$Unumchapterpath/${Unumchaptername}.xml");
    $Unumchstr=~s/<\?(.*?)\?>//g;
    my $Unumchaux=&read_file("$Unumchapterpath/${Unumchaptername}.aux");
################################################################################
    # if ($Unumchaptername=~m/JWST947-c05/){
    # 	# print ("$Unumchaptername\n");
    # 	$Unumchaux=&read_file("${Unumchaptername}.aux");
    # }
################################################################################
    my $UnumchapNum="";
    my $UnumchapName="";
    $Unumchaptername=~m/\-c([0-9]+)/;
    $UnumchapNum=$1;
    $UnumchapNum=~s/^0//;
    # if($Unumchstr=~/<\/eventGroup>[^<]*<numberingGroup>[^<]*<numbering type=\"main\">([0-9]+)<\/numbering>/g) {
    # 	$UnumchapNum=$1;
    # }
    if($Unumchstr=~/<contentMeta>[^<]*<titleGroup>[^<]*[\<title type\=\"name\"\>0-9\<\/title\>]*[^<]*<title type=\"main\">(.*?)<\/title>/g) {
	$UnumchapName=$1;
    }
    # print ("$UnumchapNum \t $UnumImgPgNum\n");
    # print ("$UnumchapName \t $UnumImgPgNum\n");
    while($Unumchstr=~/<blockFixed type\=\"graphic\">[^<]*<mediaResource[^>]+href=\"urn:x-wiley:[A-Z0-9]+:media:[a-zA-Z0-9]+:([^\"]+)[^>]*>[^<]*<\/blockFixed>/g) {
	my $UnumImgID="";
	my $UnumImgName="Unnumbered";
	my $Unumelmno="";
	my $Unumpgslno="";
	my $Unumcaption="NA";
	my $tempFigID=$1;
	# $Unumcaption=$3;
	$Unumpgslno=$1;
	$Unumelmno=$Unumpgslno;
	$Unumelmno=~s/\-(.*?)//;
	print (". ");
	# print ("figure ID $tempFigID ****** $Unumpgslno\n");
	while ($Unumchaux=~/\\newlabel\{$tempFigID\}\{\{[0-9\.]*\}\{([0-9]+)\}/gs){
	    $blockFigIDhash{$Unumpgslno}=$1;
	    # my $tempchdvi=$2;
	    # print "Step.....1\t$tempFigID\t$FigIDhash{$Unumpgslno}\n";
	}
	my $myepswd="";
	my $myepsht="";
	my $myresizewd="";
	if(-e "$Unumchapterpath/art/${Unumpgslno}.eps") {
	    # print("step 1....\n");
	    $UnumImgID="${Unumpgslno}.eps";
	    $UnumImgID=~m/f([^\.]+)/;
	    # my $tempImgID=$1;
	    # $tempImgID=~s/^0*//g;
	    # $UnumImgName="Figure $UnumchapNum.$tempImgID";

		############### Figure Height and width calculation ###########################
	    my $outstream=`/app/teTeX/scripts/perllibs/bin/exiftool $Unumchapterpath/art/${Unumpgslno}.eps`;
	    $myepsht=0;
	    $myepswd=0;
	    if($outstream=~/Image Height[^\n]+\:[^\n0-9]+([0-9]+)/) {
		$myepsht=$1;
	    }
	    if($outstream=~/Image Width[^\n]+\:[^\n0-9]+([0-9]+)/) {
		$myepswd=$1;
	    }
	    chop($myepswd,$myepsht);
	    $myresizewd=$myepswd * 100 /72 * 2;
	    $myepsht=$myepsht/12 * 20;
	    $myepswd=$myepswd/12 * 20;
	    # system("/app/ghostscript9.16/bin/gs -dSAFER -dBATCH -dNOPAUSE -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -sDEVICE=png16m  -dEPSCrop -r90x90 -sOutputFile=$artoutfolder/art${bookid}/${Unumpgslno}.png $Unumchapterpath/art/${Unumpgslno}.eps 1>/dev/null 2>/dev/null");
	    # system("/app/ghostscript9.16/bin/gs -dSAFER -dBATCH -dNOPAUSE -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -sDEVICE=tiff24nc  -dEPSCrop -r110x110 -sOutputFile=$artoutfolder/art${bookid}/${Unumpgslno}.tif $Unumchapterpath/art/${Unumpgslno}.eps");
	    if($myepswd > $myepsht) {
	    system("/app/ghostscript9.16/bin/gs -dSAFER -dBATCH -dNOPAUSE -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -sDEVICE=png16m  -dEPSCrop -r110x110 -sOutputFile=$artoutfolder/art${bookid}/${Unumpgslno}.png $Unumchapterpath/art/${Unumpgslno}.eps 1>/dev/null 2>/dev/null");
	    } else {
	    system("/app/ghostscript9.16/bin/gs -dSAFER -dBATCH -dNOPAUSE -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -sDEVICE=png16m  -dEPSCrop -r110x110 -sOutputFile=$artoutfolder/art${bookid}/${Unumpgslno}.png $Unumchapterpath/art/${Unumpgslno}.eps 1>/dev/null 2>/dev/null");
	    }
		##################################################################
		
	    my $UnumImgPgNum="XXXX";
	    foreach my $tempLine(sort keys %blockFigIDhash){
		$UnumImgID=~s/.eps//g;
		if ($tempLine=~m/$UnumImgID/){
		    $UnumImgPgNum=$blockFigIDhash{$UnumImgID};
		}
	    }
	    # print ("$UnumImgPgNum\n");
	    $UnumImgID=~s/.eps//g;
	    my $tempoutdata="<tr>\n<td>$UnumchapNum<\/td>\n<td>$UnumchapName<\/td>\n<td>$UnumImgPgNum<\/td>\n<td>$UnumImgID\.eps<\/td>\n<td>$UnumImgName<\/td>\n<td>$Unumcaption<\/td>\n<td><img src\=\"art${bookid}\/${UnumImgID}\.png\"\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<td align\=\"left\"><br\/><\/td>\n<\/tr>\n";
	    # print("$tempoutdata\n\n");
	    $UnumFigoutdata.=$tempoutdata;
	}
	# print "$UnumFigoutdata\n\n";
	$Unumchstr=~s/<blockFixed type\=\"graphic\">[^<]*<mediaResource[^>]+href=\"urn:x-wiley:[A-Z0-9]+:media:[a-zA-Z0-9]+:([^\"]+)[^>]*>[^<]*<\/blockFixed>//;		
    }
    return $UnumFigoutdata;
}
