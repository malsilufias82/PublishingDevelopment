#!/usr/bin/perl -w
use strict;
use File::Path;
use File::Copy;
use File::Find;
use Tk;

system("cls");
my (@dirlist,@finallist);
my ($myfolder,$myprefix,$mycount,$mysuffix,$mydesdir,$myoutdir);

####################################################
# Main Window
my $mw = new MainWindow(-background => 'pink',-title => "R-Name");
$mw->geometry('600x450'); ### Size of Window
$mw->resizable(0,0);
my $frm_name = $mw -> Frame(-background => 'pink');
my $lab = $frm_name -> Label(-text=>"Enter path:",-foreground => 'black',-background => 'pink');
my $path = $frm_name -> Entry(-width=>41);

#Geometry Management
$lab -> grid(-row=>1,-column=>1);
$path -> grid(-row=>1,-column=>2);
#$frm_name -> grid(-row=>1,-column=>1,-pady=>13);
$frm_name -> place(-x=>10,-y=>20);

#My Labels
my $mylabels = $mw -> Frame(-background => 'pink');
my $prefixlab = $mylabels -> Label(-text=>"Prefix",-width => 22,-foreground => 'black',-background => 'pink');
my $countlab = $mylabels -> Label(-text=>"Counter starts from",-width => 18,-foreground => 'black',-background => 'pink');
my $suffixlab = $mylabels -> Label(-text=>"Suffix",-width => 22,-foreground => 'black',-background => 'pink');

#Geometry Management
$prefixlab -> grid(-row=>1,-column=>1);
$countlab -> grid(-row=>1,-column=>2);
$suffixlab -> grid(-row=>1,-column=>3);
#$mylabels -> grid(-row=>2,-column=>1,-pady=>3);
$mylabels -> place(-x=>1,-y=>100);

#My Inputs
my $myinputs = $mw -> Frame(-background => 'pink');
my $prefixent = $myinputs -> Entry(-width=>15);
my $countent = $myinputs -> Entry(-width=>8);
my $suffixent = $myinputs -> Entry(-width=>15);

#Geometry Management
$prefixent -> grid(-row=>1,-column=>1,-padx=>25);
$countent -> grid(-row=>1,-column=>2,-padx=>25);
$suffixent -> grid(-row=>1,-column=>3,-padx=>25);
#$myinputs -> grid(-row=>3,-column=>1,-pady=>13);
$myinputs -> place(-x=>1,-y=>120);

#Submit Button
my $subbutt = $mw -> Frame(-background => 'pink');
my $but = $subbutt -> Button(-underline=>0,-text=>"Submit",-foreground => 'white',-background => 'blue', -command =>\&push_button);

#Geometry Management
$but -> grid(-row=>1,-column=>1,-columnspan=>3);
#$subbutt -> grid(-row=>4,-column=>1);
$subbutt -> place(-x=>460,-y=>104);

#Buttons
my $mybuttons = $mw -> Frame(-background => 'pink');
my $resetbutt = $mybuttons -> Button(-underline=>1,-text => "Reset",-foreground => 'black',-background => 'green', -command => \&reset);
my $exitbutt = $mybuttons -> Button(-underline=>0,-text => "Quit",-foreground => 'black',-background => 'orange', -command => sub{exit});

#Geometry Management
$but -> grid(-row=>1,-column=>3,-padx=>13,-pady=>13);
$resetbutt -> grid(-row=>1,-column=>2,-padx=>13,-pady=>13);
$exitbutt -> grid(-row=>1,-column=>3,-padx=>13,-pady=>13);
#$mybuttons -> grid(-row=>5,-column=>1,-columnspan=>2);
$mybuttons -> place(-x=>240,-y=>370);

#Text Area
my $textarea = $mw -> Frame(-background => 'pink');
#my $display = $textarea -> Text(-width=>40, -height=>10);
my $display = $textarea -> Text(-height=>10);
my $srl_y = $textarea -> Scrollbar(-orient=>'v',-background => 'gray',-command=>[yview => $display]);
my $srl_x = $textarea -> Scrollbar(-orient=>'h',-background => 'gray',-command=>[xview => $display]);
$display -> configure(-yscrollcommand=>['set', $srl_y],-xscrollcommand=>['set',$srl_x]);

#Geometry Management
$display -> grid(-row=>1,-column=>1);
$srl_y -> grid(-row=>1,-column=>2,-sticky=>"ns");
$srl_x -> grid(-row=>2,-column=>1,-sticky=>"ew");
#$textarea -> grid(-row=>3,-column=>1,-columnspan=>2,-pady=>13);
$textarea -> place(-x=>10,-y=>200);

MainLoop;

#######################################################################################################
											#FUNCTIONS#
#######################################################################################################
#######################################################################################################
sub push_button
{
	$myfolder = $path -> get();
	$myprefix = $prefixent -> get();
	$mycount = $countent -> get();
	$mysuffix = $suffixent -> get();
	my $mypprefix = $myprefix;
	$myfolder =~ s/\\/\//g;
    $mydesdir = "FINAL";
	$myoutdir = "${myfolder}/${mydesdir}";
	rmtree($myoutdir);
	mkdir($myoutdir);
	find sub { push(@dirlist, $File::Find::name)}, "$myfolder";
	############### To obtain number of digits in the supplied number ####################
	my $mynum = $mycount;
	my ($numrem,$nod);
	while(($mynum ne 0))
	{
		$numrem = $mynum % 10;
		$mynum = $mynum/10;
		#$display -> insert('end',"$mynum\t ->\t $numrem\n");
		last if($numrem eq 0);
		$nod++;
	}
	#$display -> insert('end',"\n\nNumber of digits in $mycount: $nod\n");
	######################################################################################

	#$myprefix = $myprefix."000" if($nod eq 1);
	#$myprefix = $myprefix."00" if($nod eq 2);
	#$myprefix = $myprefix."0" if($nod eq 3);

	######################################################################################
	foreach my $entry(@dirlist){
		$entry =~ s/\Q$myfolder\E//;
		$entry=~s/^\///;
		next if(($entry =~ /\.(DS_Store|rsrc|rsrc(.*?)|\_(.*?))$/));
		push(@finallist, $entry) if($entry =~ /(.*?)\.(.*?)/);
	}
	foreach my $entry(@finallist){
		if(($mycount <= 9))
		{
			$myprefix = $mypprefix."000";
		}
		elsif(($mycount > 9)&($mycount <= 99))
		{
			$myprefix = $mypprefix."00";
		}
		else
		{
			$myprefix = $mypprefix."0";
		}
		copy("${myfolder}/$entry","${myoutdir}/$myprefix$mycount$mysuffix");
		$display -> insert('end',"$entry copied as -> $myprefix$mycount$mysuffix\n");
		$mycount++;
	}
}
#######################################################################################################

#######################################################################################################
sub reset {
	$path-> delete('0.0','end');
	$prefixent-> delete('0.0','end');
	$countent-> delete('0.0','end');
	$suffixent-> delete('0.0','end');
	$display-> delete('0.0','end');
	$mycount="";
	delete @dirlist[0 .. $#dirlist];
	delete @finallist[0 .. $#finallist];
}
#######################################################################################################
