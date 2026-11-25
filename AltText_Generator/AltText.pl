#!/usr/bin/perl -w
use strict;
use File::Path;
use File::Find;
use File::Copy;
use File::Basename;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use Spreadsheet::WriteExcel;
use XML::Entities;

system("cls");
$ENV{PATH}  = 'c:\\ImageMagick;c:\\gs\\gs9.25\\bin';

########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%47s%8s\n","*","DEVELOPED BY : Saiful Islam (Wiley Books)","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################

my $filename = "$ARGV[0]";
chomp($filename);

if (!$ARGV[0]) {
    print "\nAltText.exe <File Name>, Try Again...\n\n";
    exit(0);
}

################################## VARIABLE DECLARATIONS ######################################
my ($filestr,$xlsdata,$AltTextData,$texgrp,$mainfilename,$myfolder,$count,$newcount,$tempdata,$figname,$txtdata,$matchedpara,$logtxt);
my ($xmlname,$finalfilename);
my $chnum = "";
my $chtitle = "";
$tempdata = "";
$xlsdata = "";
$txtdata = "";
$logtxt = "";
my (%FigsIds,%TabsIds,%FigsCaption,%TabsCaption,%ActFigsIds,%ActTabsIds,%WtgFigsIds,%WtgTabsIds,%SeqByImageID,%ParaWithID,%ActFigname);
my (@WtgIDS,@WtgFigIDS,@WtgTabIDS,@figsids,@paraids);
my ($pagecnt,$PageNum,$mythumbdir);
my (%PageText,%FigNumByPage,%FigUnNumByPage);
my(@dirlist,@filelist,@imagelist,@thimagelist,@physfigsid,@physfigsname,@figOnly,@figOnly4Page);
my $extn = qr/eps|jpg|tif|png|gif/x;
##################################### CALL FUNCTIONS ##########################################
#print " \n\n ~~~~~~~~~~~~~~~~~~ Welcome ${username} ~~~~~~~~~~~~~~~~~~\n\n";

$mainfilename = basename($filename);
$myfolder = $filename;
$myfolder =~ s/$mainfilename//s;
$mainfilename =~ s/\.(\w+)$//s;
my $outdir = $myfolder;
$outdir =~ s/\\([^\\]+)\\$//s;
$outdir .= "\\OUT\\$mainfilename";		
$myfolder .= "$mainfilename";

# print "\nMain File Name: $mainfilename\n\n";
# print "File Name: $filename\n\n";
# print "Path: $myfolder\n";
# print "OUT Path: $outdir\n";
		
print "PROCESSING.....\n\n";

&extract_zip($filename);
&read_folder($myfolder);

foreach $xmlname (@filelist){
	chomp($xmlname);
	$finalfilename = basename($xmlname); 
	$finalfilename =~ s/\.(\w+)$//s;
	
	$filestr=&read_file($xmlname);
	$filestr =~ s/<\!\*--/<\!--/g;


	&get_chNumNTitle(); #Get Chapter Number and Title
	&glob_replace(); #Miscellenous global replacement
	&save_ID(); #Stores <figure and <tabular IDS in "%FigsIds/%TabsIds"
	&save_wtglinksInArray(); #Stores all wtglink IDs in an array
	&checkNInsert_IfNotWtglinks(); #check and insert <?wTglink?> in XML for correct counters
	&save_wtglinks(); #Stores figure and tables wTglink IDS in "%WtgFigsIds/%WtgTabsIds"
	&comp_IDs(); # compare and save figure and table counters in new refrence/hash named "%ActFigsIds/%ActTabsIds"
	&save_byImageID(); #compare and save figure and table counters in final refrence/hash named "SeqByImageID"
	&pick_LinkedPara2($xmlname); #write the first cited paragraph in textfile.

	rmtree($outdir);
	mkdir($outdir);
	&conv_img();
	&flush_imgFolder();
	&read_folder($outdir);

	&gen_PageNum();

	&gen_Excel();  #write Excel file
	&write_html(); #write "HTML" file

	# &write_OUTfile();
	# &write_Temp();
	#&write_log();
}
rmtree($myfolder);
unlink("$filename");
sleep(1);
print "\nDONE.....\n";
##################################### FUNCTIONS DEFINITIONS ##########################################

sub read_file(){
	my ($myfilename)=@_;
#	my $myfilename=shift;
	open(INFILE, "$myfilename") or die "Can't open '$myfilename': $!";;
	my @filearr=<INFILE>;
	close(INFILE);
	my $filestring=join("",@filearr);
	$filestring =~ s/\r*\n/\n/g;
	return($filestring);
}
########################
sub extract_zip(){
	my ($zipname)=@_;
	chomp($zipname);
	my $zipfilename = basename($zipname);
	my $zipfolder = $zipname;
	$zipfolder =~ s/$zipfilename//s;

	my $zip = Archive::Zip->new();
	unless ( $zip->read($zipname) == AZ_OK ) { 
		die 'read error';
	}

	$zip->extractTree( '', "$zipfolder/" );
}
########################
sub get_chNumNTitle(){
	if(($filestr =~ /<figure ([^<>]+)>/s)||($filestr =~ /<table ([^<>]+)>/s)||($filestr =~ /<section ([^<>]+)>/s)){
		my $tagatts = $1;
		if($tagatts =~ /id=\"([^\"]+)\"/s){
			my $tagIds = $1;
			my @findchnum = split(/-/, $tagIds);
			$chnum = $findchnum[0];
			$chnum =~ s/^([a-z]+)//s;
			while($chnum =~ /^0/){
				$chnum =~ s/^0//s;
			}
		}
	}
	if($filestr =~ /<contentMeta>(.*?)<\/contentMeta>/s){
		my $cnttext = $1;
		if($cnttext =~ /<title type=\"main\">(.*?)<\/title>/s){
			$chtitle = $1;
			$chtitle =~ s/<\?new-page\?>//g;
		}
	}
}
########################
sub glob_replace(){
	while($filestr =~ s/<\!--(?s)(.*?)-->/<\!-\*-$1-->/s){
		my $mycommentedtext = $1;
		$mycommentedtext =~ s/<blockFixed/<YYblockFixed/g;
		$mycommentedtext =~ s/<figure/<YYfigure/g;
		$mycommentedtext =~ s/<inlineGraphic/<YYinlineGraphic/g;
		$mycommentedtext =~ s/<mediaResource/<YYmediaResource/g;
		$mycommentedtext =~ s/<tabular/<YYtabular/g;
		$mycommentedtext =~ s/<tabularFixed/<YYtabularFixed/g;
		$filestr =~ s/<\!-\*-(?s)(.*?)-->/<\!\*--$mycommentedtext-->/s;
	}
	$filestr =~ s/<\!\*--/<\!--/g;
			  
	$filestr =~ s/<\?cmd breaksequence\?>//g;
	$filestr =~ s/<blockFixed type=\"graphic\">(?s)(.*?)<\/blockFixed>/<AltTextFig><blockFixed type=\"graphic\">$1<\/blockFixed><\/AltTextFig>/g;
	$filestr =~ s/<figure ([^>]+)>(?s)(.*?)<\/figure>/<AltTextFig><figure $1>$2<\/figure><\/AltTextFig>/g;
	$filestr =~ s/<\?att out=\"no\" \?><link/<\?att out=\"no\" \?><Ylink/g;
	$filestr =~ s/<\?att out=\"no\" \?><\?cmd ([^>]+)\?><link/<\?att out=\"no\" \?><Ylink/g;
	$filestr =~ s/<\?setcnt (\w+) (\d+)\?><\?cmd ([^>]+)\?><\?wTglink/<\?cmd $3\?><\?setcnt $1 $2\?><\?wTglink/g;
	$filestr =~ s/<\?setcnt (\w+) (\d+)\?><\!--(?s)(.*?)--><\?wTglink/<\?setcnt $1 $2\?><\?wTglink/g;
			  
	while($filestr =~ s/<tabular ([^>]+)>(?s)(.*?)<\/tabular>/<AltTextTbl><Xtabular $1>$2<\/tabular><\/AltTextTbl>/s){
		my $temptext = $2;
		$temptext =~ s/<AltTextFig><blockFixed type=\"graphic\">(?s)(.*?)<\/blockFixed><\/AltTextFig>/<blockFixed type=\"graphic\">$1<\/blockFixed>/g;	
		$filestr =~ s/<AltTextTbl><Xtabular ([^>]+)>(?s)(.*?)<\/tabular><\/AltTextTbl>/<AltTextTbl><XXtabular $1>$temptext<\/tabular><\/AltTextTbl>/s;
	}
	while($filestr =~ s/<tabularFixed ([^>]+)>(?s)(.*?)<\/tabularFixed>/<AltTextTbl><XtabularFixed $1>$2<\/tabularFixed><\/AltTextTbl>/s){
		my $temptext = $2;
		$temptext =~ s/<AltTextFig><blockFixed type=\"graphic\">(?s)(.*?)<\/blockFixed><\/AltTextFig>/<blockFixed type=\"graphic\">$1<\/blockFixed>/g;	
		$filestr =~ s/<AltTextTbl><XtabularFixed ([^>]+)>(?s)(.*?)<\/tabularFixed><\/AltTextTbl>/<AltTextTbl><XXtabularFixed $1>$temptext<\/tabularFixed><\/AltTextTbl>/s;
	}
	$filestr =~ s/<XXtabular/<tabular/g;
}
########################
sub save_ID(){
	$count = 1;
	while($filestr =~ s/<figure ([^>]+)>/<XXfigure $1>/s){
		my $figatribtext = $1;
		if($figatribtext =~ /xml:id=\"([^\"]+)\"/s)
		{
			my $myfigID = $1;
			$FigsIds{$myfigID} = $count;
		}
		$count++;
	}
	$count = 1;
	while($filestr =~ s/<tabular ([^>]+)>/<XXtabular $1>/s){
		my $tabatribtext = $1;
		if($tabatribtext =~ /xml:id=\"([^\"]+)\"/s)
		{
			my $mytabID = $1;
			$TabsIds{$mytabID} = $count;
		}
		$count++;
	}
}
########################
sub save_wtglinksInArray(){
	while($filestr =~ s/<\?wTglink ([^>]+)>/<\?XwTglink $1>/s){
		my $wtgatribtext = $1;
		if($wtgatribtext =~ /type=\"fig\"/s)
		{	
			my $myWtgfigID = $wtgatribtext;
			$myWtgfigID =~ s/(.*?)href=\"([^\"]+)\"(.*?)$/$2/s;
			my @findfigWtgID = split(/:/, $myWtgfigID);
			$myWtgfigID = $findfigWtgID[$#findfigWtgID];
			push (@WtgFigIDS,$myWtgfigID);
			# print "$myWtgfigID\n";
		}
		elsif($wtgatribtext =~ /type=\"tbl\"/s)
		{	
			my $myWtgtblID = $wtgatribtext;
			$myWtgtblID =~ s/(.*?)href=\"([^\"]+)\"(.*?)$/$2/s;
			my @findtblWtgID = split(/:/, $myWtgtblID);
			$myWtgtblID = $findtblWtgID[$#findtblWtgID];
			push (@WtgTabIDS,$myWtgtblID);
			# print "$myWtgtblID\n";
		}
	}
	$filestr =~ s/<\?XwTglink/<\?wTglink/g;
	# foreach my $myentry(@WtgFigIDS){
		# print "$myentry\n";
	# }
	# print "\n\n";
	# foreach my $myentry(@WtgTabIDS){
		# print "$myentry\n";
	# }
}
########################
sub checkNInsert_IfNotWtglinks(){
	foreach my $Origkey(sort keys %FigsIds)
	{
		if(!(grep(/$Origkey/, @WtgFigIDS))){
			while($filestr =~ s/<link([^>]+)\/>/<Xlink$1\/>/s){
				my $fighref = $1;
				$fighref =~ s/(.*?)href=\"([^\"]+)\"(.*?)$/$2/s;
				my $fighreftwo = $fighref;
				my @findhref = split(/:/, $fighref);
				$fighref = $findhref[$#findhref];
				# if(($fighref =~ /$Origkey/s)&&($filestr !~ /<\?att out=\"no\" \?><Xlink href=\"$fighreftwo\"\/>/s)){
				if($fighref =~ /$Origkey/s){
					$filestr =~ s/<Xlink href=\"$fighreftwo\"\/>/<XXlink href=\"$fighreftwo\"\/><\?wTglink href=\"$fighref\" type=\"fig\"\?>/s;
					#print "$Origkey\n$fighreftwo\n$fighref\n\n";
					last;
				}
			}#last;
		}
	}

	foreach my $Origkey(sort keys %TabsIds)
	{
		if(!(grep(/$Origkey/, @WtgTabIDS))){
			while($filestr =~ s/<link([^>]+)\/>/<Xlink$1\/>/s){
				my $tblhref = $1;
				$tblhref =~ s/(.*?)href=\"([^\"]+)\"(.*?)$/$2/s;
				my $tblhreftwo = $tblhref;
				my @findhref = split(/:/, $tblhref);
				$tblhref = $findhref[$#findhref];
				if($tblhref =~ /$Origkey/s){
					$filestr =~ s/<Xlink href=\"$tblhreftwo\"\/>/<XXlink href=\"$tblhreftwo\"\/><\?wTglink href=\"$tblhref\" type=\"tbl\"\?>/s;
					# print "$Origkey\n$tblhreftwo\n$tblhref\n\n";
					last;
				}
			}#last;
		}
	}

	$filestr =~ s/<Xlink/<link/g;
}

########################
sub save_wtglinks(){
	$count = 1;
	while($filestr =~ s/<\?wTglink ([^>]+)>/<\?XwTglink $1>/s){
		my $wtgatribtext = $1;
		if($wtgatribtext =~ /type=\"fig\"/s)
		{
			my $myWtgfigID = $wtgatribtext;
			$myWtgfigID =~ s/(.*?)href=\"([^\"]+)\"(.*?)$/$2/s;
			if($filestr =~ /<\?setcnt figure ([0-9]+)([^<]+)<\?XwTglink href=\"$myWtgfigID\" type=\"fig\"\?>/s){
				$newcount = $1;
				$newcount++;
				$WtgFigsIds{$myWtgfigID} = $newcount;
				$count = $newcount+1;
				#print "<$count updated>\n";
			}
			else
			{
				$WtgFigsIds{$myWtgfigID} = $count;
				$count++;
				#print "$count\n";
			}
		}
	}

	$count = 1;
	while($filestr =~ s/<\?XwTglink ([^>]+)>/<\?XXwTglink $1>/s){
		my $wtgatribtext = $1;
		if($wtgatribtext =~ /type=\"tbl\"/s)
		{
			my $myWtgtabID = $wtgatribtext;
			$myWtgtabID =~ s/(.*?)href=\"([^\"]+)\"(.*?)$/$2/s;
			if($filestr =~ /<\?setcnt table ([0-9]+)([^<]+)<\?XXwTglink href=\"$myWtgtabID\" type=\"tbl\"\?>/s){
				$newcount = $1;
				$newcount++;
				$WtgTabsIds{$myWtgtabID} = $newcount;
				$count = $newcount+1;
			}
			else
			{
				$WtgTabsIds{$myWtgtabID} = $count;
				$count++;
			}
		}
	}
}
########################
sub comp_IDs(){
	foreach my $Origkey(sort keys %FigsIds)
	{
		foreach my $Wtgkey(sort keys %WtgFigsIds)
		{
			if($Origkey =~ /$Wtgkey/s){
				$ActFigsIds{$Origkey} = $WtgFigsIds{$Wtgkey};
				last;
			}else{
				$ActFigsIds{$Origkey} = $FigsIds{$Origkey};
			}
		}
	}

	foreach my $Origkey(sort keys %TabsIds)
	{
		foreach my $Wtgkey(sort keys %WtgTabsIds)
		{
			if($Origkey =~ /$Wtgkey/s){
				$ActTabsIds{$Origkey} = $WtgTabsIds{$Wtgkey};
				last;
			}else{
				$ActTabsIds{$Origkey} = $TabsIds{$Origkey};
			}
		}
	}
}
########################
sub save_byImageID(){
	$filestr =~ s/<mediaResource(.*?)mimeType=\"([^\"]+)\"(.*?)\/>/<ZmediaResource$1mimeType=\"$2\"$3\/>/g;
	
	while($filestr =~ s/<AltTextFig>(?s)(.*?)<\/AltTextFig>/<XXAltTextFig>$1<\/AltTextFig>/s){
		$AltTextData = $1;
		if($AltTextData =~ /<blockFixed type=\"graphic\">/s){
			if($AltTextData =~ /<mediaResource(.*?)href=\"([^\"]+)\"(.*?)\/>/s){
				$figname = $2;
				# $figname =~ s/([^\:]+):([^\:]+):([^\:]+):([^\:]+):([^\:]+):(.*?)$/$6/s;
				my @findfig = split(/:/, $figname);
				$figname = $findfig[$#findfig];
			}
			$SeqByImageID{$figname} = "UnNum Figure";
		}
		##########################
		if($AltTextData =~ /<XXfigure ([^>]+)>/s){
			my $figatribtext = $1;
			my $myfignum = "";
			my $myfigID;
			if($figatribtext =~ /xml:id=\"([^\"]+)\"/s)
			{
				$myfigID = $1;
				foreach my $mykey(sort keys %ActFigsIds)
				{
					if($mykey =~ /$myfigID/s){
						$myfignum = $ActFigsIds{$mykey};
					}
				}
				################### Store figure captions ########################
				if($AltTextData =~ /<caption>(?s)(.*?)<\/caption>/s){
					my $figcaption = $1;
					$figcaption =~ s/<p ([^>]+)>/<p>/g;
					$figcaption =~ s/<\?noind\?>//g;
					$figcaption =~ s/\&hyphen\;/-/g;
					$figcaption =~ s/<fc>(.*?)<\/fc>/$1/g;
					$figcaption =~ s/<\?([vh])sp ([0-9ptcemx]+)\?>//g;
					$figcaption =~ s/<\?brk([^>]+)\?>//g;
					$figcaption =~ s/<term ([^>]+)>(.*?)<\/term>/<span style=\"color:red\;\"><b><i>$2<\/i><\/b><\/span>/g;
					$figcaption =~ s/<termDefinition ([^>]+)>(.*?)<\/termDefinition>/<span style=\"color:green\;\"><b><i>$2<\/i><\/b><\/span>/g;
					$figcaption =~ s/<source>(.*?)<\/source>//g;
					# print "$myfigID\n*******************\n$figcaption\n\n";

					$FigsCaption{$myfigID} = $figcaption;
				}
				##################################################################
			}

			if($AltTextData =~ /<mediaResource(.*?)href=\"([^\"]+)\"(.*?)\/>/s){
				while($AltTextData =~ s/<mediaResource(.*?)href=\"([^\"]+)\"(.*?)\/>/<XmediaResource$1href=\"$2\"$3\/>/s){
					$figname = $2;
					my @findfig = split(/:/, $figname);
					$figname = $findfig[$#findfig];
					$ActFigname{$myfigID} = $figname;
					#print "$myfigID\t-->$figname\n";
					$SeqByImageID{$figname} = "FIGURE $chnum\.$myfignum";
				}
			}
		}
		
	}	
	##########################
	while($filestr =~ s/<AltTextTbl>(?s)(.*?)<\/AltTextTbl>/<XXAltTextTbl>$1<\/AltTextTbl>/s){
		$AltTextData = $1;
		
		if($AltTextData =~ /<tabularFixed([^>]+)>/s){
			if($AltTextData =~ /<mediaResource(.*?)href=\"([^\"]+)\"(.*?)\/>/s){
				while($AltTextData =~ s/<mediaResource(.*?)href=\"([^\"]+)\"(.*?)\/>/<XmediaResource$1href=\"$2\"$3\/>/s){
					$figname = $2;
					my @findfig = split(/:/, $figname);
					$figname = $findfig[$#findfig];
					$SeqByImageID{$figname} = "Un Table";
				}
			}
			elsif($AltTextData =~ /<inlineGraphic(.*?)href=\"([^\"]+)\"(.*?)\/>/s){
				while($AltTextData =~ s/<inlineGraphic(.*?)href=\"([^\"]+)\"(.*?)\/>/<XinlineGraphic$1href=\"$2\"$3\/>/s){
					$figname = $2;
					my @findfig = split(/:/, $figname);
					$figname = $findfig[$#findfig];
					$SeqByImageID{$figname} = "Un Table";
				}
			}
		}
		##########################
		if($AltTextData =~ /<XXtabular ([^>]+)>/s){
			my $tblatribtext = $1;
			my $mytblnum = "";
			if($tblatribtext =~ /xml:id=\"([^\"]+)\"/s)
			{
				my $mytblID = $1;
				foreach my $mykey(sort keys %ActTabsIds)
				{
					if($mykey =~ /$mytblID/s){
						$mytblnum = $ActTabsIds{$mykey};
					}
				}
				################### Store figure captions ########################
				if($AltTextData =~ /<caption>(?s)(.*?)<\/caption>/s){
					my $tblcaption = $1;
					$tblcaption =~ s/<p ([^>]+)>/<p>/g;
					$tblcaption =~ s/<\?noind\?>//g;
					$tblcaption =~ s/\&hyphen\;/-/g;
					$tblcaption =~ s/<fc>(.*?)<\/fc>/$1/g;
					$tblcaption =~ s/<\?([vh])sp ([0-9ptcemx]+)\?>//g;
					$tblcaption =~ s/<\?brk([^>]+)\?>//g;
					$TabsCaption{$mytblID} = $tblcaption;
				}
				##################################################################
			}

			if($AltTextData =~ /<mediaResource(.*?)href=\"([^\"]+)\"(.*?)\/>/s){
				while($AltTextData =~ s/<mediaResource(.*?)href=\"([^\"]+)\"(.*?)\/>/<XmediaResource$1href=\"$2\"$3\/>/s){
					$figname = $2;
					my @findfig = split(/:/, $figname);
					$figname = $findfig[$#findfig];
					$SeqByImageID{$figname} = "TABLE $mytblnum";
				}
			}
			elsif($AltTextData =~ /<inlineGraphic(.*?)href=\"([^\"]+)\"(.*?)\/>/s){
				while($AltTextData =~ s/<inlineGraphic(.*?)href=\"([^\"]+)\"(.*?)\/>/<XinlineGraphic$1href=\"$2\"$3\/>/s){
					$figname = $2;
					my @findfig = split(/:/, $figname);
					$figname = $findfig[$#findfig];
					$SeqByImageID{$figname} = "TABLE $mytblnum";
				}
			}
		}
	}
}
########################
sub pick_LinkedPara2(){
	my ($xmlname)=@_;
	my $paratext=&read_file($xmlname);
	$paratext =~ s/<\!\*--/<\!--/g;
	$paratext =~ s/<\!--(?s)(.*?)-->//g;
	$paratext =~ s/<\?cmd breaksequence\?>//g;
#	&remove_comment;
#	$paratext=&read_file("${myfolder}${finalfilename}-SAIF.xml");

	################### Differentiate between parent and child Paragraph ###################
	$paratext =~ s/<p>/<ce:para>/g;
	$paratext =~ s/<p ([^>]+)>/<ce:para>/g;
	$paratext =~ s/<\/p>/<\/ce:para>/g;
	my $paracnt = 1;
	my $temp;
	while($paratext =~ /(.?)ce:para/) {
		$temp = "$1ce:para";
		#print "$temp\n";

		if(($paracnt > 1)&&($temp =~ /\<ce:para/s)) {
			$paratext =~ s/<ce:para/<ce:unnumpara/s;
			$paratext =~ s/<\/ce:para>/<\/ce:unnumpara>/s;
			#print "****CHILD Para****\n";
		}
		if($temp =~ /<ce:para/s){
			if($paracnt eq 1) {
				$paratext =~ s/<ce:para/<ce:Xpara/s;
				#print "Parent Para Begins\n";
			}
			$paracnt++;
		}
		elsif($temp =~ /\/ce:para/s) {
			$paratext =~ s/<\/ce:para>/<\/ce:Xpara>/s;
			#print "Parent Para Ends\n";
			$paracnt = 1;
		}
	} #END of While
	#################################### END of Paragraph ##################################
			   
	################## Conversion of paragraphs for HTML ##################
		$paratext =~ s/\&hyphen\;/-/g;
		$paratext =~ s/<\?tight\?>//g;
		$paratext =~ s/\&([a-zA-Z])macr\;/$1/g;
		$paratext =~ s/ce:unnumpara/p/g;
		
		########### converts featureFixed in text ##################
		while($paratext =~ s/<featureFixed ([^>]+)>(?s)(.*?)<\/featureFixed>/<XfeatureFixed>$2<\/featureFixed>/s){
			my $featuretxt = $2;
			$featuretxt =~ s/<titleGroup>//s;
			$featuretxt =~ s/<\/titleGroup>//s;
			$featuretxt =~ s/<title type=\"main\">([^<>]+)<\/title>/<p><b>$1<\/b><\/p>/s;
			$featuretxt =~ s/<title type=\"([^\"]+)\">(.*?)<\/title>//s;
			
			$paratext =~ s/<XfeatureFixed>(?s)(.*?)<\/featureFixed>/$featuretxt/s;
		}
		############################################################
		
		########### converts Key Terms in text ##################
		$paratext =~ s/<termGroup>//g;
		$paratext =~ s/<\/termGroup>//g;
		$paratext =~ s/<term type=\"displayForm\">(.*?)<\/term>//g;
		while($paratext =~ /<term ([^>]+)>(.*?)<\/term><termDefinition ([^>]+)>(.*?)<\/termDefinition>/s){
			my $keyterm = $2;
			my $keydef = $4;
			$paratext =~ s/<term ([^>]+)>(.*?)<\/term><termDefinition ([^>]+)>(.*?)<\/termDefinition>/<span style=\"color:red\;\"><b><i>$keyterm<\/i><\/b><\/span> <span style=\"color:green\;\"><i>$keydef<\/i><\/span>/s;
		}
		$paratext =~ s/<span style=\"color:red\;\"><b><i>(.*?)<\/term>/<span style=\"color:red\;\"><b><i>$1<\/i><\/b><\/span>/g;
		$paratext =~ s/<term ([^>]+)>(.*?)<\/i><\/b><\/span>/<span style=\"color:red\;\"><b><i>$2<\/i><\/b><\/span>/g;

		$paratext =~ s/<term ([^>]+)>(.*?)<\/term>/<span style=\"color:red\;\"><b><i>$2<\/i><\/b><\/span>/g;
		$paratext =~ s/<termDefinition ([^>]+)>(.*?)<\/termDefinition>/<span style=\"color:green\;\"><b><i>$2<\/i><\/b><\/span>/g;
		############################################################
		
		########### converts list in text ##################
		while($paratext =~ /<list ([^>]+)>(?s)(.*?)<\/list>/s){
			my $liststyle = $1;
			my $listtext = $2;
			$listtext =~ s/<listItem>/<li>/g;
			$listtext =~ s/<\/listItem>/<\/li>/g;
			while($listtext =~ /<li>(?s)(.*?)<\/li>/s){
				my $lsttxt = $1;
				if($lsttxt !~ /<p>/){
					$lsttxt =~ s/^(.*?)/<p>$1/s;
					$lsttxt =~ s/(.*?)$/$1<\/p>/s;
				}
				$listtext =~ s/<li>(?s)(.*?)<\/li>/<Xli>$lsttxt<\/Xli>/s
			}
			$listtext =~ s/<Xli>/<li>/g;
			$listtext =~ s/<\/Xli>/<\/li>/g;
			
			$listtext =~ s/<title type="main">(.*?)<\/title>/<i>$1<\/i>/g;
			$paratext =~ s/<list ([^>]+)>(?s)(.*?)<\/list>/<list $1>$listtext<\/list>/s;
			
			if($liststyle =~ /style=\"([1|a|A|i|I])\"/s){
				$paratext =~ s/<list ([^>]+)>/<ol>/s;
				$paratext =~ s/<\/list>/<\/ol>/s;
			}else{
				$paratext =~ s/<list ([^>]+)>/<ul>/s;
				$paratext =~ s/<\/list>/<\/ul>/s;
			}
		}
		########################## END of Conversion ########################## 
		$paratext =~ s/<\?wTglink ([^>]+)\?>//g;
		#$paratext =~ s/<\?([^\?]+)\?>//g;

	foreach my $mykey(sort keys %ActFigsIds)
	{
		while($paratext =~ /<ce:Xpara>(.*?)<\/ce:Xpara>/s){
			my $pdata = $1;
			if($pdata =~ /$mykey/){
				$matchedpara = $pdata;
				$ParaWithID{$mykey} = $matchedpara;
				last;
			}
			$paratext =~ s/<ce:Xpara>(.*?)<\/ce:Xpara>/<XXce:para>$1<\/XXce:para>/s;
		}
		$paratext =~ s/XXce:para/ce:Xpara/g;
	}

		
#	open(FILEONE, ">${myfolder}$finalfilename-SAIF.xml");
#	print FILEONE "$paratext";
#	close(FILEONE);
#	unlink("${myfolder}${finalfilename}-SAIF.xml");
}

########################
sub remove_comment()
{
	my $mytag=0;
	open(INPUT,"<${xmlname}");
	open(OUTPUT, ">${myfolder}$finalfilename-SAIF.xml");
	while(<INPUT>)
	{
		if(/<\!--/s)
		{
			$mytag=1;
		}
		if(/(.*?)-->/s)
		{
			s/(.*?)-->\n//;
			s/(.*?)-->//;
			$mytag=0;
		}
		if($mytag eq 0)
		{
			print OUTPUT $_;
		}
	}
	close(INPUT);
	close(OUTPUT);
}
########################
sub gen_PageNum(){
	my $pageFirst;
	if($filestr =~ /<numbering type=\"pageFirst\">([0-9]+)<\/numbering>/s){
		$pageFirst = $1;
	}

	$filestr =~ s/<\?new-page \?>/<\?new-page\?>/g;
	$filestr =~ s/< \?new-page\?>/<\?new-page\?>/g;
	$filestr =~ s/< \?new-page \?>/<\?new-page\?>/g;
	$filestr =~ s/<\?new-page\?>/<\?fnew-page\?>/s;

	while($filestr =~ /<\?XXwTglink href=\"([^\"]+)\"([^<>]+)\?>/s){
		my $tmpid = $1;
		$filestr =~ s/<\?XXwTglink href=\"$tmpid\"([^<>]+)\?>/<\?XwTglink href=\"$tmpid\"$1\?>/s;
	}

	if($filestr =~ /^(.*)<\?fnew-page\?>/s){
		my $fpara = $1;
		$PageText{"Page$pageFirst"} = $fpara;
	}
	$filestr =~ s/<\?fnew-page\?>/<\?new-page\?>/s;
	$pagecnt = $pageFirst;
	$pagecnt++;
#	$pagecnt++;
	while($filestr =~ s/<\?new-page\?>(.*?)<\?new-page\?>/<\?Xnew-page\?>$1<\?new-page\?>/s){
		my $paragraphtext = $1;
		$PageText{"Page$pagecnt"} = $paragraphtext;
		#print "$pagecnt\n";
		$pagecnt++;
	}
	if($filestr =~ /<\?new-page\?>(.*?)<\/body>/s){
		$PageText{"Page$pagecnt"} = $1;
	}

	my $wtgid;
	foreach my $pgtext (sort keys %PageText){
		while($PageText{$pgtext} =~ s/<\?XwTglink href=\"([^\"]+)\"([^<>]+)\?>/<\?wTglink href=\"$1\"$2\?>/s){
			$wtgid = $1;
			$wtgid =~ s/^\#//s;
			if(($wtgid !~ /-tbl-/s)&&(grep { $_ =~ /$wtgid/ } keys %ActFigname)){
				$wtgid = $ActFigname{$wtgid};
				$FigNumByPage{$wtgid} = "$pgtext";
			}
		}
		while($PageText{$pgtext} =~ s/<blockFixed([^<>]+)>(.*?)<\/blockFixed>/<XblockFixed$1>$2<\/XblockFixed>/s){
			my $blockText = $2;
			if($blockText =~ /<mediaResource(.*?)href=\"([^\"]+)\"(.*?)\/>/s){
				my $unnumfig = $2;
				my @unfigID = split(/:/, $unnumfig);
				$unnumfig = $unfigID[$#unfigID];
				$FigNumByPage{$unnumfig} = "$pgtext";
			}
		}
	}
}
########################
sub gen_Excel(){
	my $workbook = Spreadsheet::WriteExcel->new("${outdir}\\$finalfilename.xls");
	my $worksheet = $workbook->add_worksheet();
	$worksheet->add_write_handler(qr[\w]);
	
	my $ferrari = $workbook->set_custom_color(40, 204, 255, 255);
	my %headcell = (font => 'Times',
					size => 12,
					color => 'black',
					bg_color => $ferrari,
					bold => 1,
					text_wrap => 1,
					align => 'left',
					border => '1',
				   );
	my %boldcell = (font => 'Times',
					size => 12,
					color => 'black',
					bg_color => 'white',
					bold => 1,
					text_wrap => 1,
					align => 'left',
					border => '2',
				   );
	my %whitecell = (font => 'Times',
					size => 12,
					color => 'black',
					bg_color => 'white'	 ,
					align => 'left',
					border => '1',
				   );
	my %imagecell = (font => 'Times',
					 size => 12,
					 color => 'black',
					 bg_color => 'white'	 ,
					 align => 'vcenter',
					 border => '1',
					);

	my $formatheader = $workbook->add_format(%headcell); # Add a format
    my $bolddatacell = $workbook->add_format(%boldcell); # Add a format
	my $whitedatacell = $workbook->add_format(%whitecell); # Add a format
	my $imagedatacell = $workbook->add_format(%imagecell); # Add a format

	$worksheet->set_column(1, 0, 30);	#Element Number
	$worksheet->set_column(2, 1, 36);	#Element Name
	$worksheet->set_column(3, 2, 14);	#Page/Slide Number
    $worksheet->set_column(4, 3, 21);	#Image Filename
    $worksheet->set_column(5, 4, 21);	#Image Name in Text
    $worksheet->set_column(6, 5, 60);	#Caption
    $worksheet->set_column(7, 6, 50);	#Thumbnail Image
    $worksheet->set_column(8, 7, 35);	#Alt Text
    $worksheet->set_column(9, 8, 30);	#Comments

	############################### HEADINGS
	$worksheet->write(1, 0, 'ISBN:',$bolddatacell);
	$worksheet->write(2, 0, 'Title:',$bolddatacell);
	$worksheet->write(3, 0, 'Author:',$bolddatacell);
	$worksheet->write(4, 0, 'Source Material: ',$bolddatacell);
	$worksheet->write(1, 1, '',$bolddatacell);
	$worksheet->write(2, 1, '',$bolddatacell);
	$worksheet->write(3, 1, '',$bolddatacell);
	$worksheet->write(4, 1, 'PDF',$bolddatacell);

	$worksheet->write(6, 0, 'Element Number',$formatheader);
	$worksheet->write(6, 1, 'Element Name',$formatheader);
	$worksheet->write(6, 2, 'Page/Slide Number',$formatheader);
	$worksheet->write(6, 3, 'Image Filename',$formatheader);
	$worksheet->write(6, 4, 'Image Name in Text',$formatheader);
	$worksheet->write(6, 5, 'Caption',$formatheader);
	$worksheet->write(6, 6, 'Thumbnail Image',$formatheader);
	$worksheet->write(6, 7, 'Alt Text',$formatheader);
	$worksheet->write(6, 8, 'Comments',$formatheader);
	###############################
	$chtitle =~ s/<\?([^\?]+)\?>//g;
	foreach my $mykey(sort keys %ActFigname)
	{
		push(@physfigsid,$mykey);
		#print "$mykey\t$ActFigname{$mykey}\n"
	}

	foreach my $fgnm(sort keys %SeqByImageID)
	{
		push(@physfigsname,$fgnm);
		#print "$fgnm\t$SeqByImageID{$fgnm}\n"
	}

	foreach my $mykey(sort keys %SeqByImageID)
	{
		# if($SeqByImageID{$mykey} =~ /(UnNum Figure|FIGURE )/i){
			push (@figOnly,$mykey);
		# }
	}

	my $row = 7;

	my ($figID,$xlsfigcaption,$xlsfignum);
	foreach my $figskey(@figOnly)
	{
		my $tempid = $figskey;
		$xlsfigcaption = "";
		$xlsfignum = "";
		foreach my $tempfigid(sort keys %ActFigname)
		{
			if($ActFigname{$tempfigid} eq $figskey){
				$figID = $tempfigid;
				last;
			}else{
				$figID = "";
			}
		}

		if($figID){
			if(grep { $_ =~ /$figID/ } keys %FigsCaption){
				$xlsfigcaption = "$FigsCaption{$figID}";
			}else{
				$xlsfigcaption = "";
			}
		}
		$xlsfignum = "$SeqByImageID{$figskey}";

		# $xlsfignum =~ s/UnNum Figure//s;
		$xlsfigcaption =~ s/\&(l|r)dquo\;/\"/g;
		$xlsfigcaption =~ s/\&(l|r)squo\;/\'/g;
		$xlsfigcaption = &conv_cite($xlsfigcaption);
		$xlsfigcaption =~ s/<span style=\"color:black\;background-color:yellow\"><b>(.*?)<\/b><\/span>/$1/g;
		$xlsfigcaption =~ s/<span style=\"color:([^\"]+)\"><b><i>(.*?)<\/i><\/b><\/span>/$2/g;
		$xlsfigcaption =~ s/<span style=\"([^\"]+)\">(.*?)<\/span>/$2/g;
		$xlsfigcaption =~ s/<span ([^<>]+)>(.*?)<\/span>/$2/g;
		$xlsfigcaption =~ s/<source>(.*?)<\/source>//g;
		$xlsfigcaption =~ s/<url ([^<>]+)>(.*?)<\/url>/$2/g;
		$xlsfigcaption =~ s/<\?new-page\?>//g;
		$xlsfigcaption =~ s/<\?([^\?]+)\?>//g;
		$xlsfigcaption =~ s/<p>//g;
		$xlsfigcaption =~ s/<\/p>//g;
		$xlsfigcaption =~ s/<\!--(?s)(.*?)-->//g;
		$xlsfigcaption = XML::Entities::decode('all', $xlsfigcaption);
		$PageNum = "$FigNumByPage{$figskey}";
		$PageNum =~ s/Page//s;
		$chtitle = XML::Entities::decode('all', $chtitle);
				
		$worksheet->set_row($row, 170,$imagedatacell);

		$worksheet->write($row, 0, "$chnum", $whitedatacell);
		$worksheet->write($row, 1, "$chtitle", $whitedatacell);
		$worksheet->write($row, 2, "$PageNum", $whitedatacell);
		$worksheet->write($row, 3, "$figskey", $whitedatacell);
		$worksheet->write($row, 4, "$xlsfignum", $whitedatacell);
		$worksheet->write($row, 5, "$xlsfigcaption", $whitedatacell);

		foreach my $imgname(@imagelist)
		{
			if(-e $imgname){
				my $actimgname = basename($imgname);
				my $thumbimgname = $actimgname;
				my $imgpath = $imgname;
				$imgpath =~ s/$actimgname//s;
				if($thumbimgname =~ /(.*)-thumb\.(\w+)$/s){
					if(($thumbimgname =~ /$tempid/)&&(-e "$imgpath$thumbimgname")){
						$worksheet->insert_image($row, 6, "$imgpath$thumbimgname");
					}
				}
			}
		}
		$row++;
	}
}
########################
sub write_OUTfile(){
	$filestr =~ s/<XX/</g;
	$filestr =~ s/<Ylink/<link/g;
	$filestr =~ s/<YY/</g;
	$filestr =~ s/<\?XwTglink/<\?wTglink/g;
	$filestr =~ s/<\?XXwTglink/<\?wTglink/g;
	$filestr =~ s/<\!\*--/<\!--/g;
	$filestr =~ s/<AltTextFig>//g;
	$filestr =~ s/<\/AltTextFig>//g;
	$filestr =~ s/<AltTextTbl>//g;
	$filestr =~ s/<\/AltTextTbl>//g;
	$filestr =~ s/<\?cmd ([^>]+)\?><\?setcnt (\w+) (\d+)\?><\?wTglink/<\?setcnt $2 $3\?><\?cmd $1\?><\?wTglink/g;

	open(OUTFILE, ">${outdir}$finalfilename-out.xml");
	print OUTFILE "$filestr";
	close(OUTFILE);
}
########################
sub write_html(){
	$txtdata .= "<style>\n\.cpt \{
		width: 100%\;
		border: 5px solid green\;
		padding: 5px\;
		margin: 5px\;
	\}\n\n";
	$txtdata .= "\.cit \{
		width: 100%\;
		border: 5px solid blue\;
		padding: 5px\;
		margin: 5px\;
	\}\n<\/style>\n\n";

	foreach my $figentry(sort keys %FigsCaption){
		push(@figsids,$figentry);
	}
	foreach my $pentry(sort keys %ParaWithID){
		push(@paraids,$pentry);
		#$logtxt .= "$pentry\n**************************\n$ParaWithID{$pentry}\n\n";
	}

	foreach my $entry(@figsids){
		if((grep(/$entry/, @paraids))){
			foreach my $imgname(@imagelist)
			{
				if(-e $imgname){
					my $actimgname = basename($imgname);
					my $thumbimgname = $actimgname;
					my $imgpath = $imgname;
					$imgpath =~ s/$actimgname//s;
					if($thumbimgname =~ /(.*)-thumb\.(\w+)$/s){
						if(($thumbimgname =~ /$ActFigname{$entry}/)&&(-e "$imgpath$thumbimgname")){
							# $txtdata .= "<img src=\"$mythumbdir$thumbimgname\"/>\n";
							$txtdata .= "<img src=\"Thumbs\\$thumbimgname\"/>\n";
						}
					}
				}
			}

			$txtdata .= "<br\/><span style=\"color:red\;\"><b>FIGURE $chnum\.$ActFigsIds{$entry}<\/b><\/span>\n";
			my $captext = $FigsCaption{$entry};
			$captext = &conv_cite($captext);
			$captext =~ s/<\!--(?s)(.*?)-->//g;
		    $captext =~ s/<\?new-page\?>//g;
			$txtdata .= "<br\/><br\/><span style=\"color:green\;\"><b>CAPTION<\/b><\/span><div class=\"cpt\">$captext<\/div>\n";
			my $paragraphtxt = "$ParaWithID{$entry}";
			$paragraphtxt = &conv_cite($paragraphtxt);
			$paragraphtxt =~ s/<\!--(?s)(.*?)-->//g;
			$paragraphtxt =~ s/<\?new-page\?>//g;
			$txtdata .= "<span style=\"color:blue\;\"><b>CITATION<\/b><\/span><div class=\"cit\">$paragraphtxt<\/div><br\/>\n\n";
        }else{
			if(!(grep(/(continued|\&numsp\;)/, $FigsCaption{$entry}))){
				$txtdata .= "<br\/><span style=\"color:red\;\"><b>FIGURE $chnum\.$ActFigsIds{$entry}<\/b><\/span>\n";
				$txtdata .= "<br\/><br\/><span style=\"color:green\;\"><b>CAPTION<\/b><\/span><div class=\"cpt\">$FigsCaption{$entry}<\/div>\n";
				$txtdata .= "<span style=\"color:blue\;\"><b>CITATION<\/b><\/span><div class=\"cit\"><span style=\"color:red\;\"><b>FIGURE $chnum\.$ActFigsIds{$entry} CITATION IS MISSING !!!<\/b><\/span><\/div><br\/>\n\n";
			}
		}
	}
	open(HTMLFILE, ">${outdir}\\$finalfilename.html");
	print HTMLFILE "$txtdata";
	close(HTMLFILE);
}

########################
sub conv_cite(){
	my ($convcitetxt)=@_;
	########### converts figure/table citation in text ##########
	while($convcitetxt =~ /<link ([^>]+)>/s){
		my $ttext = $1;
		$ttext =~ s/(.*?)href=\"([^\"]+)\"(.*?)$/$2/s;
		my @templinkID = split(/:/, $ttext);
		$ttext = $templinkID[$#templinkID];
		if($ttext =~ /-fig-/s){
			foreach my $mytkey(sort keys %ActFigsIds){
				if($mytkey eq $ttext){
					$ttext = $ActFigsIds{$mytkey};
				}
			}
			$ttext = "<span style=\"color:black\;background-color:lime\"><b>$ttext<\/b><\/span>";
		}
		elsif($ttext =~ /-tbl-/s){
			foreach my $mytkey(sort keys %ActTabsIds){
				if($mytkey eq $ttext){
					$ttext = $ActTabsIds{$mytkey};
				}
			}
			$ttext = "<span style=\"color:black\;background-color:pink\"><b>$ttext<\/b><\/span>";
		}else{
			my @tlink = split(/-/, $ttext);
			$ttext = $tlink[$#tlink];
			while($ttext =~ /^0/){
				$ttext =~ s/^0//s;
			}
			$ttext = "<span style=\"color:black\;background-color:yellow\"><b>$ttext<\/b><\/span>";
		}
		#$convcitetxt =~ s/<link ([^>]+)>/<span style=\"color:black\;background-color:lime\"><b>$ttext<\/b><\/span>/s;
		$convcitetxt =~ s/<link ([^>]+)>/$ttext/s;
	}
	############################################################
	return($convcitetxt);
}
########################
sub read_folder(){
	my ($mydir)=@_;
	find sub { push(@dirlist, $File::Find::name)}, "$mydir";
	foreach my $entry(@dirlist)
	{
        next if($entry =~ /\.rsrc/);
        next if($entry =~ /\.\./);

		if($entry =~ /\.(xhtml|xml)$/s){
			push(@filelist,$entry);
		}elsif($entry =~ /\.$extn$/s){
			push(@imagelist,$entry);
		}
	}
}
########################
sub flush_imgFolder(){
	@dirlist = ();
	@filelist = ();
	@imagelist = ();
}
########################
sub conv_img(){
	$mythumbdir = "${outdir}/Thumbs/";
	foreach my $imgname(@imagelist)
	{
		if($imgname =~ /-thumb\.(\w+)/s){
			unlink("$imgname");
		}
	}
	rmtree($mythumbdir);
	mkdir($mythumbdir);
	
	foreach my $imgname(@imagelist)
	{
		if(-e $imgname){
			my $actimgname = basename($imgname);
			my $thumbimgname = $actimgname;
			if($actimgname =~ /\.eps$/s){
				$thumbimgname =~ s/\.(\w+)$//s;
				$thumbimgname = "${thumbimgname}-thumb.png";
				push(@thimagelist,$thumbimgname);
				# print "$imgname\n$mythumbdir$thumbimgname\n\n";
				system("convert -density 300 $imgname -resize 200x200 -units pixelsperinch -density 300 $mythumbdir$thumbimgname");
			}else{
				if(($thumbimgname =~ /\.(\w+)$/s)&&($thumbimgname !~ /-thumb\.png$/s)){
					my $imgextn = $1;
					$thumbimgname =~ s/\.(\w+)$//s;
					$thumbimgname = "${thumbimgname}-thumb\.$imgextn";
					push(@thimagelist,$thumbimgname);
					system("convert -density 300 $imgname -resize 200x200 -units pixelsperinch -density 300 $mythumbdir$thumbimgname");
				}
			}
		}
	}
}
########################
sub write_Temp(){
	my $mykey;
	$tempdata .="\nFigures\n***********************\n\n";
	foreach $mykey(sort keys %FigsIds)
	{
		$tempdata .= "$mykey --> $FigsIds{$mykey}\n";
	}
	$tempdata .="\nFigures Wtg Links\n***********************\n\n";
	foreach $mykey(sort keys %WtgFigsIds)
	{
		$tempdata .= "$mykey --> $WtgFigsIds{$mykey}\n";
	}
	$tempdata .="\nActual Figures Links\n***********************\n\n";
	foreach $mykey(sort keys %ActFigsIds)
	{
		$tempdata .= "$mykey --> $ActFigsIds{$mykey}\n";
	}

	# $tempdata .="\nCited Paragraph\n***********************\n\n";
	# foreach $mykey(sort keys %ParaWithID)
	# {
		# $tempdata .= "\n***********************\n$mykey\n***********************\n$ParaWithID{$mykey}\n";
	# }
	
	$tempdata .="\nTables\n***********************\n\n";
	foreach $mykey(sort keys %TabsIds)
	{
		$tempdata .= "$mykey --> $TabsIds{$mykey}\n";
	}
	$tempdata .="\nTables Wtg Links\n***********************\n\n";
	foreach $mykey(sort keys %WtgTabsIds)
	{
		$tempdata .= "$mykey --> $WtgTabsIds{$mykey}\n";
	}
	$tempdata .="\nActual Tables Links\n***********************\n\n";
	foreach $mykey(sort keys %ActTabsIds)
	{
		$tempdata .= "$mykey --> $ActTabsIds{$mykey}\n";
	}

	open(TEMPFILE, ">TEMPTEXT.txt");
	print TEMPFILE "$tempdata";
	close(TEMPFILE);
}
########################
sub write_log(){
	open(TEMPFILE, ">${outdir}\\MissedPara.log");
	print TEMPFILE "$logtxt";
	close(TEMPFILE);
}

__END__

