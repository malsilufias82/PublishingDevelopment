#!/usr/bin/perl -w
use strict;
use File::Path;
use File::Find;
use File::Copy;
use File::Copy::Recursive qw(dircopy);
use File::Basename;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use List::Util qw(first);

system("cls");

########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%47s%8s\n","*","DEVELOPED BY : Saiful Islam (Wiley Books)","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################

################################## VARIABLE DECLARATIONS ######################################
my ($foldername,$dirname,$myfolder,$outdir);
my (@dirlist,@subdirlist,@imagelist);
my $extn = qr/eps|jpg|tif|png|gif/x;
########################################################################################

$foldername = "$ARGV[0]";
chomp($foldername);
$dirname = basename($foldername);
$myfolder = $foldername;
$myfolder =~ s/$dirname//s;

# if(!(-d "c:\\support")){
	# mkdir("c:\\support");
# }
# $outdir = "c:\\support\\${dirname}-New";
$outdir = "${myfolder}${dirname}-New";

rmtree($outdir);
mkdir($outdir);

	print "PROCESSING !!!\n";
	&open_folder($foldername);
	foreach my $subdir(@dirlist){
		&read_subfolder("${foldername}\\$subdir");
		if(@imagelist){
			&copy_fromSubfolder($subdir);
			&gen_zip("$outdir\\$subdir");
			@imagelist = ();
			@subdirlist = ();
		}
	}
	print "\n\nAll zipped files are copied to $outdir\n\n";
	
system("start $outdir");

########################
sub open_folder{
	my ($mydir)=@_;
	opendir(DIR,${mydir});
    while(my $entry = readdir(DIR))
    {
        next if($entry =~ /\.rsrc/);
        next if($entry =~ /\.\./);
        next if($entry =~ /\./);
        push(@dirlist,$entry);
    }
	@dirlist = sort(@dirlist);
}

########################
sub copy_fromSubfolder(){
	my ($mydir)=@_;
	my $dname = basename($mydir);
	my $outsubdir = "$outdir\\$dname";
	rmtree($outsubdir);
	mkdir($outsubdir);
	if(-e "${foldername}\\${mydir}\\${dname}\.xml"){
		my $outinsubdir = "$outsubdir\\$dname";
		rmtree($outinsubdir);
		mkdir($outinsubdir);
		copy("${foldername}\\${mydir}\\${dname}\.xml","$outinsubdir\\");
		rmtree("$outinsubdir\\art");
		mkdir("${outinsubdir}\\art");
		dircopy("${foldername}\\${mydir}\\art","$outinsubdir\\art\\");
		rmtree("${outinsubdir}\\art\\web");
	}
}
########################
sub read_subfolder(){
	my ($mysubdir)=@_;
	find sub { push(@subdirlist, $File::Find::name)}, "$mysubdir";
	foreach my $entry(@subdirlist)
	{
        next if($entry =~ /\.rsrc/);
        next if($entry =~ /\.\./);

		if($entry =~ /\.$extn$/s){
			push(@imagelist,$entry);
		}
	}
}
########################
sub gen_zip(){
	my ($mydir)=@_;
	chomp($mydir);
	my $mainfoldername = basename($mydir);
	my $myfolder = $mydir;
	$myfolder =~ s/$mainfoldername//s;
	my $zipfilename = "$myfolder\\$mainfoldername\.zip";

	my $zip = Archive::Zip->new();
	$zip->addTree($mydir);
	$zip->writeToFileNamed($zipfilename);
	rmtree($mydir);
	# if ($zip->writeToFileNamed($zipfilename) == AZ_OK) 
	# {  
		# print "\n\nArchive created successfully!\n";
	# } 
}
__END__