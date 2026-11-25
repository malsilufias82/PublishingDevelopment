#!/usr/local/bin/perl -w
use strict;
use File::Path;
use File::Copy;
use File::Find;


my $myfolder;
if (!$ARGV[0]) {
    print "Enter Path of TOC Tex Files: ";
    $myfolder = <STDIN>; 
    chomp($myfolder);
} else {
    $myfolder=$ARGV[0];
}


my (@dirlist,@myfiles,@filearr,@Data,@storeauthor,@indivauthor,@sepauthor);
my ($filestr,$texgrp,$authornames,$pagenum,$fname,$surname,$txtdata,$firstname,$initials);

$texgrp = qr{\{(?: (?> [^{}]+ )|(??{ $texgrp }))*\}}x;

&Step1_compinput();
&step2_standardfile();
&step3_extractauthors();
&step4_replace_FN_n_SN();

###################################### FUNCTIONS ###############################
sub Step1_compinput()
{
	opendir(DIR,$myfolder);
	while(my $entry = readdir(DIR))
	{
		push(@dirlist,$entry);
	}
	
	foreach my $entry(@dirlist)
	{
		if($entry =~ /.tex$|.TeX$|.TEX$|.Tex$/s)
		{
			push(@myfiles,$entry);
			print "$entry\n";
		}
	}
	
	foreach my $entry(@myfiles)
	{
		open(INFILE,"<$myfolder/$entry");
		@Data=<INFILE>;
		close(INFILE);
		push(@filearr,@Data);
	}
	
	$filestr=join("",@filearr);
	open(OUTFILE,">$myfolder/BMindx.idx");
	print OUTFILE $filestr;
	close(OUTFILE);
}

##################################################################

sub step2_standardfile()
{
	open(INPUT, "$myfolder/BMindx.idx");
	open(OUTPUT, ">$myfolder/BMindx-in.idx");
	@filearr=<INPUT>;
	close(INPUT);
	$filestr=join("",@filearr);
	while($filestr =~ /\n\\TOCentry|\n\\entry/s)
	{
		$filestr =~ s/\n\\TOCentry/\\indexentry/s;    
		$filestr =~ s/\n\\entry/\\indexentry/s;
		$filestr =~ s/\\indexentry($texgrp)($texgrp)\{([0-9]+)\/\[([0-9]+)\]\}/\\indexentry$2\{$4\}/s;
		$filestr =~ s/\\indexentry\{([0-9]+)\}($texgrp)($texgrp)/\\indexentry$3\{$1\}/s;
		$filestr =~ s/\\indexentry($texgrp)\{([0-9]+)\}($texgrp)/\\indexentry$3\{$2\}/s;
		$filestr =~ s/\\indexentry($texgrp)($texgrp)\{([0-9]+)\}/\\indexentry$2\{$3\}/s;
		$filestr =~ s/\\\\//g;
        $filestr =~ s/\n([a-zA-Z])/ $1/g;
		$filestr =~ s/(\w+)\n(\w+)/$1 $2/g;
		$filestr =~ s/(\w+) \n(\w+)/$1 $2/g;
		$filestr =~ s/(\w+)\n (\w+)/$1 $2/g;
		$filestr =~ s/, \n/, /g;
		$filestr =~ s/,\n (\w+)/, $2/g;
		$filestr =~ s/, \n (\w+)/, $2/g;
		$filestr =~ s/, and /, /g;
		$filestr =~ s/, And /, /g;
		$filestr =~ s/ and /, /g;
		$filestr =~ s/\$\\\!\$//g;
	}
	print OUTPUT $filestr;
	close(OUTPUT);
}


sub step3_extractauthors()
{
	open(INPUT,"<$myfolder/BMindx-in.idx");
	@filearr=<INPUT>;
	$filestr=join("",@filearr);
	open(OUTPUT,">$myfolder/BMindx.idx");
	close(INPUT);
	while($filestr=~/\\indexentry($texgrp)($texgrp)/g)
	{
		$authornames=$1;
		$pagenum = $2;
		$authornames =~ s/^\{//s;
		$authornames =~ s/\}$//s;
	    @storeauthor = split(/,[ ]+/,$authornames);

		foreach my $entry(@storeauthor)
		{
			my $finaldata = "\\indexentry{$entry}${pagenum}";
			chomp($finaldata);
			push(@indivauthor,$finaldata);
			print OUTPUT "$finaldata\n";
		}
	}
	unlink("$myfolder/BMindx-in.idx"); 
#	chdir($myfolder);
#	system("makeindex BMindx");
}

sub step4_replace_FN_n_SN()
{
	open(AUOUTPUT,">$myfolder/AUindx.idx");
	open(AUINOUTPUT,">$myfolder/AUINITindx.idx");
	open(UNAUIND,">$myfolder/UnSortedAuInd.txt");

	my $flag = 0;
	my ($test,$ttest);
	foreach my $entry(@indivauthor)
	{
		if($entry =~ / von der | van der | van | von | Paz De | del | de la | de | De | Da | da | le | Le | St | don | dos /s)
		{
			$surname = $entry;
			$surname =~ s/\{(.*?)( von der | van der | van | von | Paz De | del | de la | de | De | Da | da | le | Le | St | don | dos )(.*?)\}\{([0-9]+)\}/$2$3/s;
			$surname =~ s/\\indexentry //s;
			$firstname = $entry;
			$firstname =~ s/$surname//s;
			$firstname =~ s/\\indexentry\{(.*?)\}\{([0-9]+)\}/$1/s;
			$firstname =~ s/ $//s;
			$surname =~ s/^(.*?)$/$1,/s;
		}
		elsif($entry =~ /\\indexentry\{([A-Z])([a-z]+)\}\{([0-9]+)\}/s)
		{
			$surname = $entry;
			$surname =~ s/\\indexentry\{([A-Z])([a-z]+)\}\{([0-9]+)\}/$1$2/s;
			$firstname = "";
		}
		else
		{
			@sepauthor="";
			@sepauthor = split(/ /,$entry);
			$surname = $sepauthor[$#sepauthor];
			$surname =~ s/\}\{([0-9]+)\}$//s;
			$surname =~ s/^(.*?)$/$1,/s;
		
			$firstname = "";
			$initials = "";
			my $totelem = @sepauthor;
			$totelem--;
			my $i=0;
			while($i<$totelem)
			{
				$firstname = $firstname." $sepauthor[$i++]";
			}
		
			$firstname =~ s/ \\indexentry\{//s;
		}

		$initials = $firstname;
		$initials =~ s/\\([a-z])\{([a-z])\}/$2/g;
		$initials =~ s/\\\'\{([a-z])\}/$1/g;
		$initials =~ s/\\\`\{([a-z])\}/$1/g;
		$initials =~ s/\\\;\{([a-z])\}/$1/g;
		$initials =~ s/([A-Z])([a-z]+)/$1\./g;
		$pagenum = $entry;
		$pagenum =~ s/\\indexentry($texgrp)($texgrp)/$2/s;
		$pagenum =~ s/\{([0-9]+)\}/$1/s;

		print AUOUTPUT "\\indexentry\{$surname $firstname\}\{$pagenum\}\n";
		print AUINOUTPUT "\\indexentry\{$surname $initials\}\{$pagenum\}\n";
		print UNAUIND "$surname $initials, $pagenum\n";
		
	}
	close(AUOUTPUT);
	close(AUINOUTPUT);
	close(UNAUIND);
	chdir($myfolder);
	system("makeindex AUindx");
	system("makeindex AUINITindx");
	open(AUININD,"<$myfolder/AUINITindx.ind");
	open(AUINTXT,">$myfolder/AUINITindx.txt");
	@Data=<AUININD>;
	close(AUININD);
	$txtdata=join("",@Data);
	
	$txtdata =~ s/\\begin\{theindex\}\n\n//g;
	$txtdata =~ s/\\end\{theindex\}\n//g;
	$txtdata =~ s/ \\item //g;
	$txtdata =~ s/\t\\item //g;
	$txtdata =~ s/  / /g;
	$txtdata =~ s/\\indexspace\n\n/\\\\\\\\\n/g;
	$txtdata =~ s/\n\n \\\\\\\\/\\\\\\\\/g;
	$txtdata =~ s/\n\t//g;
	$txtdata =~ s/([0-9]+)\n/$1\\\\\n/g;
	$txtdata =~ s/^ //g;
	$txtdata =~ s/\n /\n/g;
	
	print AUINTXT "$txtdata\n";
    unlink("$myfolder/AUINITindx.ilg"); 
    unlink("$myfolder/AUINITindx.idx");
    unlink("$myfolder/AUindx.ilg"); 
    unlink("$myfolder/AUindx.idx");        
}
