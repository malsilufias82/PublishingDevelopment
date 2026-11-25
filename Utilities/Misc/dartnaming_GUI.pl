#!/usr/bin/perl -w
use strict;
use File::Path;
use File::Copy;
use File::Find;
use Tk;

system("cls");
my $myfolder;

####################################################
# Main Window
my $mw = new MainWindow(-background => 'pink',-title => "Aptara Tool Kit");
$mw->geometry('600x450'); ### Size of Window
my $frm_name = $mw -> Frame(-background => 'pink');
my $lab = $frm_name -> Label(-text=>"Enter path:",-foreground => 'black',-background => 'pink');
my $ent = $frm_name -> Entry(-width=>41);
my $but = $frm_name -> Button(-underline=>0,-text=>"Submit",-foreground => 'black',-background => 'red', -command =>\&push_button);

#Text Area
my $textarea = $mw -> Frame(-background => 'pink');
#my $txt = $textarea -> Text(-width=>40, -height=>10);
my $txt = $textarea -> Text(-height=>10);
my $srl_y = $textarea -> Scrollbar(-orient=>'v',-background => 'gray',-command=>[yview => $txt]);
my $srl_x = $textarea -> Scrollbar(-orient=>'h',-background => 'gray',-command=>[xview => $txt]);
$txt -> configure(-yscrollcommand=>['set', $srl_y],
				  -xscrollcommand=>['set',$srl_x]);

#Buttons
my $mybuttons = $mw -> Frame(-background => 'pink');
my $resetbutt = $mybuttons -> Button(-underline=>1,-text => "Reset",-foreground => 'black',-background => 'green', -command => \&reset);
my $exitbutt = $mybuttons -> Button(-underline=>0,-text => "Quit",-foreground => 'black',-background => 'orange', -command => sub{exit});
$exitbutt->bind('Q'=>sub{exit});

#Geometry Management
$lab -> grid(-row=>1,-column=>1);
$ent -> grid(-row=>1,-column=>2);
$but -> grid(-row=>1,-column=>3,-padx=>13,-pady=>13);
#$frm_name -> grid(-row=>1,-column=>1);
$frm_name -> place(-x=>18,-y=>50);

$txt -> grid(-row=>1,-column=>1);
$srl_y -> grid(-row=>1,-column=>2,-sticky=>"ns");
$srl_x -> grid(-row=>2,-column=>1,-sticky=>"ew");
$textarea -> grid(-row=>3,-column=>1,-columnspan=>2,-pady=>13);

$resetbutt -> grid(-row=>1,-column=>2,-padx=>13,-pady=>13);
$exitbutt -> grid(-row=>1,-column=>3,-padx=>13,-pady=>13);
$mybuttons -> grid(-row=>5,-column=>1,-columnspan=>2);


MainLoop;

## Functions
#This function will be executed when the button is pushed
sub push_button {
	$myfolder = $ent -> get();

my $mydesdir = "FINAL";
my $myoutdir = "${myfolder}/${mydesdir}";

rmtree($myoutdir);
mkdir($myoutdir);

my (@dirlist,@fmmatter);
my $i=1;

$myfolder =~ s/\\/\//g;
$txt -> insert('end',"The selected path Folder contains follwing items:\n\n");
find sub { push(@dirlist, $File::Find::name)}, "$myfolder";


############################### FMMATTER ###################################################
foreach my $entry(@dirlist)
{
	$entry=~s/\Q$myfolder\E//;
	$entry=~s/\Q$mydesdir\E//;
    $entry=~s/^\///;
    $entry=~s/\.rsrc//;
    push(@fmmatter,$entry) if(($entry =~ /ffirs.pdf|FMTOC.pdf/s));
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
	copy("${myfolder}/$entry","${myoutdir}/c0$i.pdf");
	$txt -> insert('end',"$entry copied as c0$i.pdf\n");
	$i++;
}
############################################################################################

############################### CHAPTERS ###################################################
foreach my $entry(@dirlist)
{
	if(($entry =~ /c([0-9]+).pdf|c([0-9]+)(.*?).pdf/s))
	{
		my $temp = $entry;
		if($i<=9)
		{
			$temp =~ s/c([0-9]+).pdf/c0$i.pdf/;
			$temp =~ s/c([0-9]+)(.*?).pdf/c0$i.pdf/;
		}
		else
		{
			$temp =~ s/c([0-9]+).pdf/c$i.pdf/;
			$temp =~ s/c([0-9]+)(.*?).pdf/c$i.pdf/;
		}
		copy("${myfolder}/$entry","${myoutdir}/$temp");
		$txt -> insert('end',"$entry copied as $temp\n");
		$i++;
	}
}
############################################################################################

############################### BMMATTERS ###################################################
foreach my $entry(@dirlist)
{
	if(($entry =~ /(^BM(\w+).pdf$)|(^bm(\w+).pdf$)|(^B(\w+).pdf$)|(^b(\w+).pdf$)/s))
	{
		my $temp = $entry;
		$temp =~ s/BM(\w+).pdf/c$i.pdf/;
		$temp =~ s/b(\w+).pdf/c$i.pdf/;
		copy("${myfolder}/$entry","${myoutdir}/$temp");
		$txt -> insert('end',"$entry copied as c$i.pdf\n");
		$i++;
	}
}
############################################################################################

$txt -> insert('end',"\n\nCONGRATS!!! Renaming Done!\n");

} ## END ####
####################################################

sub reset {
    $txt-> delete('1.0','end');
	$ent-> delete('1.0','end');
}
