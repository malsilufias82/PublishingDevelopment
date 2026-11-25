#!/usr/bin/perl -w
use strict;
use File::Path;
use File::Find;
use File::Copy;
use File::Basename;

system("cls");

########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%40s%15s\n","*","DEVELOPED BY : Saiful Islam","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################


my $txtname = "$ARGV[0]";
chomp($txtname);


if((!$ARGV[0])) {
    print "\nGenerateToc.exe <Sequence .txt File Name>, Try Again...\n\n";
    exit(0);
}

################################## VARIABLE DECLARATIONS ######################################
my ($booktitle,$filestr,$count,$filename,$toctext,$chnum,$figcaptions,$figtitle,$outfile,$logtxt,$chtitle);
my $H2FLAG;
my (@toclist,@pagelist,@listoftable,@listoffigure);
my (@Compseqfiles,@txtseqfiles,@dirlist,@filelist,@imagelist,@tempfilelist);
my $extn = qr/jpg|tif|png|gif/x;

my $txtfilename = basename($txtname);
my $myfolder = $txtname;
$myfolder =~ s/$txtfilename//s;
$txtfilename =~ s/\.(\w+)$//s;

##################################### CALL FUNCTIONS ##########################################

&read_txtfile;
&fetch_listoffile;

&write_tocPrelims;
&tocList;
&write_lot;
&write_loi;
&write_guidelist;
&write_pageList;
   
&write_ftoc;
&write_tocncx;
&write_opf;

# &write_logfile;

######################################### FUNCTIONS #########################################
sub read_txtfile(){
	my $txtstr=&read_file($txtname);
	open(XTXTFILE, ">$myfolder${txtfilename}_New.txt");
	print XTXTFILE "$txtstr";
	close(XTXTFILE);
	move("$myfolder${txtfilename}_New.txt", "$myfolder${txtfilename}.txt");
	
	open(TXTFILE, "$txtname") or die "Can't open '$filename': $!";
	my $line;
	while(<TXTFILE>){
		$line = $_;
		if($line !~ /(toc|cover)/){
			push(@txtseqfiles,$line);
		}
		push(@Compseqfiles,$line);
	}
}
########################
sub read_file(){
	my ($filename)=@_;
	open(INFILE, "$filename") or die "Can't open '$filename': $!";;
	my @filearr=<INFILE>;
	close(INFILE);
	my $filestring=join("",@filearr);
	$filestring =~ s/\r*\n/\n/g;
	$filestring =~ s/([ ]+)/ /g;
	$filestring =~ s/([\t]+)//g;
    $filestring =~ s/([\n]+)/\n/g;
	return($filestring);
}
########################
sub fetch_listoffile(){
	find sub { push(@dirlist, $File::Find::name)}, "$myfolder";

	foreach my $entry(@dirlist)
	{
        next if($entry =~ /\.rsrc/);
        next if($entry =~ /\.\./);

		if($entry =~ /\.xhtml$/s){
			push(@filelist,$entry);
			# print "$entry\n";
		}elsif($entry =~ /\.$extn$/s){
			push(@imagelist,$entry);
		}
	}
	@filelist = sort(@filelist);
	@imagelist = sort(@imagelist);
}
########################
sub write_tocPrelims(){
	foreach my $entry(@txtseqfiles)
	{
		chomp($entry);
		if((grep(/$entry/, @filelist))){
			$filename = "$myfolder$entry";
			$filestr=&read_file($filename);
			$filestr =~ s/<br\/>/ /g;
			$filestr =~ s/([ ]+)/ /g;
			if($filestr =~ /<h1 class=\"bookTitle\">([^<>]+)<\/h1>/){
				$booktitle = $1;
			}
			$filestr = "";			
		}
	}
	
	if(!$booktitle){
		$booktitle = "XXXXXXXXXXXXXX";
	}
	
	# $toctext .= "<\?xml version=\"1\.0\" encoding=\"utf-8\"\?>\n<\!DOCTYPE html>\n<html xmlns=\"http:\/\/www.w3.org\/1999\/xhtml\" xmlns:epub=\"http:\/\/www.idpf.org\/2007\/ops\" xmlns:m=\"http:\/\/www.w3.org\/1998\/Math\/MathML\" xmlns:svg=\"http:\/\/www.w3.org\/2000\/svg\" xmlns:ibooks=\"http:\/\/vocabulary.itunes.apple.com\/rdf\/ibooks\/vocabulary-extensions-1.0\" epub:prefix=\"ibooks: http:\/\/vocabulary.itunes.apple.com\/rdf\/ibooks\/vocabulary-extensions-1.0 index: http:\/\/www.index.com\/\" xml:lang=\"en\" lang=\"en\">\n";
	$toctext .= "<\!DOCTYPE html>\n<html xmlns=\"http:\/\/www.w3.org\/1999\/xhtml\" xmlns:epub=\"http:\/\/www.idpf.org\/2007\/ops\" xmlns:m=\"http:\/\/www.w3.org\/1998\/Math\/MathML\" xmlns:svg=\"http:\/\/www.w3.org\/2000\/svg\" xmlns:ibooks=\"http:\/\/vocabulary.itunes.apple.com\/rdf\/ibooks\/vocabulary-extensions-1.0\" epub:prefix=\"ibooks: http:\/\/vocabulary.itunes.apple.com\/rdf\/ibooks\/vocabulary-extensions-1.0 index: http:\/\/www.index.com\/\" xml:lang=\"en\" lang=\"en\">\n";
	$toctext .= "<head>\n<title>$booktitle<\/title>\n<link href=\"WileyTemplate_v5.5.css\" rel=\"stylesheet\" type=\"text\/css\"\/>\n</head>\n";
	$toctext .= "<body epub:type=\"frontmatter\">\n<nav class=\"tocList\" role=\"doc-toc\" epub:type=\"toc\" id=\"toc\">\n<h1>CONTENTS</h1>\n";
}
########################
sub tocList(){
	$toctext .= "<ol role=\"directory\">\n<li class=\"contentsH1\"><a href=\"fcover.xhtml\">Cover<\/a><\/li>\n";
	############################## Write TOC for FM ##############################
	foreach my $entry(@txtseqfiles)
	{
		chomp($entry);
		if((grep(/$entry/, @filelist))){
			$filename = "$myfolder$entry";
			$filestr=&read_file($filename);
			$filestr =~ s/<\!--(?s)(.*?)-->//g;
			$filestr =~ s/\n<(\w+)\/>/<$1\/>/g;
			$filestr =~ s/<br\/>//g;
			$filestr =~ s/<span epub:type=\"pagebreak\"([^<>]+)\/>//g;
			$filestr =~ s/<span epub:type=\"pagebreak\"([^<>]+)><\/span>//g;
			$filestr =~ s/<span([^<>]+)epub:type=\"pagebreak\"([^<>]+)\/>//g;
			$filestr =~ s/<span([^<>]+)epub:type=\"pagebreak\"([^<>]+)><\/span>//g;

			if($filestr =~ /<h1(.*?)<\/h1>/){
				my $h1text = $1;
				$h1text =~ s/<b ([^<>]+)>(.*?)<\/b>/<b>$2<\/b>/g;
				$h1text =~ s/(ChapterTitle|Chapteritle|Chaptertitle|chaptertitle|CHAPTERTITLE)/chapterTitle/g;
				$h1text =~ s/(PartTitle|Parttitle|partTitle|PARTTITLE)/partTitle/g;
				$h1text =~ s/(ChapterNumber|Chapternumber|chapternumber|chapterNumber|CHAPTERNUMBER)/chapterNumber/g;
				$h1text =~ s/(PartNumber|Partnumber|partnumber|partNumber|PARTNUMBER)/partNumber/g;
				$filestr =~ s/<h1(.*?)<\/h1>/<h1$h1text<\/h1>/s;
			}
			if(($filestr =~ /<h1(.*?)<b>(.*?)<\/b><\/h1>/)||($filestr =~ /<h1(.*?)<span class=\"chapterTitle\">(.*?)<\/span><\/h1>/)||($filestr =~ /<h1(.*?)<span class=\"partTitle\">(.*?)<\/span><\/h1>/)){
				my $h1att = $1;
				$chtitle = $2;
				$chtitle =~ s/<span ([^<>]+)>(.*?)<\/span>/$2/g;
				$chtitle =~ s/<span>(.*?)<\/span>/$1/g;
				$chtitle =~ s/<span ([^<>]+)>//g;
				$chtitle =~ s/<span>//g;
				$chtitle =~ s/<\/span>//g;
				$chtitle =~ s/<a ([^<>]+)>(.*?)<\/a>/$2/g;
				
				if(($h1att =~ /<span class=\"chapterNumber\">(.*?)<\/span>/)||($h1att =~ /<span class=\"partNumber\">(.*?)<\/span>/)){
					my $chnum = $1;
					if(($filestr =~ /<h1(.*?)Part (.*?)<\/h1>/s)||($filestr =~ /<h1(.*?)PART (.*?)<\/h1>/s)){
						$toctext .= "<Pli class=\"contentsH1\"><a href=\"$entry\">$chnum $chtitle<\/a>\n<ol>\n";
						$toctext =~ s/<b>(.*?)<\/b>/$1/g;
						push(@toclist,"<part><a href=\"$entry\">$chnum $chtitle<\/a><\/part>");
					}else{
						$toctext .= "<li class=\"contentsH1\"><a href=\"$entry\">$chnum $chtitle<\/a>\n<ol>\n";
						push(@toclist,"<chapter><a href=\"$entry\">$chnum $chtitle<\/a><\/chapter>");
					}
				}elsif(($filestr =~ /<h1(.*?)<span class=\"partTitle\">(.*?)<\/span><\/h1>/)&&(!grep(/partNumber/,$filestr))){
					$toctext .= "<Pli class=\"contentsH1\"><a href=\"$entry\">$chtitle<\/a>\n<ol>\n";
					$toctext =~ s/<b>(.*?)<\/b>/$1/g;
					push(@toclist,"<part><a href=\"$entry\">$chtitle<\/a><\/part>");
				}else{
					$toctext .= "<li class=\"contentsH1\"><a href=\"$entry\">$chtitle<\/a><\/li>\n";
					push(@toclist,"<fm><a href=\"$entry\">$chtitle<\/a><\/fm>");
				}
			}elsif(($filestr =~ /<h1 class=\"chapterTitle\"(.*?)<\/h1>/)||($filestr =~ /<h1 class=\"partTitle\"(.*?)<\/h1>/)){
				$chtitle = $1;
				if($filestr =~ /<h1 class=\"(chapterTitle|partTitle)\">(.*?)<\/h1>/){
					$chtitle = $2;
				}
				$chtitle =~ s/<span ([^<>]+)>(.*?)<\/span>/$2/g;
				$chtitle =~ s/<span>(.*?)<\/span>/$1/g;
				$chtitle =~ s/<span ([^<>]+)>//g;
				$chtitle =~ s/<span>//g;
				$chtitle =~ s/<\/span>//g;
				$chtitle =~ s/<a([^<>]+)\/>//g;
				$chtitle =~ s/<a([^<>]+)>//g;
				$chtitle =~ s/<\/a>//g;
				if(($filestr =~ /<h1 class=\"chapterTitle\"(.*?)<\/h1>/)&&(!grep(/partNumber/,$filestr))){
					$toctext .= "<li class=\"contentsH1\"><a href=\"$entry\">$chtitle<\/a>\n<ol>\n";
					push(@toclist,"<chapter><a href=\"$entry\">$chtitle<\/a><\/chapter>");
				}elsif(($filestr =~ /<h1 class=\"partTitle\"(.*?)<\/h1>/)&&(!grep(/partNumber/,$filestr))){
					$toctext .= "<Pli class=\"contentsH1\"><a href=\"$entry\">$chtitle<\/a>\n<ol>\n";
					$toctext =~ s/<b>(.*?)<\/b>/$1/g;
					push(@toclist,"<part><a href=\"$entry\">$chtitle<\/a><\/part>");
				}else{
					$toctext .= "<li class=\"contentsH1\"><a href=\"$entry\">$chtitle<\/a><\/li>\n";
					push(@toclist,"<fm><a href=\"$entry\">$chtitle<\/a><\/fm>");
				}
			}
			############## Sections ################
			$H2FLAG = "FALSE";
			while($filestr =~ s/<h2(.*?)<\/h2>/<Xh2$1<\/Xh2>/s){
				my $hdata = "<h2$1<\/h2>";
				my ($hid,$htitle);
				if($hdata =~ /id=\"([^\"]+)\"/s){
					$hid = $1;
				}
				if($hdata !~ /class=\"book([^\"]+)\"/){
					$hdata =~ s/<a ([^<>]+)\/>//g;
					$hdata =~ s/<a ([^<>]+)>//g;
					$hdata =~ s/<\/a>//g;
					$hdata =~ s/<span>//g;
					$hdata =~ s/<span([^>]+)>//g;
					$hdata =~ s/<\/span>//g;
					$htitle = $hdata;
					$htitle =~ s/<h2>//s;
					$htitle =~ s/<h2 ([^<>]+)>//s;
					$htitle =~ s/<\/h2>//s;
					if(($hid)&&($hdata =~ /<h2/s)){
						$toctext .= "<li class=\"contentsH2\"><a href=\"$entry\#$hid\">$htitle<\/a><\/li>\n";
						push(@toclist,"<heads2><a href=\"$entry\#$hid\">$htitle<\/a><\/heads2>");
						$H2FLAG = "TRUE";
					}
				}
			}
			if(($filestr =~ /<Xh2/s)&&($H2FLAG eq "TRUE")){
				$toctext =~ s/<li class=\"contentsH1\">(.*?)<\/li>\n<li class=\"contentsH2\">/<li class=\"contentsH1\">$1\n<ol>\n<li class=\"contentsH2\">/g;
				$toctext .= "<\/ol><\/li>\n";
			}
		}
		$toctext =~ s/<li class=\"contentsH1\"><a href=\"([^\"]+)\"><\/a>\n<ol>\n<li class=\"contentsH1\">/<li class=\"contentsH1\"><a href=\"$1\"><\/a><\/li>\n<li class=\"contentsH1\">/g;
		$filestr = "";
	}

	
	if($toctext =~ /<Pli(.*?)<\/a>/s){
		$toctext .= "<\/ol><\/li>\n<\/ol>\n<\/nav>\n\n";
	}else{
		$toctext .= "<\/ol>\n<\/nav>\n\n";
	}
	$toctext =~ s/<li class=\"([^\"]+)\"><a href=\"([^\"]+)\">Cover<\/a><\/li>\n<\/ol><\/li>\n/<li class=\"$1\"><a href=\"$2\">Cover<\/a><\/li>\n/s;
	$toctext =~ s/<Pli/<li/s;
	$toctext =~ s/<Pli/<\/ol><\/li>\n<li/g;
}
########################
sub write_lot(){
	my $tabtext .= "<nav epub:type=\"lot\">\n<h2><b>List of Tables<\/b><\/h2>\n<ol>\n";
	my $TABFLAG = "FALSE";
	foreach my $entry(@txtseqfiles)
	{
		chomp($entry);
		if((grep(/$entry/, @filelist))){
			$filename = "$myfolder$entry";
			$filestr=&read_file($filename);
			$filestr =~ s/<\!--(?s)(.*?)-->//g;
			$filestr =~ s/<span epub:type=\"pagebreak\"([^<>]+)\/>//g;
			$filestr =~ s/<span epub:type=\"pagebreak\"([^<>]+)><\/span>//g;
			$filestr =~ s/<span([^<>]+)epub:type=\"pagebreak\"([^<>]+)\/>//g;
			$filestr =~ s/<span([^<>]+)epub:type=\"pagebreak\"([^<>]+)><\/span>//g;
			
			&place_IDs();
			&get_chnum();
			
			if($filestr =~ /<span class=\"figureLabel\">(.*?)>(Table|TABLE|table) ([^<>]+)(.*?)<\/span>/){
				$chnum = "\L$chnum\E";
				$chnum =~ s/chapter //s;
				# $chnum =~ s/CHAPTER //s;
				$tabtext .= "<li class=\"contentsH1\"><span>Chapter $chnum</span>\n<ol>\n";
				push(@listoftable,"<span>Chapter $chnum</span>");
				$TABFLAG = "TRUE";
			}
			my ($myFigID,$ancatt,$ancdata);
			$ancdata = "";
			while($filestr =~ s/<span class=\"figureLabel\">(.*?)<\/span>/<Xspan class=\"figureLabel\">$1<\/Xspan>/s){
				my $figcaptions = $1;
				if($figcaptions =~ /<a([^<>]+)>(.*?)<\/a>/s){
					$ancatt = $1;
					$ancdata = $2;
					if($ancatt =~ /id=\"([^\"]+)\"/s){
						$myFigID = $1;
					}
				}
				if($ancdata =~ /(Table|TABLE|table) /s){
					$tabtext .= "<li class=\"contentsH1\"><a href=\"$entry\#$myFigID\">$ancdata<\/a><\/li>\n";
					push(@listoftable,"<a href=\"$entry\#$myFigID\">$ancdata<\/a>");
				}
				$ancdata = "";
			}
			if($filestr =~ /<Xspan class=\"figureLabel\">(.*?)>(Table|TABLE|table) ([^<>]+)(.*?)<\/Xspan>/){
				$tabtext .= "<\/ol><\/li>\n\n";
			}
		}
	}
	$tabtext .= "<\/ol>\n<\/nav>\n\n";
	if($TABFLAG eq "TRUE"){
		$toctext .= $tabtext;
	}
}
########################
sub write_loi(){
	my $loitext .= "<nav epub:type=\"loi\">\n<h2><b>List of Illustrations<\/b><\/h2>\n<ol>\n";
	my $FIGFLAG = "FALSE";
	foreach my $entry(@txtseqfiles)
	{
		chomp($entry);
		if((grep(/$entry/, @filelist))){
			$filename = "$myfolder$entry";
			$filestr=&read_file($filename);
			$filestr =~ s/<\!--(?s)(.*?)-->//g;
			$filestr =~ s/<span epub:type=\"pagebreak\"([^<>]+)\/>//g;
			$filestr =~ s/<span epub:type=\"pagebreak\"([^<>]+)><\/span>//g;
			$filestr =~ s/<span([^<>]+)epub:type=\"pagebreak\"([^<>]+)\/>//g;
			$filestr =~ s/<span([^<>]+)epub:type=\"pagebreak\"([^<>]+)><\/span>//g;

			&place_IDs();
			&get_chnum();
			if($filestr =~ /<span class=\"figureLabel\">(.*?)>(Figure|FIGURE|ILLUSTRATION|Illustration) ([^<>]+)(.*?)<\/span>/){
					$chnum = "\L$chnum\E";
					$chnum =~ s/chapter //s;
					$loitext .= "<li class=\"contentsH1\"><span>Chapter $chnum</span>\n<ol>\n";
					push(@listoffigure,"<span>Chapter $chnum</span>");
					$FIGFLAG = "TRUE";
			}
			my ($myFigID,$ancatt,$ancdata);
			while($filestr =~ s/<figcaption>(.*?)<\/figcaption>/<Xfigcaption>$1<\/Xfigcaption>/s){
				$figcaptions = $1;
				$figcaptions =~ s/<\/span>([ ]+)<\/p>/<\/span><\/p>/g;
				if($figcaptions =~ /<span class=\"figureLabel\">(.*?)(Figure|FIGURE|ILLUSTRATION|Illustration) ([^<>]+)(.*?)<\/span>/){
					if($figcaptions =~ /<a([^<>]+)>(.*?)<\/a>/s){
						$ancatt = $1;
						$ancdata = $2;
						$ancdata =~ s/<span>//g;
						$ancdata =~ s/<span ([^>]+)>//g;
						$ancdata =~ s/<\/span>//g;
						$ancdata =~ s/<b>//g;
						$ancdata =~ s/<\/b>//g;
						if($ancatt =~ /id=\"([^\"]+)\"/s){
							$myFigID = $1;
						}
					}
					
					if($figcaptions =~ /<p><span ([^<>]+)>(.*?)<\/span><\/p>/){
						$figtitle = $2;
						$figtitle =~ s/<a([^<>]+)>(.*?)<\/a>//s;
						$figtitle =~ s/<a([^<>]+)>(.*?)<\/a>/$2/g;
						$figtitle =~ s/<b>//g;
						$figtitle =~ s/<\/b>//g;
						# print "$myFigID\n";
					}elsif($figcaptions =~ /<p><span ([^<>]+)>(.*?)<\/span> (.*?)<\/p>/){
						$figtitle = $3;
						$figtitle =~ s/<a([^<>]+)>(.*?)<\/a>/$2/g;
						$figtitle =~ s/<b>//g;
						$figtitle =~ s/<\/b>//g;
					}
					if(!$myFigID){
						$myFigID = "";
					}
					if(!$ancdata){
						$ancdata = "";
					}
					if($figtitle){
						my $tagcnt = 1;
						my %tagholder;
						while($figtitle =~ /<([^>]+)>/s){
							my $temptag = "<$1>";
							$tagholder{"\&tag$tagcnt\;"} = "$temptag";
							$figtitle =~ s/<([^>]+)>/\&tag$tagcnt\;/s;
							$tagcnt++;
						}

						$figtitle = &get_80char();
						
						while($figtitle =~ /\&tag([0-9]+)\;/s){
							my $tempkey = "\&tag$1\;";
							my $keyvalue = $tagholder{"$tempkey"};
							$figtitle =~ s/\&tag([0-9]+)\;/$keyvalue/s;
						}
					}else{
						$figtitle = "";
					}
					if($ancdata =~ /(Figure|FIGURE|ILLUSTRATION|Illustration) /s){
						$loitext .= "<li class=\"contentsH2\"><a href=\"$entry\#$myFigID\">$ancdata $figtitle<\/a><\/li>\n";
						push(@listoffigure,"<a href=\"$entry\#$myFigID\">$ancdata $figtitle<\/a>");
					}
					$ancdata = "";
				}
			}

			if($filestr =~ /<span class=\"figureLabel\">(.*?)>(Figure|FIGURE|ILLUSTRATION|Illustration) ([^<>]+)(.*?)<\/span>/){
				$loitext .= "<\/ol><\/li>\n\n";
			}
		}
	}
	$loitext .= "<\/ol>\n<\/nav>\n\n";
	$loitext =~ s/([ ]+)/ /g;
	$loitext =~ s/<li class=\"contentsH1\"><span>Chapter ([^<>]+)<\/span>\n<ol>\n<\/ol><\/li>\n\n//g;
	if($FIGFLAG eq "TRUE"){
		$toctext .= $loitext;
	}
}
########################
sub place_IDs(){
		while($filestr =~ /<figure>(.*?)<\/figure>/s){
			$filestr =~ s/<figure>(.*?)<\/figure>/<Xfigure>$1<\/Xfigure>/s;
		}

		while($filestr =~ /<figure ([^<>]+)>(.*?)<\/figure>/s){
			my $figatt = $1;
			my $figdata = $2;
			if($figatt =~ /id=\"([^\"]+)\"/s){
				my $actfigID = $1;
				if($figdata =~ /<span class=\"figureLabel\"><a([^<>]+)>/s){
					my $figID = $1;
					if($figID !~ /id=\"([^\"]+)\"/s){
						$figdata =~ s/<span class=\"figureLabel\"><a([^<>]+)>/<span class=\"figureLabel\"><a id=\"$actfigID\" $1>/s;
					}
				}
			}
			$filestr =~ s/<figure ([^<>]+)>(.*?)<\/figure>/<Zfigure $1>$figdata<\/Zfigure>/s;
		}
		$filestr =~ s/([ ]+)/ /g;
}
########################
sub get_chnum(){
	if(($filestr =~ /<h1(.*?)<b>(.*?)<\/b><\/h1>/)||($filestr =~ /<h1(.*?)<span class=\"chapterTitle\">(.*?)<\/span><\/h1>/)){
		my $h1att = $1;
		if($h1att =~ /<span class=\"chapterNumber\">([^<>]+)<\/span>/){
			$chnum = $1;
		}
	}else{
		$chnum = "XXX";
	}
#	return($chnum);
}

########################
sub get_80char(){
	my $FLAG = "TRUE";
	my $figcap = "";
	$count = 1;
	while($figtitle =~ s/(.)//s){
		my $mychar = $1;
		$figcap .= $mychar;

		if($mychar =~ /(\&|<)/s){
			$FLAG = "FALSE";
		}
		if(($mychar =~ /(\;|>)/s)){
			$FLAG = "TRUE";
		}

		if($FLAG eq "TRUE")
		{
			if(($mychar !~ />/s)){
				$count++;
			}
		}

		if($count > 80){
			$figcap .= "\.\.\.";
			last;
		}
	}
	return($figcap);
}
########################
sub write_guidelist(){
	$toctext .= "<nav class=\"guideList\" epub:type=\"landmarks\" id=\"guide\">\n<h2>Guide</h2>\n<ol>\n";
	foreach my $entry(@filelist){
		if($entry =~ /cover/){
			$entry = basename($entry);
			$toctext .= "<li><a epub:type=\"cover\" href=\"$entry\">Cover<\/a><\/li>\n";
		}elsif($entry =~ /toc/){
			$entry = basename($entry);
			$toctext .= "<li><a epub:type=\"toc\" href=\"$entry\">Table of Contents<\/a><\/li>\n";
			last;
		}
	}
	
	if(!(grep(/toc/,@filelist))){
		$toctext .= "<li><a epub:type=\"toc\" href=\"ftoc.xhtml\">Table of Contents<\/a><\/li>\n";
	}
	
	foreach my $entry(@txtseqfiles)
	{
		chomp($entry);
		if((grep(/$entry/, @filelist))){
			$filename = "$myfolder$entry";
			$filestr=&read_file($filename);

			if(($filestr =~ /<h1(.*?)<b>(.*?)<\/b><\/h1>/)||($filestr =~ /<h1(.*?)<span class=\"chapterTitle\">(.*?)<\/span><\/h1>/is)){
				my $h1att = $1;
				my $chtitle = $2;
				if($chtitle =~ /(Preface|Foreword|Introduction|PREFACE|FOREWORD|INTRODUCTION)/){
					$toctext .= "<li><a epub:type=\"\L$chtitle\E\" href=\"$entry\">$chtitle<\/a><\/li>\n";
					last;
				}elsif($h1att =~ /<span class=\"chapterNumber\">([^<>]+)<\/span>/is){
					$chnum = $1;
					$chnum =~ s/(CHAPTER |Chapter |chapter )//s;
					$chnum =~ s/(CHAPTER|Chapter|chapter)//s;
					$toctext .= "<li><a epub:type=\"Chapter\" href=\"$entry\">Chapter $chnum<\/a><\/li>\n";
					last;
				}else{
					$toctext .= "<li><a epub:type=\"chapter\" href=\"$entry\">Chapter<\/a><\/li>\n";
					last;
				}
			}elsif($filestr =~ /<h1 class=\"chapterTitle\"(.*?)<\/h1>/is){
				$chtitle = $1;
				if($filestr =~ /<h1 class=\"chapterTitle\">(.*?)<\/h1>/is){
					$chtitle = $1;
				}
				$chtitle =~ s/<span ([^<>]+)>(.*?)<\/span>/$2/g;
				$chtitle =~ s/<span>(.*?)<\/span>/$1/g;
				$chtitle =~ s/<span ([^<>]+)>//g;
				$chtitle =~ s/<span>//g;
				$chtitle =~ s/<\/span>//g;
				$chtitle =~ s/<a([^<>]+)\/>//g;
				$chtitle =~ s/<a([^<>]+)>//g;
				$chtitle =~ s/<\/a>//g;
				if(($chtitle =~ /(Preface|Foreword|Introduction|PREFACE|FOREWORD|INTRODUCTION)/)&&($chtitle !~ /(Preface |Foreword |Introduction |PREFACE |FOREWORD |INTRODUCTION )/)){
					$toctext .= "<li><a epub:type=\"\L$chtitle\E\" href=\"$entry\">$chtitle<\/a><\/li>\n";
					last;
				}else{
					$toctext .= "<li><a epub:type=\"chapter\" href=\"$entry\">Chapter<\/a><\/li>\n";
					last;
				}
			
			}
		}
	}
	$toctext .= "<\/ol>\n<\/nav>\n\n";
}
########################
sub write_pageList(){
	$toctext .= "<nav class=\"pageList\" epub:type=\"page-list\" id=\"pages\" hidden=\"hidden\">\n<h2>Pages<\/h2>\n<ol>\n";
	foreach my $entry(@Compseqfiles)
	{
		if($entry !~ /toc/){
			chomp($entry);
			$filename = "$myfolder$entry";
			$filestr=&read_file($filename);
			$filestr =~ s/<\!--(?s)(.*?)-->//g;
			
			$filestr =~ s/<span([^<>]+)epub:type=\"pagebreak\"([^<>]+)\/>/<span$1epub:type=\"pagebreak\"$2><\/span>/g;
			my ($spanatt,$spid,$sptitle);
			while($filestr =~ s/<span([^<>]+)epub:type=\"pagebreak\"([^<>]+)><\/span>/<Xspan$1epub:type=\"pagebreak\"$2><\/Xspan>/s){
				$spanatt = "$1 $2";
				if($spanatt =~ /id=\"([^\"]+)\"/s){
					$spid = $1;
				}
				if($spanatt =~ /title=\"([^\"]+)\"/s){
					$sptitle = $1;
				}
				if($sptitle){
					$toctext .= "<li><a href=\"$entry\#${spid}\">$sptitle<\/a><\/li>\n";
					push(@pagelist,"<a href=\"$entry\#${spid}\">$sptitle<\/a>");
				}
			}
			if(!($sptitle)){
				$logtxt .= "Page tag NOT FOUND in $entry\n";
			}
		}
	}
	$logtxt .= "\n\n";
	$toctext .= "<\/ol>\n<\/nav>\n";
}
########################
sub write_tocncx(){
	my $tocncx;
	$tocncx = "<?xml version=\"1.0\" encoding=\"UTF-8\"\?>\n<ncx xmlns=\"http:\/\/www.daisy.org\/z3986\/2005\/ncx\/\"\n\txmlns:ncx=\"http:\/\/www.daisy.org\/z3986\/2005\/ncx\/\"\n\tversion=\"2005-1\" xml:lang=\"en\">\n";
	$tocncx .= "<head>\n\t<meta name=\"dtb:uid\" content=\"XXXXXXXXXXXXX\"\/>\n\t<meta name=\"dtb:depth\" content=\"2\"\/>\n\t<meta name=\"dtb:totalPageCount\" content=\"000\"\/>\n\t<meta name=\"dtb:maxPageNumber\" content=\"000\"\/>\n<\/head>\n";
	$tocncx .= "<docTitle>\n\t<text>$booktitle<\/text>\n<\/docTitle>\n";
	$tocncx .= "<navMap>\n";
	
	my $fitemtoclist = $toclist[0];
	$fitemtoclist =~ s/<([^<>]+)><a href="([^\"]+)">(.*?)<\/a><\/([^<>]+)>/$2/s;
	my $playorder = 1;
	foreach my $cmpentry(@Compseqfiles){
		if($cmpentry =~ /cover/s){
			$tocncx .= "<navPoint id=\"c$playorder\" playOrder=\"$playorder\">\n\t<navLabel><text>Cover<\/text><\/navLabel>\n\t<content src=\"$cmpentry\"\/>\n<\/navPoint>\n";
			$playorder++;
		}elsif($cmpentry =~ /toc/s){
			next;
		}elsif($cmpentry =~ /$fitemtoclist/s){
			last;
		}else{
			chomp($cmpentry);
			$filename = "$myfolder$cmpentry";
			$filestr=&read_file($filename);
			$filestr =~ s/<\!--(?s)(.*?)-->//g;
			if($filestr =~ /\"(titlePage|titlepage)\"/s){
				$tocncx .= "<navPoint id=\"c$playorder\" playOrder=\"$playorder\">\n\t<navLabel><text>Title Page<\/text><\/navLabel>\n\t<content src=\"$cmpentry\"\/>\n<\/navPoint>\n";
				$playorder++;
			}elsif($filestr =~ /<p class=\"copyright\">/s){
				$tocncx .= "<navPoint id=\"c$playorder\" playOrder=\"$playorder\">\n\t<navLabel><text>Copyright<\/text><\/navLabel>\n\t<content src=\"$cmpentry\"\/>\n<\/navPoint>\n";
				$playorder++;
			}else{
				$tocncx .= "<navPoint id=\"c$playorder\" playOrder=\"$playorder\">\n\t<navLabel><text>XXXXXXXXXXXXX<\/text><\/navLabel>\n\t<content src=\"$cmpentry\"\/>\n<\/navPoint>\n";
				$playorder++;
			}
		}
	
	}

	my $FLAG = "";
	foreach my $entry(@toclist){
		$entry =~ s/<fm><a href=\"c([^\.]+).xhtml\">(.*?)<\/a><\/fm>/<chapter><a href=\"c$1.xhtml\">$2<\/a><\/chapter>/s;
	
		if($entry =~ /<fm>(.*?)<\/fm>/s){
			my $enttext = $1;
			my ($hrefid,$enttitle);
			if($enttext =~ /<a href=\"([^\"]+)\">(.*?)<\/a>/s){
				$hrefid = $1;
				$enttitle = $2;
				$enttitle =~ s/<(b|i|sup|sub)>([^<>]+)<\/(b|i|sup|sub)>/$2/g;
			}
			$tocncx .= "<FnavPoint id=\"c$playorder\" playOrder=\"$playorder\">\n\t<navLabel><text>$enttitle<\/text><\/navLabel>\n\t<content src=\"$hrefid\"\/>\n<\/FnavPoint>\n";
		}elsif($entry =~ /<part>(.*?)<\/part>/s){
			my $enttext = $1;
			my ($hrefid,$enttitle);
			if($enttext =~ /<a href=\"([^\"]+)\">(.*?)<\/a>/s){
				$hrefid = $1;
				$enttitle = $2;
				$enttitle =~ s/<(b|i|sup|sub)>([^<>]+)<\/(b|i|sup|sub)>/$2/g;
			}
			$tocncx .= "<PnavPoint id=\"c$playorder\" playOrder=\"$playorder\">\n\t<PnavLabel><text>$enttitle<\/text><\/navLabel>\n\t<Pcontent src=\"$hrefid\"\/>\n<\/PnavPoint>\n";
			$FLAG = "PART";
		}elsif($entry =~ /<chapter>(.*?)<\/chapter>/s){
			my $enttext = $1;
			my ($hrefid,$enttitle);
			if($enttext =~ /<a href=\"([^\"]+)\">(.*?)<\/a>/s){
				$hrefid = $1;
				$enttitle = $2;
				$enttitle =~ s/<(b|i|sup|sub)>([^<>]+)<\/(b|i|sup|sub)>/$2/g;
			}
			$tocncx .= "<CnavPoint id=\"c$playorder\" playOrder=\"$playorder\">\n\t<CnavLabel><text>$enttitle<\/text><\/navLabel>\n\t<Ccontent src=\"$hrefid\"\/>\n<\/CnavPoint>\n";
		}elsif($entry =~ /<heads2>(.*?)<\/heads2>/s){
			my $enttext = $1;
			my ($hrefid,$enttitle);
			if($enttext =~ /<a href=\"([^\"]+)\">(.*?)<\/a>/s){
				$hrefid = $1;
				$enttitle = $2;
				$enttitle =~ s/<(b|i|sup|sub)>([^<>]+)<\/(b|i|sup|sub)>/$2/g;
			}
			$tocncx .= "<HnavPoint id=\"c$playorder\" playOrder=\"$playorder\">\n\t<HnavLabel><text>$enttitle<\/text><\/navLabel>\n\t<Hcontent src=\"$hrefid\"\/>\n<\/HnavPoint>\n";
		}
		$playorder++;
	}
	$tocncx .= "<\/navMap>\n\n";
	
	$tocncx =~ s/<\/FnavPoint>\n<HnavPoint/<HnavPoint/g;
	$tocncx =~ s/<\/CnavPoint>\n<HnavPoint/<HnavPoint/g;
	$tocncx =~ s/<\/HnavPoint>\n<FnavPoint/<\/HnavPoint>\n<\/FnavPoint>\n<FnavPoint/g;
	$tocncx =~ s/<\/HnavPoint>\n<CnavPoint/<\/HnavPoint>\n<\/CnavPoint>\n<CnavPoint/g;
	

	if($FLAG eq "PART"){
		$tocncx =~ s/<\/FnavPoint>\n<PnavPoint/<PnavPoint/g;
		$tocncx =~ s/<\/PnavPoint>\n<FnavPoint/<FnavPoint/g;
		$tocncx =~ s/<\/PnavPoint>\n<CnavPoint/<CnavPoint/g;
		$tocncx =~ s/<\/HnavPoint>\n<PnavPoint/<\/HnavPoint>\n<\/FnavPoint>\n<PnavPoint/s;
		$tocncx =~ s/<\/HnavPoint>\n<PnavPoint/<\/HnavPoint>\n<\/CnavPoint>\n<\/PnavPoint>\n<PnavPoint/g;
		$tocncx =~ s/<\/FnavPoint>([^<]+)<FnavPoint id="([^<>]+)" playOrder="([^<>]+)">\n\t<navLabel><text>([^<>]+)<\/text><\/navLabel>\n\t<content src="([^\"]+)"\/>\n<\/FnavPoint>\n<\/navMap>/<\/FnavPoint>\n<\/PnavPoint>$1<FnavPoint id="$2" playOrder="$3">\n\t<navLabel><text>$4<\/text><\/navLabel>\n\t<content src="$5"\/>\n<\/FnavPoint>\n<\/navMap>/s;
		$tocncx =~ s/<\/HnavPoint>([^<]+)<FnavPoint id="([^<>]+)" playOrder="([^<>]+)">\n\t<navLabel><text>([^<>]+)<\/text><\/navLabel>\n\t<content src="([^\"]+)"\/>\n<\/FnavPoint>\n<\/navMap>/<\/HnavPoint>\n<\/CnavPoint>\n<\/PnavPoint>$1<FnavPoint id="$2" playOrder="$3">\n\t<navLabel><text>$4<\/text><\/navLabel>\n\t<content src="$5"\/>\n<\/FnavPoint>\n<\/navMap>/s;
		$tocncx =~ s/<\/FnavPoint>\n<PnavPoint/<\/XnavPoint>\n<PnavPoint/s;
		$tocncx =~ s/<\/FnavPoint>\n<PnavPoint/<\/FnavPoint>\n<\/PnavPoint>\n<PnavPoint/g;
		$tocncx =~ s/<\/CnavPoint>\n<PnavPoint/<\/XnavPoint>\n<PnavPoint/s;
		$tocncx =~ s/<\/CnavPoint>\n<PnavPoint/<\/CnavPoint>\n<\/PnavPoint>\n<PnavPoint/g;
	}else{
		$tocncx =~ s/<\/HnavPoint>([^<]+)<FnavPoint(.*?)<\/FnavPoint>\n<\/navMap>/<\/HnavPoint>\n<\/CnavPoint>$1<FnavPoint$2<\/FnavPoint>\n<\/navMap>/s;
	}

	$tocncx =~ s/<H/\t<H/g;
	$tocncx =~ s/<\/H/\t<\/H/g;

	
	$tocncx =~ s/<F/</g;
	$tocncx =~ s/<\/F/<\//g;
	$tocncx =~ s/<P/</g;
	$tocncx =~ s/<\/P/<\//g;
	$tocncx =~ s/<C/</g;
	$tocncx =~ s/<\/C/<\//g;
	$tocncx =~ s/<H/</g;
	$tocncx =~ s/<\/H/<\//g;
	$tocncx =~ s/<\/X/<\//g;

	##################### Page List ########################
	$tocncx .= "<pageList>\n<navInfo>\n<text>Pages</text>\n</navInfo>\n";
	# push(@pagelist,"<a href=\"$entry\#${spid}\">$sptitle<\/a>");
	my ($src,$pgn);
	foreach my $pgtext (@pagelist){
		next if($pgtext =~ /cover/s);
		if($pgtext =~ /<a href=\"([^\"]+)\">([^<>]+)<\/a>/){
			$src = $1;
			$pgn = $2;
		}
		if($pgn =~ /([a-z]+)/){
			$tocncx .= "<pageTarget type=\"front\" playOrder=\"$playorder\">\n";
		}elsif($pgn =~ /([0-9]+)/){
			$tocncx .= "<pageTarget type=\"normal\" playOrder=\"$playorder\">\n";
		}
		
		$tocncx .= "  <navLabel>\n\t<text>Page $pgn<\/text>\n  <\/navLabel>\n  <content src=\"$src\"\/>\n<\/pageTarget>\n";

		$playorder++;
	}
	$tocncx .= "<\/pageList>\n";
	########################################################
	$tocncx .= "<\/ncx>\n";
	
	open(NCXFILE,">$myfolder\\toc_New.ncx") || die "cann't find the file\n";
	print NCXFILE "$tocncx\n";
	close(NCXFILE);
}
########################
sub write_opf(){
	my $opftext;
	$opftext .= "<\?xml version=\"1.0\" encoding=\"UTF-8\"\?>\n";
	$opftext .= "<package xmlns=\"http:\/\/www.idpf.org\/2007\/opf\" version=\"3.0\" unique-identifier=\"pub-id\"\n\t\t\txmlns:epub=\"http:\/\/www.idpf.org\/2007\/ops\" \n\t\t\txmlns:ibooks=\"http:\/\/apple.com\/ibooks\/html-extensions\"\n\t\t\tprefix=\"ibooks: http:\/\/vocabulary.itunes.apple.com\/rdf\/ibooks\/vocabulary-extensions-1.0\/\"\n\t\t\txml:lang=\"en\">\n";
	$opftext .= "\t\t<metadata xmlns:dc=\"http:\/\/purl.org\/dc\/elements\/1.1\/\">\n\t\t\t<meta name=\"cover\" content=\"cover-image\"\/>\n\t\t\t<meta property=\"dcterms:modified\">2018-11-10T12:00:00Z<\/meta>\n\t\t\t<dc:date>2018-11-10T00:00:00Z<\/dc:date>\n\t\t\t<meta property=\"ibooks:specified-fonts\">false<\/meta>\n\t\t\t<dc:title id=\"t1\">$booktitle<\/dc:title>\n\n";
	$opftext .= "\t\t\t<dc:creator id=\"creator01\">XXXXXXXXXXXXXX<\/dc:creator>\n\t\t\t<meta refines=\"#creator01\" property=\"role\" scheme=\"marc:relators\" id=\"role01\">aut<\/meta>\n\t\t\t<meta refines=\"#creator01\" property=\"file-as\">XXXXXXXXXXXXXX<\/meta>\n\t\t\t<meta refines=\"#creator01\" property=\"display-seq\">1<\/meta>\n\n";
	$opftext .= "\t\t\t<dc:language>en-US<\/dc:language>\n\n<meta property=\"schema:accessibilitySummary\">This publication contains well-structured HTML with page mapping and alt text. There are no extended descriptions of images. There is no MathML, and math is captured as images.<\/meta>\n<meta property=\"schema:accessMode\">textual<\/meta>\n<meta property=\"schema:accessMode\">visual<\/meta>\n<meta property=\"schema:accessModeSufficient\">textual<\/meta>\n<meta property=\"schema:accessModeSufficient\">visual<\/meta>\n<meta property=\"schema:accessibilityFeature\">structuralNavigation<\/meta>\n<meta property=\"schema:accessibilityFeature\">alternativeText<\/meta> \n<meta property=\"schema:accessibilityFeature\">printPageNumbers<\/meta>\n<meta property=\"schema:accessibilityFeature\">displayTransformability<\/meta>\n<meta property=\"schema:accessibilityFeature\">readingOrder<\/meta>\n<meta property=\"schema:accessibilityAPI\">ARIA<\/meta>\n<meta property=\"schema:accessibilityHazard\">none<\/meta>\n\n";
	$opftext .= "<dc:identifier id=\"pub-id\">XXXXXXXXXXXXX<\/dc:identifier>\n<meta refines=\"\#pub-id\" property=\"identifier-type\" scheme=\"xsd:string\">uuid<\/meta>\n<dc:identifier id=\"isbn-id\">urn:isbn:XXXXXXXXXXXXX<\/dc:identifier>\n<meta refines=\"\#isbn-id\" property=\"identifier-type\" scheme=\"onix:codelist5\">15<\/meta>\n<meta refines=\"\#src-id\" property=\"source-of\">pagination<\/meta>\n<dc:source id=\"src-id\">XXXXXXXXXXXXX<\/dc:source>\n<meta refines=\"\#src-id\" property=\"identifier-type\" scheme=\"onix:codelist5\">15<\/meta>\n\n";
	$opftext .= "<\/metadata>\n<manifest>\n";

	foreach my $cmpentry(@Compseqfiles){
		chomp($cmpentry);
		my $fnonly = $cmpentry;
		$fnonly =~ s/\.(\w+)$//s;
		if($fnonly =~ /toc/s){
			$filename = "$myfolder$cmpentry";
			if(-e $filename){
				$opftext .= "\n\t<item id=\"$fnonly\" href=\"$cmpentry\" media-type=\"application\/xhtml\+xml\" properties=\"nav\"\/>\n";
			}else{
				my $ofile = "${myfolder}ftoc_New.xhtml";
				my $nfile = "${myfolder}ftoc.xhtml";
				move($ofile, $nfile);
				$opftext .= "\n\t<item id=\"ftoc\" href=\"ftoc.xhtml\" media-type=\"application\/xhtml\+xml\" properties=\"nav\"\/>\n";
			}
		}else{
			$opftext .= "\t<item id=\"$fnonly\" href=\"$cmpentry\" media-type=\"application\/xhtml\+xml\"\/>\n";
		}
	}
	$opftext .= "\n\t<item id=\"ncx\" href=\"toc.ncx\" media-type=\"application\/x-dtbncx\+xml\"\/>\n";
	$opftext .= "<\!-- CSS files -->\n\t<item id=\"css\" href=\"WileyTemplate_v5.5.css\" media-type=\"text\/css\"\/>\n\t<item id=\"css2\" href=\"index.css\" media-type=\"text\/css\"\/>\n\n";

	$opftext .= "<!-- Image files -->\n";
	my $figcnt = 1;
	my $imgname;
	my $newfigdir = "${myfolder}LinkedImages";
	rmdir($newfigdir);
	mkdir($newfigdir);
	foreach my $cmpentry(@Compseqfiles){
		chomp($cmpentry);
		if ($cmpentry =~ /toc/s){
			next;
		}
		$filename = "$myfolder$cmpentry";
		$filestr=&read_file($filename);
		$filestr =~ s/<\!--(?s)(.*?)-->//g;
		while($filestr =~ s/<img([^>]+)\/>/<Ximg$1\/>/s){
			my $imgdata = $1;
			if($imgdata =~ /src=\"([^\"]+)\"/s){
				$imgname = $1;
			}
			my $figname = basename($imgname);
			my $extn;
			if($figname =~ /\.(\w+)$/s){
				$extn = $1;
				if($extn =~ /jpg/s){
					$extn = "jpeg";
				}
			}
			$filestr =~ s/<img([^<>]+)src=\"$imgname\"([^<>]+)>//g;
			
			if($cmpentry =~ /cover/){
				$opftext .= "\t<item id=\"cover-image\" href=\"$imgname\" media-type=\"image\/jpeg\" properties=\"cover-image\"\/>\n";
				$imgname = basename($imgname);
				foreach my $ffname(@imagelist){
					if((grep(/$imgname/, $ffname))){
						copy("$ffname","${newfigdir}\\$imgname");
					}
				}
			}else{
				if((grep(/$imgname/, @imagelist))){
					$opftext .= "\t<item id=\"img$figcnt\" href=\"$imgname\" media-type=\"image\/$extn\"\/>\n";
					foreach my $ffname(@imagelist){
						if((grep(/$imgname/, $ffname))){
							$imgname = basename($imgname);
							copy("$ffname","${newfigdir}\\$imgname");
						}
					}
				}else{
					$opftext .= "\t<item id=\"img$figcnt\" href=\"$imgname\" media-type=\"image\/$extn\"\/><NOT FOUND!!!>\n";
					$logtxt .= "$imgname NOT FOUND but LINKED in $cmpentry\n";
				}
				$figcnt++;
			}
		}
	}

	$figcnt = 1;
	while($opftext =~ /<item id=\"img([0-9]+)\" href=\"([^\"]+)\" media-type=\"([^\"]+)\"\/>/s){
		my $opfimg = $2;
		$opftext =~ s/<item id=\"img([0-9]+)\" href=\"([^\"]+)\" media-type=\"([^\"]+)\"\/>/<Xitem id=\"img$figcnt\" href=\"$opfimg\" media-type=\"$3\"\/>/s;
		$opftext =~ s/<item id=\"img([0-9]+)\" href=\"$opfimg\" media-type=\"([^\"]+)\"\/>\n//g;
		$figcnt++;
	}	
	$opftext =~ s/([\t]+)/\t/g;
	$opftext =~ s/<Xitem/<item/g;
	$opftext .= "\n<\/manifest>\n<spine toc=\"ncx\">\n";
	my $OPFFLAG = 0;
	foreach my $cmpentry(@Compseqfiles){
		$cmpentry =~ s/\.(\w+)$//s;
		if($cmpentry =~ /cover/){
			$opftext .= "\t<itemref idref=\"fcover\" linear=\"no\"\/>\n";
		}elsif($cmpentry =~ /(toc|eula)/){
			$opftext .= "\n\t<itemref idref=\"$cmpentry\"\/>\n\n";
			$OPFFLAG = 1;
		}elsif($OPFFLAG == 1){
			$opftext .= "\t<itemref idref=\"$cmpentry\" linear=\"yes\"\/>\n";
		}else{
			$opftext .= "\t<itemref idref=\"$cmpentry\"\/>\n";
		}
		
	}
	$opftext .= "<\/spine>\n";
	$opftext .= "<guide>\n\t<reference type=\"cover\" title=\"Cover\" href=\"fcover.xhtml\"\/>\n\t<reference type=\"toc\" title=\"Table of Contents\" href=\"ftoc.xhtml\"\/>\n<\/guide>\n";
	$opftext .= "<\/package>\n";
	open(OUTFILE,">$myfolder\\content_New.opf") || die "cann't find the file\n";
	print OUTFILE "$opftext\n";
	close(OUTFILE);
}
########################
sub write_ftoc(){
	#my ($toctext)=@_;
	$toctext .= "<\/body>\n<\/html>\n";
	open(OUTFILE,">$myfolder\\ftoc_New.xhtml") || die "cann't find the file\n";
	print OUTFILE "$toctext\n";
	close(OUTFILE);
}
########################
sub write_logfile(){
	if($logtxt){
		open(LOGFILE, ">${myfolder}/error.log");
		print LOGFILE "$logtxt";
		close(LOGFILE);
		system("start notepad ${myfolder}/error.log");
	}
}
########################
sub write_Newfile(){
my ($outfile)=@_;
$outfile =~ s/\.([a-z]+)$//s;
open(XOUTFILE, ">${myfolder}/${outfile}_New.xhtml");
print XOUTFILE "$filestr\n";
close(XOUTFILE);
}

__END__