#!/usr/bin/perl -w
use strict;
use File::Path;
use File::Find;
use File::Copy;
use File::Basename;

system("cls");
$ENV{PATH}  = 'c:\\ImageMagick;c:\\gs\\gs9.25\\bin';
########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%47s%8s\n","*","DEVELOPED BY : Saiful Islam (Wiley Books)","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################

my (@dirlist,@imagelist);

my $myfolder = "$ARGV[0]";
chomp($myfolder);
my $outdir = "${myfolder}\\Thumbs";
rmtree($outdir);
mkdir($outdir);

print "PROCESSING .....\n\n";
&read_folder($myfolder);
&conv_img($outdir);

print "\n\nDONE !!!\n\n";
########################
sub read_folder(){
	my ($mydir)=@_;
	find sub { push(@dirlist, $File::Find::name)}, "$mydir";
	foreach my $entry(@dirlist)
	{
        next if($entry =~ /\.rsrc/);
        next if($entry =~ /\.\./);

		if($entry =~ /\.eps$/s){
			push(@imagelist,$entry);
		}
	}
}
########################
sub conv_img(){
	my ($mythumbdir) = @_;
	foreach my $fname(@imagelist)
	{
		my $thumbimgname = basename($fname);
		$thumbimgname =~ s/\.(\w+)$//s;
		$thumbimgname = "$mythumbdir\\${thumbimgname}.jpg";
		if(!(-e $thumbimgname)){
			# system("convert -density 300 $fname -resize 200x200 -units pixelsperinch -density 300 $thumbimgname");
			system("convert -density 300 $fname -units pixelsperinch -density 300 $thumbimgname");
		}
	}
}
