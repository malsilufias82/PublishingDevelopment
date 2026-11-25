#!/usr/bin/perl -w
use strict;
use File::Path;
use File::Copy;
use File::Find;
use File::Basename;
use Math::Roman qw/roman/;
use Tk;

system("cls");

#####################################################################################################
                                            # Main Window#
#####################################################################################################
my $mw = new MainWindow(-background => 'pink',-title => "BPA");
$mw->geometry('450x200'); ### Size of Window
$mw->resizable(0,0); 
my $frm_name = $mw -> Frame(-background => 'pink');
my $lab = $frm_name -> Label(-text=>"Enter path:",-foreground => 'black',-background => 'pink');
my $path = $frm_name -> Entry(-width=>41);
my $other = $frm_name -> Label(-text=>"OR",-foreground => 'black',-background => 'pink');
my $browsebut = $frm_name -> Button(-underline=>0,-text=>"Browse",-foreground => 'black',-background => 'gray',-relief => 'groove', -command =>\&open_folder);
$mw->bind("<Alt-b>", sub {&open_folder} );
$browsebut->bind("<Alt-b>", sub{});

#Geometry Management
$lab -> grid(-row=>1,-column=>1);
$path -> grid(-row=>1,-column=>2);
$other -> grid(-row=>1,-column=>3,-padx=>23);
$browsebut -> grid(-row=>1,-column=>4,-padx=>3);
$frm_name -> place(-x=>10,-y=>20);

#####################################################################################################
												#Load txt file#
#####################################################################################################
my $mytxtframe = $mw -> Frame(-background => 'pink');
my $loadbutt = $mytxtframe -> Button(-underline=>0,-text=>"Load TXT File...",-foreground => 'black',-background => 'gray', -command =>\&load_button);
$mw->bind("<Alt-l>", sub {&load_button} );
$loadbutt->bind("<Alt-l>", sub{});


$loadbutt -> grid(-row=>1,-column=>1);
$mytxtframe -> place(-x=>10,-y=>60);
#####################################################################################################
                                                #Buttons#
#####################################################################################################
my $mybuttons = $mw -> Frame(-background => 'pink');
my $subbutt = $mybuttons -> Button(-underline=>0,-text=>"Submit",-foreground => 'white',-background => 'blue', -command =>\&push_button);
my $resetbutt = $mybuttons -> Button(-underline=>1,-text => "Reset",-foreground => 'black',-background => 'green', -command => \&reset);
my $exitbutt = $mybuttons -> Button(-underline=>0,-text => "Quit",-foreground => 'black',-background => 'orange', -command => sub{exit});
$mw->bind("<Alt-s>", sub {&push_button} );
$subbutt->bind("<Alt-s>", sub{});
$mw->bind("<Alt-e>", sub {&reset} );
$resetbutt->bind("<Alt-e>", sub{});
$mw->bind("<Alt-q>", sub{exit} );
$exitbutt->bind("<Alt-q>", sub{});

#Geometry Management
$subbutt -> grid(-row=>1,-column=>1);
$resetbutt -> grid(-row=>1,-column=>2,-padx=>16);
$exitbutt -> grid(-row=>1,-column=>3);
$mybuttons -> place(-x=>160,-y=>120);

#####################################################################################################
                                                #Signature#
#####################################################################################################
my $code_font = $mw->fontCreate('code', -family => "Monotype Corsiva", -size => 12, -weight => 'bold');

my $mysignature = $mw -> Frame(-background => 'pink');
my $mydev = $mysignature -> Label(-text=>"Developed By:",-foreground => 'black',-background => 'pink', -font => 'Times 9 bold');
my $mysign = $mysignature -> Label(-text=>"Saif",-foreground => 'red',-background => 'pink', -font => $code_font);

#Geometry Management
$mydev -> grid(-row=>1,-column=>1);
$mysign -> grid(-row=>1,-column=>2);
$mysignature -> place(-x=>330,-y=>175);


MainLoop;

#######################################################################################################
                                            #DECLARATIONS#
#######################################################################################################
my ($myfolder,$mydesdir,$myoutdir,$genimagedir,$imagesdir,$chtitle_file,$filestr,$compauthors,$comptitle,$finaltext,$totbmitem,$tempdata,$FLAG,$FMFLAG);
my ($creatnum,$authname,$sname,$fname,$tempstr,$extn,$indterm);
my (@completefileslist,@dirlist,@genimagelist,@fmlist,@tmpfmlist,@chlist,@bmlist,@childbmlist,@compbmlist,@partlist,@anclist);
my (@sourcelist,@fmcontent,@fmfigs,@chcontent,@chfigs,@bmcontent,@bmfigs,@anccontent,@ancfigs);
my (%chtitles,%chauthors);

#######################################################################################################
                                            #FUNCTIONS#
#######################################################################################################
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
sub open_folder
{
	$myfolder = $mw->chooseDirectory(-initialdir => '~', -title => 'Choose a folder');
	$path -> insert('end',"$myfolder\n");
}
#######################################################################################################
#######################################################################################################
sub load_button
{
	my @types =
			   (["TXT files", [qw/.TXT /]],
				["All files",        '*'],
			   );
	$chtitle_file= $mw->getOpenFile(-filetypes => \@types);

	$tempdata = "";
	open(TXTFILE, "$chtitle_file") or die "Can't open '$chtitle_file': $!";
	my $line;
	my @allfiles;
	my $mycnt = 1;
	while(<TXTFILE>){
		$line = $_;
		if(($line =~ /<cn>([^<]+)<\/cn><ct>(.*?)<\/ct>/s)||($line =~ /<pn>([^<]+)<\/pn><pt>(.*?)<\/pt>/s)){
			my $compno = "$1";
			$comptitle = "$2";
			$chtitles{$compno}=$comptitle;
			push(@allfiles,$compno);
		}elsif(($line =~ /<cn><\/cn><ct>(.*?)<\/ct>/s)||($line =~ /<pn><\/pn><pt>(.*?)<\/pt>/s)){
			$comptitle = "$1";
			$chtitles{"p$mycnt"}=$comptitle;
			push(@allfiles,"p$mycnt");
			$mycnt++;
		}
	}
	close(TXTFILE);
	
	$mycnt = 1;
	open(TXTFILE, "$chtitle_file") or die "Can't open '$chtitle_file': $!";
	while(<TXTFILE>){
		$line = $_;
		if(($line =~ /<cn>([^<]+)<\/cn><ct>(.*?)<\/ct><authors>([^<]+)<\/authors>/)||($line =~ /<pn>([^<]+)<\/pn><pt>(.*?)<\/pt><authors>([^<]+)<\/authors>/)){
			my $compno = "$1";
			$compauthors = "$3";
			$chauthors{$compno}=$compauthors;
		}elsif(($line =~ /<cn><\/cn><ct>(.*?)<\/ct><authors>([^<]+)<\/authors>/)||($line =~ /<pn><\/pn><pt>(.*?)<\/pt><authors>([^<]+)<\/authors>/)){
			$compauthors = "$2";
			$chauthors{"p$mycnt"}=$compauthors;
			$mycnt++;
		}
	}		
	close(TXTFILE);
	my $textstr = &read_file($chtitle_file);
	if(($textstr =~ /<frontmatter>(.*)<\/frontmatter>/s)||($textstr =~ /<fm>(.*)<\/fm>/s)){
		my $fmitems = $1;
		while($fmitems =~ s/<cn>([^>]+)<\/cn>/<Xcn>$1<\/cn>/s){
			my $fmitem = $1;
			push(@fmlist, $fmitem);
		}
	}else{
		$tempdata .= "<fm> tags are not tagged before and after fmatter in TXT that is LOADED\n";
	}

	$mycnt = 1;
	if($textstr =~ /<chapters>(.*)<\/chapters>/s){
		my $chitems = $1;
		while(($chitems =~ s/<pn>(.*?)<\/pt>/<Xpn>$1<\/pt>/s)||($chitems =~ s/<cn>(.*?)<\/ct>/<Xcn>$1<\/ct>/s)){
			my $chitem = $1;
			if($chitem =~ /([^>]+)<\/(c|p)n>/s){
				$chitem = "$1";
			}else{
				$chitem = "p$mycnt";
				$mycnt++;
			}
			push(@chlist, $chitem);
		}
		$chitems =~ s/<Xpn>/<pn>/g;
		$mycnt = 1;
		while($chitems =~ s/<pn>(.*?)<\/pt>/<Xpn>$1<\/pt>/s){
			my $partitem = $1;
			if($partitem =~ /([^>]+)<\/pn>/s){
				$partitem = "$1";
			}else{
				$partitem = "p$mycnt";
				$mycnt++;
			}
			push(@partlist, $partitem);
		}
	}else{
		$tempdata .= "<chapters> tags are not tagged before and after chapter in TXT that is LOADED\n";
	}

	
	if(($textstr =~ /<backmatter>(.*)<\/backmatter>/s)||($textstr =~ /<bm>(.*)<\/bm>/s)){
		my $bmitems = $1;
		while($bmitems =~ s/<cn>([^>]+)<\/cn>/<Xcn>$1<\/cn>/s){
			my $bmitem = $1;
			push(@bmlist, $bmitem);
		}
	}else{
		$tempdata .= "<bm> tags are not tagged before and after bmatter in TXT that is LOADED\n";
	}

	if($textstr =~ /<ancmat>(.*)<\/ancmat>/s){
		my $ancitems = $1;
		while($ancitems =~ s/<cn>([^>]+)<\/cn>/<Xcn>$1<\/cn>/s){
			my $ancitem = $1;
			push(@anclist, $ancitem);
		}
	}
	
	my (@onlyfmfiles,@onlychfiles,@onlybmfiles,@onlyancfiles);
	foreach my $entry(@allfiles){
		foreach my $flist(@fmlist){
			if($entry eq $flist){
				push(@onlyfmfiles,$entry);
			}
		}
	}
	@fmlist = @onlyfmfiles;
	
	foreach my $entry(@allfiles){
		foreach my $clist(@chlist){
			if($entry eq $clist){
				push(@onlychfiles,$entry);
			}
		}
	}
	@chlist = @onlychfiles;
	
	foreach my $entry(@allfiles){
		foreach my $blist(@bmlist){
			if($entry eq $blist){
				push(@onlybmfiles,$entry);
			}
		}
	}
	@bmlist = @onlybmfiles;

	foreach my $entry(@allfiles){
		if((grep(/$entry/,@anclist))){
			push(@onlyancfiles,$entry);
		}
	}
	@anclist = @onlyancfiles;
	
	delete @onlyfmfiles[0 .. $#onlyfmfiles];
	delete @onlychfiles[0 .. $#onlychfiles];
	delete @onlybmfiles[0 .. $#onlybmfiles];
	delete @onlyancfiles[0 .. $#onlyancfiles];
	# foreach my $entry(@fmlist){
		# $tempdata .= "$entry\n";
	# }
	# $tempdata .= "\n******************************\n\n";
	# foreach my $entry(@chlist){
		# print "$entry\n";
	# }
	# $tempdata .= "\n******************************\n\n";
	# foreach my $entry(@bmlist){
		# $tempdata .= "$entry\n";
	# }
	# $tempdata .= "\n******************************\n\n";
	# foreach my $entry (sort keys %chtitles){
		# $tempdata .= "$entry --> $chtitles{$entry}\n";
		# print "$entry --> $chtitles{$entry}\n";
	# }
	# $tempdata .= "\n******************************\n\n";
	# foreach my $entry (sort keys %chauthors){
		# $tempdata .= "$entry --> $chauthors{$entry}\n";
		# $print "$entry --> $chauthors{$entry}\n";
	# }
}
#######################################################################################################
#######################################################################################################
sub push_button
{
	if(!$myfolder){
		$myfolder = $path -> get();
	}
	$myfolder =~ s/\\/\//g;
    $mydesdir = "metadata";
    $myoutdir = "${myfolder}/${mydesdir}";

	rmtree($myoutdir);
	chdir($myfolder);
	mkdir($mydesdir);

	$finaltext="";
	#$tempdata="";
	
    opendir(DIR,${myfolder});
    while(my $entry = readdir(DIR))
    {
        next if($entry =~ /\.rsrc/);
        next if($entry =~ /\.\./);
        next if($entry =~ /\./);
        push(@dirlist,$entry);
    }
	@dirlist = sort(@dirlist);
    find sub { push(@completefileslist, $File::Find::name)}, "$myfolder";

	$indterm = qr/Author Index|Company Index|Subject Index|Index/x;
	$extn = qr/eps|ps|jpg|pdf|ai|tif|png|psd/x;
	
	&gen_image();
	&front_matter();
	&calc_chapters();
	&back_matters();
	&anc_matters();

	if(-e "${myfolder}/source"){
		$finaltext.="<contentUnit>\n<VVV.contentUnitType>source material<\/VVV.contentUnitType>\n<VVV.compliesWithFilenaming>Books0.5<\/VVV.compliesWithFilenaming>\n<GGG.contentUnitId\/>\n<VVV.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV.DOI\/>\n<SSS.publicationDate\/>\n<titleInfo>\n<VVV.title textformat=\"ASCII\">complete Wiley SD<\/VVV.title>\n<GGG.titleLabel\/>\n<VVV.titleLabelOverride\/>\n<VVV.titleForDisplay textformat=\"ASCII\"\/>\n<GGG.titleSortKey\/>\n<VVV.titleSortKeyOverride\/>\n<VVV.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n<creator>\n<SSS.creatorId\/>\n<VVV.sequenceNumber\/>\n<SSS.creatorRole\/>\n<GGG.personName\/>\n<GGG.personNameInverted\/>\n<VVV.titlesBeforeNames\/>\n<VVV.namesBeforeKey\/>\n<VVV.prefixToKey\/>\n<VVV.keyNames\/>\n<VVV.namesAfterKey\/>\n<VVV.suffixToKey\/>\n<VVV.lettersAfterNames\/>\n<VVV.titlesAfterNames\/>\n<GGG.creatorSortKey\/>\n<VVV.creatorSortKeyOverride\/>\n<\/creator>\n<SSS.copyrightYear\/>\n<VVV.copyrightLine\/>\n<subjectGroup>\n<SSS.subject1Name\/>\n<SSS.subject1Code\/>\n<\/subjectGroup>\n<keywordGroup>\n<VVV.keyword\/>\n<\/keywordGroup>\n<\/publicationInfoForUnit>\n<adminNotes\/>\n";
		find sub { push(@sourcelist, $File::Find::name)}, "$myfolder/source";
			foreach my $sitem(@sourcelist){
				next if($sitem !~ /(.*?)\.(.*?)/);
				$sitem =~ s/\Q$myfolder\E\///s;
				$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>$sitem<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>source<\/VVV\.resourceVersion>\n<VVV\.resourceUse>other<\/VVV\.resourceUse>\n<VVV\.resourceType>text<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
			}
			$finaltext.="<\/contentUnit>\n";
			delete @sourcelist[0 .. $#sourcelist];
	}
	
	&find_Missingfigs();

	&write_file();
	&write_TempFile();
}

####################################### GENIMAGES ####################################
sub gen_image{
	my (@Manifestlist,@coverlist);
	foreach my $myitem(@dirlist){
		if($myitem=~/Manifest/is){
			$finaltext.="<contentUnit>\n<VVV.contentUnitType>control<\/VVV.contentUnitType>\n<VVV.compliesWithFilenaming>Books0.5<\/VVV.compliesWithFilenaming>\n<GGG.contentUnitId\/>\n<VVV.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV.DOI\/>\n<SSS.publicationDate\/>\n<titleInfo>\n<VVV.title textformat=\"ASCII\">Manifest; Pagination Sheet; stylesheet<\/VVV.title>\n<GGG.titleLabel\/>\n<VVV.titleLabelOverride\/>\n<VVV.titleForDisplay textformat=\"ASCII\"\/>\n<GGG.titleSortKey\/>\n<VVV.titleSortKeyOverride\/>\n<VVV.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n<creator>\n<SSS.creatorId\/>\n<VVV.sequenceNumber\/>\n<SSS.creatorRole\/>\n<GGG.personName\/>\n<GGG.personNameInverted\/>\n<VVV.titlesBeforeNames\/>\n<VVV.namesBeforeKey\/>\n<VVV.prefixToKey\/>\n<VVV.keyNames\/>\n<VVV.namesAfterKey\/>\n<VVV.suffixToKey\/>\n<VVV.lettersAfterNames\/>\n<VVV.titlesAfterNames\/>\n<GGG.creatorSortKey\/>\n<VVV.creatorSortKeyOverride\/>\n<\/creator>\n<SSS.copyrightYear\/>\n<VVV.copyrightLine\/>\n<subjectGroup>\n<SSS.subject1Name\/>\n<SSS.subject1Code\/>\n<\/subjectGroup>\n<keywordGroup>\n<VVV.keyword\/>\n<\/keywordGroup>\n<\/publicationInfoForUnit>\n<adminNotes\/>\n";
			find sub { push(@Manifestlist, $File::Find::name)}, "$myfolder/Manifest";
			foreach my $geni(@Manifestlist){
				next if($geni !~ /(.*?)\.(.*?)/);
				$geni =~ s/\Q$myfolder\E\///s;
				$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>$geni<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>source<\/VVV\.resourceVersion>\n<VVV\.resourceUse>other<\/VVV\.resourceUse>\n<VVV\.resourceType>readme<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
			}
			$finaltext.="<\/contentUnit>\n";
			delete @Manifestlist[0 .. $#Manifestlist];
		}
	}
	foreach my $myitem(@dirlist){
		if($myitem=~/cover/is){
			$finaltext.="<contentUnit>\n<VVV.contentUnitType>cover<\/VVV.contentUnitType>\n<VVV.compliesWithFilenaming>Books0.5<\/VVV.compliesWithFilenaming>\n<GGG.contentUnitId\/>\n<VVV.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV.DOI\/>\n<SSS.publicationDate\/>\n<titleInfo>\n<VVV.title textformat=\"ASCII\">Cover<\/VVV.title>\n<GGG.titleLabel\/>\n<VVV.titleLabelOverride\/>\n<VVV.titleForDisplay textformat=\"ASCII\"\/>\n<GGG.titleSortKey\/>\n<VVV.titleSortKeyOverride\/>\n<VVV.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n<creator>\n<SSS.creatorId\/>\n<VVV.sequenceNumber\/>\n<SSS.creatorRole\/>\n<GGG.personName\/>\n<GGG.personNameInverted\/>\n<VVV.titlesBeforeNames\/>\n<VVV.namesBeforeKey\/>\n<VVV.prefixToKey\/>\n<VVV.keyNames\/>\n<VVV.namesAfterKey\/>\n<VVV.suffixToKey\/>\n<VVV.lettersAfterNames\/>\n<VVV.titlesAfterNames\/>\n<GGG.creatorSortKey\/>\n<VVV.creatorSortKeyOverride\/>\n<\/creator>\n<SSS.copyrightYear\/>\n<VVV.copyrightLine\/>\n<subjectGroup>\n<SSS.subject1Name\/>\n<SSS.subject1Code\/>\n<\/subjectGroup>\n<keywordGroup>\n<VVV.keyword\/>\n<\/keywordGroup>\n<\/publicationInfoForUnit>\n<adminNotes\/>\n";
			find sub { push(@coverlist, $File::Find::name)}, "$myfolder/cover";
			foreach my $geni(@coverlist){
				next if($geni !~ /(.*?)\.(.*?)/);
				$geni =~ s/\Q$myfolder\E\///s;
				$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>$geni<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>archive<\/VVV\.resourceVersion>\n<VVV\.resourceUse>press PDF<\/VVV\.resourceUse>\n<VVV\.resourceType>publication file<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
			}
			$finaltext.="<\/contentUnit>\n";
			delete @coverlist[0 .. $#coverlist];
		}
	}
	foreach my $myitem(@dirlist){
		if($myitem=~/genimage/){
			$finaltext.="<contentUnit>\n<VVV\.contentUnitType>generic files<\/VVV\.contentUnitType>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<GGG\.contentUnitId\/>\n<VVV\.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV\.DOI\/>\n<SSS\.publicationDate\/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">generic files<\/VVV\.title>\n<GGG\.titleLabel\/>\n<VVV\.titleLabelOverride\/>\n<VVV\.titleForDisplay textformat=\"ASCII\"\/>\n<GGG\.titleSortKey\/>\n<VVV\.titleSortKeyOverride\/>\n<VVV\.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n<creator>\n<SSS\.creatorId\/>\n<VVV\.sequenceNumber\/>\n<SSS\.creatorRole\/>\n<GGG\.personName\/>\n<GGG\.personNameInverted\/>\n<VVV\.titlesBeforeNames\/>\n<VVV\.namesBeforeKey\/>\n<VVV\.prefixToKey\/>\n<VVV\.keyNames\/>\n<VVV\.namesAfterKey\/>\n<VVV\.suffixToKey\/>\n<VVV\.lettersAfterNames\/>\n<VVV\.titlesAfterNames\/>\n<GGG\.creatorSortKey\/>\n<VVV\.creatorSortKeyOverride\/>\n<\/creator>\n<SSS\.copyrightYear\/>\n<VVV\.copyrightLine\/>\n<subjectGroup>\n<SSS\.subject1Name\/>\n<SSS\.subject1Code\/>\n<\/subjectGroup>\n<keywordGroup>\n<VVV\.keyword\/>\n<\/keywordGroup>\n<\/publicationInfoForUnit>\n<adminNotes\/>\n";
			find sub { push(@genimagelist, $File::Find::name)}, "$myfolder/genimage";
			foreach my $geni(@genimagelist){
				next if($geni !~ /(.*?)\.(.*?)/);
				$geni =~ s/\Q$myfolder\E\///s;
				$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>$geni<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>archive<\/VVV\.resourceVersion>\n<VVV\.resourceUse>high-res print graphic<\/VVV\.resourceUse>\n<VVV\.resourceType>icon<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
			}
			$finaltext.="<\/contentUnit>\n";
			delete @genimagelist[0 .. $#genimagelist];
		}
	}
}

####################################### FMMATTER ####################################

sub front_matter{
	find sub { push(@fmcontent, $File::Find::name)}, "$myfolder/fmatter";
	foreach my $fmitem (@fmlist){
		my $fmitemloc;
		foreach my $fitem(@fmcontent){
			if($fitem =~ /$fmitem/s){
				$fmitemloc = $fitem;
			}
		}
		if(!(grep(/$fmitem/,@fmcontent))){
			foreach my $entry(@completefileslist){
				if($entry =~ /$fmitem/s){
					$fmitemloc = $entry;
					push(@fmcontent,$entry);
				}
			}
		}

		my $fmwithcmppath = $fmitemloc;
		$fmitemloc =~ s/\Q$myfolder\E\///s;
		my $fname;
		
		if(($fmitem =~ /ffirs/s)){
			$finaltext.="<contentUnit>\n<VVV\.contentUnitType>before table of contents<\/VVV\.contentUnitType>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<GGG\.contentUnitId>ffirs<\/GGG\.contentUnitId>\n<VVV\.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV\.DOI\/>\n<SSS\.publicationDate\/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">title page\; copyright page\; dedication page<\/VVV\.title>\n<GGG\.titleLabel>before table of contents<\/GGG\.titleLabel>\n<VVV\.titleLabelOverride\/>\n<VVV\.titleForDisplay textformat=\"ASCII\"\/>\n<GGG\.titleSortKey\/>\n<VVV\.titleSortKeyOverride\/>\n<VVV\.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n<creator>\n<SSS\.creatorId\/>\n<VVV\.sequenceNumber\/>\n<SSS\.creatorRole\/>\n<GGG\.personName\/>\n<GGG\.personNameInverted\/>\n<VVV\.titlesBeforeNames\/>\n<VVV\.namesBeforeKey\/>\n<VVV\.prefixToKey\/>\n<VVV\.keyNames\/>\n<VVV\.namesAfterKey\/>\n<VVV\.suffixToKey\/>\n<VVV\.lettersAfterNames\/>\n<VVV\.titlesAfterNames\/>\n<GGG\.creatorSortKey\/>\n<VVV\.creatorSortKeyOverride\/>\n<\/creator>\n<SSS\.copyrightYear\/>\n<VVV\.copyrightLine\/>\n<subjectGroup>\n<SSS\.subject1Name\/>\n<SSS\.subject1Code\/>\n<\/subjectGroup>\n<keywordGroup>\n<VVV\.keyword\/>\n<\/keywordGroup>\n<\/publicationInfoForUnit>\n<adminNotes\/>\n";
		}elsif(($fmitem =~ /ftoc/s)){
			$finaltext.="<contentUnit>\n<VVV\.contentUnitType>table of contents<\/VVV\.contentUnitType>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<GGG\.contentUnitId\/>\n<VVV\.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV\.DOI\/>\n<SSS\.publicationDate\/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">Contents<\/VVV\.title>\n<GGG\.titleLabel\/>\n<VVV\.titleLabelOverride\/>\n<VVV\.titleForDisplay textformat=\"ASCII\"\/>\n<GGG\.titleSortKey\/>\n<VVV\.titleSortKeyOverride\/>\n<VVV\.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n<creator>\n<SSS\.creatorId\/>\n<VVV\.sequenceNumber\/>\n<SSS\.creatorRole\/>\n<GGG\.personName\/>\n<GGG\.personNameInverted\/>\n<VVV\.titlesBeforeNames\/>\n<VVV\.namesBeforeKey\/>\n<VVV\.prefixToKey\/>\n<VVV\.keyNames\/>\n<VVV\.namesAfterKey\/>\n<VVV\.suffixToKey\/>\n<VVV\.lettersAfterNames\/>\n<VVV\.titlesAfterNames\/>\n<GGG\.creatorSortKey\/>\n<VVV\.creatorSortKeyOverride\/>\n<\/creator>\n<SSS\.copyrightYear\/>\n<VVV\.copyrightLine\/>\n<subjectGroup>\n<SSS\.subject1Name\/>\n<SSS\.subject1Code\/>\n<\/subjectGroup>\n<keywordGroup>\n<VVV\.keyword\/>\n<\/keywordGroup>\n<\/publicationInfoForUnit>\n<adminNotes\/>\n";
		}elsif(($fmitem =~ /fbetw/s)){
			foreach my $entry(@completefileslist){
				if($entry =~ /fbetw\.(xml|tex|ind|indd)/s){
					$fname = basename($entry);
				}
			}
			if($chtitles{$fname}){
				$finaltext.="<contentUnit>\n<VVV\.contentUnitType>between table of contents and preface<\/VVV\.contentUnitType>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<GGG\.contentUnitId\/>\n<VVV\.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV\.DOI\/>\n<SSS\.publicationDate\/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">$chtitles{$fname}<\/VVV\.title>\n<GGG\.titleLabel\/>\n<VVV\.titleLabelOverride\/>\n<VVV\.titleForDisplay textformat=\"ASCII\"\/>\n<GGG\.titleSortKey\/>\n<VVV\.titleSortKeyOverride\/>\n<VVV\.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n<creator>\n<SSS\.creatorId\/>\n<VVV\.sequenceNumber\/>\n<SSS\.creatorRole\/>\n<GGG\.personName\/>\n<GGG\.personNameInverted\/>\n<VVV\.titlesBeforeNames\/>\n<VVV\.namesBeforeKey\/>\n<VVV\.prefixToKey\/>\n<VVV\.keyNames\/>\n<VVV\.namesAfterKey\/>\n<VVV\.suffixToKey\/>\n<VVV\.lettersAfterNames\/>\n<VVV\.titlesAfterNames\/>\n<GGG\.creatorSortKey\/>\n<VVV\.creatorSortKeyOverride\/>\n<\/creator>\n<SSS\.copyrightYear\/>\n<VVV\.copyrightLine\/>\n<subjectGroup>\n<SSS\.subject1Name\/>\n<SSS\.subject1Code\/>\n<\/subjectGroup>\n<keywordGroup>\n<VVV\.keyword\/>\n<\/keywordGroup>\n<\/publicationInfoForUnit>\n<adminNotes\/>\n";
			}else{
				$finaltext.="<contentUnit>\n<VVV\.contentUnitType>between table of contents and preface<\/VVV\.contentUnitType>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<GGG\.contentUnitId\/>\n<VVV\.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV\.DOI\/>\n<SSS\.publicationDate\/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">XXXXXXXXXXXXXXXX<\/VVV\.title>\n<GGG\.titleLabel\/>\n<VVV\.titleLabelOverride\/>\n<VVV\.titleForDisplay textformat=\"ASCII\"\/>\n<GGG\.titleSortKey\/>\n<VVV\.titleSortKeyOverride\/>\n<VVV\.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n<creator>\n<SSS\.creatorId\/>\n<VVV\.sequenceNumber\/>\n<SSS\.creatorRole\/>\n<GGG\.personName\/>\n<GGG\.personNameInverted\/>\n<VVV\.titlesBeforeNames\/>\n<VVV\.namesBeforeKey\/>\n<VVV\.prefixToKey\/>\n<VVV\.keyNames\/>\n<VVV\.namesAfterKey\/>\n<VVV\.suffixToKey\/>\n<VVV\.lettersAfterNames\/>\n<VVV\.titlesAfterNames\/>\n<GGG\.creatorSortKey\/>\n<VVV\.creatorSortKeyOverride\/>\n<\/creator>\n<SSS\.copyrightYear\/>\n<VVV\.copyrightLine\/>\n<subjectGroup>\n<SSS\.subject1Name\/>\n<SSS\.subject1Code\/>\n<\/subjectGroup>\n<keywordGroup>\n<VVV\.keyword\/>\n<\/keywordGroup>\n<\/publicationInfoForUnit>\n<adminNotes\/>\n";
			}
		}elsif(($fmitem =~ /fpref/s)){
			foreach my $entry(@completefileslist){
				if($entry =~ /fpref\.(xml|tex|ind|indd)/s){
					$fname = basename($entry);
				}
			}
			if($chtitles{$fname}){
				$finaltext.="<contentUnit>\n<VVV\.contentUnitType>preface<\/VVV\.contentUnitType>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<GGG\.contentUnitId\/>\n<VVV\.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV\.DOI\/>\n<SSS\.publicationDate\/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">$chtitles{$fname}<\/VVV\.title>\n<GGG\.titleLabel\/>\n<VVV\.titleLabelOverride\/>\n<VVV\.titleForDisplay textformat=\"ASCII\"\/>\n<GGG\.titleSortKey\/>\n<VVV\.titleSortKeyOverride\/>\n<VVV\.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n<creator>\n<SSS\.creatorId\/>\n<VVV\.sequenceNumber\/>\n<SSS\.creatorRole\/>\n<GGG\.personName\/>\n<GGG\.personNameInverted\/>\n<VVV\.titlesBeforeNames\/>\n<VVV\.namesBeforeKey\/>\n<VVV\.prefixToKey\/>\n<VVV\.keyNames\/>\n<VVV\.namesAfterKey\/>\n<VVV\.suffixToKey\/>\n<VVV\.lettersAfterNames\/>\n<VVV\.titlesAfterNames\/>\n<GGG\.creatorSortKey\/>\n<VVV\.creatorSortKeyOverride\/>\n<\/creator>\n<SSS\.copyrightYear\/>\n<VVV\.copyrightLine\/>\n<subjectGroup>\n<SSS\.subject1Name\/>\n<SSS\.subject1Code\/>\n<\/subjectGroup>\n<keywordGroup>\n<VVV\.keyword\/>\n<\/keywordGroup>\n<\/publicationInfoForUnit>\n<adminNotes\/>\n";
			}else{
				$finaltext.="<contentUnit>\n<VVV\.contentUnitType>preface<\/VVV\.contentUnitType>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<GGG\.contentUnitId\/>\n<VVV\.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV\.DOI\/>\n<SSS\.publicationDate\/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">XXXXXXXXXXXXXXXX<\/VVV\.title>\n<GGG\.titleLabel\/>\n<VVV\.titleLabelOverride\/>\n<VVV\.titleForDisplay textformat=\"ASCII\"\/>\n<GGG\.titleSortKey\/>\n<VVV\.titleSortKeyOverride\/>\n<VVV\.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n<creator>\n<SSS\.creatorId\/>\n<VVV\.sequenceNumber\/>\n<SSS\.creatorRole\/>\n<GGG\.personName\/>\n<GGG\.personNameInverted\/>\n<VVV\.titlesBeforeNames\/>\n<VVV\.namesBeforeKey\/>\n<VVV\.prefixToKey\/>\n<VVV\.keyNames\/>\n<VVV\.namesAfterKey\/>\n<VVV\.suffixToKey\/>\n<VVV\.lettersAfterNames\/>\n<VVV\.titlesAfterNames\/>\n<GGG\.creatorSortKey\/>\n<VVV\.creatorSortKeyOverride\/>\n<\/creator>\n<SSS\.copyrightYear\/>\n<VVV\.copyrightLine\/>\n<subjectGroup>\n<SSS\.subject1Name\/>\n<SSS\.subject1Code\/>\n<\/subjectGroup>\n<keywordGroup>\n<VVV\.keyword\/>\n<\/keywordGroup>\n<\/publicationInfoForUnit>\n<adminNotes\/>\n";
			}
		}elsif(($fmitem =~ /flast/s)){
			foreach my $entry(@completefileslist){
				if($entry =~ /flast\.(xml|tex|ind|indd)/s){
					$fname = basename($entry);
				}
			}
			if($chtitles{$fname}){
				$finaltext.="<contentUnit>\n<VVV\.contentUnitType>after table of contents\/preface<\/VVV\.contentUnitType>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<GGG\.contentUnitId\/>\n<VVV\.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV\.DOI\/>\n<SSS\.publicationDate\/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">$chtitles{$fname}<\/VVV\.title>\n<GGG\.titleLabel\/>\n<VVV\.titleLabelOverride\/>\n<VVV\.titleForDisplay textformat=\"ASCII\"\/>\n<GGG\.titleSortKey\/>\n<VVV\.titleSortKeyOverride\/>\n<VVV\.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n<creator>\n<SSS\.creatorId\/>\n<VVV\.sequenceNumber\/>\n<SSS\.creatorRole\/>\n<GGG\.personName\/>\n<GGG\.personNameInverted\/>\n<VVV\.titlesBeforeNames\/>\n<VVV\.namesBeforeKey\/>\n<VVV\.prefixToKey\/>\n<VVV\.keyNames\/>\n<VVV\.namesAfterKey\/>\n<VVV\.suffixToKey\/>\n<VVV\.lettersAfterNames\/>\n<VVV\.titlesAfterNames\/>\n<GGG\.creatorSortKey\/>\n<VVV\.creatorSortKeyOverride\/>\n<\/creator>\n<SSS\.copyrightYear\/>\n<VVV\.copyrightLine\/>\n<subjectGroup>\n<SSS\.subject1Name\/>\n<SSS\.subject1Code\/>\n<\/subjectGroup>\n<keywordGroup>\n<VVV\.keyword\/>\n<\/keywordGroup>\n<\/publicationInfoForUnit>\n<adminNotes\/>\n";
			}else{
				$finaltext.="<contentUnit>\n<VVV\.contentUnitType>after table of contents\/preface<\/VVV\.contentUnitType>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<GGG\.contentUnitId\/>\n<VVV\.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV\.DOI\/>\n<SSS\.publicationDate\/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">XXXXXXXXXXXXXXXX<\/VVV\.title>\n<GGG\.titleLabel\/>\n<VVV\.titleLabelOverride\/>\n<VVV\.titleForDisplay textformat=\"ASCII\"\/>\n<GGG\.titleSortKey\/>\n<VVV\.titleSortKeyOverride\/>\n<VVV\.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n<creator>\n<SSS\.creatorId\/>\n<VVV\.sequenceNumber\/>\n<SSS\.creatorRole\/>\n<GGG\.personName\/>\n<GGG\.personNameInverted\/>\n<VVV\.titlesBeforeNames\/>\n<VVV\.namesBeforeKey\/>\n<VVV\.prefixToKey\/>\n<VVV\.keyNames\/>\n<VVV\.namesAfterKey\/>\n<VVV\.suffixToKey\/>\n<VVV\.lettersAfterNames\/>\n<VVV\.titlesAfterNames\/>\n<GGG\.creatorSortKey\/>\n<VVV\.creatorSortKeyOverride\/>\n<\/creator>\n<SSS\.copyrightYear\/>\n<VVV\.copyrightLine\/>\n<subjectGroup>\n<SSS\.subject1Name\/>\n<SSS\.subject1Code\/>\n<\/subjectGroup>\n<keywordGroup>\n<VVV\.keyword\/>\n<\/keywordGroup>\n<\/publicationInfoForUnit>\n<adminNotes\/>\n";
			}
		}else{
			my ($cht,$ucht);
			if(grep { $_ =~ /$fmitem/ } keys %chtitles){
				$cht = $chtitles{$fmitem};
				$ucht = "\U$cht\E";
				$cht =~ s/\-/&hyphen;/g;
				$ucht =~ s/\-/&hyphen\;/g;
				$ucht =~ s/<([^>]+)>/<\L$1\E>/g;
				$ucht =~ s/<\/([^>]+)>/<\/\L$1\E>/g;
				$ucht =~ s/\&(\w+)\;/\&\L$1\E\;/g;
			}else{
				$cht = "XXXXXXXXXXXXXXXX";
				$ucht = "XXXXXXXXXXXXXXXX";
			}
			$finaltext.="<contentUnit>\n<VVV.contentUnitType>\L$cht\E<\/VVV.contentUnitType>\n<GGG.contentUnitId>c00<\/GGG.contentUnitId>\n<VVV.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV.DOI\/>\n<SSS.publicationDate\/>\n<titleInfo>\n<VVV.title textformat=\"ASCII\">$cht<\/VVV.title>\n<GGG.titleLabel>Chapter 0<\/GGG.titleLabel>\n<VVV.titleLabelOverride\/>\n<VVV.titleForDisplay textformat=\"ASCII\"\/>\n<GGG.titleSortKey>$ucht<\/GGG.titleSortKey>\n<VVV.titleSortKeyOverride\/>\n<VVV.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n<creator>\n<SSS.creatorId\/>\n<VVV.sequenceNumber\/>\n<SSS.creatorRole\/>\n<GGG.personName\/>\n<GGG.personNameInverted\/>\n<VVV.titlesBeforeNames\/>\n<VVV.namesBeforeKey\/>\n<VVV.prefixToKey\/>\n<VVV.keyNames\/>\n<VVV.namesAfterKey\/>\n<VVV.suffixToKey\/>\n<VVV.lettersAfterNames\/>\n<VVV.titlesAfterNames\/>\n<GGG.creatorSortKey\/>\n<VVV.creatorSortKeyOverride\/>\n<\/creator>\n<SSS.copyrightYear\/>\n<VVV.copyrightLine\/>\n<subjectGroup>\n<SSS.subject1Name\/>\n<SSS.subject1Code\/>\n<\/subjectGroup>\n<keywordGroup>\n<VVV.keyword\/>\n<\/keywordGroup>\n<\/publicationInfoForUnit>\n<adminNotes\/>\n";
		}
		
		my $fmcompname = $fmitem;
		$fmcompname =~ s/\.(\w+)$//s;
		
		if(-e "$myfolder/pdf/$fmcompname.pdf"){
			$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>pdf\/$fmcompname\.pdf<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>archive<\/VVV\.resourceVersion>\n<VVV\.resourceUse>press PDF<\/VVV\.resourceUse>\n<VVV\.resourceType>publication file<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
		}
		if(-e "$myfolder/Web-optimized/$fmcompname.pdf"){
			$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>Web-optimized\/$fmcompname\.pdf<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>archive<\/VVV\.resourceVersion>\n<VVV\.resourceUse>online PDF<\/VVV\.resourceUse>\n<VVV\.resourceType>publication file<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
		}

		$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>$fmitemloc<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>source<\/VVV\.resourceVersion>\n<VVV\.resourceUse>other<\/VVV\.resourceUse>\n<VVV\.resourceType>text<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";

		if($fmwithcmppath =~ /\.xml$/s){
			my $fmtext = &read_file($fmwithcmppath);
			$fmtext =~ s/<\!--(?s)(.*?)-->//g;
			while($fmtext =~ s/<mediaResource ([^<>]+)\/>/<XmediaResource $1\/>/s){
				my $meddata = $1;
				if($meddata =~ /href=\"([^\"]+)\"/s){
					my $figname = $1;
					my @findfig = split(/:/, $figname);
					$figname = $findfig[$#findfig];
					push(@fmfigs,$figname);
				}
			}
			if(@fmfigs){
				&insert_xmlfigs(\@fmcontent,\@fmfigs,$fmcompname);
			}
		}else{
			&insert_FMBMfigs(\@fmcontent,$fmcompname);
		}
		$finaltext.="<\/contentUnit>\n";
		delete @fmfigs[0 .. $#fmfigs];
	}
	delete @fmcontent[0 .. $#fmcontent];
}

####################################### CHAPTER ####################################

sub calc_chapters{
	my $chcnt = 1;
	my $partcnt = 1;
	foreach my $chitem(@chlist){
		my ($chitemloc,$chname,$chpath,$chwithcmppath);
		foreach my $citem(@completefileslist){
			if($citem =~ /$chitem/s){
				$chitemloc = $citem;
			}
		}
		# if(!$chitemloc){
			# print "PLEASE CHECK THE NAMING OF CHAPTER'S FILE NAMING IN TXT FILE\n";
			# exit(0);
		# }
		if($chitemloc){
			$chname = basename($chitemloc);
			$chname =~ s/\.(\w+)$//s;
			$chpath = $chitemloc;
			$chwithcmppath = $chitemloc;
			$chpath =~ s/\Q$myfolder\E\///s;
			$chitemloc =~ s/$chitem//s;
			$chitemloc =~ s/\\([^\\]+)\\$//s;
			$chitemloc =~ s/\/([^\/]+)\/$//s;
			
			find sub { push(@chcontent, $File::Find::name)}, "$chitemloc";
		}else{
			$chname = $chitem;
			$chpath = "";
			$chwithcmppath = "";
		}
		##### Pick the Chapter Titles from txt
		my ($cht,$ucht);
		if(grep { $_ =~ /$chitem/ } keys %chtitles){
			$cht = $chtitles{$chitem};
			$ucht = "\U$cht\E";
			$cht =~ s/\-/&hyphen;/g;
			$ucht =~ s/\-/&hyphen\;/g;
			$ucht =~ s/<([^>]+)>/<\L$1\E>/g;
			$ucht =~ s/<\/([^>]+)>/<\/\L$1\E>/g;
			$ucht =~ s/\&(\w+)\;/\&\L$1\E\;/g;
		}else{
			$cht = "XXXXXXXXXXXXXXXX";
			$ucht = "XXXXXXXXXXXXXXXX";
		}
		
		if(grep(/$chitem/,@partlist)){
			$partcnt = roman($partcnt);
			
			$finaltext.="<PcontentUnit>\n<VVV\.contentUnitType>part<\/VVV\.contentUnitType>\n<GGG\.contentUnitId\/>\n<VVV\.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV\.DOI\/>\n<SSS\.publicationDate\/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">$cht<\/VVV\.title>\n<GGG\.titleLabel>Part $partcnt<\/GGG\.titleLabel>\n<VVV\.titleLabelOverride\/>\n<VVV\.titleForDisplay textformat=\"ASCII\"\/>\n<GGG\.titleSortKey>$ucht<\/GGG\.titleSortKey>\n<VVV\.titleSortKeyOverride\/>\n<VVV\.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n";
		}else{
			$finaltext.="<contentUnit>\n<VVV\.contentUnitType>chapter<\/VVV\.contentUnitType>\n<GGG\.contentUnitId>$chname<\/GGG\.contentUnitId>\n<VVV\.contentUnitIdOverride\/>\n<publicationInfoForUnit>\n<VVV\.DOI\/>\n<SSS\.publicationDate\/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">$cht<\/VVV\.title>\n<GGG\.titleLabel>Chapter $chcnt<\/GGG\.titleLabel>\n<VVV\.titleLabelOverride\/>\n<VVV\.titleForDisplay textformat=\"ASCII\"\/>\n<GGG\.titleSortKey>$ucht<\/GGG\.titleSortKey>\n<VVV\.titleSortKeyOverride\/>\n<VVV\.subtitle textformat=\"ASCII\"\/>\n<\/titleInfo>\n";
		}

		##### End of Pick the Chapter Titles from txt

		##### Add creators here if any
		if(grep { $_ =~ /$chitem/ } keys %chauthors){
			$authname = $chauthors{$chitem};
			&add_creators($authname);
		}else{
			$finaltext.="<creator>\n<SSS\.creatorId/>\n<VVV\.sequenceNumber/>\n<SSS\.creatorRole/>\n<GGG\.personName/>\n<GGG\.personNameInverted/>\n<VVV\.titlesBeforeNames/>\n<VVV\.namesBeforeKey/>\n<VVV\.prefixToKey/>\n<VVV\.keyNames/>\n<VVV\.namesAfterKey/>\n<VVV\.suffixToKey/>\n<VVV\.lettersAfterNames/>\n<VVV\.titlesAfterNames/>\n<GGG\.creatorSortKey/>\n<VVV\.creatorSortKeyOverride/>\n</creator>\n";
		}
		$authname="";
		#### creators END
		$finaltext.="<SSS\.copyrightYear/>\n<VVV\.copyrightLine/>\n<subjectGroup>\n<SSS\.subject1Name/>\n<SSS\.subject1Code/>\n</subjectGroup>\n<keywordGroup>\n<VVV\.keyword/>\n</keywordGroup>\n</publicationInfoForUnit>\n<adminNotes/>\n";

		if(-e "$myfolder/pdf/$chname.pdf"){
			$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>pdf\/$chname\.pdf<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>archive<\/VVV\.resourceVersion>\n<VVV\.resourceUse>press PDF<\/VVV\.resourceUse>\n<VVV\.resourceType>publication file<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
		}
		if(-e "$myfolder/Web-optimized/$chname.pdf"){
			$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>Web-optimized\/$chname\.pdf<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>archive<\/VVV\.resourceVersion>\n<VVV\.resourceUse>online PDF<\/VVV\.resourceUse>\n<VVV\.resourceType>publication file<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
		}

		if($chpath){
			$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>$chpath<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>source<\/VVV\.resourceVersion>\n<VVV\.resourceUse>other<\/VVV\.resourceUse>\n<VVV\.resourceType>text<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
		}

		if($chwithcmppath =~ /\.xml$/s){
			my $chtext = &read_file($chwithcmppath);
			$chtext =~ s/<\!--(?s)(.*?)-->//g;
			while($chtext =~ s/<mediaResource ([^<>]+)\/>/<XmediaResource $1\/>/s){
				my $meddata = $1;
				if($meddata =~ /href=\"([^\"]+)\"/s){
					my $figname = $1;
					my @findfig = split(/:/, $figname);
					$figname = $findfig[$#findfig];
					push(@chfigs,$figname);
				}
			}
			if(@chfigs){
				&insert_xmlfigs(\@chcontent,\@chfigs,$chname);
			}
		}else{
			&insert_figs(\@chcontent,$chname);
		}

		if(!(grep(/$chitem/,@partlist))){
			$finaltext.="<\/contentUnit>\n";
		}
		if((grep(/$chitem/,@partlist))){
			$partcnt++;
		}else{
			$chcnt++;
		}
		delete @chfigs[0 .. $#chfigs];
		delete @chcontent[0 .. $#chcontent];
	}

	$finaltext =~ s/<PcontentUnit>/<contentUnit>/s;
	$finaltext =~ s/<PcontentUnit>/<\/contentUnit>\n<contentUnit>/g;
	
	if(@partlist){
		$finaltext.="<\/contentUnit>\n";
	}
	delete @partlist[0 .. $#partlist];
	delete @chlist[0 .. $#chlist];
}

####################################### Back Matter ####################################

sub back_matters{
	foreach my $bmitem(@bmlist){
		my $bmitemloc;
		foreach my $bitem(@completefileslist){
			if($bitem =~ /$bmitem/s){
				$bmitemloc = $bitem;
			}
		}
		if(!$bmitemloc){
			print "PLEASE CHECK THE NAMING OF BACKMATTER'S FILE NAMING IN TXT FILE\n";
			exit(0);
		}
		my $bmname = basename($bmitemloc);
		$bmname =~ s/\.(\w+)$//s;
		my $bmpath = $bmitemloc;
		my $bmwithcmppath = $bmitemloc;
		$bmpath =~ s/\Q$myfolder\E\///s;
		$bmitemloc =~ s/$bmitem//s;
		$bmitemloc =~ s/\\([^\\]+)\\$//s;
		$bmitemloc =~ s/\/([^\/]+)\/$//s;
		
  		find sub { push(@bmcontent, $File::Find::name)}, "$bmitemloc";

		## Pick the Chapter Titles from txt
		if(grep { $_ =~ /$bmitem/ } keys %chtitles){
			my $bmht = $chtitles{$bmitem};
			my $ubmht = "\U$bmht\E";
			$bmht =~ s/\-/&hyphen;/g;
			$ubmht =~ s/\-/&hyphen\;/g;
			$ubmht =~ s/<([^>]+)>/<\L$1\E>/g;
			$ubmht =~ s/<\/([^>]+)>/<\/\L$1\E>/g;
			$ubmht =~ s/\&(\w+)\;/\&\L$1\E\;/g;

			$finaltext.="<contentUnit>\n<VVV\.contentUnitType>backmatter</VVV\.contentUnitType>\n<VVV\.compliesWithFilenaming>Books0\.5</VVV\.compliesWithFilenaming>\n<GGG\.contentUnitId/>\n<VVV\.contentUnitIdOverride/>\n<publicationInfoForUnit>\n<VVV\.DOI/>\n<SSS\.publicationDate/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">$bmht</VVV\.title>\n<GGG\.titleLabel/>\n<VVV\.titleLabelOverride/>\n<VVV\.titleForDisplay textformat=\"ASCII\"/>\n<GGG\.titleSortKey/>\n<VVV\.titleSortKeyOverride/>\n<VVV\.subtitle textformat=\"ASCII\"/>\n</titleInfo>\n";
		}else{
			$finaltext.="<contentUnit>\n<VVV\.contentUnitType>backmatter</VVV\.contentUnitType>\n<VVV\.compliesWithFilenaming>Books0\.5</VVV\.compliesWithFilenaming>\n<GGG\.contentUnitId/>\n<VVV\.contentUnitIdOverride/>\n<publicationInfoForUnit>\n<VVV\.DOI/>\n<SSS\.publicationDate/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">XXXXXXXXXXXXXXXXXX</VVV\.title>\n<GGG\.titleLabel/>\n<VVV\.titleLabelOverride/>\n<VVV\.titleForDisplay textformat=\"ASCII\"/>\n<GGG\.titleSortKey/>\n<VVV\.titleSortKeyOverride/>\n<VVV\.subtitle textformat=\"ASCII\"/>\n</titleInfo>\n";
		}
		# End of Pick the Chapter Titles from txt

		## Add creators here if any
		if(grep { $_ =~ /$bmitem/ } keys %chauthors){
			$authname = $chauthors{$bmitem};
			&add_creators($authname);
		}else{
			$finaltext.="<creator>\n<SSS\.creatorId/>\n<VVV\.sequenceNumber/>\n<SSS\.creatorRole/>\n<GGG\.personName/>\n<GGG\.personNameInverted/>\n<VVV\.titlesBeforeNames/>\n<VVV\.namesBeforeKey/>\n<VVV\.prefixToKey/>\n<VVV\.keyNames/>\n<VVV\.namesAfterKey/>\n<VVV\.suffixToKey/>\n<VVV\.lettersAfterNames/>\n<VVV\.titlesAfterNames/>\n<GGG\.creatorSortKey/>\n<VVV\.creatorSortKeyOverride/>\n</creator>\n";
		}
		$authname="";
		# creators END
		$finaltext.="<SSS\.copyrightYear/>\n<VVV\.copyrightLine/>\n<subjectGroup>\n<SSS\.subject1Name/>\n<SSS\.subject1Code/>\n</subjectGroup>\n<keywordGroup>\n<VVV\.keyword/>\n</keywordGroup>\n</publicationInfoForUnit>\n<adminNotes/>\n";

		if(-e "$myfolder/pdf/$bmname.pdf"){
			$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>pdf\/$bmname\.pdf<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>archive<\/VVV\.resourceVersion>\n<VVV\.resourceUse>press PDF<\/VVV\.resourceUse>\n<VVV\.resourceType>publication file<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
		}
		if(-e "$myfolder/Web-optimized/$bmname.pdf"){
			$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>Web-optimized\/$bmname\.pdf<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>archive<\/VVV\.resourceVersion>\n<VVV\.resourceUse>online PDF<\/VVV\.resourceUse>\n<VVV\.resourceType>publication file<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
		}

		$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>$bmpath<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>source<\/VVV\.resourceVersion>\n<VVV\.resourceUse>other<\/VVV\.resourceUse>\n<VVV\.resourceType>text<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";

		if($bmwithcmppath =~ /\.xml$/s){
			my $bmtext = &read_file($bmwithcmppath);
			$bmtext =~ s/<\!--(?s)(.*?)-->//g;
			while($bmtext =~ s/<mediaResource ([^<>]+)\/>/<XmediaResource $1\/>/s){
				my $meddata = $1;
				if($meddata =~ /href=\"([^\"]+)\"/s){
					my $figname = $1;
					my @findfig = split(/:/, $figname);
					$figname = $findfig[$#findfig];
					push(@bmfigs,$figname);
				}
			}
			if(@bmfigs){
				&insert_xmlfigs(\@bmcontent,\@bmfigs,$bmname);
			}
		}else{
			&insert_FMBMfigs(\@bmcontent,$bmname);
		}
		$finaltext.="<\/contentUnit>\n";
		delete @bmfigs[0 .. $#bmfigs];
		delete @bmcontent[0 .. $#bmcontent];
	}
}
###################################################################################
sub anc_matters{
	foreach my $ancitem(@anclist){
		my $ancitemloc;
		foreach my $anitem(@completefileslist){
			if($anitem =~ /$ancitem/s){
				$ancitemloc = $anitem;
			}
		}
		my $ancname = basename($ancitemloc);
		$ancname =~ s/\.(\w+)$//s;
		my $ancpath = $ancitemloc;
		my $ancwithcmppath = $ancitemloc;
		$ancpath =~ s/\Q$myfolder\E\///s;
		$ancitemloc =~ s/$ancitem//s;
		$ancitemloc =~ s/\\([^\\]+)\\$//s;
		$ancitemloc =~ s/\/([^\/]+)\/$//s;
		
  		find sub { push(@anccontent, $File::Find::name)}, "$ancitemloc";

		## Pick the Chapter Titles from txt
		my $ancht;
		if(grep { $_ =~ /$ancitem/ } keys %chtitles){
			$ancht = $chtitles{$ancitem};
			$ancht =~ s/\-/&hyphen;/g;
		}else{
			$ancht = "XXXXXXXXXXXXXXXX";
		}
		$finaltext.="<contentUnit>\n<VVV\.contentUnitType>ancillary material</VVV\.contentUnitType>\n<VVV\.compliesWithFilenaming>Books0\.5</VVV\.compliesWithFilenaming>\n<GGG\.contentUnitId/>\n<VVV\.contentUnitIdOverride/>\n<publicationInfoForUnit>\n<VVV\.DOI/>\n<SSS\.publicationDate/>\n<titleInfo>\n<VVV\.title textformat=\"ASCII\">$ancht</VVV\.title>\n<GGG\.titleLabel/>\n<VVV\.titleLabelOverride/>\n<VVV\.titleForDisplay textformat=\"ASCII\"/>\n<GGG\.titleSortKey/>\n<VVV\.titleSortKeyOverride/>\n<VVV\.subtitle textformat=\"ASCII\"/>\n</titleInfo>\n";
		# End of Pick the Chapter Titles from txt

		## Add creators here if any
		if(grep { $_ =~ /$ancitem/ } keys %chauthors){
			$authname = $chauthors{$ancitem};
			&add_creators($authname);
		}else{
			$finaltext.="<creator>\n<SSS\.creatorId/>\n<VVV\.sequenceNumber/>\n<SSS\.creatorRole/>\n<GGG\.personName/>\n<GGG\.personNameInverted/>\n<VVV\.titlesBeforeNames/>\n<VVV\.namesBeforeKey/>\n<VVV\.prefixToKey/>\n<VVV\.keyNames/>\n<VVV\.namesAfterKey/>\n<VVV\.suffixToKey/>\n<VVV\.lettersAfterNames/>\n<VVV\.titlesAfterNames/>\n<GGG\.creatorSortKey/>\n<VVV\.creatorSortKeyOverride/>\n</creator>\n";
		}
		$authname="";
		# creators END
		$finaltext.="<SSS\.copyrightYear/>\n<VVV\.copyrightLine/>\n<subjectGroup>\n<SSS\.subject1Name/>\n<SSS\.subject1Code/>\n</subjectGroup>\n<keywordGroup>\n<VVV\.keyword/>\n</keywordGroup>\n</publicationInfoForUnit>\n<adminNotes/>\n";

		if(-e "$myfolder/pdf/$ancname.pdf"){
			$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>pdf\/$ancname\.pdf<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>archive<\/VVV\.resourceVersion>\n<VVV\.resourceUse>press PDF<\/VVV\.resourceUse>\n<VVV\.resourceType>publication file<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
		}
		if(-e "$myfolder/Web-optimized/$ancname.pdf"){
			$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>Web-optimized\/$ancname\.pdf<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>archive<\/VVV\.resourceVersion>\n<VVV\.resourceUse>online PDF<\/VVV\.resourceUse>\n<VVV\.resourceType>publication file<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
		}

		$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>$ancpath<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>source<\/VVV\.resourceVersion>\n<VVV\.resourceUse>other<\/VVV\.resourceUse>\n<VVV\.resourceType>text<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";

		if($ancwithcmppath =~ /\.xml$/s){
			my $anctext = &read_file($ancwithcmppath);
			$anctext =~ s/<\!--(?s)(.*?)-->//g;
			while($anctext =~ s/<mediaResource ([^<>]+)\/>/<XmediaResource $1\/>/s){
				my $meddata = $1;
				if($meddata =~ /href=\"([^\"]+)\"/s){
					my $figname = $1;
					my @findfig = split(/:/, $figname);
					$figname = $findfig[$#findfig];
					push(@ancfigs,$figname);
				}
			}
			if(@ancfigs){
				&insert_xmlfigs(\@anccontent,\@ancfigs,$ancname);
			}
		}else{
			&insert_FMBMfigs(\@anccontent,$ancname);
		}
		$finaltext.="<\/contentUnit>\n";
		delete @ancfigs[0 .. $#ancfigs];
	}
	delete @anccontent[0 .. $#anccontent];
}
#######################################################################################################
sub add_creators{
	$authname = shift;
	$authname =~ s/, /,/g;
	$creatnum=1;

	if($authname =~ /,/){
		my @authors = split(/,/, $authname);
		foreach my $tauth (@authors){
			my $utauth = "\U$tauth\E";
			$tauth =~ s/\-/&hyphen;/g;
			$utauth =~ s/\-/&hyphen;/g;

			&sep_authors($tauth);

			$finaltext.="<creator>\n<SSS\.creatorId>000000<\/SSS\.creatorId>\n<VVV\.sequenceNumber>$creatnum<\/VVV\.sequenceNumber>\n<SSS\.creatorRole>Author<\/SSS\.creatorRole>\n<GGG\.personName>$tauth<\/GGG\.personName>\n<GGG\.personNameInverted>$sname, $fname<\/GGG\.personNameInverted>\n<VVV\.titlesBeforeNames><\/VVV\.titlesBeforeNames>\n<VVV\.namesBeforeKey>$fname<\/VVV\.namesBeforeKey>\n<VVV\.prefixToKey><\/VVV\.prefixToKey>\n<VVV\.keyNames>$sname<\/VVV\.keyNames>\n<VVV\.namesAfterKey><\/VVV\.namesAfterKey>\n<VVV\.suffixToKey><\/VVV\.suffixToKey>\n<VVV\.lettersAfterNames><\/VVV\.lettersAfterNames>\n<VVV\.titlesAfterNames><\/VVV\.titlesAfterNames>\n<GGG\.creatorSortKey><\/GGG\.creatorSortKey>\n<VVV\.creatorSortKeyOverride>$utauth<\/VVV\.creatorSortKeyOverride>\n<\/creator>\n";
			$creatnum++;
		}
	}else{
		my $uauthname = "\U$authname\E";
		$authname =~ s/\-/&hyphen;/g;
		$uauthname =~ s/\-/&hyphen;/g;

		&sep_authors($authname);

		$finaltext.="<creator>\n<SSS\.creatorId>000000<\/SSS\.creatorId>\n<VVV\.sequenceNumber>$creatnum<\/VVV\.sequenceNumber>\n<SSS\.creatorRole>Author<\/SSS\.creatorRole>\n<GGG\.personName>$authname<\/GGG\.personName>\n<GGG\.personNameInverted>$sname, $fname<\/GGG\.personNameInverted>\n<VVV\.titlesBeforeNames><\/VVV\.titlesBeforeNames>\n<VVV\.namesBeforeKey>$fname<\/VVV\.namesBeforeKey>\n<VVV\.prefixToKey><\/VVV\.prefixToKey>\n<VVV\.keyNames>$sname<\/VVV\.keyNames>\n<VVV\.namesAfterKey><\/VVV\.namesAfterKey>\n<VVV\.suffixToKey><\/VVV\.suffixToKey>\n<VVV\.lettersAfterNames><\/VVV\.lettersAfterNames>\n<VVV\.titlesAfterNames><\/VVV\.titlesAfterNames>\n<GGG\.creatorSortKey><\/GGG\.creatorSortKey>\n<VVV\.creatorSortKeyOverride>$uauthname<\/VVV\.creatorSortKeyOverride>\n<\/creator>\n";
	}
}


#######################################################################################################
sub sep_authors{
	my $myauth = shift;
	my @sepauthor="";

	if($myauth =~ / von der | van der | van | von | Paz De | del | de la | de | De | Da | da | le | Le | St | don | dos /s)
	{
		$sname = $myauth;
		$sname =~ s/(.*?)( von der | van der | van | von | Paz De | del | de la | de | De | Da | da | le | Le | St | don | dos )(.*?)/$2$3/s;
	    $fname = $myauth;
		$fname =~ s/$sname//s;
		$sname =~ s/^(\s+)//s;
		$fname =~ s/ $//s;
	}else{
		@sepauthor = split(/ /,$myauth);
		$sname = $sepauthor[$#sepauthor];
		
		$fname = "";
		my $totelem = @sepauthor;
		$totelem--;
		my $i=0;
		while($i<$totelem)
		{
			$fname = $fname." $sepauthor[$i++]";
		}
	}
	$fname =~ s/^(\s+)//s;
	#return($fname,$sname);
}

#######################################################################################################
sub insert_figs{
	my ($one_ref, $CHName) = @_;
    my @figlist = @{ $one_ref };
	my $figtype;
	foreach my $myitem(@figlist){
		next if($myitem !~ /(.*?)\.(.*?)/);
		$myitem =~ s/\Q$myfolder\E\///s;
		
	    if(($myitem =~ /(.*?)\.($extn)/)&&($myitem =~ /image_a/)){
			if($myitem =~ /${CHName}f/s){
				$figtype = "figure, numbered";
			}elsif($myitem =~ /${CHName}uf/s){
				$figtype = "figure, unnumbered";
			}elsif($myitem =~ /${CHName}t/s){
				$figtype = "table, numbered";
			}elsif($myitem =~ /${CHName}ut/s){
				$figtype = "table, unnumbered";
			}elsif($myitem =~ /${CHName}e/s){
				$figtype = "equation, numbered";
			}elsif($myitem =~ /${CHName}ue/s){
				$figtype = "equation, unnumbered";
			}elsif($myitem =~ /(ffirs|fpref|flast|fbetw)/s){
				$figtype = "icon";
			}else{
				$figtype = "figure, numbered";
			}
		
			$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>$myitem<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>archive<\/VVV\.resourceVersion>\n<VVV\.resourceUse>high-res print graphic<\/VVV\.resourceUse>\n<VVV\.resourceType>$figtype<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
		}
	}
}
#######################################################################################################
sub insert_FMBMfigs{
	my ($one_ref, $FBMName) = @_;
    my @figlist = @{ $one_ref };

	my $figtype;
	foreach my $myitem(@figlist){
		next if($myitem !~ /(.*?)\.(.*?)/);
		$myitem =~ s/\Q$myfolder\E\///s;

	    if(($myitem =~ /$FBMName(.*?)\.($extn)/)&&($myitem =~ /image_a/)){
			if($myitem =~ /${FBMName}f/s){
				$figtype = "figure, numbered";
			}elsif($myitem =~ /${FBMName}uf/s){
				$figtype = "figure, unnumbered";
			}elsif($myitem =~ /${FBMName}t/s){
				$figtype = "table, numbered";
			}elsif($myitem =~ /${FBMName}ut/s){
				$figtype = "table, unnumbered";
			}elsif($myitem =~ /${FBMName}e/s){
				$figtype = "equation, numbered";
			}elsif($myitem =~ /${FBMName}ue/s){
				$figtype = "equation, unnumbered";
			}elsif($myitem =~ /(ffirs|fpref|flast|fbetw)/s){
				$figtype = "icon";
			}else{
				$figtype = "figure, numbered";
			}

			$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>$myitem<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>archive<\/VVV\.resourceVersion>\n<VVV\.resourceUse>high-res print graphic<\/VVV\.resourceUse>\n<VVV\.resourceType>$figtype<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
		}
	}
}
#######################################################################################################
sub find_Missingfigs{
	my @figlist;
	foreach my $myitem(@completefileslist){
		if($myitem =~ /(.*?)\.($extn)/){
			$myitem =~ s/\Q$myfolder\E\///s;
			push(@figlist, $myitem)
		}
	}
	foreach my $myitem(@figlist){
		if($finaltext !~ /$myitem/s){
			my $filename = $myitem;
			$filename =~ s/^([^\/]+)\/(.*?)$/$1/s;
			$myitem = basename($myitem);
			$tempdata .= "$myitem is UNUSED in $filename\n";		
		}
	}
}
#######################################################################################################
sub insert_xmlfigs{
	my ($one_ref, $two_ref, $compname) = @_;
    my @complist = @{ $one_ref };
    my @figlist = @{ $two_ref };
	
	my ($figwithpath,$figwithchpath,$newfigpath,$figname);
	
	foreach my $cmpentry(@complist){
		if($cmpentry =~ /(.*?)\.($extn)/){
			$figwithchpath = basename($cmpentry);
			my $chn = $cmpentry;
			$chn =~ s/$figwithchpath//s;
			$chn =~ s/\Q$myfolder\E\///s;
			$chn =~ s/\/([^\/]+)\///s;
			my $fignm = $figwithchpath;
			$figwithchpath =~ s/\.(\w+)$//s;
			
			if(!(grep(/$figwithchpath/,@figlist))){
				$tempdata .= "$fignm is UNUSED in $chn\n";
			}
		}
	}	
	
	my $figtype;
	foreach my $myitem(@figlist){
		foreach my $cmpentry(@complist){
			if($cmpentry =~ /$myitem/s){
				$figwithpath = $cmpentry;
			}
		}
		$figname = basename($figwithpath);
		$figwithchpath = $figwithpath;
		$figwithchpath =~ s/\Q$myfolder\E\///s;
		# copy("$figwithpath","${newfigpath}$figname");
		
	    if($figwithchpath =~ /(.*?)\.($extn)/){
			if($myitem =~ /${compname}f/s){
				$figtype = "figure, numbered";
			}elsif($myitem =~ /${compname}uf/s){
				$figtype = "figure, unnumbered";
			}elsif($myitem =~ /${compname}t/s){
				$figtype = "table, numbered";
			}elsif($myitem =~ /${compname}ut/s){
				$figtype = "table, unnumbered";
			}elsif($myitem =~ /${compname}e/s){
				$figtype = "equation, numbered";
			}elsif($myitem =~ /${compname}ue/s){
				$figtype = "equation, unnumbered";
			}elsif($myitem =~ /(ffirs|fpref|flast|fbetw)/s){
				$figtype = "icon";
			}else{
				$figtype = "figure, numbered";
			}
			$finaltext.="<file>\n<VVV\.compliesWithFilenaming>Books0\.5<\/VVV\.compliesWithFilenaming>\n<VVV\.operatingSystem>Macintosh<\/VVV\.operatingSystem>\n<VVV\.path>$figwithchpath<\/VVV\.path>\n<VVV\.pathInArchive\/>\n<VVV\.resourceVersion>archive<\/VVV\.resourceVersion>\n<VVV\.resourceUse>high-res print graphic<\/VVV\.resourceUse>\n<VVV\.resourceType>$figtype<\/VVV\.resourceType>\n<VVV\.resourceNumber\/>\n<\/file>\n";
		}
	}
}
###################################################################################################
sub write_file{
	# $finaltext=~s/([\n]+)/\n/gs;
	open(OUTFILE,">${myoutdir}/metadata.xml") || die "cann't find the file\n";
    print OUTFILE $finaltext;
	close(OUTFILE);
	$finaltext="";
	#system("start e32 ${myoutdir}/metadata.xml");
	system("start $myoutdir");
}
###################################################################################################
sub write_TempFile{
	if($tempdata){
		open(TEMPFILE,">${myoutdir}/error.log") || die "cann't find the file\n";
		print TEMPFILE "$tempdata\n";
		close(TEMPFILE);
		system("start notepad ${myoutdir}/error.log");
	}
}
#######################################################################################################
#######################################################################################################
sub reset {
    $path-> delete('0.0','end');
	delete @dirlist[0 .. $#dirlist];
	delete @genimagelist[0 .. $#genimagelist];
	delete @tmpfmlist[0 .. $#tmpfmlist];
	delete @fmlist[0 .. $#fmlist];
	delete @chlist[0 .. $#chlist];
	delete @bmlist[0 .. $#bmlist];
	delete @childbmlist[0 .. $#childbmlist];
	delete @completefileslist[0 .. $#completefileslist];
	delete @fmcontent[0 .. $#fmcontent];
	delete @fmfigs[0 .. $#fmfigs];
	delete @chcontent[0 .. $#chcontent];
	delete @chfigs[0 .. $#chfigs];
	delete @bmcontent[0 .. $#bmcontent];
	delete @bmfigs[0 .. $#bmfigs];
	delete @anclist[0 .. $#anclist];
	delete @anccontent[0 .. $#anccontent];
	
	undef %chtitles;
	undef %chauthors;
	$finaltext="";
	$myfolder="";
	$FLAG="";
	$creatnum=1;
}
#######################################################################################################
