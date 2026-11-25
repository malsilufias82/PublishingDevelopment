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
my ($filestr,$mainfilename,$myfolder,$xmlname,$finalfilename,$xlsdata,$mythumbdir,$logtxt,$chnum,$chtitle);
my ($figlabel,$figtitle);
my (@dirlist,@filelist,@imagelist,@thimagelist,@figChWise);
my (%figlabelsaver,%figaltsaver,%figwithpath,%thimagesaver,%PageText,%FigNumByPage);
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
# if(-d $myfolder){
	# print "Path: $myfolder\n";
# }
# print "OUT Path: $outdir\n";
		
print "PROCESSING.....\n\n";

&extract_zip($filename);
&read_folder($myfolder);
rmtree($outdir);
mkdir($outdir);

foreach $xmlname (@filelist){
	chomp($xmlname);
	$finalfilename = basename($xmlname); 
	$finalfilename =~ s/\.(\w+)$//s;
	
	$filestr=&read_file($xmlname);
	$filestr =~ s/<\!--(.*?)-->//g;
	$filestr =~ s/([ ]+)/ /g;


	
	if(($filestr =~ /<img ([^<>]+)\/>/s)&&($xmlname !~ /(cover|title)/s)){
		&get_chTitle();
		&save_figLabels();
		&save_AltText();
		&save_PageNum();

		&conv_img();   # Convert images into thumbnails
		&gen_Excel();  #write Excel file

		&undef_all();
	}
}


&write_log();
rmtree($myfolder); #remove unzipped folder from base path
unlink("$filename"); #remove zip file from base path
rmtree($mythumbdir);

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
sub undef_all(){
	%figaltsaver = ();
	%figlabelsaver =();
	%thimagesaver = ();
	%FigNumByPage = ();
	%PageText = ();
	@figChWise = ();
}
########################
sub extract_zip(){
	my ($zipname)=@_;
	chomp($zipname);
	my $zipfilename = basename($zipname);
	my $zipfolder = $zipname;
	$zipfolder =~ s/$zipfilename//s;
	$zipfilename =~ s/\.(\w+)$//s;
	$zipfolder .= "$zipfilename";
	rmtree($zipfolder);
	mkdir($zipfolder);
	
	my $zip = Archive::Zip->new();
	unless ( $zip->read($zipname) == AZ_OK ) { 
		die 'read error';
	}

	$zip->extractTree( '', "$zipfolder/" );
}
########################
sub get_chTitle(){
	$chtitle = "";
	if($filestr =~ /<h1(.*?)<\/h1>/){
		my $h1text = $1;
		$h1text =~ s/<b ([^<>]+)>(.*?)<\/b>/<b>$2<\/b>/g;
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
	}
	if(($filestr =~ /<h1(.*?)<span class=\"chapterTitle ([^\"]+)\">(.*?)<\/span><\/h1>/)||($filestr =~ /<h1(.*?)<span class=\"partTitle ([^\"]+)\">(.*?)<\/span><\/h1>/)){
		my $h1att = $1;
		$chtitle = $3;
		$chtitle =~ s/<span ([^<>]+)>(.*?)<\/span>/$2/g;
		$chtitle =~ s/<span>(.*?)<\/span>/$1/g;
		$chtitle =~ s/<span ([^<>]+)>//g;
		$chtitle =~ s/<span>//g;
		$chtitle =~ s/<\/span>//g;
	}
}
########################
sub save_figLabels(){
	while($filestr =~ s/<img ([^<>]+)\/>/<Ximg $1\/>/s){
		my $imgtext = $1;
		my $imgnm;
		if($imgtext =~ /src=\"([^\"]+)\"/s){
			$imgnm = $1;
		}
		if($filestr =~ /<img([^<>]+)src=\"$imgnm\"([^<>]+)\/>/s){
			$filestr =~ s/<Ximg([^<>]+)src=\"$imgnm\"([^<>]+)\/>/<XXimg$1src=\"$imgnm\"$2 type=\"icon\"\/>/s;
			$filestr =~ s/<img([^<>]+)src=\"$imgnm\"([^<>]+)\/>//g;
		}
	}
	$filestr =~ s/<Ximg/<img/g;
	$filestr =~ s/<XXimg/<img/g;
	
	while($filestr =~ /<figure>(.*?)<\/figure>/s){
		my $figdata = $1;
		&loadFigcapByFigname($figdata);
		$filestr =~ s/<figure>(.*?)<\/figure>/<Xfigure>$figdata<\/Xfigure>/s;
	}

	while($filestr =~ /<figure ([^<>]+)>(.*?)<\/figure>/s){
		my $figdata = $2;
		&loadFigcapByFigname($figdata);
		$filestr =~ s/<figure ([^<>]+)>(.*?)<\/figure>/<Zfigure $1>$figdata<\/Zfigure>/s;
	}
}
########################
sub loadFigcapByFigname(){
	my ($myfigdata)=@_;
	$myfigdata =~ s/\n<(\w+)\/>/<$1\/>/g;
	$myfigdata =~ s/\n<\/(\w+)>/<\/$1>/g;
	
	my $figcaptions;
	if($myfigdata =~ /<figcaption>(.*?)<\/figcaption>/s){
		$figcaptions = $1;
		if($figcaptions =~ /<p><span(.*?)<\/span><\/p>/){
			$figtitle = $1;
		}elsif($figcaptions =~ /<p><span ([^<>]+)>(.*?)<\/span> (.*?)<\/p>/){
			$figtitle = $2;
		}

		if($figtitle =~ /class=\"figureLabel\"/s){
			if($figtitle =~ /<a([^<>]+)>(.*?)<\/a>/s){
				$figlabel = $2;
				$figlabel =~ s/<b>(.*?)<\/b>/$1/g;
				$figlabel =~ s/<span ([^<>]+)>//g;
				$figlabel =~ s/<span>//g;
				$figlabel =~ s/<\/span>//g;
			}
		}
		if($figcaptions !~ /class=\"figureLabel\"/s){
			$figlabel = "";
		}
	}else{
		$figlabel = "";
	}

	while($myfigdata =~ s/<img ([^>]+)\/>/<Ximg $1\/>/s){
		my $imgcontent = $1;
		if($imgcontent =~ /src=\"([^\"]+)\"/s){
			my $imgname = $1;
			$imgname = basename($imgname);
			if(($figlabel)&&($imgcontent !~ /type=\"icon\"/s)){
				$figlabelsaver{$imgname} = $figlabel;
				# $logtxt .= "$imgname\t-->\t$figlabel\n\n";
				# $myfigdata =~ s/<figcaption>/<Xfigcaption>/g;
			}if(($figlabel)&&($imgcontent =~ /type=\"icon\"/s)){
				$figlabelsaver{$imgname} = "icon";
				# $logtxt .= "$imgname\t-->\ticon\n\n";
				# $myfigdata =~ s/<figcaption>/<Yfigcaption>/g;
			}elsif(!($figlabel)){
				$figlabelsaver{$imgname} = "";
				# $logtxt .= "$imgname\t-->\tXXXXX\n\n";
				# $myfigdata =~ s/<figcaption>/<Zfigcaption>/g;
			}
		}
	}
}
########################
sub save_AltText(){
	while($filestr =~ s/<img ([^<>]+)\/>/<Ximg $1\/>/s){
		my $imgcontent = $1;
		my $imgname;
		if($imgcontent =~ /src=\"([^\"]+)\"/s){
			$imgname = $1;
			my $fpath = $imgname;
			$imgname = basename($imgname);
			# $fpath =~ s/$imgname//s;
			$figwithpath{$imgname} = $fpath;
			push(@figChWise,$imgname);
		}

		if($imgcontent =~ /alt=\"\"/s){
			$figaltsaver{$imgname} = "alt=\"\"";
		}elsif($imgcontent =~ /alt=\"(\w+)([^\"]+)\"/s){
			my $temp = "$1$2";
			$figaltsaver{$imgname} = $temp;
		}
	}
	$filestr =~ s/<Ximg/<img/g;
}
########################
sub save_PageNum(){
	$filestr =~ s/<span([^<>]+)epub:type=\"pagebreak\"([^<>]+)\/>/<span$1epub:type=\"pagebreak\"$2><\/span>/g;

	my ($spanatt,$paragraphtext,$spid);
	while($filestr =~ s/<span([^<>]+)epub:type=\"pagebreak\"([^>]+)><\/span>(.*?)<span([^<>]+)epub:type=\"pagebreak\"([^>]+)><\/span>/<Xspan$1epub:type=\"pagebreak\"$2><\/span>$3<span$4epub:type=\"pagebreak\"$5><\/span>/s){
		$spanatt = "$1 $2";
		$paragraphtext = $3;
		$spid;
		if($spanatt =~ /id=\"([^\"]+)\"/s){
			$spid = $1;
		}
		$PageText{$spid} = $paragraphtext;
	}
	if($filestr =~ /<span([^<>]+)epub:type=\"pagebreak\"([^>]+)><\/span>(.*?)<\/body>/s){
		$spanatt = "$1 $2";
		$paragraphtext = $3;
		$spid;
		if($spanatt =~ /id=\"([^\"]+)\"/s){
			$spid = $1;
		}
		$PageText{$spid} = $paragraphtext;
	}
	
	my ($imgatt,$pgimgname,$pgnum);
	foreach my $pgtext (sort keys %PageText){
		while($PageText{$pgtext} =~ s/<img ([^<>]+)\/>/<Ximg $1\/>/s){
			$imgatt = $1;
			if($imgatt =~ /src=\"([^\"]+)\"/s){
				$pgimgname = $1;
				$pgimgname = basename($pgimgname);
				$pgnum = $pgtext;
				$pgnum =~ s/Page_//s;
				$FigNumByPage{$pgimgname} = $pgnum;
			}
		}
	}
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

	foreach my $imgname (sort keys %figwithpath){
		foreach my $fname(@imagelist)
		{
			if($fname =~ /$figwithpath{$imgname}/s){
				my $thumbimgname = $imgname;
				$thumbimgname =~ s/\.(\w+)$//s;
				$thumbimgname = "$mythumbdir${thumbimgname}-thumb.png";
				if(!(-e $thumbimgname)){
					push(@thimagelist,$thumbimgname);
					$thimagesaver{$imgname} = $thumbimgname;
					# $logtxt .= "Physical NAME: $fname\nName in XHTML: $thumbimgname\n\n";
					system("convert -density 300 $fname -resize 200x200 -units pixelsperinch -density 300 $thumbimgname");
				}
			}
		}
	}
}
########################
sub conv_img1(){
	rmtree($outdir);
	mkdir($outdir);
	$mythumbdir = "${outdir}/Thumbs/";
	foreach my $imgname(@imagelist)
	{
		if($imgname =~ /-thumb\.(\w+)/s){
			unlink("$imgname");
		}
	}
	rmtree($mythumbdir);
	mkdir($mythumbdir);

	my ($tpath,$ponly);
	foreach my $imgname (sort keys %figwithpath){
		foreach my $fname(@imagelist)
		{
			if($fname =~ /$figwithpath{$imgname}/s){
				$ponly = "$figwithpath{$imgname}";
				$ponly =~ s/$imgname//s;
				$tpath = "$mythumbdir$ponly";
				if(!(-d $figwithpath{$imgname})){
					mkdir($tpath);
				}
				my $thumbimgname = $imgname;
				$thumbimgname =~ s/\.(\w+)$//s;
				$thumbimgname = "$tpath${thumbimgname}-thumb.png";
				# $thumbimgname = "$mythumbdir${thumbimgname}-thumb.png";
				if(!(-e $thumbimgname)){
					push(@thimagelist,$thumbimgname);
					system("convert -density 300 $fname -resize 200x200 -units pixelsperinch -density 300 $thumbimgname");
				}
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

	$worksheet->set_column(1, 0, 30);	#Chaper Number
	$worksheet->set_column(2, 1, 36);	#Chapter Name
	$worksheet->set_column(3, 2, 14);	#Page/Slide Number
    $worksheet->set_column(4, 3, 21);	#Image Filename
    $worksheet->set_column(5, 4, 21);	#Image ID
    $worksheet->set_column(6, 5, 50);	#Thumbnail Image
    $worksheet->set_column(7, 6, 35);	#Alt Text
    $worksheet->set_column(8, 7, 30);	#Comments

	############################### HEADINGS
	$worksheet->write(6, 0, 'Chapter Number',$formatheader);
	$worksheet->write(6, 1, 'Chapter Name',$formatheader);
	$worksheet->write(6, 2, 'Page Number',$formatheader);
	$worksheet->write(6, 3, 'Figure name',$formatheader);
	$worksheet->write(6, 4, 'Image  Id',$formatheader);
	$worksheet->write(6, 5, 'Thumbnails',$formatheader);
	$worksheet->write(6, 6, 'Alt-Text',$formatheader);
	$worksheet->write(6, 7, 'Comments',$formatheader);
	###############################

	my $row = 7;
	foreach my $figskey(@figChWise)
	{
		my $xlsfignum = "";
		if($figlabelsaver{$figskey}){
			$xlsfignum = $figlabelsaver{$figskey};
		}
		my $xlsfigalttext = "";
		if($figaltsaver{$figskey}){
			$xlsfigalttext = $figaltsaver{$figskey};
		}
		$xlsfigalttext = XML::Entities::decode('all', $xlsfigalttext);
		$chtitle = XML::Entities::decode('all', $chtitle);
		my $xlsthimagename = "";
		if($thimagesaver{$figskey}){
			$xlsthimagename = $thimagesaver{$figskey};
		}
		my $PageNum = "";
		if($FigNumByPage{$figskey}){
			$PageNum = "$FigNumByPage{$figskey}";
		}
		$figskey =~ s/\.(\w+)$//s;
		
		$worksheet->set_row($row, 170,$imagedatacell);

		$worksheet->write($row, 0, "$finalfilename", $whitedatacell);
		$worksheet->write($row, 1, "$chtitle", $whitedatacell);
		$worksheet->write($row, 2, "$PageNum", $whitedatacell);
		$worksheet->write($row, 3, "$xlsfignum", $whitedatacell);
		$worksheet->write($row, 4, "$figskey", $whitedatacell);
		if((-e $xlsthimagename)){
			$worksheet->insert_image($row, 5, "$xlsthimagename");
		}else{
			$worksheet->write($row, 5, "", $whitedatacell);
		}
		$worksheet->write($row, 6, "$xlsfigalttext", $whitedatacell);
		$worksheet->write($row, 7, "",$whitedatacell);

		$row++;
	}
}
########################
sub write_log(){
	if($logtxt){
		open(TEMPFILE, ">${myfolder}\\MissedPara.log");
		print TEMPFILE "$logtxt";
		close(TEMPFILE);
	}
	$logtxt = "";
}

__END__

