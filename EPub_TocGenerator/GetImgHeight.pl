#!/usr/bin/perl -w
use strict;
use File::Path;
use File::Find;
use File::Copy;
use File::Basename;
use Image::Info qw(image_info dim);


system("cls");

my $username = Win32::LoginName;
$username=~s/\./ /g;
$username=uc($username);

my $myfolder = "$ARGV[0]";
chomp($myfolder);
my $myoutdir = "${myfolder}/Final";

rmtree($myoutdir);
mkdir($myoutdir);


if((!$ARGV[0])) {
    print "\nGetImgHeight.exe <Folder Name>, Try Again...\n\n";
    exit(0);
}

################################## VARIABLE DECLARATIONS ######################################
my ($filestr,$logtext,$count,$listoffiles,$extn,$imgname,$filename);
my (@dirlist,@imagelist,@filelist);
my %figlist;
$extn = qr/jpg|tif|png|gif/x;


##################################### CALL FUNCTIONS ##########################################
#print " \n\n ~~~~~~~~~~~~~~~~~~ Welcome ${username} ~~~~~~~~~~~~~~~~~~\n\n";
########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%40s%15s\n","*","DEVELOPED BY : Saiful Islam","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################

print ("\n\nProcessing.");
find sub { push(@dirlist, $File::Find::name)}, "$myfolder";

foreach my $entry(@dirlist)
{

	if($entry =~ /\.xhtml$/s){
		push(@filelist,$entry);
	}elsif($entry =~ /\.$extn$/s){
		push(@imagelist,$entry);
	}
}

foreach my $imgname(@imagelist)
{
	if(-e $imgname){
		my @getimgdim = get_imagedim("$imgname");
		# my $actimgname = basename($imgname);
		my $actimgname = $imgname;
		$actimgname =~ s/(.*?)\/images\/(.*?)/images\/$2/s;
		my $maniheight = $getimgdim[1]/17;
		$maniheight =~ s/([0-9]+)\.([0-9])([0-9])(.*?)$/$1\.$2$3/s;
		$figlist{$actimgname}=$maniheight;
		$logtext .= "$actimgname\t-->\tActual Height: $getimgdim[1]\tCalculated Height: $maniheight\n";
		# print (".");
	}
}

#foreach my $xentry(keys %figlist){
#	$logtext .= "$xentry\t-->\t$figlist{$xentry}\n";
#}

foreach my $xmlname(@filelist)
{
	if(-e $xmlname){
		$filestr=&read_file($xmlname);
		while($filestr =~ /<figure(.*?)<\/figure>/s){
			my $imgtext = $1;
			$imgtext =~ s/<img/<figimg/g;

			$filestr =~ s/<figure(.*?)<\/figure>/<Xfigure$imgtext<\/figure>/s;
		}
		$filestr =~ s/<Xfigure/<figure/g;

		while($filestr =~ /<figcaption(.*?)<\/figcaption>/s){
			my $fgcaptext = $1;
			$fgcaptext =~ s/<figimg/<img/g;

			$filestr =~ s/<figcaption(.*?)<\/figcaption>/<Xfigcaption$fgcaptext<\/figcaption>/s;
		}
		$filestr =~ s/<Xfigcaption/<figcaption/g;

		while($filestr =~ /<table(.*?)<\/table>/s){
			my $tbltext = $1;
			$tbltext =~ s/<figimg/<img/g;

			$filestr =~ s/<table(.*?)<\/table>/<Xtable$tbltext<\/table>/s;
		}
		$filestr =~ s/<Xtable/<table/g;

		while($filestr =~ /<p(.*?)<\/p>/s){
			my $ptext = $1;
			$ptext =~ s/<figimg/<img/g;

			$filestr =~ s/<p(.*?)<\/p>/<Xp$ptext<\/p>/s;
		}
		$filestr =~ s/<Xp/<p/g;

		while($filestr =~ /<li(.*?)<\/li>/s){
			my $litext = $1;
			$litext =~ s/<figimg/<img/g;

			$filestr =~ s/<li(.*?)<\/li>/<Xli$litext<\/li>/s;
		}
		$filestr =~ s/<Xli/<li/g;

		while($filestr =~ /<img([^<>]+)\/>/s){
			my $imgdata = $1;
			$imgdata =~ s/ style=\"([^\"]+)\"//g;
			if($imgdata =~ /src=\"([^\"]+)\"/s){
				my $tempimgname = $1;
				print (".");
				# $tempimgname = basename($tempimgname);
				foreach my $xentry(keys %figlist){
					if($tempimgname eq $xentry){
						$imgdata .= " style=\"vertical-align:middle;height:$figlist{$xentry}em\"";
					}
				}
			}
			$imgdata =~ s/([ ]+)/ /g;
			$filestr =~ s/<img([^<>]+)\/>/<Ximg$imgdata\/>/s;
		}
		# print ("\n");
		$filestr =~ s/<Ximg/<img/g;
		$filestr =~ s/<figimg/<img/g;


		if($xmlname =~ /toc\.xhtml/){
			$filestr=&read_file($xmlname);
			while($filestr =~ /<img([^<>]+)\/>/s){
				my $imgdata = $1;
				$imgdata =~ s/ style=\"([^\"]+)\"//g;
				if($imgdata =~ /src=\"([^\"]+)\"/s){
					my $tempimgname = $1;
					print (".");
					foreach my $xentry(keys %figlist){
						if($tempimgname eq $xentry){
							$imgdata .= " style=\"vertical-align:middle;height:$figlist{$xentry}em\"";
						}
					}
				}
				$imgdata =~ s/([ ]+)/ /g;
				$filestr =~ s/<img([^<>]+)\/>/<Ximg$imgdata\/>/s;
			}
			$filestr =~ s/<Ximg/<img/g;
			############################
			while(($filestr =~ /<li class=\"contentsH([1-6])\"><a ([^<>]+)><b>Figure ([^<>]+)<\/b> (.*?)<\/a><\/li>/s)||($filestr =~ /<li class=\"contentsH([1-6])\"><a ([^<>]+)>Figure ([0-9\.\-]+) (.*?)<\/a><\/li>/s)){
				my $figname = $3;
				my $figdata = $4;

				my $tagcnt = 1;
				my %tagholder;
				while($figdata =~ /<([^>]+)>/s){
					my $temptag = "<$1>";
					$tagholder{"\&tag$tagcnt\;"} = "$temptag";
					$figdata =~ s/<([^>]+)>/\&tag$tagcnt\;/s;
					$tagcnt++;
				}
				
				my $FLAG = "TRUE";
				my $figcap = "";
				$count = 1;
				while($figdata =~ s/(.)//s){
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

				while($figcap =~ /\&tag([0-9]+)\;/s){
					my $tempkey = "\&tag$1\;";
					my $keyvalue = $tagholder{"$tempkey"};
					$figcap =~ s/\&tag([0-9]+)\;/$keyvalue/s;
				}
				
				$filestr =~ s/<li class=\"contentsH([1-6])\"><a ([^<>]+)><b>Figure ([^<>]+)<\/b> (.*?)<\/a><\/li>/<Xli class=\"contentsH$1\"><a $2><b>Figure $3<\/b> $figcap<\/a><\/li>/s;
				$filestr =~ s/<li class=\"contentsH([1-6])\"><a ([^<>]+)>Figure ([0-9\.\-]+) (.*?)<\/a><\/li>/<Xli class=\"contentsH$1\"><a $2><b>Figure $3<\/b> $figcap<\/a><\/li>/s;
			}


			$filestr =~ s/<Xli/<li/g;
		}
		
		$filename = basename($xmlname);
		&write_file($filename,$filestr);
		$filestr = "";
	}else{
		print "$xmlname doesn't FOUND!!!\n";
	}
}

&write_figsheight;

######################################### FUNCTIONS #########################################

########################
sub read_file(){
	my ($filename)=@_;
	open(INFILE, "$filename") or die "Can't open '$filename': $!";;
	my @filearr=<INFILE>;
	close(INFILE);
	my $filestring=join("",@filearr);
	$filestring =~ s/\r*\n/\n/g;
	return($filestring);
}
########################
sub get_imagedim()
{
	my ($imgname)=@_;

	my $info = image_info("$imgname");
	if (my $error = $info->{error}) {
		die "Can't parse image info: $error\n";
	}

	my($w, $h) = dim($info);
	return($w,$h);
}

########################
sub write_figsheight(){
	open(OUTFILE,">${myoutdir}/FileNames.txt") || die "cann't find the file\n";
	print OUTFILE "$logtext\n";
	close(OUTFILE);
}
########################
sub write_file(){
	my ($xhtmlfilename,$filedata)=@_;
	open(OUTFILE,">${myoutdir}/$xhtmlfilename") || die "cann't find the file\n";
	print OUTFILE "$filedata\n";
	close(OUTFILE);
}
########################



__END__

