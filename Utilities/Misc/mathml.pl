#!/usr/bin/perl

# This programme is designed to convert Mathml into TeX code developed by Saiful Islam

#system("cls");
system("clear");

my $file = "$ARGV[0]";
my $filen = "$file.xml";
undef $/;

open (INPUT, "<$filen") or die $!;
print "$filen\n";
my $inputstr=<INPUT>;
close (INPUT);

my $ofile = "$file.tex";
open (OUTPUT, ">$ofile") or die $!;
print "$ofile\n";

my $line=$inputstr;
$line =~ s/\n//g;
$line =~ s/\s*//g;
$line =~ s/<mo>&\#x2061\;<\/mo>//g;
#$line =~ s/>(.*)</></g;
$line =~ s/<math><semantics><mrow>//g;
$line =~ s/<math><semantics>//g;
$line =~ s/<semantics><mrow>//g;
$line =~ s/<semantics>//g;
#$line =~ s/<annotation(\w*)(.*?).*$//;
#################################################
$line =~ s/<\/mrow><annotation([^][]*)$//g;
$line =~ s/<annotation([^][]*)$//g;
$line =~ s/MathType([^][]*)$//g;
$line =~ s/<\/semantics>//g;
$line =~ s/<\/math>//g;
################################################
$line =~ s/<msup><mtext>([^][]*)<\/mtext><mtext>([0-9]+)<\/mtext><\/msup>/{\\rm $1}^{$2}/g;
$line =~ s/<mtext>([.\w]+)&nbsp;<\/mtext>/\\mbox{$1} /g;
$line =~ s/<mtext>&nbsp;([.\w]+)<\/mtext>/ \\mbox{$1}/g;
$line =~ s/<mtext>&nbsp;([.\w]+)&nbsp;<\/mtext>/ \\mbox{$1} /g;
$line =~ s/<msup><mrow><mtext>&nbsp;([a-zA-Z]+)\/([a-zA-Z]+)<\/mtext><\/mrow><mn>([0-9]+)<\/mn><\/msup>/\\,\\mbox{$1\/$2}^{$3}/g;
$line =~ s/<msup><mrow><mtext>&nbsp;([a-zA-Z]+)<\/mtext><\/mrow><mrow><mo>&\#x2212\;<\/mo><mn>([0-9]+)<\/mn><\/mrow><\/msup>/\\,{$1}^{-$2}/g;
$line =~ s/<msup><mi>([a-zA-Z]+)<\/mi><mrow><mo>&\#x2212\;<\/mo><mn>([0-9]+)<\/mn><\/mrow><\/msup>/{$1}^{-$2}/g;
$line =~ s/<msup><mtext>&nbsp;([.\w]+)\/([.\w]+)<\/mtext><mn>([0-9]+)<\/mn><\/msup>/\\,\\mbox{$1\/$2}^{$3}/g;
$line =~ s/<mtext>&nbsp;([.\w]+)<\/mtext>/\\,\\mbox{$1}/g;
$line =~ s/<mtext>&nbsp;([.\w]+)\/([.\w]+)<\/mtext>/\\,\\mbox{$1\/$2}/g;
$line =~ s/<mtext>,&nbsp;([.\w]+)&nbsp;<\/mtext>/, \\mbox{$1} /g;
$line =~ s/<mtext>&nbsp;([.\w]+)\/([.\w]+)\:&nbsp;<\/mtext>/\\mbox{$1\/$2}\: /g;
$line =~ s/<mtext>&nbsp;([.\w]+)\/([.\w]+),&nbsp;<\/mtext>/\\mbox{$1\/$2}, /g;
$line =~ s/<mtext>&nbsp;([a-zA-Z]+),&nbsp;<\/mtext>/\\mbox{$1}, /g;
$line =~ s/<mtext>,&nbsp;<\/mtext>/, /g;
$line =~ s/([.\w]+)&nbsp;([.\w]+)/$1 $2/g;
$line =~ s/([.\w]+)&nbsp;/$1 /g;
$line =~ s/&nbsp;([.\w]+)/ $1/g;


$line =~ s/<msup><mrow><mn>([0-9]+)<\/mn><\/mrow><mn>([0-9]+)<\/mn><\/msup>/{$1}^{$2}/g;
$line =~ s/<msup><mi>([a-zA-Z]+)<\/mi><mn>([0-9]+)<\/mn><\/msup>/{$1}^{$2}/g;
$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mn>([0-9]+)<\/mn><\/msub>/{$1}_{$2}/g;
$line =~ s/<msub><mn>([0-9]+)<\/mn><mn>([0-9]+)<\/mn><\/msub>/{$1}_{$2}/g;
$line =~ s/<msub><mstylemathvariant=\'bold\'mathsize=\'normal\'><mi>([a-zA-Z]+)<\/mi><\/mstyle><mn>([0-9]+)<\/mn><\/msub>/\\bm{$1}_{$2}/g;
$line =~ s/<msub><mstylemathvariant=\'bold\'mathsize=\'normal\'><mi>([a-zA-Z]+)<\/mi><\/mstyle><mi>([a-zA-Z]+)<\/mi><\/msub>/\\bm{$1}_{$2}/g;
$line =~ s/<msub><mstylemathvariant=\'bold\'mathsize=\'normal\'><mi>([a-zA-Z]+)<\/mi><\/mstyle><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+)\;<\/mi><\/msub>/\\bm{$1}_{&\#x$2$3$4\;}/g;
$line =~ s/<msub><mstylemathvariant=\'bold\'mathsize=\'normal\'><mi>([a-zA-Z]+)<\/mi><\/mstyle><mrow>([^][]*)<\/mrow><\/msub>/\\bm{$1}_{$2}/g;
$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mrow><mtext>([.\w]*)<\/mtext><\/mrow><\/msub>/{$1}_{\\mbox{$2}}/g;
$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mrow><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/mrow><\/msub>/{$1}_{$2$3}/g;
$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mrow><mi>([a-zA-Z]+)<\/mi><\/mrow><\/msub>/{$1}_{$2}/g;
$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msub>/{$1}_{$2}/g;
$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+);<\/mi><\/msub>/{$1}_{&\#x$2$3$4\;}/g;
$line =~ s/<msup><mi>([a-zA-Z]+)<\/mi><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+);<\/mi><\/msup>/{$1}^{&\#x$2$3$4\;}/g;

$line =~ s/<mstylemathvariant=\'bold\'mathsize=\'normal\'><mi>([a-zA-Z]+)<\/mi><\/mstyle>/\\bm{$1}/g;
$line =~ s/<msup><mrow><mn>([0-9]+)<\/mn><\/mrow><mrow><mo>&#x2212;<\/mo><mn>([0-9]+)<\/mn><\/mrow><\/msup>/{$1}^{-$2}/g;
$line =~ s/<msup><mrow><mtext>&nbsp\;ft\/sec<\/mtext><\/mrow><mn>([0-9]+)<\/mn><\/msup>/\\,{ft\/sec}^{$1}/g;
$line =~ s/<msup><mrow><mtext>&nbsp\;ft\/s<\/mtext><\/mrow><mn>([0-9]+)<\/mn><\/msup>/\\,{ft\/s}^{$1}/g;
$line =~ s/<msup><mtext>([a-zA-Z]+)<\/mtext><mn>([0-9]+)<\/mn><\/msup>/\\mbox{$1}^{$2}/g;
$line =~ s/<msup><mrow><mtext>([a-zA-Z]+)<\/mtext><\/mrow><mrow><mtext>-([0-9]+)<\/mtext><\/mrow><\/msup>/\\mbox{$1}^{-\\mbox{$2}}/g;
$line =~ s/<msup><mtext>([a-zA-Z]+)<\/mtext><mrow><mtext>-([0-9]+)<\/mtext><\/mrow><\/msup>/\\mbox{$1}^{-\\mbox{$2}}/g;
$line =~ s/<msup><mi>([a-zA-Z])<\/mi><mn>([0-9]+)<\/mn><\/msup>/{$1}^{$2}/g;
$line =~ s/<msup><mrow><mtext>&nbsp;([a-zA-Z]+)\/([a-zA-Z]+)<\/mtext><\/mrow><mn>([0-9]+)<\/mn><\/msup>/ \\mbox{$1\/$2}^{$3}/g;
$line =~ s/<msup><mi>([a-zA-Z])<\/mi><mrow>/{$1}^{/g;
$line =~ s/<msup><mrow><mi>sin<\/mi><\/mrow><mn>([0-9]+)<\/mn><\/msup>/{\\sin}^{$1}/g;

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% COMPLEX SUPERSCRIPTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
$line =~ s/<msup><mrow>([^][]*)<\/mrow><mi>([a-zA-Z]+)<\/mi><\/msup>/{$1}^{$2}/g;
$line =~ s/<msup><mrow>([^][]*)<\/mrow><mtext>([a-zA-Z]+)<\/mtext><\/msup>/{$1}^{\\rm $2}/g;
$line =~ s/<msup><mrow>([^][]*)<\/mrow><mtext>([0-9]+)<\/mtext><\/msup>/{$1}^{$2}/g;
$line =~ s/<msup><mrow>([^][]*)<\/mrow><mn>([0-9]+)<\/mn><\/msup>/{$1}^{$2}/g;
$line =~ s/<msup><mrow>([^][]*)<\/mrow><mrow>([^][]*)<\/mrow><\/msup>/{$1}^{$2}/g;
$line =~ s/<msup><mi>([^][]*)<\/mi><mrow>([^][]*)<\/mrow><\/msup>/{$1}^{$2}/g;
$line =~ s/<msup><mn>([^][]*)<\/mn><mrow>([^][]*)<\/mrow><\/msup>/{$1}^{$2}/g;
$line =~ s/<msup><mtext>([^][]*)<\/mtext><mrow>([^][]*)<\/mrow><\/msup>/{\\rm $1}^{$2}/g;

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% COMPLEX SUBSCRIPTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
$line =~ s/<msub><mrow>([^][]*)<\/mrow><mi>([a-zA-Z]+)<\/mi><\/msub>/{$1}_{$2}/g;
$line =~ s/<msub><mrow>([^][]*)<\/mrow><mtext>([a-zA-Z]+)<\/mtext><\/msub>/{$1}_{\\rm $2}/g;
$line =~ s/<msub><mrow>([^][]*)<\/mrow><mn>([0-9]+)<\/mn><\/msub>/{$1}_{$2}/g;
$line =~ s/<msub><mrow>([^][]*)<\/mrow><mrow>([^][]*)<\/mrow><\/msub>/{$1}_{$2}/g;
$line =~ s/<msub><mi>([^][]*)<\/mi><mrow>([^][]*)<\/mrow><\/msub>/{$1}_{$2}/g;
$line =~ s/<msub><mn>([^][]*)<\/mn><mrow>([^][]*)<\/mrow><\/msub>/{$1}_{$2}/g;
$line =~ s/<msub><mtext>([^][]*)<\/mtext><mrow>([^][]*)<\/mrow><\/msub>/{\\rm $1}_{$2}/g;
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$line =~ s/<mfrac><mrow><msubsup><mi>([a-zA-Z]+)<\/mi><mn>([0-9]+)<\/mn><mn>([0-9]+)<\/mn><\/msubsup><\/mrow><mi>([a-zA-Z]+)<\/mi><\/mfrac>/\\frac{$1_{$2}^{$3}}{$4}/g;
$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mn>([0-9]+)<\/mn><mn>([0-9]+)<\/mn><\/msubsup>/{$1}_{$2}^{$3}/g;
$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><mo>&\#x2032\;<\/mo><\/msubsup>/{$1}_{$2}^{\\prime}/g;
$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mn>([0-9]+)<\/mn><mo>&\#x2032\;<\/mo><\/msubsup>/{$1}_{$2}^{\\prime}/g;

##################### FRACTIONS ###########################
$line =~ s/<mfrac><mn>([0-9]+)<\/mn><mi>([a-zA-Z]+)<\/mi><\/mfrac>/\\frac{$1}{$2}/g;
$line =~ s/<mfrac><mi>([a-zA-Z]+)<\/mi><mn>([0-9]+)<\/mn><\/mfrac>/\\frac{$1}{$2}/g;
$line =~ s/<mfrac><mi>([a-zA-Z]+)<\/mi><mrow>([^][]*)<\/mrow><\/mfrac>/\\frac{$1}{$2}/g;
$line =~ s/<mfrac><mrow><mi>([.\w]+)<\/mi><mn>([0-9]+)<\/mn><\/mrow><mi>([a-zA-Z]+)<\/mi><\/mfrac>/\\frac{$1$2}{$3}/g;
$line =~ s/<mfrac><mrow><mn>([0-9]+)<\/mn><\/mrow><mn>([0-9]+)<\/mn><\/mfrac>/\\frac{$1}{$2}/g;
$line =~ s/<mfrac><mn>([0-9]+)<\/mn><mrow><mn>([0-9]+)<\/mn><\/mrow><\/mfrac>/\\frac{$1}{$2}/g;
$line =~ s/<mfrac><mn>([0-9]+)<\/mn><mn>([0-9]+)<\/mn><\/mfrac>/\\frac{$1}{$2}/g;
$line =~ s/<mfrac><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/mfrac>/\\frac{$1}{$2}/g;
#$line =~ s/<mfrac><mrow><mi>([a-zA-Z]+)<\/mi><\/mrow><mi>([a-zA-Z]+)<\/mi><\/mfrac>/\\frac{$1}{$2}/g;
#$line =~ s/<mfrac><mi>([a-zA-Z]+)<\/mi><mrow><mi>([a-zA-Z]+)<\/mi><\/mrow><\/mfrac>/\\frac{$1}{$2}/g;
#$line =~ s/<mfrac><mn>([0-9]+)<\/mn><mrow>/\\frac{$1}{/g;
#$line =~ s/<mfrac><mi>([a-zA-Z]+)<\/mi><mrow><mi>([a-zA-Z]+)<\/mi><mo>&\#x2212\;<\/mo><mi>([a-zA-Z]+)<\/mi><\/mrow><\/mfrac>/\\frac{$1}{$2 - $3}/g;
$line =~ s/<mfracbevelled=\'true\'><mi>([a-zA-Z]+)<\/mi><mn>([0-9]+)<\/mn><\/mfrac>/{$1\/$2}/g;

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% COMPLEX FRACTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
$line =~ s/<mfrac><mrow>([^][]*)<\/mrow><mi>([a-zA-Z]+)<\/mi><\/mfrac>/\\frac{$1}{$2}/g;
$line =~ s/<mfrac><mrow>([^][]*)<\/mrow><mtext>([a-zA-Z]+)<\/mtext><\/mfrac>/\\frac{$1}{$2}/g;
$line =~ s/<mfrac><mrow>([^][]*)<\/mrow><mn>([0-9]+)<\/mn><\/mfrac>/\\frac{$1}{$2}/g;
$line =~ s/<mfrac><mrow>([^][]*)<\/mrow><mrow>([^][]*)<\/mrow><\/mfrac>/\\frac{$1}{$2}/g;
$line =~ s/<mfrac><mi>([^][]*)<\/mi><mrow>([^][]*)<\/mrow><\/mfrac>/\\frac{$1}{$2}/g;
$line =~ s/<mfrac><mn>([^][]*)<\/mn><mrow>([^][]*)<\/mrow><\/mfrac>/\\frac{$1}{$2}/g;
$line =~ s/<mfrac><mtext>([^][]*)<\/mtext><mrow>([^][]*)<\/mrow><\/mfrac>/\\frac{$1}{$2}/g;
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

###%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ENTITY SUB-SUP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
$line =~ s/<msub><mi>&\#x([0-9]+)\;<\/mi><mi>([a-zA-Z]+)<\/mi><\/msub>/{&\#x$1;}_{$2}/g;
$line =~ s/<msub><mi>&\#x([a-zA-Z]+)([0-9]+)\;<\/mi><mi>([a-zA-Z]+)<\/mi><\/msub>/{&\#x$1$2;}_{$3}/g;
$line =~ s/<msub><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+)\;<\/mi><mi>([a-zA-Z]+)<\/mi><\/msub>/{&\#x$1$2$3;}_{$4}/g;
$line =~ s/<msub><mi>&\#x([0-9]+)([a-zA-Z]+)\;<\/mi><mi>([a-zA-Z]+)<\/mi><\/msub>/{&\#x$1$2;}_{$3}/g;
$line =~ s/<msub><mi>&\#x([0-9]+)\;<\/mi><mn>([0-9]+)<\/mn><\/msub>/{&\#x$1;}_{$2}/g;
$line =~ s/<msub><mi>&\#x([a-zA-Z]+)([0-9]+)\;<\/mi><mn>([0-9]+)<\/mn><\/msub>/{&\#x$1$2;}_{$3}/g;
$line =~ s/<msub><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+)\;<\/mi><mn>([0-9]+)<\/mn><\/msub>/{&\#x$1$2$3;}_{$4}/g;
$line =~ s/<msub><mi>&\#x([0-9]+)([a-zA-Z]+)\;<\/mi><mn>([0-9]+)<\/mn><\/msub>/{&\#x$1$2;}_{$3}/g;
$line =~ s/<msub><mi>&\#x([0-9]+)\;<\/mi><mtext>([^][]*)<\/mtext><\/msub>/{&\#x$1;}_{$2}/g;
$line =~ s/<msub><mi>&\#x([a-zA-Z]+)([0-9]+)\;<\/mi><mtext>([^][]*)<\/mtext><\/msub>/{&\#x$1$2;}_{$3}/g;
$line =~ s/<msub><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+)\;<\/mi><mtext>([^][]*)<\/mtext><\/msub>/{&\#x$1$2$3;}_{$4}/g;
$line =~ s/<msub><mi>&\#x([0-9]+)([a-zA-Z]+)\;<\/mi><mtext>([^][]*)<\/mtext><\/msub>/{&\#x$1$2;}_{$3}/g;
######
$line =~ s/<msup><mi>&\#x([0-9]+)\;<\/mi><mi>([a-zA-Z]+)<\/mi><\/msup>/{&\#x$1;}^{$2}/g;
$line =~ s/<msup><mi>&\#x([a-zA-Z]+)([0-9]+)\;<\/mi><mi>([a-zA-Z]+)<\/mi><\/msup>/{&\#x$1$2;}^{$3}/g;
$line =~ s/<msup><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+)\;<\/mi><mi>([a-zA-Z]+)<\/mi><\/msup>/{&\#x$1$2$3;}^{$4}/g;
$line =~ s/<msup><mi>&\#x([0-9]+)([a-zA-Z]+)\;<\/mi><mi>([a-zA-Z]+)<\/mi><\/msup>/{&\#x$1$2;}^{$3}/g;
$line =~ s/<msup><mi>&\#x([0-9]+)\;<\/mi><mn>([0-9]+)<\/mn><\/msup>/{&\#x$1;}^{$2}/g;
$line =~ s/<msup><mi>&\#x([a-zA-Z]+)([0-9]+)\;<\/mi><mn>([0-9]+)<\/mn><\/msup>/{&\#x$1$2;}^{$3}/g;
$line =~ s/<msup><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+)\;<\/mi><mn>([0-9]+)<\/mn><\/msup>/{&\#x$1$2$3;}^{$4}/g;
$line =~ s/<msup><mi>&\#x([0-9]+)([a-zA-Z]+)\;<\/mi><mn>([0-9]+)<\/mn><\/msup>/{&\#x$1$2;}^{$3}/g;
$line =~ s/<msup><mi>&\#x([0-9]+)\;<\/mi><mtext>([^][]*)<\/mtext><\/msup>/{&\#x$1;}^{$2}/g;
$line =~ s/<msup><mi>&\#x([a-zA-Z]+)([0-9]+)\;<\/mi><mtext>([^][]*)<\/mtext><\/msup>/{&\#x$1$2;}^{$3}/g;
$line =~ s/<msup><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+)\;<\/mi><mtext>([^][]*)<\/mtext><\/msup>/{&\#x$1$2$3;}^{$4}/g;
$line =~ s/<msup><mi>&\#x([0-9]+)([a-zA-Z]+)\;<\/mi><mtext>([^][]*)<\/mtext><\/msup>/{&\#x$1$2;}^{$3}/g;
###%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$line =~ s/<msup><moveraccent=\'true\'><mi>([a-zA-Z]+)<\/mi><mo>&\#x02D9\;<\/mo><\/mover><mn>([0-9]+)<\/mn><\/msup>/\\dot{$1}^{$2}/g;
$line =~ s/<msup><moveraccent=\'true\'><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+)\;<\/mi><mo>&\#x02D9\;<\/mo><\/mover><mn>([0-9]+)<\/mn><\/msup>/\\dot{&\#x$1$2$3;}^{$4}/g;
$line =~ s/<msub><moveraccent=\'true\'><mi>([a-zA-Z]+)<\/mi><mo>&\#x02D9\;<\/mo><\/mover><mn>([0-9]+)<\/mn><\/msub>/\\dot{$1}_{$2}/g;
$line =~ s/<msub><moveraccent=\'true\'><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+)\;<\/mi><mo>&\#x02D9\;<\/mo><\/mover><mn>([0-9]+)<\/mn><\/msub>/\\dot{&\#x$1$2$3;}_{$4}/g;
$line =~ s/<mover accent=\'true\'><mi>([a-zA-Z]+)<\/mi><mo>&\#x02D9\;<\/mo><\/mover>/\\dot{$1}/g;
$line =~ s/<moveraccent=\'true\'><mi>([a-zA-Z]+)<\/mi><mo>&\#x02D9\;<\/mo><\/mover>/\\dot{$1}/g;
$line =~ s/<moveraccent=\'true\'><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+)\;<\/mi><mo>&\#x02D9\;<\/mo><\/mover>/\\dot{&\#x$1$2$3;}/g;
$line =~ s/<moveraccent=\'true\'><mi>&\#x([0-9]+)\;<\/mi><mo>&\#x02D9\;<\/mo><\/mover>/\\dot{&\#x$1;}/g;
#####
$line =~ s/<msup><moveraccent=\'true\'><mi>([a-zA-Z]+)<\/mi><mo>&\#x00A8\;<\/mo><\/mover><mn>([0-9]+)<\/mn><\/msup>/\\ddot{$1}^{$2}/g;
$line =~ s/<msup><moveraccent=\'true\'><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+)\;<\/mi><mo>&\#x00A8\;<\/mo><\/mover><mn>([0-9]+)<\/mn><\/msup>/\\ddot{&\#x$1$2$3;}^{$4}/g;
$line =~ s/<msub><moveraccent=\'true\'><mi>([a-zA-Z]+)<\/mi><mo>&\#x00A8\;<\/mo><\/mover><mn>([0-9]+)<\/mn><\/msub>/\\ddot{$1}_{$2}/g;
$line =~ s/<msub><moveraccent=\'true\'><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+)\;<\/mi><mo>&\#x00A8\;<\/mo><\/mover><mn>([0-9]+)<\/mn><\/msub>/\\ddot{&\#x$1$2$3;}_{$4}/g;
$line =~ s/<mover accent=\'true\'><mi>([a-zA-Z]+)<\/mi><mo>&\#x00A8\;<\/mo><\/mover>/\\ddot{$1}/g;
$line =~ s/<moveraccent=\'true\'><mi>([a-zA-Z]+)<\/mi><mo>&\#x00A8\;<\/mo><\/mover>/\\ddot{$1}/g;
$line =~ s/<moveraccent=\'true\'><mi>&\#x([0-9]+)([a-zA-Z]+)([0-9]+)\;<\/mi><mo>&\#x00A8\;<\/mo><\/mover>/\\ddot{&\#x$1$2$3;}/g;
$line =~ s/<moveraccent=\'true\'><mi>&\#x([0-9]+)\;<\/mi><mo>&\#x00A8\;<\/mo><\/mover>/\\ddot{&\#x$1;}/g;

###########################################################
$line =~ s/<mn>([0-9]+)<\/mn><mi>&\#x03C0\;<\/mi>/$1\\pi /g;
$line =~ s/<mi>&\#x03C0\;<\/mi><mi>([a-zA-Z]+)<\/mi>/\\pi $1/g;
$line =~ s/<msup><mi>&#x03C0;<\/mi><mn>([0-9]+)<\/mn><\/msup>/\\pi^{$1}/g;

$line =~ s/<mi>sin<\/mi>/\\sin/g;
$line =~ s/<mi>cos<\/mi>/\\cos/g;
$line =~ s/<mi>sec<\/mi>/\\sec/g;
$line =~ s/<mi>cot<\/mi>/\\cot/g;
$line =~ s/<mi>cosec<\/mi>/\\cosec/g;
$line =~ s/<mi>tan<\/mi>/\\tan/g;
$line =~ s/<mtext>\s([^][]*)<\/mtext>/ \\mbox{$1} /g;
$line =~ s/<mtext>([^][]*)\s<\/mtext>/ \\mbox{$1} /g;
$line =~ s/<mtext>\s([^][]*)\s<\/mtext>/ \\mbox{$1} /g;
$line =~ s/<mtext>([^][]*)<\/mtext>/ \\mbox{$1} /g;
$line =~ s/<mo>([^][]*)<\/mo>/$1/g;
$line =~ s/<mn>([^][]*)<\/mn>/$1/g;
$line =~ s/<mi>([a-zA-Z]+)<\/mi>/$1/g;
$line =~ s/<mi>([^][]*)<\/mi>/$1/g;
############################################
$line =~ s/<mtext>&nbsp;<\/mtext>/ /g;
$line =~ s/<mtext>//g;
$line =~ s/<\/mtext>//g;
$line =~ s/&nbsp;/ /g;
$line =~ s/<mo>//g;
$line =~ s/<\/mo>//g;
$line =~ s/<mn>//g;
$line =~ s/<\/mn>//g;
$line =~ s/<mrow>/{/g;
$line =~ s/<\/mrow>/}/g;
$line =~ s/<mo>+<\/mo>/ + /g;
$line =~ s/<mo>-<\/mo>/ - /g;
$line =~ s/<mo>=<\/mo>/ = /g;
$line =~ s/\+/ + /g;
$line =~ s/-/ - /g;
$line =~ s/=/ = /g;
$line =~ s/ ,/,/g;
$line =~ s/{ - ([0-9]+)}/{-$1}/g;
$line =~ s/&\#x2212\;/ - /g;
$line =~ s/&\#x00D7\;/ \\mult /g;
$line =~ s/&\#x22C5\;/ \\cdot /g;
$line =~ s/&\#x03B8\;/\\theta /g;

$line =~ s/&\#x03B1\;/ \\alpha /g;
$line =~ s/&\#x003C\;/ \\lt /g;
$line =~ s/&\#x2264\;/ \\le /g;
$line =~ s/&\#x2192\;/ \\rightarrow /g;
$line =~ s/&\#x221E\;/ \\infty /g;
$line =~ s/&\#x03C0\;/ \\pi /g;
$line =~ s/&\#x0394\;/ \\Delta /g;
$line =~ s/&\#x03C1\;/ \\rho /g;
$line =~ s/&\#x03C6\;/ \\phi /g;
$line =~ s/&\#x03B4\;/ \\delta /g;
$line =~ s/&\#x03A9\;/ \\Omega /g;
$line =~ s/&\#x03C9\;/ \\omega /g;
$line =~ s/&\#x03B2\;/ \\beta /g;
$line =~ s/&\#x03B3\;/ \\gamma /g;
$line =~ s/&\#x2032\;/\\prime/g;
$line =~ s/<msqrt>/\\sqrt{/g;
$line =~ s/<\/msqrt>/}/g;
$line =~ s/&\#x2061\;//g;


$line =~ s/&\#x00B0\;/^{\\circ}/g;

$line =~ s/<mathdisplay = \'block\'>//g;
$line =~ s/ &([a-zA-Z]+)\; / &$1\; /g;
$line =~ s/<mfrac>{/\\frac{/g;
$line =~ s/}<\/mfrac>/}/g;
$line =~ s/<\/msup>//g;
$line =~ s/\\mbox{}//g;
$line =~ s/ \\mbox{,} /, /g;
$line =~ s/\\mbox{ - ([0-9]+)}/\\mbox{-$1}/g;
$line =~ s/{ - ([a-zA-Z]+)}/{-$1}/g;
$line =~ s/{ /{/g;
$line =~ s/ }/}/g;
$line =~ s/  / /g;
$line =~ s/,([a-zA-Z]+)/, $1/g;
$line =~ s/,([0-9]+)/, $1/g;
$line =~ s/\\, /\\,/g;
$line =~ s/ <\/mi>//g;
$line =~ s/<mi>//g;
$line =~ s/{max}/{\\rm max}/g;
$line =~ s/{min}/{\\rm min}/g;


print OUTPUT "$line";
close (OUTPUT);

print "Converted successfull!!!\n";


#=begin comment
#=cut
