#!/usr/bin/perl -w
use strict;
use File::Path;
use File::Copy;
use File::Find;
use Time::localtime;
use File::stat;
use File::Basename;
use Time::Piece;

system("cls");


my $before = Time::Piece->strptime("2001/01/01", "%Y/%m/%d");
my $now = localtime;

$diff = $now - $before;
print int($diff->days), " days since $before\n";
__END__


########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%40s%15s\n","*","DEVELOPED BY : Saiful Islam","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################
#my $myfolder = "$ARGV[0]";

#my (@dirlist,@fmmatter);

#find sub {push(@dirlist, $File::Find::name)}, @ARGV;

my $progname = basename($0);
print "$progname\n";

print "\n Last access   time: ", ctime( stat($progname)->atime );
print "\n Last modify   time: ", ctime( stat($progname)->mtime );
print "\n File creation time: ", ctime(stat($progname)->ctime);


__END___

my $metafile="metadata.xml";

open(META,">${metafile}");


print META "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE deliverable SYSTEM \"dart-content.dtd\">\n\n<!-- do not change : REDCAP-ORDERID:200197 -->\n<deliverable>\n<VVV.deliverableType>book</VVV.deliverableType>\n<VVV.compliesWith/>\n<VVV.compliesWithFilenaming/>\n<publisherInfo>\n<SSS.publisherName/>\n<VVV.imprint/>\n<SSS.publisherLocation>United States</SSS.publisherLocation>\n<SSS.publisherDivision>C</SSS.publisherDivision>\n<SSS.publishingEditorCode>076</SSS.publishingEditorCode>\n</publisherInfo>\n<publicationInfo>\n<SSS.ISBN>9781118334331</SSS.ISBN>\n<SSS.mediumCode>C</SSS.mediumCode>\n<VVV.DOI/>\n<SSS.publicationDate>2014-12-08</SSS.publicationDate>\n<SSS.publicationStatus>I</SSS.publicationStatus>\n<VVV.publicationNotes/>\n<SSS.languageCode>eng</SSS.languageCode>\n<titleInfo>\n<VVV.title textformat=\"ASCII\">Managerial Accounting</VVV.title>\n<GGG.titleLabel>book</GGG.titleLabel>\n<VVV.titleLabelOverride/>\n<VVV.titleForDisplay textformat=\"ASCII\"/>\n<GGG.titleSortKey>MANAGERIAL ACCOUNTING TOOLS FOR BUSINESS DECISION MAKING</GGG.titleSortKey>\n<VVV.titleSortKeyOverride/>\n<VVV.subtitle textformat=\"ASCII\">Tools for Business Decision Making</VVV.subtitle>\n</titleInfo>\n<edition>\n<VVV.editionOnCover textformat=\"ASCII\"/>\n<VVV.editionNumber>7</VVV.editionNumber>\n</edition>\n<VVV.revision/>\n<creator>\n<SSS.creatorId>2249</SSS.creatorId>\n<VVV.sequenceNumber>1</VVV.sequenceNumber>\n<SSS.creatorRole>Author</SSS.creatorRole>\n<GGG.personName>Jerry J. Weygandt</GGG.personName>\n<GGG.personNameInverted>Weygandt, Jerry J.</GGG.personNameInverted>\n<VVV.titlesBeforeNames/>\n<VVV.namesBeforeKey>Jerry J.</VVV.namesBeforeKey>\n<VVV.prefixToKey/>\n<VVV.keyNames>Weygandt</VVV.keyNames>\n<VVV.namesAfterKey/>\n<VVV.suffixToKey/>\n<VVV.lettersAfterNames/>\n<VVV.titlesAfterNames/>\n<GGG.creatorSortKey>WEYGANDT JERRY J</GGG.creatorSortKey>\n<VVV.creatorSortKeyOverride/>\n</creator>\n<rightsInfo>\n<SSS.copyrightYear>2015</SSS.copyrightYear>\n<VVV.copyrightLine>Copyright &copy; 2015, 2012, 2010, 2008, 2005, 2002, 2000 John Wiley &amp; Sons, Inc. All rights reserved.</VVV.copyrightLine>\n<SSS.marketRestrictions>restricted</SSS.marketRestrictions>\n<SSS.eRights/>\n</rightsInfo>\n<relationInfo>\n<SSS.productLine>4</SSS.productLine>\n<SSS.seriesCode/>\n<SSS.seriesDescription/>\n<VVV.isPartOf/>\n<SSS.audioISBN/>\n<SSS.clothISBN>9781118334331</SSS.clothISBN>\n<SSS.ebookISBN/>\n<SSS.onlineISBN/>\n<SSS.paperISBN/>\n<VVV.componentVolumes>\n<SSS.ISBN/>\n</VVV.componentVolumes>\n<relatedProduct>\n<VVV.relatedISBN/>\n<VVV.relatedMediumCode/>\n<VVV.relation/>\n</relatedProduct>\n<relatedProduct>\n<VVV.relatedISBN/>\n<VVV.relatedMediumCode/>\n<VVV.relation/>\n</relatedProduct>\n<relatedProduct>\n<VVV.relatedISBN/>\n<VVV.relatedMediumCode/>\n<VVV.relation/>\n</relatedProduct>\n<relatedProduct>\n<VVV.relatedISBN/>\n<VVV.relatedMediumCode/>\n<VVV.relation/>\n</relatedProduct>\n</relationInfo>\n<SSS.subjectJWS>AC20</SSS.subjectJWS>\n<SSS.subjectBISAC>BUS001040</SSS.subjectBISAC>\n<keywordGroup>\n<VVV.keyword/>\n</keywordGroup>\n<SSS.courseCode>AC0700</SSS.courseCode>\n</publicationInfo>\n<adminNotes/>\n";

############################### FMMATTER ###################################################
foreach my $entry(@dirlist)
{
	$entry=~s/\Q$myfolder\E//;
    $entry=~s/^\///;
    $entry=~s/\.rsrc//;
	push(@fmmatter,$entry) if(($entry =~ /ffirs.pdf/s));
}

foreach my $entry(@dirlist)
{
	push(@fmmatter,$entry) if(($entry =~ /ftoc.pdf/s));
}

foreach my $entry(@dirlist)
{
	push(@fmmatter,$entry) if(($entry =~ /fbetw.pdf/s));
}

foreach my $entry(@dirlist)
{
	push(@fmmatter,$entry) if(($entry =~ /fpref.pdf/s));
}

foreach my $entry(@dirlist)
{
	push(@fmmatter,$entry) if(($entry =~ /flast.pdf/s));
}

foreach my $entry(@fmmatter)
{
	my $mytemp;
	if(($entry =~ /ffirs.pdf/s))
	{
		$mytemp ="before table of contents";
	}
	elsif(($entry =~ /ftoc.pdf/s))
	{
		$mytemp ="table of contents";
	}
	else
	{
		$mytemp ="after table of contents\/";
	}
	print META "<contentUnit>\n <VVV.contentUnitType>$mytemp</VVV.contentUnitType>\n <VVV.compliesWithFilenaming>Books1.0</VVV.compliesWithFilenaming>\n <GGG.contentUnitId/>\n <VVV.contentUnitIdOverride/>\n <publicationInfoForUnit>\n <VVV.DOI/>\n <SSS.publicationDate/>\n <titleInfo>\n <VVV.title textformat=\"ASCII\">XXXXXXXXXXX</VVV.title>\n <GGG.titleLabel/>\n <VVV.titleLabelOverride/>\n <VVV.titleForDisplay textformat=\"ASCII\"/>\n <GGG.titleSortKey/>\n <VVV.titleSortKeyOverride/>\n <VVV.subtitle textformat=\"ASCII\"/>\n </titleInfo>\n </publicationInfoForUnit>\n <file>\n\t<VVV.compliesWithFilenaming>Books1.0</VVV.compliesWithFilenaming>\n\t<VVV.operatingSystem>Macintosh</VVV.operatingSystem>\n\t<VVV.path>pdf/$entry</VVV.path>\n\t<VVV.resourceVersion>archive</VVV.resourceVersion>\n\t<VVV.resourceUse>press PDF</VVV.resourceUse>\n\t<VVV.resourceType>publication file</VVV.resourceType>\n </file>\n <file>\n\t<VVV.compliesWithFilenaming>Books1.0</VVV.compliesWithFilenaming>\n\t<VVV.operatingSystem>Macintosh</VVV.operatingSystem>\n\t<VVV.path>Web-optimized/$entry</VVV.path>\n\t<VVV.resourceVersion>archive</VVV.resourceVersion>\n\t<VVV.resourceUse>online PDF</VVV.resourceUse>\n\t<VVV.resourceType>publication file</VVV.resourceType>\n </file>\n</contentUnit>\n";
}

############################################################################################
	
############################### CHAPTERS ###################################################
foreach my $entry(@dirlist)
{
	if(($entry =~ /c([0-9]+)(.*?).pdf/s))
	{
		my $cn = "c$1.pdf";
		my $ct = "$2";
		$ct =~ s/([a-z])([A-Z])/$1 $2/g;
		$ct =~ s/- ([A-Z])/-$1/g;
		#$ct =~ s/([A-Z]) ([A-Z])/$1$2/g;
		#print "$ct\n";
    		print META "<contentUnit>\n <VVV.contentUnitType>chapter</VVV.contentUnitType>\n <VVV.compliesWithFilenaming>Books1.0</VVV.compliesWithFilenaming>\n <GGG.contentUnitId/>\n <VVV.contentUnitIdOverride/>\n <publicationInfoForUnit>\n <VVV.DOI/>\n <SSS.publicationDate/>\n <titleInfo>\n <VVV.title textformat=\"ASCII\">$ct</VVV.title>\n <GGG.titleLabel/>\n <VVV.titleLabelOverride/>\n <VVV.titleForDisplay textformat=\"ASCII\"/>\n <GGG.titleSortKey/>\n <VVV.titleSortKeyOverride/>\n <VVV.subtitle textformat=\"ASCII\"/>\n </titleInfo>\n </publicationInfoForUnit>\n <file>\n\t<VVV.compliesWithFilenaming>Books1.0</VVV.compliesWithFilenaming>\n\t<VVV.operatingSystem>Macintosh</VVV.operatingSystem>\n\t<VVV.path>pdf/$cn</VVV.path>\n\t<VVV.resourceVersion>archive</VVV.resourceVersion>\n\t<VVV.resourceUse>press PDF</VVV.resourceUse>\n\t<VVV.resourceType>publication file</VVV.resourceType>\n </file>\n <file>\n\t<VVV.compliesWithFilenaming>Books1.0</VVV.compliesWithFilenaming>\n\t<VVV.operatingSystem>Macintosh</VVV.operatingSystem>\n\t<VVV.path>Web-optimized/$cn</VVV.path>\n\t<VVV.resourceVersion>archive</VVV.resourceVersion>\n\t<VVV.resourceUse>online PDF</VVV.resourceUse>\n\t<VVV.resourceType>publication file</VVV.resourceType>\n </file>\n</contentUnit>\n";
	}
}
############################################################################################

############################### BMMATTERS ###################################################
foreach my $entry(@dirlist)
{
	if(($entry =~ /(^BM(\w+).pdf$)|(^bm(\w+).pdf$)|(^B(\w+).pdf$)|(^b(\w+).pdf$)/s))
	{
		#print "$entry\n";
		print META "<contentUnit>\n <VVV.contentUnitType>backmatter</VVV.contentUnitType>\n <VVV.compliesWithFilenaming>Books1.0</VVV.compliesWithFilenaming>\n <GGG.contentUnitId/>\n <VVV.contentUnitIdOverride/>\n <publicationInfoForUnit>\n <VVV.DOI/>\n <SSS.publicationDate/>\n <titleInfo>\n <VVV.title textformat=\"ASCII\">XXXXXXXXXXX</VVV.title>\n <GGG.titleLabel/>\n <VVV.titleLabelOverride/>\n <VVV.titleForDisplay textformat=\"ASCII\"/>\n <GGG.titleSortKey/>\n <VVV.titleSortKeyOverride/>\n <VVV.subtitle textformat=\"ASCII\"/>\n </titleInfo>\n </publicationInfoForUnit>\n <file>\n\t<VVV.compliesWithFilenaming>Books1.0</VVV.compliesWithFilenaming>\n\t<VVV.operatingSystem>Macintosh</VVV.operatingSystem>\n\t<VVV.path>pdf/$entry</VVV.path>\n\t<VVV.resourceVersion>archive</VVV.resourceVersion>\n\t<VVV.resourceUse>press PDF</VVV.resourceUse>\n\t<VVV.resourceType>publication file</VVV.resourceType>\n </file>\n <file>\n\t<VVV.compliesWithFilenaming>Books1.0</VVV.compliesWithFilenaming>\n\t<VVV.operatingSystem>Macintosh</VVV.operatingSystem>\n\t<VVV.path>Web-optimized/$entry</VVV.path>\n\t<VVV.resourceVersion>archive</VVV.resourceVersion>\n\t<VVV.resourceUse>online PDF</VVV.resourceUse>\n\t<VVV.resourceType>publication file</VVV.resourceType>\n </file>\n</contentUnit>\n";
		}
}
############################################################################################
print META "<\/deliverable>";
close(META);