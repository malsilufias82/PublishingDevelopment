#!/usr/bin/perl -w
use strict;
use File::Basename;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
use HTML::Entities;
use HTML::Entities::Numbered;
use Text::Unidecode;
use PDF::API2;

system("cls");

########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%47s%8s\n","*","DEVELOPED BY : Saiful Islam (Wiley Books)","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################

################################## VARIABLE DECLARATIONS ######################################
my ($xlsname,$newxlsname,$metaans,$metadata,$metacontent,$logtxt);
my ($isbn,$pubdate,$title,$edition,$author,$year,$holder,$productline,$bisacsubject,$coursecode,$pagecount,$description,$category,$subcategory,$color,$dimensions);
my (@xlsmetakeys,@xmlmetakeys,@authorsID,@authorsName,@subjectID,@courseID,@pdflist);
my (%xlskeydata,%metakeydata,%metakeytype,%pagebypdf);
###############################################################################################

##################################### CALL FUNCTIONS ##########################################

print "Enter the \.xls file name with Path: ";
$xlsname = <STDIN>;
chomp($xlsname);
$newxlsname = basename($xlsname);
my $myfolder = $xlsname;
$myfolder =~ s/$newxlsname//s;
$newxlsname =~ s/\.(\w+)$//s;
$newxlsname .= "-new.xls";

&read_xls($xlsname);
&consolidate_xls();
	
print "\n\nDo you have *\_content\.xml (Y/N): ";
$metaans = getc();
chomp($metaans);


if(($metaans eq "Y")||($metaans eq "y")){
	getc();
	
	print "\n\nEnter the metadata\.xml file's path: ";
	$metadata = <STDIN>;
	chomp($metadata);

	$metacontent = &read_file($metadata);
	&extract_meta($metacontent);
	
	print "\n\nEnter the PDF file's Complete path: ";
	my $pdfpath = <STDIN>;
	chomp($pdfpath);

	&save_pdfPageNum($pdfpath);
}else{
	getc();
}


&gen_Excel();

# $logtxt .= "\n\nBODY PART\n************************\n";
# foreach my $entry(@xmlmetakeys){
	# $logtxt .= "$entry\t-->\t$metakeydata{$entry}\n";
# }

# &write_log();


###############################################################################################
##################################### FUNCTIONS DECLARATIONS ##########################################
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
sub read_xls(){
	my($excelfilename) = @_;
	
	# Read an existing file with ReadData
	my $parser   = Spreadsheet::ParseExcel->new();
	my $workbook = $parser->parse("$excelfilename");

	if ( !defined $workbook ) {
		die $parser->error(), ".\n";
	}
 
	my($xlskey,$keydata,$xlsval,$keyvalue);
	for my $worksheet ( $workbook->worksheets() ) {
		my ( $col_min, $col_max ) = $worksheet->col_range();
	 
		for my $col ( $col_min .. $col_max ) {
			$xlskey = $worksheet->get_cell(0, $col );
			$keydata = $xlskey->value();
			$xlsval = $worksheet->get_cell(1, $col );
			next unless $xlsval;
			push(@xlsmetakeys,$keydata);
			$keyvalue = $xlsval->value();
			
			$xlskeydata{$keydata} = "$keyvalue";
		}
	}
}
########################
sub consolidate_xls(){
	if(grep { $_ =~ /ISBN/ } keys %xlskeydata){
		$isbn = "$xlskeydata{\"ISBN\"}";
	}

	if(grep { $_ =~ /Date, consolidated release date\/ship/ } keys %xlskeydata){
		my $tdate = "$xlskeydata{\"Date, consolidated release date\/ship\"}";
		$tdate =~ s/([0-9][0-9])\-([0-9][0-9])\-([0-9][0-9][0-9][0-9])/$3\-$2\-$1/s;
		$pubdate = "$tdate";
	}
	
	if(grep { $_ =~ /Full title/ } keys %xlskeydata){
		$title = "$xlskeydata{\"Full title\"}";
	}
	
	if(grep { $_ =~ /Edition number/ } keys %xlskeydata){
		$edition = "$xlskeydata{\"Edition number\"}";
	}
	
	foreach my $ent(@xlsmetakeys){
		if($ent =~ /Author ID \(Coltrane\)/s){
			push(@authorsID,$xlskeydata{$ent});
		}elsif($ent =~ /Author full name/s){
			my $authname = "$xlskeydata{$ent}";
			my @authcompname = split(/ /, $authname);
			my $sn = "$authcompname[$#authcompname]";
			my $fn = $authname;
			$fn =~ s/$sn//s;
			$authname = "$sn, $fn";
			push(@authorsName,$authname);
		}
	}
	
	if(grep { $_ =~ /Copyright year/ } keys %xlskeydata){
	$year = "$xlskeydata{\"Copyright year\"}";
	}
	
	$holder = "John Wiley \&amp\; Sons, Inc\.";
	
	if(grep { $_ =~ /Product line/ } keys %xlskeydata){
	$productline = "$xlskeydata{\"Product line\"}";
	}
	
	if(grep { $_ =~ /Subject \(BISAC \- Bookstore category\)/ } keys %xlskeydata){
	$bisacsubject = "$xlskeydata{\"Subject \(BISAC \- Bookstore category\)\"}";
	}

	my $mycourse = "FALSE";
	my $mycoursekey;
	foreach my $entry(sort keys %xlskeydata){
		if(($entry eq "Course")||($entry eq "Course ")){
			$mycoursekey = $entry;
			$mycourse = "TRUE";
		}
	}
	if($mycourse eq "TRUE"){
		$coursecode = "$xlskeydata{$mycoursekey}";
	}else{
		$coursecode = "";
	}
	
	if(grep { $_ =~ /Number of pages/ } keys %xlskeydata){
		$pagecount = "$xlskeydata{\"Number of pages\"}";
	}
	
	if(grep { $_ =~ /Description \(Higher Education\)/ } keys %xlskeydata){
		if($xlskeydata{"Description \(Higher Education\)"}){
			$description = "$xlskeydata{\"Description \(Higher Education\)\"}";
		}else{
			$description = "xx";
		}
	}elsif(grep { $_ =~ /Business rule descriptive copy/ } keys %xlskeydata){
		if($xlskeydata{"Business rule descriptive copy"}){
			$description = "$xlskeydata{\"Business rule descriptive copy\"}";
		}else{
			$description = "xx";
		}
	}else{
		$description = "xx";
	}
	$description =~ s/  / /g;
	$description =~ s/^ //g;
	$description = encode_entities($description);
	$description = name2hex($description);
	$description =~ s/([^[:ascii:]]+)/unidecode($1)/ge;
	$description =~ s/\-\-/\&\#x2013\;/g;

	foreach my $ent(@xlsmetakeys){
		if($ent =~ /Subject ([0-9]+)$/s){
			push(@subjectID,$xlskeydata{$ent});
		}
	}
	my $subcnt = 0;
	my $subtxt = "";
	while($subcnt le $#subjectID){
		$subtxt .= "$subjectID[$subcnt], ";
		$subcnt++;
	}
	$subtxt =~ s/, $//s;
	
	if($subtxt){
		$category = "$subtxt";
	}
	
	foreach my $ent(@xlsmetakeys){
		if($ent =~ /Course ([0-9]+)$/s){
			push(@courseID,$xlskeydata{$ent});
		}
	}
	my $coursecnt = 0;
	my $coursetxt = "";
	while($coursecnt le $#courseID){
		$coursetxt .= "$courseID[$coursecnt], ";
		$coursecnt++;
	}
	$coursetxt =~ s/, $//s;
	
	if($coursetxt){
		$subcategory = "$coursetxt";
	}
	
	$color = "color";

	my ($height,$width,$trimsize);
	if(grep { $_ =~ /Trim size\(Desc\.\)/ } keys %xlskeydata){
		$trimsize = "$xlskeydata{\"Trim size\(Desc\.\)\"}";
		if($trimsize =~ /([0-9\.]+) x ([0-9\.]+) cm\./s){
			$width = $1/2.54;
			$height = $2/2.54;
			$width =~ s/([0-9]+)\.([0-9][0-9])([0-9]+)/$1\.$2/s;
			$height =~ s/([0-9]+)\.([0-9][0-9])([0-9]+)/$1\.$2/s;
		}
		# $dimensions= "$width x $height";
		$dimensions= "8.5 x 11";
	}
}
########################
sub extract_meta(){
	my($metatext) = @_;
	$metatext =~ s/^(.*?)<contentUnit>([^<]+)<VVV\.contentUnitType>before table of contents<\/VVV\.contentUnitType>/<contentUnit>$2<VVV\.contentUnitType>before table of contents<\/VVV\.contentUnitType>/s;
	while($metatext =~ s/<contentUnit>(.*?)<\/contentUnit>/<XcontentUnit>$1<\/XcontentUnit>/s){
		my $contenttext = $1;
		my($contentUnitType,$contentUnitId,$contentTitle);
		if($contenttext =~ /<VVV.contentUnitType>([^<>]+)<\/VVV.contentUnitType>/s){
			$contentUnitType = $1;
		}
		if($contenttext =~ /<GGG.contentUnitId>([^<>]+)<\/GGG.contentUnitId>/s){
			$contentUnitId = $1;
		}
		if(($contenttext =~ /<VVV.title textformat=\"ASCII\">([^<>]+)<\/VVV.title>/s)||($contenttext =~ /<VVV.title>([^<>]+)<\/VVV.title>/s)){
			$contentTitle = $1;
		}
		if($contentUnitId){
			push(@xmlmetakeys,$contentUnitId);
			$metakeydata{$contentUnitId} = "$contentTitle";
			$metakeytype{$contentUnitId} = "$contentUnitType";
		}
	}
}
########################
sub gen_Excel(){
	my $workbook = Spreadsheet::WriteExcel->new("$myfolder$newxlsname");
	my $worksheet = $workbook->add_worksheet();
	$worksheet->add_write_handler(qr[\w]);
	
	my $ferrari = $workbook->set_custom_color(40, 204, 255, 204);
	my %headcell = (font => 'Arial',
					size => 10,
					color => 'black',
					bg_color => $ferrari,
					bold => 1,
					text_wrap => 1,
					align => 'left',
					border => '1',
				   );
	my %unboldcell = (font => 'Arial',
					size => 10,
					color => 'black',
					bg_color => 'white',
					# bold => 1,
					# text_wrap => 1,
					align => 'left',
					border => '1',
				   );
	my %isbncell = (font => 'Arial',
					size => 10,
					color => 'black',
					bg_color => 'white',
					# bold => 1,
					# text_wrap => 1,
					align => 'left',
					border => '1',
					num_format => "1",
				   );
	my %whitecell = (font => 'Arial',
					size => 10,
					color => 'black',
					bg_color => 'white'	 ,
					text_wrap => 1,
					align => 'left',
					border => '1',
				   );
	my $formatheader = $workbook->add_format(%headcell); # Add a format
	my $isbndatacell = $workbook->add_format(%isbncell); # Add a format
    my $unbolddatacell = $workbook->add_format(%unboldcell); # Add a format
	my $whitedatacell = $workbook->add_format(%whitecell); # Add a format

	$worksheet->set_column(0, 0, 11);	#TOC
	$worksheet->set_column(1, 1, 15);	#ID
	$worksheet->set_column(2, 2, 15);	#Type
    $worksheet->set_column(3, 3, 70);	#Title
    $worksheet->set_column(4, 4, 15);	#StartPage
    $worksheet->set_column(5, 5, 15);	#PageCount

	############################### HEADINGS
	$worksheet->write(0, 0, 'isbn',$unbolddatacell);
	$worksheet->write(0, 1, $isbn,$isbndatacell);

	$worksheet->write(1, 0, 'pubdate',$unbolddatacell);
	$worksheet->write(1, 1, $pubdate,$unbolddatacell);

	$worksheet->write(2, 0, 'title',$unbolddatacell);
	$worksheet->write(2, 1, $title,$unbolddatacell);

	$worksheet->write(3, 0, 'edition',$unbolddatacell);
	$worksheet->write(3, 1, $edition,$unbolddatacell);

	my $row = 4;
	my $author = "";
	my $authcnt = 0;
	while($authcnt le $#authorsID){
		$worksheet->write($row, 0, 'author',$unbolddatacell);
		$worksheet->write($row, 1, $authorsID[$authcnt],$unbolddatacell);
		$worksheet->write($row, 2, $authorsName[$authcnt],$unbolddatacell);
		$authcnt++;
		$row++;
	}

	$worksheet->write($row, 0, 'year',$unbolddatacell);
	$worksheet->write($row, 1, $year,$unbolddatacell);
	$row++;

	$worksheet->write($row, 0, 'holder',$unbolddatacell);
	$worksheet->write($row, 1, $holder,$unbolddatacell);
	$row++;

	$worksheet->write($row, 0, 'product-line',$unbolddatacell);
	$worksheet->write($row, 1, $productline,$unbolddatacell);
	$row++;

	$worksheet->write($row, 0, 'bisac-subject',$unbolddatacell);
	$worksheet->write($row, 1, $bisacsubject,$unbolddatacell);
	$row++;

	$worksheet->write($row, 0, 'course-code',$unbolddatacell);
	$worksheet->write($row, 1, $coursecode,$unbolddatacell);
	$row++;

	$worksheet->write($row, 0, 'page-count',$unbolddatacell);
	$worksheet->write($row, 1, $pagecount,$unbolddatacell);
	$row++;

	$worksheet->write($row, 0, 'description',$unbolddatacell);
	$worksheet->write($row, 1, $description,$unbolddatacell);
	$row++;

	$worksheet->write($row, 0, 'category',$unbolddatacell);
	$worksheet->write($row, 1, $category,$unbolddatacell);
	$row++;

	$worksheet->write($row, 0, 'subcategory',$unbolddatacell);
	$worksheet->write($row, 1, $subcategory,$unbolddatacell);
	$row++;

	$worksheet->write($row, 0, 'color',$unbolddatacell);
	$worksheet->write($row, 1, $color,$unbolddatacell);
	$row++;

	$worksheet->write($row, 0, 'dimensions',$unbolddatacell);
	$worksheet->write($row, 1, $dimensions,$unbolddatacell);
	$row++;
	###############################
	$worksheet->write($row, 0, 'TOC',$formatheader);
	$worksheet->write($row, 1, 'ID',$formatheader);
	$worksheet->write($row, 2, 'Type',$formatheader);
	$worksheet->write($row, 3, 'Title',$formatheader);
	$worksheet->write($row, 4, 'StartPage',$formatheader);
	$worksheet->write($row, 5, 'PageCount',$formatheader);
	$row++;

	foreach my $comp (@xmlmetakeys){
		$worksheet->write($row, 0, "toc-part",$whitedatacell);
		$worksheet->write($row, 1, $comp,$whitedatacell);
		my $comptype = "$metakeytype{$comp}";
		if($comptype eq "before table of contents"){
			$comptype = "fm_first";
		}elsif($comptype eq "table of contents"){
			$comptype = "fm_TOC";
		}elsif($comptype eq "between table of contents and preface"){
			$comptype = "fm_between";
		}elsif($comptype eq "preface"){
			$comptype = "fm_preface";
		}elsif($comptype eq "after table of contents/preface"){
			$comptype = "fm_last";
		}elsif($comptype eq "chapter"){
			$comptype = "chapter";
		}elsif($comptype eq "part"){
			$comptype = "part";
		}elsif($comptype eq "backmatter"){
			$comptype = "bm";
		}elsif($comptype eq "index"){
			$comptype = "bm_index";
		}
		$worksheet->write($row, 2, $comptype,$whitedatacell);
		$worksheet->write($row, 3, $metakeydata{$comp},$whitedatacell);
		$worksheet->write($row, 4, "",$whitedatacell);

		if(grep { $_ =~ /$comp/ } keys %pagebypdf){
			$worksheet->write($row, 5, "$pagebypdf{$comp}",$whitedatacell);
		}else{
			$worksheet->write($row, 5, "",$whitedatacell);
		}
		$row++;
	}

}
########################
sub save_pdfPageNum(){
	my($pdffolder) = @_;
	
	opendir(DIR,${pdffolder});
	while(my $entry = readdir(DIR))
	{
		next if($entry =~ /\.rsrc/);
		next if($entry =~ /\.\./);
        next if($entry =~ /\\\./);
        next if($entry =~ /\/\./);
		push(@pdflist,$entry) if($entry =~ /(.*?)\.pdf/s);
	}
	@pdflist = sort(@pdflist);

	foreach my $pdfentry(@pdflist){
		my $pdffile = PDF::API2->open("$pdffolder/$pdfentry");
		my $pdfpages = $pdffile->pages();
		$pdfentry =~ s/\.(\w+)$//s;
		$pagebypdf{$pdfentry} = "$pdfpages";
	}
}

########################
sub write_log(){
	if($logtxt){
		open(TEMPFILE, ">log.txt");
		print TEMPFILE "$logtxt";
		close(TEMPFILE);
	}
	$logtxt = "";
}
########################
