#!/usr/bin/perl -w
use strict;
use File::Basename;
use Math::Roman qw/roman/;

push @INC, sub {
my (undef, $file) = @_;
if ( $file !~ /^PERL2EXE_STORAGE/ ) {
print "\n ADD THIS PRAGMA:\n";
print "#perl2exe_include \"$file\"\n\n";
}
return undef;
};

#perl2exe_include "Math/BigInt/Calc.pm"


system("cls");

########################################################################################
printf("\n\n\n\n%68s\n","********************************************************");
printf("%13s%45s%10s\n","*","THIS PROGRAM IS DESIGNED IN Perl 5.8.8","*");
printf("%13s%47s%8s\n","*","DEVELOPED BY : Saiful Islam (Wiley Books)","*");
printf("%68s\n\n\n","********************************************************");
########################################################################################

my $filename = "$ARGV[0]";
chomp($filename);

if (!$ARGV[0]) {
    print "\nAutoFilteration.exe <File Name>, Try Again...\n\n";
    exit(0);
}


################################## VARIABLE DECLARATIONS ######################################
my ($sqbrgrp,$curlbrgrp,$mainfilename,$filetype,$extn,$myfolder,$filestr,$refstr);
my (%mathInItal,%EnvInItal,%siUnit);
$curlbrgrp = qr{\{(?: (?> [^{}]+ )|(??{ $curlbrgrp }))*\}}x;
$sqbrgrp = qr{\[(?: (?> [^\[\]]+ )|(??{ $sqbrgrp }))*\]}x;

my $LMS = qr/plms|jlms|blms|topo|tlm/x;
my $VCH = qr/pmic|andp|lpor|qute|prop|adtp|adts|mats|mabi|mame|marc|mren|macp|aelm/x;
my $citeprops = qr/in|In|by|By|from|From|of|Ref\.|Refs\.|ref\.|refs\.|to|with/x;
# my $mypunc = qr/\.|,|:|\;/x;
my $myword = qr/and|is|work|works|Work|Works|See\~also|see\~also|see|See|see\~in\~particluar|See\~in\~particluar|for\~example|For\~example|e\.g\.,|e\.g\.| cf\.| cf\.\~also/x;

my $spauthwords = qr/van|Van|der|Der|De|de|den|Le|la|Da|da|Du|do|Al|Op/x;
my $spauthsuffix = qr/Jr|Snr|Sr|I|II|III|IV/x;

###############################################################################################

##################################### CALL FUNCTIONS ##########################################
$mainfilename = basename($filename);
$myfolder = $filename;
$myfolder =~ s/$mainfilename//s;
$extn = $mainfilename;
$extn =~ s/^(.*?)\.(\w+)$/$2/s;
$mainfilename =~ s/\.(\w+)$//s;
$filetype = $mainfilename;
$filetype =~ s/([0-9]+)//g;
# print "$mainfilename\t$filetype\t$extn\n\n";

	$filestr=&read_file($filename);
	$filestr =~ s/\\,/\&thinsp\;/g;
	$filestr =~ s/\\replaced($curlbrgrp)([^\{]+)($curlbrgrp)/\\replaced$1$3/g;
	if(($filestr =~ /\\deleted($curlbrgrp)/s)||($filestr =~ /\\added($curlbrgrp)/s)||($filestr =~ /\\replaced($curlbrgrp)($curlbrgrp)/s)){
		while($filestr =~ /\\deleted($curlbrgrp)/s){
			$filestr =~ s/\\deleted($curlbrgrp)//s;
		}
		while($filestr =~ /\\added($curlbrgrp)/s){
			my $tmptxt = $1;
			$tmptxt = &remove_flcurlbraces($tmptxt);
			$filestr =~ s/\\added($curlbrgrp)/$tmptxt/s;
		}
		while($filestr =~ /\\replaced($curlbrgrp)($curlbrgrp)/s){
			my $tmptxt = $1;
			$tmptxt = &remove_flcurlbraces($tmptxt);
			$filestr =~ s/\\replaced($curlbrgrp)($curlbrgrp)/$tmptxt/s;
		}
	}
	##########################
	if($filestr =~ /\\begin{abstract}(.*?)\\end{abstract}/s){
		my $abstext = $1;
		my $ptwords = qr/I|We|we|was|were|had|did|could|Could|might/x;
		$abstext =~ s/^($ptwords) /\\hl{$1} /g;
		$abstext =~ s/\n($ptwords) /\n\\hl{$1} /g;
		$abstext =~ s/ ($ptwords) / \\hl{$1} /g;
		$filestr =~ s/\\begin{abstract}(.*?)\\end{abstract}/\\begin{abstract}$abstext\\end{abstract}/s;
		$filestr =~ s/\\begin{document}/\\usepackage{soul}\n\\begin{document}/s;
	}
	##########################
	##########################
	if($filestr =~ /\\begin{tabular}/s){
		$filestr =~ s/\\begin{document}/\\usepackage{dcolumn}\n\\newcolumntype{d}\[1\]{D{\.}{\.}{\#1}}\n\\begin{document}/s;
	}
	##########################
	if(($filestr =~ /\\ce($curlbrgrp)/s)||($filestr =~ /\\ch($curlbrgrp)/s)){
		$filestr=&conv_chemformula($filestr);
	}
	##########################
	my $bibdata;
	if($filestr =~ /\\begin{thebibliography}(.*?)\\end{thebibliography}/s){
		$bibdata = "\\begin{thebibliography}$1\\end{thebibliography}";
		
		$filestr =~ s/\\begin{thebibliography}(.*?)\\end{thebibliography}/<bibliography>/s;
	}
	$filestr=&conv_mathInItalic($filestr);
	$filestr=&change_mathbraces($filestr);
	$filestr=&ins_imageonly($filestr);
	$filestr =~ s/<bibliography>/$bibdata/s;
	##########################

	while($filestr =~ /\\MakeLowercase($curlbrgrp)/s){
		my $lctext = $1;
		$lctext = &remove_flcurlbraces($lctext);
		my $nlctext = "\L$lctext\E";
		$filestr =~ s/\\MakeLowercase($curlbrgrp)/$nlctext/s;
	}

	##########################
	# $filestr=&conv_lists($filestr);
	##########################

	if($filetype =~ /($VCH|kin|admi|smll|adfm|zamm|adom|advs|adma)/is){
		$filestr =~ s/([ ]+)/ /g;
		$filestr =~ s/see also/see\~also/g;
		$filestr =~ s/See also/See\~also/g;
		$filestr =~ s/ cf\. also/ cf\.\~also/g;
		$filestr =~ s/for example/for\~example/g;
		$filestr =~ s/For example/For\~example/g;
		$filestr =~ s/see in particluar/see\~in\~particluar/g;
		$filestr =~ s/See in particluar/See\~in\~particluar/g;
		$filestr =~ s/ \n\\cite/ \\cite/g;
		$filestr =~ s/\n \\cite/ \\cite/g;
		$filestr =~ s/\n\\cite/ \\cite/g;
		$filestr =~ s/\~\\cite/ \\cite/g;
		$filestr =~ s/\\citenum/\\cite/g;
		$filestr =~ s/ \\cite($curlbrgrp) /\~\\cite$1 /g;
		$filestr =~ s/ \\cite($curlbrgrp)\n/\\cite$1\n/g;
		$filestr =~ s/([ ]+)/ /g;

		$filestr =~ s/ ($citeprops)\\cite($curlbrgrp)/ $1\~\\cite$2/g;
		$filestr =~ s/ ($citeprops) \\cite($curlbrgrp)/ $1\~\\cite$2/g;
		$filestr =~ s/\~($citeprops) \\cite($curlbrgrp)/ $1\~\\cite$2/g;
		$filestr =~ s/\~($citeprops)\~\\cite($curlbrgrp)/ $1\~\\cite$2/g;
		while($filestr =~ / ($citeprops)\~\\cite($curlbrgrp)/s){
			my $myprop = $1;
			my $citetxt = $2;
			
			$filestr =~ s/ ($citeprops)\~\\cite($curlbrgrp)/ $myprop\~\[\\cite$citetxt\]/s;
		}
		$filestr =~ s/\~\\cite/ \\cite/g;

		# while($filestr =~ / ($myword) \\cite($curlbrgrp)/s){
			# my $citedword = $1;
			# my $citetxt = $2;
		
			# $filestr =~ s/ ($myword) \\cite($curlbrgrp)/ $citedword\~\[\\Xcite$citetxt\]/s;
		# }
		while($filestr =~ /([^A-z])($myword) \\cite($curlbrgrp)/s){
			my $citedword = $2;
			my $citetxt = $3;
		
			$filestr =~ s/([^A-z])($myword) \\cite($curlbrgrp)/$1$citedword\~\[\\Xcite$citetxt\]/s;
		}
		while($filestr =~ / \\cite($curlbrgrp)(\.|,)/s){
			my $citetxt = $1;
		
			$filestr =~ s/ \\cite($curlbrgrp)(\.|,)/$2\\Xcite$citetxt/s;
		}
		while($filestr =~ /\\cite($curlbrgrp)(\.|,)/s){
			my $citetxt = $1;
		
			$filestr =~ s/\\cite($curlbrgrp)(\.|,)/$2\\Xcite$citetxt/s;
		}
		while($filestr =~ / \\cite($curlbrgrp)/s){
			my $citetxt = $1;
		
			$filestr =~ s/ \\cite($curlbrgrp)/\\Xcite$citetxt/s;
		}
		$filestr =~ s/\\Xcite/\\cite/g;
		$filestr =~ s/\.\.\\cite/\.\\cite/g;
		$filestr =~ s/, ,\\cite/,\\cite/g;
		$filestr =~ s/,,\\cite/,\\cite/g;
	}
	if($filetype =~ /zamm/is){
		while($filestr =~ /\\section($curlbrgrp)/s){
			my $sectxt = $1;
			$sectxt = "\U$sectxt\E";
			$filestr =~ s/\\section($curlbrgrp)/\\Xsection$sectxt/s;
		}
		while($filestr =~ /\\section\*($curlbrgrp)/s){
			my $sectxt = $1;
			$sectxt = "\U$sectxt\E";
			$filestr =~ s/\\section\*($curlbrgrp)/\\Xsection\*$sectxt/s;
		}
		$filestr =~ s/\\Xsection/\\section/g;
	}
	if($filetype =~ /($VCH|itor|zamm)/is){
		$filestr =~ s/(e|E)q\. \\eqref/Equation\~\\eqref/g;
		$filestr =~ s/(e|E)q\.\~\\eqref/Equation\~\\eqref/g;
		$filestr =~ s/(e|E)qs\. \\eqref/Equations\~\\eqref/g;
		$filestr =~ s/(e|E)qs\.\~\\eqref/Equations\~\\eqref/g;
		$filestr =~ s/equation \\eqref/Equation\~\\eqref/g;
		$filestr =~ s/equation\~\\eqref/Equation\~\\eqref/g;
		$filestr =~ s/equations \\eqref/Equations\~\\eqref/g;
		$filestr =~ s/equations\~\\eqref/Equations\~\\eqref/g;

		# $filestr =~ s/Eq\. \\ref($curlbrgrp)/Equation\~\(\\ref$1\)/g;
		# $filestr =~ s/Eq\.\~\\ref($curlbrgrp)/Equation\~\(\\ref$1\)/g;

		$filestr =~ s/Fig\. \\ref/Figure\~\\ref/g;
		$filestr =~ s/Fig\.\~\\ref/Figure\~\\ref/g;
		$filestr =~ s/Figs\. \\ref/Figures\~\\ref/g;
		$filestr =~ s/Figs\.\~\\ref/Figures\~\\ref/g;
	}
	
	##########################
	if($filestr =~ /\\begin{thebibliography}(.*?)\\end{thebibliography}/s){
		my $bibtxt = "\\begin{thebibliography}$1\\end{thebibliography}";
		if($bibtxt =~ /(\\bibinfo|\\bibfnamefont|\\bibfield)/s){
			$bibtxt=&conv_revTeX($bibtxt);

			$filestr =~ s/\\begin{thebibliography}(.*?)\\end{thebibliography}/$bibtxt/s;
		}
	}	
	##########################

	$filestr=&conv_reference($filestr);
	$filestr =~ s/\&thinsp\;/\\,/g;

	&write_newfile($filestr);
###############################################################################################


##################################### FUNCTIONS DEFINITIONS ##########################################
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
sub conv_reference(){
	my ($bibstr)=@_;
	if($bibstr =~ /\\begin{thebibliography}(.*?)\\end{thebibliography}/s){
		$refstr = $1;
		
		$refstr =~ s/\t/ /g;
		$refstr = &gen_conv($refstr);
		$refstr =~ s/\t(\s+)/ /g;
		$refstr =~ s/ \n/\n/g;
		
		if($filetype =~ /$LMS/is){
			$refstr = &lms_regrep($refstr);
		}else{
			$refstr = &nonlms_regrep($refstr);
		}
		$refstr =~ s/  / /g;
		$refstr =~ s/([ ]+)/ /g;
		$refstr =~ s/<percentage>/\\%/g;
		
		$bibstr =~ s/\\begin{thebibliography}(.*?)\\end{thebibliography}/\\begin{thebibliography}$refstr\n\n\\end{thebibliography}/s;
	}
	return($bibstr);
}
########################
sub conv_revTeX(){
	my ($bibstr)=@_;
	my $refprelim;
	
	$bibstr =~ s/  / /g;
	$bibstr =~ s/([ ]+)/ /g;
	$bibstr =~ s/\t/ /g;
	$bibstr =~ s/\\bibitemStop/\\XbibitemStop/g;
	$bibstr =~ s/\\bibitemNoStop/\\XbibitemNoStop/g;
	
	my $bibmatter;
	if($bibstr =~ /\\begin{thebibliography}(.*?)\\end{thebibliography}/s){
		$bibmatter = $1;
		if($bibmatter =~ /^\{(\d+)\}(.*?)\\bibitem(.*?)$/s){
			$refprelim = "\{$1\}";
			$refstr = "\\bibitem $3";
		}
		
		# $refprelim =~ s/\\providecommand(.*?)($sqbrgrp)($curlbrgrp)//g;
		# $refprelim =~ s/\\makeatletter//g;
		# $refprelim =~ s/\\let([^\n]+)\n//g;
		# $refprelim =~ s/\\expandafter([^\n]+)\n//g;
		# $refprelim =~ s/\\def([^\n]+)\n//g;
		$refstr =~ s/([\n]+)//g;
		$refstr =~ s/\\ \}/\} /g;
		$refstr =~ s/\~/ /g;
		$refstr =~ s/\\ / /g;
		$refstr =~ s/\%  \\BibitemOpen/\\BibitemOpen/g;
		$refstr =~ s/\\BibitemOpen /\n/g;
		$refstr =~ s/\\bibitem/\n\n\\bibitem/g;
		$refstr =~ s/  / /g;
		$refstr =~ s/([ ]+)/ /g;
		$refstr =~ s/\\textbf /\\textbf/g;
		$refstr =~ s/\\textit /\\textit/g;
		# $refstr =~ s/\\bibitem($curlbrgrp)/\\bibitem$1\n/g;
		# $refstr =~ s/\\bibitem ($sqbrgrp)($curlbrgrp)/\\bibitem$2/g;
		$refstr =~ s/\\([A-z]+)([\s]+)/\\$1/g;
		
		#########################
		$refstr =~ s/\\bibfield($curlbrgrp)([\s]+)/\\bibfield$1/g;
		while($refstr =~ /\\bibfield($curlbrgrp)($curlbrgrp)/s){
			my $bfield = $2;
			$bfield = &remove_flcurlbraces($bfield);
			$refstr =~ s/\\bibfield($curlbrgrp)($curlbrgrp)/$bfield/s;
		}
		#########################
		$refstr =~ s/\\bibinfo($curlbrgrp)([\s]+)/\\bibinfo$1/g;
		$refstr =~ s/\{\\it /\\textit\{/g;
		$refstr =~ s/\\(emph|textit|textbf)($curlbrgrp)/\{\\$1$2\}/g;
		while($refstr =~ /\\bibinfo($curlbrgrp)($curlbrgrp)/s){
			my $binfo = $2;
			$binfo = &remove_flcurlbraces($binfo);
			$refstr =~ s/\\bibinfo($curlbrgrp)($curlbrgrp)/$binfo/s;
		}
		#########################
		$refstr =~ s/\\bibnamefont([^\{]+)($curlbrgrp)/\\bibnamefont$2/g;
		$refstr =~ s/\\bibfnamefont([^\{]+)($curlbrgrp)/\\bibfnamefont$2/g;
		while($refstr =~ /\\bibfnamefont($curlbrgrp)/s){
			my $auname = $1;
			$auname = &remove_flcurlbraces($auname);
			$refstr =~ s/\\bibfnamefont($curlbrgrp)/$auname/s;
		}
		while($refstr =~ /\\bibnamefont($curlbrgrp)/s){
			my $auname = $1;
			$auname = &remove_flcurlbraces($auname);
			$refstr =~ s/\\bibnamefont($curlbrgrp)/$auname/s;
		}
		#########################
		while($refstr =~ /\\enquote($curlbrgrp)/s){
			my $enquote = $1;
			$enquote = &remove_flcurlbraces($enquote);
			$refstr =~ s/\\enquote($curlbrgrp)/\`\`$enquote\'\'/s;
		}
		$refstr =~ s/\\href\@noop {} ($curlbrgrp)($curlbrgrp)/\\href$1$2/g;
		$refstr =~ s/\\href([\s]+)($curlbrgrp)([\s]+)($curlbrgrp)/\\href$2$4/g;
		$refstr =~ s/\\href($curlbrgrp)([\s]+)($curlbrgrp)/\\href$1$3/g;
		while($refstr =~ /\\href($curlbrgrp)($curlbrgrp)/s){
			my $href = $2;
			$href = &remove_flcurlbraces($href);
			$href =~ s/([^<>]+) \\textbf{(\d+)}, ([^<>]+) \((\d{4})\)/{\\it $1} {\\bf $4}, {\\it $2}, $3/s;
			if($href =~ /(http|www)/s){
				$href = "\\url{$href}";
			}
			
			$refstr =~ s/\\href($curlbrgrp)($curlbrgrp)/$href/s;
		}
		
		$refstr =~ s/\{\\rm /\\textrm\{/g;
		while($refstr =~ /\\textrm($curlbrgrp)/s){
			my $trm = $1;
			$trm = &remove_flcurlbraces($trm);
			$refstr =~ s/\\textrm($curlbrgrp)/$trm/s;
		}
		$refstr =~ s/\\BibitemShut{NoStop}/\./g;
		while($refstr =~ /\\bibnamefont($curlbrgrp)/s){
			my $trm = $1;
			$trm = &remove_flcurlbraces($trm);
			$refstr =~ s/\\bibnamefont($curlbrgrp)/$trm/s;
		}
		while($refstr =~ /\\citenamefont($curlbrgrp)/s){
			my $cite = $1;
			$cite = &remove_flcurlbraces($cite);
			$refstr =~ s/\\citenamefont($curlbrgrp)/$cite/s;
		}
		$refstr =~ s/{\\natexlab($curlbrgrp)}//g;
		$refstr =~ s/ (\.|\,|\:|\;)/$1/g;
		$refstr =~ s/\\href\@noop //g;
		$refstr =~ s/\\bibitem($curlbrgrp)/\\bibitem$1\n/g;
		$refstr =~ s/\n /\n/g;
		$refstr =~ s/\\textbf{/{\\bf /g;
		$refstr =~ s/\\emph{/{\\it /g;

		$refstr =~ s/{\\bf (\d+)}, (\d+)--(\d+) \((\d{4})\)/{\\bf $4}, {\\it $1}, $2--$3/g;
		$refstr =~ s/{\\bf (\d+)}, (\d+) \((\d{4})\)/{\\bf $3}, {\\it $1}, $2/g;
	}
	$bibstr =~ s/\\begin{thebibliography}(.*?)\\end{thebibliography}/\\begin{thebibliography}$refprelim$refstr\n\\end{thebibliography}/s;
	return($bibstr);
}
########################
sub gen_conv(){
	my ($gentext)=@_;
	$gentext =~ s/\\%/<percentage>/g;
	$gentext =~ s/\%(.*?)\n//g;
	$gentext =~ s/\\,/\&thinsp\;/g;
	$gentext =~ s/\\del($curlbrgrp)//g;
	while($gentext =~ /\\ins($curlbrgrp)/){
		my $instext = $1;
		$instext = &remove_flcurlbraces($instext);
		$gentext =~ s/\\ins($curlbrgrp)/$instext/s;
	}
	$gentext =~ s/\\text(bf|it)(\s+)/\\text$1/g;
	$gentext =~ s/\\bibitem(\s+)/\\bibitem/g;
	$gentext =~ s/\t(\s+)/ /g;
	$gentext =~ s/ \n/\n/g;

	$gentext = &remove_emptytag($gentext);

	$gentext =~ s/\\href([\s]+)($curlbrgrp)([\s]+)($curlbrgrp)/\\href$2$4/g;
	$gentext =~ s/\\href($curlbrgrp)([\s]+)($curlbrgrp)/\\href$1$3/g;
	while($gentext =~ /\\href($curlbrgrp)($curlbrgrp)/){
		my $temptext = $2;
		$temptext = &remove_flcurlbraces($temptext);
		if($temptext =~ /(http|www)/s){
			$temptext = "\\url{$temptext}";
		}
		$gentext =~ s/\\href($curlbrgrp)($curlbrgrp)/$temptext/s;
	}
	
	$gentext =~ s/\n/ /g;
	$gentext =~ s/([\n]+)//g;
	$gentext =~ s/\\ \}/\} /g;
	$gentext =~ s/(\{|\(|\[) /$1/g;
	$gentext =~ s/ (\}|\]|\))/$1 /g;
	while($gentext =~ /\\ins($curlbrgrp)/){
		my $temp = $1;
		$temp =~ s/,/<comma>/g;
		$gentext =~ s/\\ins($curlbrgrp)/\\Xins$temp/s;
	}
	$gentext =~ s/,}/}, /s;
	$gentext =~ s/\\Xins/\\ins/g;
	$gentext =~ s/<comma>/,/g;

	$gentext =~ s/\\~/\\newtilde/g;
	$gentext =~ s/\~/ /g;
	$gentext =~ s/\\newtilde/\\~/g;
	$gentext =~ s/ \./\./g;
	$gentext =~ s/ ,/, /g;
	$gentext =~ s/\\ / /g;
	$gentext =~ s/  / /g;
	$gentext =~ s/([ ]+)/ /g;
	$gentext =~ s/\\harvarditem/\\bibitem/g;

	$gentext = &conv_bibitem($gentext);
	
	$gentext =~ s/\\providecommand/\n\\providecommand/g;
	$gentext =~ s/\\textbf{/{\\bf /g;
	$gentext =~ s/\\textit{/{\\it /g;
	$gentext =~ s/\\emph{/{\\it /g;
	$gentext =~ s/{\\em /{\\it /g;
	$gentext =~ s/\}{\\bf /\} {\\bf /g;
	$gentext =~ s/\}{\\it /\} {\\it /g;
	$gentext =~ s/  / /g;
	$gentext =~ s/([ ]+)/ /g;
	$gentext =~ s/\{\}//g;
	$gentext =~ s/\n /\n/g;
	$gentext =~ s/\. \./\./g;
	$gentext =~ s/\.\./\./g;
	$gentext =~ s/\&thinsp\;/\\,/g;
	$gentext =~ s/ al, et / et al\. /g;
	# $gentext =~ s/\\bibitem/\n\\bibitem/g;
	return($gentext);
}
########################
sub conv_bibitem(){
	my ($bibitem)=@_;

	if($filetype =~ /fisc/is){
		$bibitem =~ s/\\bibitem($sqbrgrp)($curlbrgrp)($curlbrgrp)($curlbrgrp) /\n\n\\bibitem\[\\protect\\citeauthoryear$2$3\]$4\n/g;
		$bibitem =~ s/\n{\\bf /\n\\textbf{/g;
		while($bibitem =~ /\n\\textbf($curlbrgrp)/s){
			my $authname = $1;
			$authname = &remove_flcurlbraces($authname);

			if($authname !~ /^\\bysame{}/){
				$authname =~ s/,//s;
			}
			$authname =~ s/ and /, /s;

			my @authors = split(/, /,$authname);
			my $nauthname;
			my $authcnt = 1;
			my ($fname,$sname);
			foreach my $auth(@authors){
				if($auth !~ /\\bysame{}/){
					$auth =~ s/\\/<backslash>/g;
					$auth = &combine_authsurname($auth);
					my @author = split(/ /,$auth);
					if($authcnt == 1){
						$sname = $author[0];
					}else{
						$sname = $author[$#author];
					}
					
					if($sname =~ /\\(?)/s){
						$auth =~ s/\\(?)//g;
					}
					$fname = $auth;
					$fname =~ s/$sname//g;
					$fname =~ s/\~/ /g;
					$fname =~ s/<backslash>/\\/g;
					$sname =~ s/<backslash>/\\/g;
					$sname =~ s/\{-\}/ /g;

					$fname = &conv_fnameinitials($fname);

					$nauthname .= "$sname, $fname, ";
				}else{
					$nauthname .= "\\bysame{}, ";
				}
				$authcnt++;
			}
			$nauthname =~ s/ , /, /g;
			$nauthname =~ s/ ,/,/g;
			$nauthname =~ s/,,/,/g;
			$nauthname =~ s/, $//g;
			$nauthname =~ s/, ([^,]+), ([A-Z\. ]+)$/ and $1, $2/s;
			
			$bibitem =~ s/\n\\textbf($curlbrgrp)/\n$nauthname/s;
		}
	}elsif($filetype =~ /$LMS/is){
		$bibitem =~ s/\\bibitem($curlbrgrp) /\\bibitem$1/g;
		$bibitem =~ s/\\bibitem($sqbrgrp)($curlbrgrp) /\\bibitem$1$2/g;
		$bibitem =~ s/\\bibitem($curlbrgrp)/\n\n\\bibitem$1\n/g;
		$bibitem =~ s/\\bibitem($sqbrgrp)($curlbrgrp)/\n\n\\bibitem$2\n/g;
	}else{
		$bibitem =~ s/\\bibitem($curlbrgrp) /\\bibitem$1/g;
		$bibitem =~ s/\\bibitem($sqbrgrp)($curlbrgrp) /\\bibitem$1$2/g;
		$bibitem =~ s/\\bibitem($curlbrgrp)/\n\n\\bibitem$1\n/g;
		$bibitem =~ s/\\bibitem($sqbrgrp)($curlbrgrp)/\n\n\\bibitem$1$2\n/g;
		
		$bibitem =~ s/\\bbland{}/and/g;
		$bibitem =~ s/\\bbland/and/g;
		$bibitem =~ s/\\bbletal{}/et al/g;
		$bibitem =~ s/\\bbletal/et al/g;
		$bibitem =~ s/\\text($curlbrgrp)/$1 /g;
		$bibitem =~ s/{\\natexlab($curlbrgrp)}/\\natexlab$1/g;
		while($bibitem =~ /\\natexlab($curlbrgrp)/s){
			my $texlab = $1;
			$texlab = &remove_flcurlbraces($texlab);
			$bibitem =~ s/\\natexlab($curlbrgrp)/$texlab/s;
		}

		while($bibitem =~ /\\bibitem($sqbrgrp)($curlbrgrp)/){
			my $citelabel = $1;
			my $biblabel = $2;
			if(($citelabel =~ /^\[\{/s)&&($citelabel =~ /\}\]$/s)){
				$citelabel =~ s/^\[\{//s;
				$citelabel =~ s/\}\]$//s;
			}else{
				$citelabel =~ s/^\[//s;
				$citelabel =~ s/\]$//s;
			}
			if($citelabel !~ /\\protect\\citeauthoryear/s){
				$citelabel =~ s/([A-z\\\`\'\"\{\}\-]+)\}\{([^<>]+)/$1\($2\)/s;

				my ($citeauthor,$citeyear);
				if(($citelabel =~ /([^\(]+)\((\d{4})\)(.*?)/s)||($citelabel =~ /([^\(]+)\((\d{4}[A-z])\)(.*?)/s)){
					$citeauthor = $1;
					$citeyear = $2;
					
					$citelabel = "\[\\protect\\citeauthoryear{$citeauthor}{$citeyear}\]";
				}else{
					$citelabel = "\[$citelabel\]";
				}
			}
			$bibitem =~ s/\\bibitem($sqbrgrp)($curlbrgrp)/\\Xbibitem$citelabel$2/s;
 		}
		if($filetype =~ /deci/is){
			$bibitem =~ s/\\Xbibitem/\\endbibitem\n\n\\Xbibitem/g;
			$bibitem =~ s/\\endbibitem//s;
			$bibitem .= "\\endbibitem";
			$bibitem =~ s/\n\n\\endbibitem/\\endbibitem/g;
			
			$bibitem =~ s/\((\d{4})\{([A-z])\}\)/\($1$2\)/g;
			
			while($bibitem =~ /\\Xbibitem($sqbrgrp)($curlbrgrp)(.*?)\\endbibitem/s){
				my $bibtxt = $1;
				my $biblabel = $2;
				my $bibmatter = $3;
				
				$bibmatter =~ s/^([^\d]+)\. (\d{4})\./$1\. \($2\)/s;
				$bibmatter =~ s/^([^\d]+)\. (\d{4}[A-z])\./$1\. \($2\)/s;

				if(($bibmatter =~ /^([^,]+), ([A-z\\\`\'\"\{\}\-\. ]+)\. \((\d{4})\)/s)||($bibmatter =~ /^([^,]+), ([A-z\\\`\'\"\{\}\-\. ]+)\. \((\d{4}[A-z])\)/s)){
					my $deciausname = $1;
					my $deciaufname = $2;

					$deciaufname = &conv_fnameinitials($deciaufname);
					
					$bibmatter =~ s/^([^,]+), ([A-z\\\`\'\"\{\}\-\. ]+)\. \((\d{4})\)/$deciausname, $deciaufname\. \($3\)/s;
					$bibmatter =~ s/^([^,]+), ([A-z\\\`\'\"\{\}\-\. ]+)\. \((\d{4}[A-z])\)/$deciausname, $deciaufname\. \($3\)/s;
				}elsif(($bibmatter =~ /([^\(]+) \((\d{4}[A-z])\)/s)||($bibmatter =~ /([^\(]+) \((\d{4})\)/s)){
					my $deciauname = $1;
					
					$deciauname =~ s/ and /, /s;
					$deciauname =~ s/,,/,/g;
					$deciauname =~ s/\.$//s;
					if($deciauname =~ /^([^,]+), ([^,]+), (.*?)$/s){
						my $dec1stausname = $1;
						my $dec1staufname = $2;
						my $deciothauth = $3;

						$dec1staufname = &conv_fnameinitials($dec1staufname);
						$deciothauth = &make_authinitials($deciothauth);
						
						$deciauname =~ s/^([^,]+), ([^,]+), (.*?)$/$dec1stausname, $dec1staufname, $deciothauth/s;
						# $deciauname =~ s/([A-Z\.]+), ([A-z\\\`\'\"\{\}]+), ([A-Z\. ]+)$/$1 and $2 $3/s;
						$deciauname =~ s/([A-Z\.]+), ([^,]+), ([A-Z\. ]+)$/$1 and $2 $3/s;
					}else{
						$deciauname =~ s/, / and /s;
						$deciauname =~ s/(.*?)$/$1\./s;
					}
					
					$bibmatter =~ s/([^\(]+) \((\d{4})\)/$deciauname \($2\)/s;
					$bibmatter =~ s/([^\(]+) \((\d{4}[A-z])\)/$deciauname \($2\)/s;
				}
				$bibmatter =~ s/ ,/,/g;
				
				$bibitem =~ s/\\Xbibitem($sqbrgrp)($curlbrgrp)(.*?)\\endbibitem/\\bibitem$1$2$bibmatter\\endbibitem/s;
			}
			$bibitem =~ s/\\bibitem/\\Xbibitem/g;
		}
		if($filetype =~ /(bimj|deci)/is){
			$bibitem =~ s/\\Xbibitem/\\endbibitem\n\n\\Xbibitem/g;
			$bibitem =~ s/\\endbibitem//s;
			$bibitem .= "\\endbibitem";
			$bibitem =~ s/\n\n\\endbibitem/\\endbibitem/g;
			
			$bibitem =~ s/\((\d{4})\{([A-z])\}\)/\($1$2\)/g;
			
			while($bibitem =~ /\\Xbibitem($sqbrgrp)($curlbrgrp)(.*?)\\endbibitem/s){
				my $bibtxt = $1;
				my $biblabel = $2;
				my $bibmatter = $3;
				$bibmatter =~ s/\t//g;
				$bibmatter =~ s/([\s]+)/ /g;
				$bibmatter =~ s/^ //s;
				$bibmatter =~ s/, and/ and/g;
				
				$bibmatter = &remove_emptytag($bibmatter);
				
				if(($bibmatter =~ /([^\(]+) \((\d{4}[A-z])\)/s)||($bibmatter =~ /([^\(]+) \((\d{4})\)/s)){
					my $authname = $1;
					my $authyear = $2;

					$authname =~ s/ and /, /s;
					$authname =~ s/ \\\& /, /s;
					$authname =~ s/([A-z\\\`\'\"\{\}\- ]+) ([A-Z])\.([A-Z])\.([A-Z])\.([A-Z])\.([A-Z])\./$1, $2\.$3\.$4\.$5\.$6\./g;
					$authname =~ s/([A-z\\\`\'\"\{\}\- ]+) ([A-Z])\.([A-Z])\.([A-Z])\.([A-Z])\./$1, $2\.$3\.$4\.$5\./g;
					$authname =~ s/([A-z\\\`\'\"\{\}\- ]+) ([A-Z])\.([A-Z])\.([A-Z])\./$1, $2\.$3\.$4\./g;
					$authname =~ s/([A-z\\\`\'\"\{\}\- ]+) ([A-Z])\.([A-Z])\./$1, $2\.$3\./g;
					$authname =~ s/([A-z\\\`\'\"\{\}\- ]+) ([A-Z])\./$1, $2\./g;
					$authname =~ s/([^,]+), ([^,]+), /$1, /g;
					$authname =~ s/, ([A-Z\.\- ]+)$//s;
					$authname =~ s/ ([A-Z\.\- ]+)$//s;
					my @bibauthors = split(/, /,$authname);
					my $bibarrsize = $#bibauthors;
					$bibarrsize++;
					if($bibarrsize == 1){
						$bibtxt = "\[\\protect\\citeauthoryear{$authname}{$authyear}\]";
					}elsif($bibarrsize == 2){
						$bibtxt = "\[\\protect\\citeauthoryear{$bibauthors[0] \\\& $bibauthors[1]}{$authyear}\]";
					}elsif($bibarrsize == 3){
						$bibtxt = "\[\\protect\\citeauthoryear{$bibauthors[0], $bibauthors[1], \\\& $bibauthors[2]}{$bibauthors[0] {\\it et al\.}}{$authyear}\]";
					}elsif($bibarrsize == 4){
						$bibtxt = "\[\\protect\\citeauthoryear{$bibauthors[0], $bibauthors[1], $bibauthors[2], \\\& $bibauthors[3]}{$bibauthors[0] {\\it et al\.}}{$authyear}\]";
					}elsif($bibarrsize == 5){
						$bibtxt = "\[\\protect\\citeauthoryear{$bibauthors[0], $bibauthors[1], $bibauthors[2], $bibauthors[3], \\\& $bibauthors[4]}{$bibauthors[0] {\\it et al\.}}{$authyear}\]";
					}elsif($bibarrsize > 5){
						$bibtxt = "\[\\protect\\citeauthoryear{$bibauthors[0] {\\it et al\.}}{$authyear}\]";
					}
					$bibtxt =~ s/{\n/{/g;
					
					$bibmatter =~ s/([^\(]+) \(\d{4}\)/$authname \($authyear\)/s;
					$bibmatter =~ s/([^\(]+) \(\d{4}[A-z]\)/$authname \($authyear\)/s;
				}
				# $bibitem =~ s/\\Xbibitem($sqbrgrp)($curlbrgrp)(.*?)\\endbibitem/\\bibitem$bibtxt$biblabel$bibmatter\\endbibitem/s;
				$bibitem =~ s/\\Xbibitem($sqbrgrp)($curlbrgrp)(.*?)\\endbibitem/\\bibitem$bibtxt$biblabel$3\\endbibitem/s;
			}
			
			while($bibitem =~ /\\bibitem($sqbrgrp)($curlbrgrp)(.*?)\\endbibitem/s){
				my $bibtxt = $1;
				my $biblabel = $2;
				my $bibmatter = $3;
				
				$bibmatter =~ s/\t//g;
				$bibmatter =~ s/([\s]+)/ /g;
				$bibmatter =~ s/^ /\n/s;
				$bibmatter =~ s/, and/ and/g;
				$bibmatter = &remove_emptytag($bibmatter);

				if(($bibmatter =~ /([^\(]+) \((\d{4}[A-z])\)/s)||($bibmatter =~ /([^\(]+) \((\d{4})\)/s)){
					my $authname = $1;
					my $authyear = $2;
					$authname =~ s/ and /, \\\& /s;
					$authname =~ s/([A-z\\\`\'\"\{\}\- ]+) ([A-Z])\.([A-Z])\.([A-Z])\.([A-Z])\.([A-Z])\./$1, $2\.$3\.$4\.$5\.$6\./g;
					$authname =~ s/([A-z\\\`\'\"\{\}\- ]+) ([A-Z])\.([A-Z])\.([A-Z])\.([A-Z])\./$1, $2\.$3\.$4\.$5\./g;
					$authname =~ s/([A-z\\\`\'\"\{\}\- ]+) ([A-Z])\.([A-Z])\.([A-Z])\./$1, $2\.$3\.$4\./g;
					$authname =~ s/([A-z\\\`\'\"\{\}\- ]+) ([A-Z])\.([A-Z])\./$1, $2\.$3\./g;
					$authname =~ s/([A-z\\\`\'\"\{\}\- ]+) ([A-Z])\./$1, $2\./g;
					$authname =~ s/([A-Z])\./$1\. /g;
					$authname =~ s/\. -/\.-/g;
					$authname =~ s/ al, et / et al\. /g;

					if($authname !~ /([A-z\\\`\'\"\{\}\- ]+)\. /s){
						$authname =~ s/, \\\& / and /s;
						$bibtxt =~ s/\\\&/and/s;
						$bibtxt =~ s/\.//g;
					}
					$bibmatter =~ s/([^\(]+) \(\d{4}\)/$authname \($authyear\)/s;
					$bibmatter =~ s/([^\(]+) \(\d{4}[A-z]\)/$authname \($authyear\)/s;
				}
				
				$bibtxt =~ s/\\citeauthoryear($curlbrgrp)($curlbrgrp)($curlbrgrp)/\\citeauthoryear$1$3/s;
				$bibitem =~ s/\\bibitem($sqbrgrp)($curlbrgrp)(.*?)\\endbibitem/\\Xbibitem$bibtxt$2$bibmatter\\endbibitem/s;
			}
			$bibitem =~ s/ ,/, /g;
			$bibitem =~ s/\\endbibitem//g;
		}
		$bibitem =~ s/\\Xbibitem/\\bibitem/g;
		if($filetype =~ /(qute|adtp|adts|mats|mabi|mame|marc|mren|macp|adma|adfm|admi|adom|advs|smtd|smll)/is){
			$bibitem =~ s/\\bibitem($sqbrgrp)($curlbrgrp)/\\bibitem$2/g;
		}
	}
	return($bibitem);
}	
########################
sub lms_regrep(){
	my ($reptext)=@_;
	
	$reptext =~ s/{\\sc /\\textsc{/g;
	while($reptext =~ /\\textsc($curlbrgrp)/s){
		my $sctxt = $1;
		$sctxt = &remove_flcurlbraces($sctxt);
		$reptext =~ s/\\textsc($curlbrgrp)/$sctxt/s;
	}

	# print "$reptext\n\n";
	
	$reptext =~ s/(\d+)-(\d+)/$1--$2/g;
	$reptext =~ s/, (\d+):(\d+), (\d{4})/ $1 \($3\) $2/g;
	$reptext =~ s/, (\d+)\((\d+)\):(\d+), (\d{4})/ $1 \($4\) $3/g;
	$reptext =~ s/, (\d+):(\d+)--(\d+), (\d{4})/ $1 \($4\) $2--$3/g;
	$reptext =~ s/, (\d+)\((\d+)\):(\d+)--(\d+), (\d{4})/ $1 \($5\) $3--$4/g;
	$reptext =~ s/, (\d+)\(([^\)]+)\):(\d+)--(\d+), (\d{4})/ $1 \($5\) $3--$4/g;
	$reptext =~ s/, (\d+) \(([^\)]+)\):(\d+)--(\d+), (\d{4})/ $1 \($5\) $3--$4/g;
	$reptext =~ s/ (\d+)\(([^\)]+)\), (\d+)--(\d+), (\d{4})/ $1 \($5\) $3--$4/g;
	$reptext =~ s/ (\d+), (\d+)--(\d+) (\d{4})/ $1 \($4\) $2--$3/g;
	$reptext =~ s/ {\\bf (\d+)} \((\d{4})\), no\. (\d+), (\d+)--(\d+)/ $1 \($2\) $4--$5/g;
	$reptext =~ s/ {\\bf (\d+)} \((\d{4})\), no\. (\d+)--(\d+), (\d+)--(\d+)/ $1 \($2\) $5--$6/g;
	$reptext =~ s/ {\\bf (\d+)} \((\d{4})\), no\. (\d+), (\d+)/ $1 \($2\) $4/g;
	$reptext =~ s/ {\\bf (\d+)} \((\d{4})\), no\. (\d+)--(\d+), (\d+)/ $1 \($2\) $5/g;
	$reptext =~ s/ {\\bf (\d+)} \((\d{4})\), (\d+)--(\d+)/ $1 \($2\) $3--$4/g;
	$reptext =~ s/ (\d+) \((\d{4})\), no\. (\d+), (\d+)--(\d+)/ $1 \($2\) $4--$5/g;
	$reptext =~ s/ (\d+) \((\d{4})\), (\d+)--(\d+)/ $1 \($2\) $3--$4/g;
	$reptext =~ s/ (\d+) \((\d+)\), (\d+)--(\d+), (\d{4})/ $1 \($5\) $3--$4/g;
	$reptext =~ s/ (\d+) (\d+)--(\d+), (\d{4})/ $1 \($4\) $2--$3/g;
	$reptext =~ s/ (\d+), (\d+)--(\d+), (\d{4})/ $1 \($4\) $2--$3/g;
	$reptext =~ s/ (\d+)\:(\d+) \((\d{4})\) (\d+)--(\d+)/ $1 \($3\) $4--$5/g;

	$reptext =~ s/ (\d+)\.(\d+) \((\d{4})\) (\d+)--(\d+)/ $1 \($3\) $4--$5/g;
	$reptext =~ s/ (\d+)\.(\d+) \((\d{4})\)\: (\d+)--(\d+)/ $1 \($3\) $4--$5/g;

	
	# $reptext =~ s/, ([A-z\\\`\'\"\{\}\-\. ]+) (\d+) \((\d{4})\) (\d+)/, {\\it $1} $2 \($3\) $4/g;
	# $reptext =~ s/, ([A-z\\\`\'\"\{\}\-\. ]+), (\d+) \((\d{4})\) (\d+)/, {\\it $1} $2 \($3\) $4/g;

	$reptext =~ s/{\\it /\\textit{/g;
	while($reptext =~ /, \\textit($curlbrgrp), \\textit($curlbrgrp)/s){
		my $temp = $1;
		$temp = &remove_flcurlbraces($temp);
		$reptext =~ s/, \\textit($curlbrgrp), \\textit($curlbrgrp)/, \`$temp\', \\textit$2/g;
	}
	$reptext =~ s/\\textit{/{\\it /g;

	
	$reptext =~ s/\\bibitem/\\endbibitem\n\n\\bibitem/g;
	$reptext =~ s/\\endbibitem//s;
	$reptext .= "\\endbibitem";
	$reptext =~ s/\n\n\\endbibitem/\\endbibitem/g;
	$reptext =~ s/ \\and / and /g;
	$reptext =~ s/{\\bibname /\\bibname{/g;
	
	while($reptext =~ /\\bibitem($curlbrgrp)(.*?)\\endbibitem/s){
		my $bibtext = $2;
		$bibtext =~ s/^\n//s;
		$bibtext =~ s/\. \\newblock {\\it ([^\.]+)\. \\newblock/<\/author>, {\\it $1/g;
		$bibtext =~ s/\. \\newblock ([^\.]+)\. \\newblock \{/, \`$1\', \{/g;
		$bibtext =~ s/\. \\newblock ([^\.]+)\. \\newblock /, \`$1\', /g;
		$bibtext =~ s/\. \\newblock ([^\.]+)\. \\newblock/, \`$1\', /g;
		$bibtext =~ s/, \\newblock ([^,]+), \\newblock/, \`$1\', /g;

		if($bibtext =~ /([^\`]+), \`/s){
			my $authname = $1;
			$authname = &make_authinitials($authname);
			
			$bibtext =~ s/([^\`]+), \`/$authname, \`/s;
		}elsif($bibtext =~ /^(.*?)<\/author>,/s){
			my $authname = $1;
			$authname = &make_authinitials($authname);
			
			$bibtext =~ s/^(.*?)<\/author>,/$authname,/s;
		}
		$bibtext =~ s/<\/author>//g;
		
		$reptext =~ s/\\bibitem($curlbrgrp)(.*?)\\endbibitem/\\Xbibitem$1\n$bibtext\\endbibitem/s;
	}

	while($reptext =~ /\\bibname($curlbrgrp)/s){
		my $bname = $1;
		$bname = &remove_flcurlbraces($bname);
		$reptext =~ s/\\bibname($curlbrgrp)/$bname/s;
	}
	$reptext =~ s/\\Xbibitem/\\bibitem/g;
	$reptext =~ s/\\endbibitem//g;

	return($reptext);
}
########################
sub make_authinitials(){
	my ($authornames)=@_;

	$authornames =~ s/ and /, /s;
	my @authors = split(/, /,$authornames);
	my ($fname,$sname,$nauthname);
	foreach my $auth(@authors){
		$auth =~ s/\\/<backslash>/g;
		$auth = &combine_authsurname($auth);
		my @author = split(/ /,$auth);
		$sname = $author[$#author];
		$fname = $auth;
		$fname =~ s/$sname//g;
		$fname =~ s/\~/ /g;
		$fname =~ s/<backslash>/\\/g;
		$sname =~ s/<backslash>/\\/g;
		$sname =~ s/\{-\}/ /g;

		$fname =~ s/^\n//s;
		$fname =~ s/ $//s;
		$fname = &conv_fnameinitials($fname);

		if($filetype =~ /deci/s){
			$nauthname .= "$sname, $fname, ";
		}else{
			$nauthname .= "$fname $sname, ";
		}
	}
	$nauthname =~ s/\. \./\./g;
	$nauthname =~ s/\.\./\./g;
	$nauthname =~ s/ , /, /g;
	$nauthname =~ s/ ,/,/g;
	$nauthname =~ s/,,/,/g;
	$nauthname =~ s/, $//g;
	$nauthname =~ s/\. -/\.-/g;
	$nauthname =~ s/([A-z\\\`\'\"\{\}]+), ([A-Z\. ]+) ([A-z\\\`\'\"\{\}\- ]+)$/$1 and $2 $3/s;

	return($nauthname);
}
########################
sub conv_fnameinitials(){
	my ($firstname)=@_;

		if($firstname =~ /\-/s){
			$firstname =~ s/([A-z])([^\-]+)\-([A-z])([^ ]+)/$1\.\-$3\./g;
			$firstname =~ s/([A-z])([^\-]+)\-([A-Z])([a-z\\\`\'\"\{\}]+)/$1\.\-$3\./g;
			$firstname =~ s/([\\.\{][A-Z][\}])([^\-]+)\-([A-Z])([a-z\\\`\'\"\{\}]+)/$1\.\-$3\./g;
		}elsif($firstname =~ / /s){
			my @fnames = split(/ /,$firstname);
			$firstname = "";
			foreach my $fn(@fnames){
				if($fn =~ /^\\./s){
					$fn =~ s/([\\.\{][A-Z][\}])([^ ]+)/$1\./s;
					$fn =~ s/([\\.\{][A-Z][\}])([a-z\\\`\'\"\{\}]+)/$1\./s;
				}elsif($fn !~ /\./s){
					$fn =~ s/([A-Z])([^ ]+)/$1\./g;
					$fn =~ s/([A-Z])([a-z\\\`\'\"\{\}]+)/$1\./g;
					$fn =~ s/^([A-Z])$/$1\./g;
				}elsif($fn =~ /\./s){
					$fn =~ s/\./\. /g;
				}
				$firstname .= "$fn ";
			}
			$firstname =~ s/ $//s;
		}else{
			if($firstname =~ /^\\./s){
				$firstname =~ s/([\\.\{][A-Z][\}])([^ ]+)/$1\./s;
			}elsif($firstname !~ /\./s){
				$firstname =~ s/([A-Z])([^ ]+)/$1\./g;
				$firstname =~ s/([A-Z])/$1\./g;
			}elsif($firstname =~ /\./s){
				$firstname =~ s/\./\. /g;
			}
		}

	return($firstname);
}
########################
sub nonlms_regrep(){
	my ($reptext)=@_;
	
	$reptext =~ s/\ / /g;
	$reptext =~ s/  / /g;
	$reptext =~ s/([ ]+)/ /g;
	$reptext =~ s/\\newblock//g;
	$reptext =~ s/, ([A-z,\.\- ]+) ([0-9\-]+) \((\d{4})\), (\d+)--(\d+)/, {\\it $1} {\\bf $3}, {\\it $2}, $4--$5/g;
	$reptext =~ s/, ([A-z,\.\- ]+) ([0-9\-]+) \((\d{4})\), (\d+)/, {\\it $1} {\\bf $3}, {\\it $2}, $4/g;
	$reptext =~ s/, ([A-z,\.\- ]+) {\\bf ([0-9\-]+)} \((\d{4})\) (\d+)/, {\\it $1} {\\bf $3}, {\\it $2}, $4/g;
	$reptext =~ s/, ([A-z,\.\- ]+) {\\bf ([0-9\-]+)} \((\d{4})\), (\d+)/, {\\it $1} {\\bf $3}, {\\it $2}, $4/g;
	$reptext =~ s/, ([A-z,\.\- ]+) {\\bf ([0-9\-]+)} \((\d{4})\), (\d+)--(\d+)/, {\\it $1} {\\bf $3}, {\\it $2}, $4/g;
	$reptext =~ s/  / /g;
	$reptext =~ s/([ ]+)/ /g;
	
	if($filetype =~ /($VCH|kin|admi|smll|adfm|advs)/is){
		$reptext = &conv_texttscjr($reptext);
		
		$reptext =~ s/\\othercit//g;
		$reptext =~ s/\\,/ /g;
		$reptext =~ s/{\\it /\\textit{/g;
		# $reptext =~ s/, \\textit($curlbrgrp), \\textit($curlbrgrp) {\\bf (\d{4})}/, \\textit$2 {\\bf $3}/g;
		$reptext =~ s/, \\textit($curlbrgrp), \\textit($curlbrgrp)/, \\textit$2/g;
		$reptext =~ s/\\textit{/{\\it /g;
		$reptext =~ s/([A-Z])\. ([^,]+), and ([A-Z])\./$1\. $2, $3\./g;
		$reptext =~ s/([A-Z])\. ([^\s]+) and ([A-Z])\./$1\. $2, $3\./g;

		# $reptext =~ s/, {\\it ([^\}]+)}, {\\it ([^\}]+)}/, {\\it $2}/g;

		$reptext =~ s/\\textsc($curlbrgrp) and \\textsc($curlbrgrp)/\\textsc$1, \\textsc$2/g;
		$reptext =~ s/(\d+) -- (\d+)/$1--$2/g;
		$reptext =~ s/(\d+)-(\d+)/$1--$2/g;
		$reptext =~ s/{\\bf (\d+)}\(([A-z0-9]+)\), (\d+)--(\d+) \((\d{4})\)/{\\bf $5}, {\\it $1}, $3/g;
		$reptext =~ s/{\\bf (\d+)}\(([A-z0-9]+)\), (\d+) \((\d{4})\)/{\\bf $4}, {\\it $1}, $3/g;
		$reptext =~ s/{\\bf (\d+)}, (\d+)--(\d+) \((\d{4})\)/{\\bf $4}, {\\it $1}, $2/g;
		$reptext =~ s/{\\bf (\d+)}, (\d+) \((\d{4})\)/{\\bf $3}, {\\it $1}, $2/g;
		$reptext =~ s/{\\bf ([A-z0-9]+)} \((\d{4})\) (\d+)--(\d+)/{\\bf $2}, {\\it $1}, $3/g;
		$reptext =~ s/{\\bf ([A-z0-9]+)} \((\d{4})\) (\d+)/{\\bf $2}, {\\it $1}, $3/g;
		$reptext =~ s/{\\bf ([A-z0-9]+)} \((\w{3}), (\d{4})\) (\d+)--(\d+)/{\\bf $3}, {\\it $1}, $4/g;
		$reptext =~ s/{\\bf ([A-z0-9]+)} \((\w{3}), (\d{4})\) (\d+)/{\\bf $3}, {\\it $1}, $4/g;
		$reptext =~ s/{\\bf (\d{4})}, (\d+), (\d+)/{\\bf $1}, {\\it $2}, $3/g;

		$reptext =~ s/{\\bf (\d{4})}, {\\it (\d+)}, (\d+)--(\d+)/{\\bf $1}, {\\it $2}, $3/g;
		$reptext =~ s/{\\bf (\d{4})}, {\\it (\d+)\(([A-z0-9\-]+)\)}, (\d+)--(\d+)/{\\bf $1}, {\\it $2}, $4/g;
		$reptext =~ s/ {\\bf ([0-9\-]+)} \((\d{4})\), (\d+)--(\d+)/ {\\bf $2}, {\\it $1}, $3/g;
		$reptext =~ s/ {\\bf ([0-9\-]+)} \((\d{4})\), (\d+)/ {\\bf $2}, {\\it $1}, $3/g;
	}	
	if($filetype =~ /(ZAMM|zamm)/is){
		$reptext = &conv_texttscjr($reptext);
		$reptext =~ s/\\othercit//g;
		
		$reptext =~ s/(\d+)-(\d+)/$1--$2/g;
		$reptext =~ s/(\d+) - (\d+)/$1--$2/g;
		$reptext =~ s/([A-Z])\. ([^,]+), and ([A-Z])\./$1\. $2, $3\./g;
		$reptext =~ s/([A-Z])\. ([^\s]+) and ([A-Z])\./$1\. $2, $3\./g;
		$reptext =~ s/([A-Z])\. ([^,]+), ([A-Z][a-z]+)/$1\. $2<comma> $3/g;
		$reptext =~ s/{\\bf (\d+)} \((\d{4})\), (\d+)--(\d+)/{\\bf $2}, {\\it $1}, $3/g;
		$reptext =~ s/{\\bf (\d+)} \((\d{4})\), (\d+)/{\\bf $2}, {\\it $1}, $3/g;
		$reptext =~ s/{\\bf (\d+)}\(([A-z0-9\-]+)\), (\d+)--(\d+) \((\d{4})\)/{\\bf $5}, {\\it $1}, $3/g;
		$reptext =~ s/{\\bf (\d+)}, (\d+)--(\d+) \((\d{4})\)/{\\bf $4}, {\\it $1}, $2/g;
		$reptext =~ s/{\\bf (\d+)} (\d+)--(\d+) \((\d{4})\)/{\\bf $4}, {\\it $1}, $2/g;
		$reptext =~ s/{\\bf (\d+)}, (\d+) \((\d{4})\)/{\\bf $3}, {\\it $1}, $2/g;
		$reptext =~ s/{\\bf (\d+)} (\d+) \((\d{4})\)/{\\bf $3}, {\\it $1}, $2/g;
		
		$reptext =~ s/{\\bf (\d+)}\(([A-z0-9\-]+)\), (\d+) \((\d{4})\)/{\\bf $4}, {\\it $1}, $3/g;
		$reptext =~ s/{\\bf (\d+)}\(([A-z0-9\-]+)\), (\d+), \((\d{4})\)/{\\bf $4}, {\\it $1}, $3/g;
		$reptext =~ s/{\\bf (\d+)}\(([A-z0-9\-]+)\) (\d+) \((\d{4})\)/{\\bf $4}, {\\it $1}, $3/g;
		
		$reptext =~ s/{\\bf (\d+)\(([A-z0-9\-]+)\)} (\d+)--(\d+) \((\d{4})\)/{\\bf $5}, {\\it $1}, $3/g;
		$reptext =~ s/{\\bf (\d+)\(([A-z0-9\-]+)\)}, (\d+)--(\d+) \((\d{4})\)/{\\bf $5}, {\\it $1}, $3/g;
		$reptext =~ s/{\\bf (\d+)\(([A-z0-9\-]+)\)}, (\d+)--(\d+), \((\d{4})\)/{\\bf $5}, {\\it $1}, $3/g;
		$reptext =~ s/{\\bf (\d+)}\;(\d+)\(([A-z0-9\-]+)\):(\d+)-(\d+)/{\\bf $1}, {\\it $2}, $4/g;
		$reptext =~ s/{\\bf (\d+)}\;(\d+)\(([A-z0-9\-]+)\):(\d+)--(\d+)/{\\bf $1}, {\\it $2}, $4/g;
		$reptext =~ s/(\d+)\((\d{4})\), (\d+)-(\d+)/{\\bf $2}, {\\it $1}, $3/g;
		$reptext =~ s/(\d+)\((\d{4})\),(\d+)-(\d+)/{\\bf $2}, {\\it $1}, $3/g;
		$reptext =~ s/(\d+) \((\d{4})\), (\d+)-(\d+)/{\\bf $2}, {\\it $1}, $3/g;
		$reptext =~ s/(\d+) \((\d{4})\),(\d+)-(\d+)/{\\bf $2}, {\\it $1}, $3/g;
		$reptext =~ s/(\d+) \((\d{4})\), (\d+)/{\\bf $2}, {\\it $1}, $3/g;
		$reptext =~ s/(\d+) \((\d{4})\),(\d+)/{\\bf $2}, {\\it $1}, $3/g;
		$reptext =~ s/(\d+)\((\d{4})\), (\d+)/{\\bf $2}, {\\it $1}, $3/g;
		$reptext =~ s/(\d+), (\d+)--(\d+)\((\d{4})\)/{\\bf $4}, {\\it $1}, $2/g;
		$reptext =~ s/(\d+), (\d+)\((\d{4})\)/{\\bf $3}, {\\it $1}, $2/g;
		$reptext =~ s/(\d+), (\d+) \((\d{4})\)/{\\bf $3}, {\\it $1}, $2/g;
		$reptext =~ s/(\d+):(\d+)\((\d{4})\)/{\\bf $3}, {\\it $1}, $2/g;
		$reptext =~ s/(\d+)\((\d{4})\),(\d+)/{\\bf $2}, {\\it $1}, $3/g;
		$reptext =~ s/{\\bf (\d+)}, \((\d{4})\)/{\\bf $2}, {\\it $1}/g;

		$reptext =~ s/, ([A-z\.\- ]+), {\\bf (\d{4})}, {\\it (\d+)}, (\d+)/, {\\it $1} {\\bf $2}, {\\it $3}, $4/g;
		$reptext =~ s/, ([A-z\.\- ]+) {\\bf (\d{4})}, {\\it (\d+)}, (\d+)/, {\\it $1} {\\bf $2}, {\\it $3}, $4/g;
		$reptext =~ s/, ([A-z\.\- ]+) {\\bf (\d{4})}, {\\it (\d+)}/, {\\it $1} {\\bf $2}, {\\it $3}/g;

		while($reptext =~ /, {\\it ([A-z\.\- ]+)} {\\bf (\d{4})}, {\\it (\d+)}, (\d+)/s){
			my $jtl = $1;
			$jtl =~ s/\./\. /g;
			$jtl =~ s/  / /g;
			$jtl =~ s/([ ]+)/ /g;
			$jtl =~ s/\. $/\./s;
			
			$reptext =~ s/, {\\it ([A-z\.\- ]+)} {\\bf (\d{4})}, {\\it (\d+)}, (\d+)/, \\textit{$jtl} {\\bf $2}, {\\it $3}, $4/s;
		}
		$reptext =~ s/\\textit{/{\\it /g;
		
		$reptext =~ s/<comma> (.*?), {\\it ([A-z\.\- ]+)} {\\bf /, {$1}, {\\it $2} {\\bf /g;
		$reptext =~ s/<comma>/,/g;
	}
	if($filetype =~ /bimj/is){
		$reptext =~ s/{\\it /\\textit{/g;
		$reptext =~ s/\\textit($curlbrgrp) {\\bf (\d+)}, /\\textit$1, {\\bf $2}, /g;
		$reptext =~ s/\\textit{/{\\it /g;
	}
	return($reptext);
}
########################
sub conv_texttscjr(){
	my ($repstr)=@_;

		$repstr =~ s/{\\tt /\\texttt{/g;
		while($repstr =~ /\\texttt($curlbrgrp)/s){
			my $ttxt = $1;
			$ttxt = &remove_flcurlbraces($ttxt);
			$repstr =~ s/\\texttt($curlbrgrp)/$ttxt/s;
		}
		while($repstr =~ /\\textsc($curlbrgrp)/s){
			my $sctxt = $1;
			$sctxt = &remove_flcurlbraces($sctxt);
			$repstr =~ s/\\textsc($curlbrgrp)/$sctxt/s;
		}
		while($repstr =~ /\\jr($curlbrgrp)/s){
			my $jrtxt = $1;
			$jrtxt = &remove_flcurlbraces($jrtxt);
			$repstr =~ s/\\jr($curlbrgrp)/{\\it $jrtxt}/s;
		}
	return($repstr);
}
########################
sub conv_labelNref(){
	my ($textstr)=@_;
	
	while($textstr =~ /\\label($curlbrgrp)/s){
		my $labtxt = $1;
		my $nlabtxt = $labtxt;
		$nlabtxt =~ s/\_/\(UND\)/g;
		$nlabtxt =~ s/\^/\(CR\)/g;
		
		$textstr =~ s/\\label($curlbrgrp)/\\Xlabel$nlabtxt/s;
		$textstr =~ s/\\ref$labtxt/\\ref$nlabtxt/g;
		$textstr =~ s/\\eqref$labtxt/\\eqref$nlabtxt/g;
	}
	$textstr =~ s/\\Xlabel/\\label/g;
	return($textstr);
}
########################
sub conv_lists(){
	my ($textstr)=@_;

	###############################
	ENUMM:
	$textstr =~ s/\\begin{enumerate}/\\begin{mainenumerate}/g;
	$textstr =~ s/\\end{enumerate}/\\end{mainenumerate}/g;
	my $enumcnt = 1;
	my $temp;

	while($textstr =~ /\\(begin|end){mainenumerate}/s) {
		$temp = "\\$1";
		$temp .= "{mainenumerate}";
		
		if(($enumcnt > 1)&&($temp =~ /\\begin{mainenumerate}/s)) {
			$textstr =~ s/\\begin{mainenumerate}/\\begin{subenumerate}/s;
			$textstr =~ s/\\end{mainenumerate}/\\end{subenumerate}/s;
			#print "****CHILD Para****\n";
		}
		if($temp =~ /\\begin{mainenumerate}/s){
			if($enumcnt eq 1) {
				$textstr =~ s/\\begin{mainenumerate}/\\begin{enumerate}/s;
				#print "Parent Para Begins\n";
			}
			$enumcnt++;
		}
		elsif($temp =~ /\\end{mainenumerate}/s) {
			$textstr =~ s/\\end{mainenumerate}/\\end{enumerate}/s;
			#print "Parent Para Ends\n";
			$enumcnt = 1;
		}
	}
	while($textstr =~ /\\begin{subenumerate}(.*?)\\end{subenumerate}/s){
		my $sublist = $1;
		$sublist =~ s/\\item/\\subitem/g;
		
		$textstr =~ s/\\begin{subenumerate}(.*?)\\end{subenumerate}/\\begin{Xsubenumerate}$sublist\\end{Xsubenumerate}/s;
	}
	$textstr =~ s/{Xsubenumerate}/{subenumerate}/g;
	###############################
	
	while($textstr =~ /\\begin{enumerate}($sqbrgrp)(.*?)\\end{enumerate}/s){
		my $listlabel = $1;
		my $listtext = $2;
		$listlabel =~ s/^\[//s;
		$listlabel =~ s/\]$//s;

		while($listtext =~ /\\begin{itemize}(.*?)\\end{itemize}/s){
			my $bullitemize = $1;
			
			$bullitemize =~ s/\\item/\\bullitem/g;
			
			$listtext =~ s/\\begin{itemize}(.*?)\\end{itemize}/\\begin{Xitemize}$bullitemize\\end{Xitemize}/s;
		}
		# print "$listlabel\n";
		my $cnt;
		if($listlabel =~ /(\d+)/s){
			$cnt = $1;
			$listtext = &conv_item($cnt,$listlabel,$listtext,"int");
		}elsif(($listlabel =~ /(\w)/s)&&($listlabel !~ /(i|I)/is)&&($listlabel !~ /(\d)/s)){
			$cnt = $1;
			$listtext = &conv_item($cnt,$listlabel,$listtext,"alph");
		}elsif($listlabel =~ /i/s){
			$cnt = 1;
			$listtext = &conv_item($cnt,$listlabel,$listtext,"smroman");
		}elsif($listlabel =~ /I/s){
			$cnt = 1;
			$listtext = &conv_item($cnt,$listlabel,$listtext,"cproman");
		}
		#print "$listlabel\n";
		
		$textstr =~ s/\\begin{enumerate}($sqbrgrp)(.*?)\\end{enumerate}/\\begin{Xenumerate}$listtext\\end{Xenumerate}/s;
	}
	$textstr =~ s/{subenumerate}/{enumerate}/g;
	$textstr =~ s/\\subitem/\\item/g;
	if($textstr =~ /\\begin{enumerate}($sqbrgrp)(.*?)\\end{enumerate}/s){
		goto ENUMM;
	}
	$textstr =~ s/{Xenumerate}/{enumerate}/g;
	$textstr =~ s/{Xitemize}/{itemize}/g;
	$textstr =~ s/\\bullitem/\\item/g;


	my %itemlabelref;
	while($textstr =~ /\\item($sqbrgrp) \\label($curlbrgrp)/s){
		my $itemval = $1;
		my $labelval = $2;
		$itemval =~ s/^\[//s;
		$itemval =~ s/\]$//s;
		$labelval = &remove_flcurlbraces($labelval);

		$itemlabelref{$labelval} = $itemval;
		# $textstr =~ s/\\item($sqbrgrp) \\label($curlbrgrp)/\\Xitem$1 \\label$2/s;
		$textstr =~ s/\\item($sqbrgrp) \\label($curlbrgrp)/\\Xitem$1 /s;
	}
	$textstr =~ s/\\Xitem/\\item/g;

	while(($textstr =~ /\\ref($curlbrgrp)/s)||($textstr =~ /\\eqref($curlbrgrp)/s)){
		my $refval = $1;
		$refval = &remove_flcurlbraces($refval);
		my $nrefval;
		foreach my $entry(sort keys %itemlabelref){
			if($refval eq $entry){
				$nrefval = "$itemlabelref{$entry}";
			}
		}

		if($nrefval){
			$textstr =~ s/\\ref($curlbrgrp)/$nrefval/s;
			$textstr =~ s/\\eqref($curlbrgrp)/$nrefval/s;
		}else{
			$textstr =~ s/\\ref($curlbrgrp)/\\Xref{$refval}/s;
			$textstr =~ s/\\eqref($curlbrgrp)/\\Xeqref{$refval}/s;
		}
	}
	$textstr =~ s/\\Xref/\\ref/g;
	$textstr =~ s/\\Xeqref/\\eqref/g;
	$textstr =~ s/  / /g;
	$textstr =~ s/([ ]+)/ /g;

	undef %itemlabelref;
	return($textstr);
}
########################
sub conv_item(){
	my ($mycnt,$itemlabel,$itemstr,$type)=@_;
	
	# $itemstr =~ s/\\item(\w)/\\item $1/g;
	$itemstr =~ s/\\item/\\item /g;
	$itemstr =~ s/  / /g;
	$itemstr =~ s/([ ]+)/ /g;
	while($itemstr =~ /\\item /s){
		if($type eq "int"){
			$itemlabel =~ s/(\d)/$mycnt/s;
		}elsif($type eq "alph"){
			$itemlabel =~ s/(\w)/$mycnt/s;
		}elsif($type eq "smroman"){
			$mycnt = roman($mycnt);
			my $nmycnt = "\L$mycnt\E";
			$itemlabel =~ s/(\w+)/$nmycnt/s;
		}elsif($type eq "cproman"){
			$mycnt = roman($mycnt);
			my $nmycnt = "\U$mycnt\E";
			$itemlabel =~ s/(\w+)/$nmycnt/s;
		}
		$itemstr =~ s/\\item /\\item\[$itemlabel\] /s;
		$mycnt++;
	}
	return($itemstr);
}
########################
sub change_mathbraces(){
	my ($mthtext)=@_;

	my $eqnenv = qr/equation\*|equation|eqnarray\*|eqnarray|align\*|align|multiline\*|multiline|gather\*|gather/x;
	if($filetype !~ /mana/is){
		while($mthtext =~ /\\begin{($eqnenv)}(.*?)\\end{($eqnenv)}/s){
			my $eqntxt = $2;
			$eqntxt = &conv_braces($eqntxt);
			
			$mthtext =~ s/\\begin{($eqnenv)}(.*?)\\end{($eqnenv)}/\\begin{X$1}$eqntxt\\end{X$3}/s;
		}
		$mthtext =~ s/{X($eqnenv)}/{$1}/g;

		while($mthtext =~ /\$\$(.*?)\$\$/s){
			my $eqntxt = $1;
			$eqntxt = &conv_braces($eqntxt);
			
			$mthtext =~ s/\$\$(.*?)\$\$/<dispeqn>$eqntxt<dispeqn>/s;
		}
		$mthtext =~ s/<dispeqn>/\$\$/g;

		while($mthtext =~ /\\\[(.*?)\\\]/s){
			my $eqntxt = $1;
			$eqntxt = &conv_braces($eqntxt);
			
			$mthtext =~ s/\\\[(.*?)\\\]/<DispEqn>$eqntxt<\/DispEqn>/s;
		}
		$mthtext =~ s/<DispEqn>/\\\[/g;
		$mthtext =~ s/<\/DispEqn>/\\\]/g;
	}	
	return($mthtext);
}
########################
sub conv_braces(){
	my ($brctext)=@_;

	my $brsize = qr/bigg|bigl|bigr|big|Bigg|Big/x;
	$brctext =~ s/\\($brsize)(\s+)/\\$1/g;

	$brctext =~ s/\\($brsize)(\(|\\{|\[)/\\left$2/g;
	$brctext =~ s/\\($brsize)(\)|\\}|\])/\\right$2/g;
	
	$brctext =~ s/\\($brsize)\\lbrace/\\left\\lbrace/g;
	$brctext =~ s/\\($brsize)\\rbrace/\\right\\rbrace/g;

	$brctext =~ s/\\($brsize)\\langle/\\left\\langle/g;
	$brctext =~ s/\\($brsize)\\rangle/\\right\\rangle/g;

	$brctext =~ s/\\($brsize)\\lfloor/\\left\\lfloor/g;
	$brctext =~ s/\\($brsize)\\rfloor/\\right\\rfloor/g;

	$brctext =~ s/\\($brsize)\\(v|V)ert(.*?)\\($brsize)\\(v|V)ert/\\left\\$2ert$3\\right\\$5ert/g;

	return($brctext);
}
########################
sub ins_imageonly(){
	my ($mthtext)=@_;

	my $eqnenv = qr/equation\*|equation|eqnarray\*|eqnarray|align\*|align|multiline\*|multiline|gather\*|gather/x;

	while($mthtext =~ /\\begin{($eqnenv)}(.*?)\\end{($eqnenv)}/s){
		my $eqntxt = $2;
		if($eqntxt =~ /(\\xymatrix|\\xy|{tikzcd}|{tikz}|{tikzpicture})/s){
			$eqntxt = "\\begin{imageonly}"."$eqntxt";
			$eqntxt .= "\\end{imageonly}\n";
			my $labels = "";
			while($eqntxt =~ /\\label($curlbrgrp)/s){
				$labels .= "\\label$1";
				$eqntxt =~ s/\\label($curlbrgrp)//s;
			}
			if($labels){
				$eqntxt =~ s/\\begin{imageonly}/$labels\n\\begin{imageonly}/s;
			}else{
				$eqntxt =~ s/\\begin{imageonly}/\n\\begin{imageonly}/s;
			}
		}
		$mthtext =~ s/\\begin{($eqnenv)}(.*?)\\end{($eqnenv)}/\\begin{X$1}$eqntxt\\end{X$3}/s;
	}
	$mthtext =~ s/{X($eqnenv)}/{$1}/g;
	############################
	while($mthtext =~ /\$\$(.*?)\$\$/s){
		my $eqntxt = $1;
		if($eqntxt =~ /(\\xymatrix|\\xy|{tikzcd}|{tikz}|{tikzpicture})/s){
			$eqntxt = "\\begin{imageonly}"."$eqntxt";
			$eqntxt .= "\\end{imageonly}\n";
			my $labels = "";
			while($eqntxt =~ /\\label($curlbrgrp)/s){
				$labels .= "\\label$1";
				$eqntxt =~ s/\\label($curlbrgrp)//s;
			}
			if($labels){
				$eqntxt =~ s/\\begin{imageonly}/$labels\n\\begin{imageonly}/s;
			}else{
				$eqntxt =~ s/\\begin{imageonly}/\n\\begin{imageonly}/s;
			}
		}
		$mthtext =~ s/\$\$(.*?)\$\$/<dispeqn>$eqntxt<dispeqn>/s;
	}
	$mthtext =~ s/<dispeqn>/\$\$/g;
	############################
	while($mthtext =~ /\\\[(.*?)\\\]/s){
		my $eqntxt = $1;
		if($eqntxt =~ /(\\xymatrix|\\xy|{tikzcd}|{tikz}|{tikzpicture})/s){
			$eqntxt = "\\begin{imageonly}"."$eqntxt";
			$eqntxt .= "\\end{imageonly}\n";
			my $labels = "";
			while($eqntxt =~ /\\label($curlbrgrp)/s){
				$labels .= "\\label$1";
				$eqntxt =~ s/\\label($curlbrgrp)//s;
			}
			if($labels){
				$eqntxt =~ s/\\begin{imageonly}/$labels\n\\begin{imageonly}/s;
			}else{
				$eqntxt =~ s/\\begin{imageonly}/\n\\begin{imageonly}/s;
			}
		}
		
		$mthtext =~ s/\\\[(.*?)\\\]/<DispEqn>$eqntxt<\/DispEqn>/s;
	}
	$mthtext =~ s/<DispEqn>/\\\[/g;
	$mthtext =~ s/<\/DispEqn>/\\\]/g;
	############################
	return($mthtext);
}
########################
sub conv_mathInItalic(){
	my ($italtext)=@_;
	
	$italtext =~ s/{\\it /\\textit{/g;
	$italtext =~ s/{\\em /\\textit{/g;
	$italtext =~ s/\\emph{/\\textit{/g;
	$italtext =~ s/\\\$/\\dollar/g;
	while($italtext =~ /\\ins($curlbrgrp)/){
		my $temp = $1;
		$temp =~ s/,/<comma>/g;
		$italtext =~ s/\\ins($curlbrgrp)/\\Xins$temp/s;
	}
	# $italtext =~ s/\\del($curlbrgrp)//g;
	while($italtext =~ /\\del($curlbrgrp)/){
		my $temp = $1;
		$temp =~ s/,/<comma>/g;
		$italtext =~ s/\\del($curlbrgrp)/\\Xdel$temp/s;
	}
	$italtext =~ s/,}/}, /s;
	$italtext =~ s/\\Xins/\\ins/g;
	$italtext =~ s/\\Xdel/\\del/g;
	$italtext =~ s/<comma>/,/g;

	my $eqcnt = 1;
	my $envcnt = 1;
	while($italtext =~ /\\textit($curlbrgrp)/s){
		my $itstr = $1;
		$itstr = &remove_flcurlbraces($itstr);
		if(($itstr =~ /^\{/s)&&($itstr =~ /\}$/s)){
			$itstr = &remove_flcurlbraces($itstr);
		}
		
		while($itstr =~ /\$([^\$]+)\$/s){
			my $eqstr = $1;
			$mathInItal{"equation$eqcnt"} = "\$$eqstr\$";
			
			$itstr =~ s/\$([^\$]+)\$/<equation$eqcnt>/s;
			$eqcnt++;
		}
		while($itstr =~ /\\begin\{([^\}]+)\}(.*?)\\end\{([^\}]+)\}/s){
			my $envstr = "\\begin\{$1\}$2\\end\{$3\}";
			$EnvInItal{"Environ$envcnt"} = "$envstr";
			
			$itstr =~ s/\\begin\{([^\}]+)\}(.*?)\\end\{([^\}]+)\}/<Environ$envcnt>/s;
			$envcnt++;
		}

		$itstr =~ s/\n/<newline>/g;
		$itstr =~ s/  / /g;
		$itstr =~ s/([ ]+)/ /g;
		my $nitstr = "{\\it $itstr}";
		$itstr = $nitstr;
		$itstr =~ s/<equation(\d+)>/}<equation$1>{\\it /g;
		$itstr =~ s/<Environ(\d+)>/}<Environ$1>{\\it /g;
		$itstr =~ s/ }/} /g;
		$itstr =~ s/{\\it  / {\\it /g;
		$itstr =~ s/{\\it ([,\.:])/$1 {\\it /g;
		$itstr =~ s/ }/} /g;
		$itstr =~ s/  / /g;
		$itstr =~ s/([ ]+)/ /g;

		while($itstr =~ /<equation(\d+)>/s){
			my $mykey = "equation$1";
			my $mykeyeq;
			if(grep { $_ =~ /$mykey/ } keys %mathInItal){
				$mykeyeq = "$mathInItal{$mykey}";
			}
			$itstr =~ s/<equation(\d+)>/$mykeyeq/s;
		}
		while($itstr =~ /<Environ(\d+)>/s){
			my $mykey = "Environ$1";
			my $mykeyenv;
			if(grep { $_ =~ /$mykey/ } keys %EnvInItal){
				$mykeyenv = "$EnvInItal{$mykey}";
			}
			$itstr =~ s/<Environ(\d+)>/\n$mykeyenv\n/s;
		}

		$italtext =~ s/\\textit($curlbrgrp)/$itstr/s;
	}
	$italtext =~ s/ {\\it} / /g;
	$italtext =~ s/{\\it}/ /g;
	$italtext =~ s/\n {\\it / \n{\\it /g;
	while($italtext =~ /<equation(\d+)>/s){
		my $mykey = "equation$1";
		my $mykeyeq;
		if(grep { $_ =~ /$mykey/ } keys %mathInItal){
			$mykeyeq = "$mathInItal{$mykey}";
		}
		$italtext =~ s/<equation(\d+)>/$mykeyeq/s;
	}
	$italtext =~ s/\\dollar/\\\$/g;
	$italtext =~ s/  / /g;
	$italtext =~ s/([ ]+)/ /g;
	$italtext =~ s/{\\it \-/\-{\\it /g;
	$italtext =~ s/<newline>/\n/g;

	undef %mathInItal;
	undef %EnvInItal;
	
	return($italtext);
}
########################
sub remove_emptytag(){
	my ($emptytag)=@_;
	$emptytag =~ s/\n\{/\n\\temptag\{/g;
	$emptytag =~ s/ \{/ \\temptag\{/g;
	$emptytag =~ s/,\{/, \\temptag\{/g;
	$emptytag =~ s/\.\{/\. \\temptag\{/g;
	$emptytag =~ s/\\temptag\{\\(\w+)/\{\\$1/g;
	while($emptytag =~ /\\temptag($curlbrgrp)/){
		my $temptext = $1;
		$temptext = &remove_flcurlbraces($temptext);
		$emptytag =~ s/\\temptag($curlbrgrp)/$temptext/s;
	}
	return($emptytag);
}
########################
sub combine_authsurname(){
	my ($surname)=@_;
	$surname =~ s/ ($spauthwords) / $1\{-\}/g;
	$surname =~ s/\{-\}($spauthwords) /\{-\}$1\{-\}/g;
	$surname =~ s/($spauthwords)\-/$1 /g;
	$surname =~ s/[ ]($spauthwords)[ ]/ $1\{-\}/g;

	$surname =~ s/\-($spauthsuffix)/ $1/g;
	$surname =~ s/ ($spauthsuffix)/ $1/g;
	$surname =~ s/[ ](Jr\.|Snr\.|Sr\.|II\.|III\.|IV\.)[ ]/\{-\}$1 /g;
	$surname =~ s/[ ](Jr,|Snr,|Sr,|II,|III,|IV,)[ ]/\{-\}$1 /g;
	$surname =~ s/[ ](Jr\.,|Snr\.,|Sr\.,|II\.,|III\.,|IV\.,)[ ]/\{-\}$1 /g;
	$surname =~ s/[ ](Jr|Snr|Sr|II|III|IV|\.|,)[ ]/\{-\}$1 /g;
	$surname =~ s/[ ](Jr|Snr|Sr|II|III|IV|\.|,)/\{-\}$1/g;
	return($surname);
}
########################
sub conv_chemformula(){
	my ($chemstr)=@_;
	
	my $chemtext;
	if($chemstr =~ /\\begin{document}(.*?)\\end{document}/s){
		$chemtext = $1;
	}
	
	# open(CHFILE, ">${myfolder}\\$mainfilename-CH\.txt");
	# print CHFILE "$chdata\t-->\t";
	while(($chemtext =~ /\\ce($curlbrgrp)/s)||($chemtext =~ /\\ch($curlbrgrp)/s)){
		my $chdata = $1;
		$chdata =~ s/\\del($curlbrgrp)//g;
		while($chdata =~ /\\ins($curlbrgrp)/){
			my $instext = $1;
			$instext = &remove_flcurlbraces($instext);
			$chdata =~ s/\\ins($curlbrgrp)/$instext/s;
		}
		$chdata =~ s/{\\it /\\textit{/g;
		$chdata =~ s/{\\em /\\textit{/g;
		
		if($chdata !~ /([\s]+)/s){
			if($chdata =~ /\\bond($curlbrgrp)/s){
				goto BOND;
			}
			$chdata =~ s/\+/\$\^{\+}\$/g;
			$chdata =~ s/\_($curlbrgrp)/\$\_$1\$/g;
			$chdata =~ s/\^($curlbrgrp)/\$\^$1\$/g;
			$chdata =~ s/\^([0-9]+)/\$\^{$1}\$/g;
			$chdata =~ s/([A-z])([0-9]+)/$1\$\_{$2}\$/g;
			$chdata =~ s/([0-9]+)([A-z])/\$\_{$1}\$$2/g;
			$chdata =~ s/([A-z])-([A-z])/$1\&ndash\;$2/g;
			$chdata =~ s/([A-z])-($curlbrgrp)/$1\&ndash\;$2/g;
			$chdata =~ s/($curlbrgrp)-([A-z])/$1\&ndash\;$2/g;
			$chdata =~ s/-/\$\^{-}\$/g;
			$chdata =~ s/\$\$\^{\+}\$\$/\$\^{\+}\$/g;
			
			while($chdata =~ /\$\^($curlbrgrp)\$\$\^($curlbrgrp)\$/s){
				my $sup1 = $1;
				my $sup2 = $2;
				$sup1 = &remove_flcurlbraces($sup1);
				$sup2 = &remove_flcurlbraces($sup2);
				
				$chdata =~ s/\$\^($curlbrgrp)\$\$\^($curlbrgrp)\$/\$\^{$sup1$sup2}\$/s;
			}
			while($chdata =~ /\$\_($curlbrgrp)\$\$\_($curlbrgrp)\$/s){
				my $sub1 = $1;
				my $sub2 = $2;
				$sub1 = &remove_flcurlbraces($sub1);
				$sub2 = &remove_flcurlbraces($sub2);
				
				$chdata =~ s/\$\_($curlbrgrp)\$\$\_($curlbrgrp)\$/\$\_{$sub1$sub2}\$/s;
			}
			while($chdata =~ /\$\^($curlbrgrp)\$/s){
				my $temp = $1;
				
				$temp =~ s/\$\^{(\+|\-|-)}\$/$1/g;
				while($temp =~ /\$\_($curlbrgrp)\$/s){
					my $tt = $1;
					$tt = &remove_flcurlbraces($tt);
					$temp =~ s/\$\_($curlbrgrp)\$/$tt/s;
				}
				
				$chdata =~ s/\$\^($curlbrgrp)\$/\$\&carret\;$temp\$/s;
			}
			while($chdata =~ /\$\_($curlbrgrp)\$/s){
				my $temp = $1;
				
				$temp =~ s/\$\&carret\;{(\+|\-|-)}\$/$1/g;
				while($temp =~ /\$\_($curlbrgrp)\$/s){
					my $tt = $1;
					$tt = &remove_flcurlbraces($tt);
					$temp =~ s/\$\_($curlbrgrp)\$/$tt/s;
				}
				
				$chdata =~ s/\$\_($curlbrgrp)\$/\$\&underscore\;$temp\$/s;
			}
			$chdata =~ s/\&carret\;/\^/g;
			$chdata =~ s/\&underscore\;/\_/g;
			###############Final Change#################
			$chdata =~ s/\$\$//g;
			$chdata =~ s/\$/<dollar>/g;
			$chdata =~ s/\&ndash\;/--/g;
			while($chdata =~ /<dollar>(.*?)<dollar>/s){
				my $temp = $1;
				$temp =~ s/\\textit($curlbrgrp)/$1/g;
				$temp =~ s/\\emph($curlbrgrp)/$1/g;
				$chdata =~ s/<dollar>(.*?)<dollar>/<Xdollar>$temp<Xdollar>/s;
			}
			$chdata =~ s/<dollar>/\$/g;
			$chdata =~ s/<Xdollar>/\$/g;
			############################################

			$chemtext =~ s/\\ce($curlbrgrp)/$chdata/s;
			$chemtext =~ s/\\ch($curlbrgrp)/$chdata/s;
		}else{
			BOND:
			$chemtext =~ s/\\ce($curlbrgrp)/\\Xce$chdata/s;
			$chemtext =~ s/\\ch($curlbrgrp)/\\Xch$chdata/s;
		}
		
	}
	# close(CHFILE);
	$chemtext =~ s/\\Xc(e|h)/\\c$1/g;

	$chemstr =~ s/\\begin{document}(.*?)\\end{document}/\\begin{document}$chemtext\\end{document}/s;
	return($chemstr);
}
########################
sub remove_flcurlbraces(){
	my ($flctext)=@_;
	$flctext =~ s/^\{//s;
	$flctext =~ s/\}$//s;
	return($flctext);
}
########################
sub write_newfile(){
	my ($finaltext)=@_;
	open(OUTFILE, ">${myfolder}\\$mainfilename-New\.$extn");
	print OUTFILE "$finaltext";
	close(OUTFILE);
}
########################
