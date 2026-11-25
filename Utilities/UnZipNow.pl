#!/usr/bin/perl -w
use strict;
use File::Basename;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

system("cls");

my $filename = "$ARGV[0]";

&extract_zip;


sub extract_zip(){
chomp($filename);
my $mainfilename = basename($filename);
my $myfolder = $filename;
$myfolder =~ s/$mainfilename//s;

my $zip = Archive::Zip->new();
unless ( $zip->read($filename) == AZ_OK ) { 
    die 'read error';
}

$zip->extractTree( '', "$myfolder/" );
}

__END__
#!/usr/bin/perl -w
use strict;
use File::Basename;
use Archive::Zip;

system("cls");

my $filename = "$ARGV[0]";
chomp($filename);


my $mainfilename = basename($filename);
my $myfolder = $filename;
$myfolder =~ s/$mainfilename//s;
$mainfilename =~ s/\.(\w+)$//s;
my $outfolder = "${myfolder}$mainfilename";

rmdir($outfolder);
mkdir($outfolder);


my $zip = Archive::Zip->new($filename);
foreach my $member ($zip->members)
{
    next if $member->isDirectory;
    (my $extractName = $member->fileName) =~ s{.*/}{};
    $member->extractToFileNamed("$outfolder/$extractName");
}
