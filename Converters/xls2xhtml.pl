#!/usr/bin/perl -w
use strict;
use File::Path;
use File::Find;
use File::Basename;
use Spreadsheet::ParseExcel;
use HTML::Entities;
use HTML::Entities::Numbered;
use Text::Unidecode;

system("cls");

########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%47s%8s\n","*","DEVELOPED BY : Saiful Islam (Wiley Books)","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################

################################## VARIABLE DECLARATIONS ######################################
my ($xlsname,$celldata,$imgname,$alttext,$myfolder,$infile,$filename,$filestr,$myimage,$myimagename,$logtxt);
my (@dirlist,@filelist,@xlsfiglist);
my %altfigtext;
my $extn = qr/eps|jpg|tif|png|gif/x;

##################################### CALL FUNCTIONS ##########################################

print "Enter the \.xls file name with Path: ";
$xlsname = <STDIN>;
chomp($xlsname);

&read_xls($xlsname);

print "\n\nEnter the final \.xhtml\/\.xml files folder path: ";
$myfolder = <STDIN>;
chomp($myfolder);
my $outdir = "$myfolder\\FINAL";
rmtree($outdir);
mkdir($outdir);
&read_folder($myfolder);
print "\n\n";

foreach $infile(@filelist){
	$filename = basename($infile);
	$filestr = &read_file($infile);
	if($filename =~ /\.xhtml$/s){
		while($filestr =~ /<img ([^<>]+)\/>/s){
			my $imgattr = $1;
			if($imgattr =~ /src=\"([^\"]+)\"/s){
				$myimagename = $1;
				$myimagename = basename($myimagename);
				$myimage = $myimagename;
				$myimage =~ s/\.(\w+)$//s;
			}

			if((grep(/$myimage/, @xlsfiglist))){
				$imgattr =~ s/ alt=\"([^\"]+)\"//s;
				$imgattr =~ s/ alt=\"\"//s;
				if($altfigtext{$myimage}){
					$imgattr .= " alt=\"$altfigtext{$myimage}\"";
				}else{
					$imgattr .= " alt=\"\"";
					$logtxt .= "***Alt Text is NOT FOUND for \"$myimagename\" of $filename***\n";
				}
			}else{
				if(($logtxt !~ /\"$myimagename\" in $filename is not listed in AltText Excel Sheet/s)){
					$logtxt .= "\"$myimagename\" in $filename is not listed in AltText Excel Sheet\n";
				}
			}
			
			$filestr =~ s/<img ([^<>]+)\/>/<Ximg $imgattr\/>/s;
			$imgattr = "";
		}
		$filestr =~ s/<Ximg/<img/g;
	}elsif($filename =~ /\.xml$/s){
		while($filestr =~ /<mediaResource ([^<>]+)\/>/s){
			my $imgattr = $1;
			if($imgattr =~ /(.*?)href=\"([^\"]+)\"(.*?)$/s){
				$myimagename =~ s/(.*?)href=\"([^\"]+)\"(.*?)$/$2/s;
				my @imageID = split(/:/, $myimagename);
				$myimagename = $imageID[$#imageID];
				$myimagename = basename($myimagename);
				$myimage = $myimagename;
			}

			if((grep(/$myimage/, @xlsfiglist))){
				$imgattr =~ s/ alt=\"([^\"]+)\"//s;
				$imgattr =~ s/ alt=\"\"//s;
				if($altfigtext{$myimage}){
					$imgattr .= " alt=\"$altfigtext{$myimage}\"";
				}else{
					$imgattr .= " alt=\"\"";
					$logtxt .= "***Alt Text is NOT FOUND for \"$myimagename\" of $filename***\n";
				}
			}else{
				if(($logtxt !~ /\"$myimagename\" in $filename is not listed in AltText Excel Sheet/s)){
					$logtxt .= "\"$myimagename\" in $filename is not listed in AltText Excel Sheet\n";
				}
			}
			
			$filestr =~ s/<mediaResource ([^<>]+)\/>/<XmediaResource $imgattr\/>/s;
			$imgattr = "";
		}
		$filestr =~ s/<XmediaResource/<mediaResource/g;
	}
	
	$filestr =~ s/\&\#xFB01\;/fi/g;
	$filestr =~ s/\&\#xFB02\;/fl/g;
	$filestr =~ s/\&\#xA8\;u/\&\#x000FC\;/g;
	$filestr =~ s/\&\#xA8\;U/\&\#x000DC\;/g;
	
	open(OUTFILE, ">$outdir\\$filename");
	print OUTFILE "$filestr";
	close(OUTFILE);
	$logtxt .= "\n\n";
	$filestr = "";
}



&write_log();
&undef_all();

print "\n\nProcess Completed !!!!\n\n";

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
sub read_folder(){
	my ($mydir)=@_;
	find sub { push(@dirlist, $File::Find::name)}, "$mydir";
	foreach my $entry(@dirlist)
	{
        next if($entry =~ /\.rsrc/);
        next if($entry =~ /\.\./);

		if($entry =~ /\.(xhtml|xml)$/s){
			push(@filelist,$entry);
		}
	}
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
 
	for my $worksheet ( $workbook->worksheets() ) {
		my ( $row_min, $row_max ) = $worksheet->row_range();
		my ( $col_min, $col_max ) = $worksheet->col_range();
	 
		for my $row ( $row_min .. $row_max ) {
			for my $col ( $col_min .. $col_max ) {
			
				my $cell = $worksheet->get_cell( $row, $col );
				next unless $cell;
				$celldata = $cell->value();
				
				if($celldata){
					if($col == 3){
						$imgname = $celldata;
						$imgname =~ s/^(.*?)\.$extn$/$1/s;
						push(@xlsfiglist,$imgname);
					}elsif($col == 7){
						$alttext = $celldata;
						$alttext = encode_entities($alttext);
						$alttext = name2hex($alttext);
						$alttext =~ s/([^[:ascii:]]+)/unidecode($1)/ge;
						$altfigtext{$imgname} = "$alttext";
					}
				}else{
					$alttext = "";
				}
			}
		}
	}
}
########################
sub write_log(){
	if($logtxt){
		open(TEMPFILE, ">${myfolder}\\error.log");
		print TEMPFILE "$logtxt";
		close(TEMPFILE);
	}
	$logtxt = "";
}
########################
sub undef_all(){
	%altfigtext = ();
	@dirlist = ();
	@filelist = ();
}

#############################################################################
__END__