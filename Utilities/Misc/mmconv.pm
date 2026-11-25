package mmconv;
use strict;

sub space
{
	my $line = $_;

	################## MISCELLENOUS #################################
	$line =~ s/<m(\w+)>\s/<m$1>/g;
	$line =~ s/<\/m(\w+)>\s/<\/m$1>/g;
	$line =~ s/([^<])\s*\n/$1/g;
	$line =~ s/([^>])\s*\n/$1/g;
	$line =~ s/\s<semantics>\n\s*//g;
	$line =~ s/<semantics>\n\s*//g;
	$line =~ s/\s<semantics>//g;
	$line =~ s/\s<annotation([^][]*)$//g;
	$line =~ s/<annotation([^][]*)$//g;
	$line =~ s/\sMathType([^][]*)$//g;
	$line =~ s/MathType([^][]*)$//g;
	$line =~ s/\s<\/semantics>\n\s*//g;
	$line =~ s/<\/semantics>\n\s*//g;
	$line =~ s/\s<\/semantics>//g;
	$line =~ s/\$\n\s*/\$/g;
	$line =~ s/\[/\[\n/g;
	$line =~ s/\\]/\n\\]/g;
	$line =~ s/\s*\<\s*/\</g;
	$line =~ s/<p>/\n<p>/g;
	$line =~ s/<\/p>/<\/p>\n/g;
	$line =~ s/<mtext>&nbsp\;/<mtext>/g;
	$line =~ s/&nbsp\;<\/mtext>/<\/mtext>/g;

	#################################################################
	return $line;
}

##################################################################################################################

sub math
{
	my $line = $_;
	$line =~ s/>\s*</></g;
	my $flag = 0;

	#################################### TABULAR EQUATIONS ###############################
	if ($line =~ /<mtable/g)
	{	
		$line =~ s/<mtable columnalign = \'/\\begin{array}\{/g;
		$line =~ s/<mtable columnalign=\'/\\begin{array}\{/g;
		
		if($line =~ /(\w+)\'><mtr><mtd>/g)
		{
			$flag = 1;
		}
		
		if($flag == 1)
		{
			$line =~ s/left | left| left |left/l/g;
			$line =~ s/center | center| center |center/c/g;
			$line =~ s/right | right| right |right/r/g;
			$line =~ s/\'><mtr><mtd>/\}\n/g;
		}
		
		$line =~ s/<\/mtd><\/mtr><mtr><mtd>/\\\\\n/g;
		$line =~ s/<\/mtd><mtd>/ & /g;
		$line =~ s/<\/mtd><\/mtr><\/mtable>/\\\\\n\\end{array}/g;
	}
	######################################################################################
	$line =~ s/<mtext>,<\/mtext>/, /g;
	$line =~ s/<mtext>,/<mo>,<\/mo><mtext>/g;
	$line =~ s/<mtext>:/<mo>:<\/mo><mtext>/g;
	$line =~ s/<mtext>;/<mo>;<\/mo><mtext>/g;
	$line =~ s/,<\/mtext>/<\/mtext><mo>,<\/mo>/g;
	$line =~ s/:<\/mtext>/<\/mtext><mo>:<\/mo>/g;
	$line =~ s/(\w+)&nbsp\;(\d+)/$1<\/mtext><mn>$2<\/mn><mtext>/g;
	$line =~ s/<mi><\/mi>//g;
	$line =~ s/<mo><\/mo>//g;
	$line =~ s/<mn><\/mn>//g;
	$line =~ s/<mtext><\/mtext>//g;


	#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUPERSCRIPTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	$line =~ s/<msup><mi>\\(\w+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msup>/{\\$1}^{$2}/g;
	$line =~ s/<msup><mi> \\(\w+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msup>/{\\$1}^{$2}/g;
	$line =~ s/<msup><mi>\\(\w+) <\/mi><mi>([a-zA-Z]+)<\/mi><\/msup>/{\\$1}^{$2}/g;
	$line =~ s/<msup><mi> \\(\w+) <\/mi><mi>([a-zA-Z]+)<\/mi><\/msup>/{\\$1}^{$2}/g;
	$line =~ s/<msup><mi>\\(\w+)<\/mi><mn>(\d+)<\/mn><\/msup>/{\\$1}^{$2}/g;
	$line =~ s/<msup><mi> \\(\w+)<\/mi><mn>(\d+)<\/mn><\/msup>/{\\$1}^{$2}/g;
	$line =~ s/<msup><mi>\\(\w+) <\/mi><mn>(\d+)<\/mn><\/msup>/{\\$1}^{$2}/g;
	$line =~ s/<msup><mi> \\(\w+) <\/mi><mn>(\d+)<\/mn><\/msup>/{\\$1}^{$2}/g;
	$line =~ s/<msup><mi>\\(\w+)<\/mi><mtext>(.*?)<\/mtext><\/msup>/{\\$1}^{$2}/g;
	$line =~ s/<msup><mi> \\(\w+)<\/mi><mtext>(.*?)<\/mtext><\/msup>/{\\$1}^{$2}/g;
	$line =~ s/<msup><mi>\\(\w+) <\/mi><mtext>(.*?)<\/mtext><\/msup>/{\\$1}^{$2}/g;
	$line =~ s/<msup><mi> \\(\w+) <\/mi><mtext>(.*?)<\/mtext><\/msup>/{\\$1}^{$2}/g;
	$line =~ s/<msup><mi>([a-zA-Z]+)<\/mi><mi>\\(\w+)<\/mi><\/msup>/{$1}^{\\$2}/g;
	$line =~ s/<msup><mi>([a-zA-Z]+)<\/mi><mi> \\(\w+)<\/mi><\/msup>/{$1}^{\\$2}/g;
	$line =~ s/<msup><mi>([a-zA-Z]+)<\/mi><mi>\\(\w+) <\/mi><\/msup>/{$1}^{\\$2}/g;
	$line =~ s/<msup><mi>([a-zA-Z]+)<\/mi><mi> \\(\w+) <\/mi><\/msup>/{$1}^{\\$2}/g;
	$line =~ s/<msup><mn>(\d+)<\/mn><mi>\\(\w+)<\/mi><\/msup>/{$1}^{\\$2}/g;
	$line =~ s/<msup><mn>(\d+)<\/mn><mi> \\(\w+)<\/mi><\/msup>/{$1}^{\\$2}/g;
	$line =~ s/<msup><mn>(\d+)<\/mn><mi>\\(\w+) <\/mi><\/msup>/{$1}^{\\$2}/g;
	$line =~ s/<msup><mn>(\d+)<\/mn><mi> \\(\w+) <\/mi><\/msup>/{$1}^{\\$2}/g;
	$line =~ s/<msup><mtext>(.*?)<\/mtext><mi>\\(\w+)<\/mi><\/msup>/{$1}^{\\$2}/g;
	$line =~ s/<msup><mtext>(.*?)<\/mtext><mi> \\(\w+)<\/mi><\/msup>/{$1}^{\\$2}/g;
	$line =~ s/<msup><mtext>(.*?)<\/mtext><mi>\\(\w+) <\/mi><\/msup>/{$1}^{\\$2}/g;
	$line =~ s/<msup><mtext>(.*?)<\/mtext><mi> \\(\w+) <\/mi><\/msup>/{$1}^{\\$2}/g;
	$line =~ s/<msup><mtext>(.*?)<\/mtext><mtext>(\d+)<\/mtext><\/msup>/{\\rm $1}^{$2}/g;
	$line =~ s/<msup><mtext>(.*?)<\/mtext><mn>(\d+)<\/mn><\/msup>/{\\rm $1}^{$2}/g;
	$line =~ s/<msup><mtext>(\w+)<\/mtext><mi>([a-zA-Z]+)<\/mi><\/msup>/{\\rm $1}^{$2}/g;
	$line =~ s/<msup><mn>(\d+)<\/mn><mn>(\d+)<\/mn><\/msup>/{$1}^{$2}/g;
	$line =~ s/<msup><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><\/msup>/{$1}^{$2}/g;
	$line =~ s/<msup><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msup>/{$1}^{$2}/g;
	$line =~ s/<msup><mi>([a-zA-Z]+)<\/mi><mtext>(\w+)<\/mtext><\/msup>/{$1}^{\\rm $2}/g;
	$line =~ s/<msup><mrow>([^][]*)<\/mrow><mi>([a-zA-Z]+)<\/mi><\/msup>/{$1}^{$2}/g;
	$line =~ s/<msup><mrow>([^][]*)<\/mrow><mtext>(\w+)<\/mtext><\/msup>/{$1}^{\\rm $2}/g;
	$line =~ s/<msup><mrow>([^][]*)<\/mrow><mtext>(\d+)<\/mtext><\/msup>/{$1}^{$2}/g;
	$line =~ s/<msup><mrow>([^][]*)<\/mrow><mn>(\d+)<\/mn><\/msup>/{$1}^{$2}/g;
	$line =~ s/<msup><mi>(.*?)<\/mi><mrow>([^][]*)<\/mrow><\/msup>/{$1}^{$2}/g;
	$line =~ s/<msup><mn>(.*?)<\/mn><mrow>([^][]*)<\/mrow><\/msup>/{$1}^{$2}/g;
	$line =~ s/<msup><mtext>(.*?)<\/mtext><mrow>([^][]*)<\/mrow><\/msup>/{\\rm $1}^{$2}/g;
	$line =~ s/<msup><mrow>([^][]*)<\/mrow><mi>(.*?)<\/mi><\/msup>/{$1}^{$2}/g;
	$line =~ s/<msup><mrow>([^][]*)<\/mrow><mn>(.*?)<\/mn><\/msup>/{$1}^{$2}/g;
	$line =~ s/<msup><mrow>([^][]*)<\/mrow><mtext>(.*?)<\/mtext><\/msup>/{$1}^{\\rm $2}/g;
	$line =~ s/<msup><mrow>([^][]*)<\/mrow><mrow>([^][]*)<\/mrow><\/msup>/{$1}^{$2}/g;
	$line =~ s/<msup><mstyle mathvariant=\'bold\' mathsize=\'normal\'><mi>([a-zA-Z]+)<\/mi><\/mstyle><mn>(\d+)<\/mn><\/msup>/\\bm{\\rm $1}^{$2}/g;
	$line =~ s/<msup><mstyle mathvariant = \'bold\' mathsize = \'normal\'><mi>([a-zA-Z]+)<\/mi><\/mstyle><mn>(\d+)<\/mn><\/msup>/\\bm{\\rm $1}^{$2}/g;

	#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBSCRIPTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	$line =~ s/<msub><mi>\\(\w+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msub>/{\\$1}_{$2}/g;
	$line =~ s/<msub><mi> \\(\w+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msub>/{\\$1}_{$2}/g;
	$line =~ s/<msub><mi>\\(\w+) <\/mi><mi>([a-zA-Z]+)<\/mi><\/msub>/{\\$1}_{$2}/g;
	$line =~ s/<msub><mi> \\(\w+) <\/mi><mi>([a-zA-Z]+)<\/mi><\/msub>/{\\$1}_{$2}/g;
	$line =~ s/<msub><mi>\\(\w+)<\/mi><mn>(\d+)<\/mn><\/msub>/{\\$1}_{$2}/g;
	$line =~ s/<msub><mi> \\(\w+)<\/mi><mn>(\d+)<\/mn><\/msub>/{\\$1}_{$2}/g;
	$line =~ s/<msub><mi>\\(\w+) <\/mi><mn>(\d+)<\/mn><\/msub>/{\\$1}_{$2}/g;
	$line =~ s/<msub><mi> \\(\w+) <\/mi><mn>(\d+)<\/mn><\/msub>/{\\$1}_{$2}/g;
	$line =~ s/<msub><mi>\\(\w+)<\/mi><mtext>(.*?)<\/mtext><\/msub>/{\\$1}_{$2}/g;
	$line =~ s/<msub><mi> \\(\w+)<\/mi><mtext>(.*?)<\/mtext><\/msub>/{\\$1}_{$2}/g;
	$line =~ s/<msub><mi>\\(\w+) <\/mi><mtext>(.*?)<\/mtext><\/msub>/{\\$1}_{$2}/g;
	$line =~ s/<msub><mi> \\(\w+) <\/mi><mtext>(.*?)<\/mtext><\/msub>/{\\$1}_{$2}/g;
	$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mi>\\(\w+)<\/mi><\/msub>/{$1}_{\\$2}/g;
	$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mi> \\(\w+)<\/mi><\/msub>/{$1}_{\\$2}/g;
	$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mi>\\(\w+) <\/mi><\/msub>/{$1}_{\\$2}/g;
	$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mi> \\(\w+) <\/mi><\/msub>/{$1}_{\\$2}/g;
	$line =~ s/<msub><mn>(\d+)<\/mn><mi>\\(\w+)<\/mi><\/msub>/{$1}_{\\$2}/g;
	$line =~ s/<msub><mn>(\d+)<\/mn><mi> \\(\w+)<\/mi><\/msub>/{$1}_{\\$2}/g;
	$line =~ s/<msub><mn>(\d+)<\/mn><mi>\\(\w+) <\/mi><\/msub>/{$1}_{\\$2}/g;
	$line =~ s/<msub><mn>(\d+)<\/mn><mi> \\(\w+) <\/mi><\/msub>/{$1}_{\\$2}/g;
	$line =~ s/<msub><mtext>(.*?)<\/mtext><mi>\\(\w+)<\/mi><\/msub>/{$1}_{\\$2}/g;
	$line =~ s/<msub><mtext>(.*?)<\/mtext><mi> \\(\w+)<\/mi><\/msub>/{$1}_{\\$2}/g;
	$line =~ s/<msub><mtext>(.*?)<\/mtext><mi>\\(\w+) <\/mi><\/msub>/{$1}_{\\$2}/g;
	$line =~ s/<msub><mtext>(.*?)<\/mtext><mi> \\(\w+) <\/mi><\/msub>/{$1}_{\\$2}/g;
	$line =~ s/<msub><mtext>(.*?)<\/mtext><mtext>(\d+)<\/mtext><\/msup>/{\\rm $1}_{$2}/g;
	$line =~ s/<msub><mtext>(.*?)<\/mtext><mn>(\d+)<\/mn><\/msub>/{\\rm $1}_{$2}/g;
	$line =~ s/<msub><mtext>(\w+)<\/mtext><mi>([a-zA-Z]+)<\/mi><\/msub>/{\\rm $1}_{$2}/g;
	$line =~ s/<msub><mn>(\d+)<\/mn><mn>(\d+)<\/mn><\/msub>/{$1}_{$2}/g;
	$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><\/msub>/{$1}_{$2}/g;
	$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msub>/{$1}_{$2}/g;
	$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mtext>(\w+)<\/mtext><\/msub>/{$1}_{\\rm $2}/g;
	$line =~ s/<msub><mrow>([^][]*)<\/mrow><mi>([a-zA-Z]+)<\/mi><\/msub>/{$1}_{$2}/g;
	$line =~ s/<msub><mrow>([^][]*)<\/mrow><mtext>(\w+)<\/mtext><\/msub>/{$1}_{\\rm $2}/g;
	$line =~ s/<msub><mrow>([^][]*)<\/mrow><mtext>(\d+)<\/mtext><\/msub>/{$1}_{$2}/g;
	$line =~ s/<msub><mrow>([^][]*)<\/mrow><mn>(\d+)<\/mn><\/msub>/{$1}_{$2}/g;
	$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mrow><mtext>(\w+)<\/mtext><\/mrow><\/msub>/{$1}_{\\rm $2}/g;
	$line =~ s/<msub><mi>([a-zA-Z]+)<\/mi><mrow><mi>([a-zA-Z]+)<\/mi><\/mrow><\/msub>/{$1}_{$2}/g;
	$line =~ s/<msub><mi>(.*?)<\/mi><mrow>([^][]*)<\/mrow><\/msub>/{$1}_{$2}/g;
	$line =~ s/<msub><mn>(.*?)<\/mn><mrow>([^][]*)<\/mrow><\/msub>/{$1}_{$2}/g;
	$line =~ s/<msub><mtext>(.*?)<\/mtext><mrow>([^][]*)<\/mrow><\/msub>/{\\rm $1}_{$2}/g;
	$line =~ s/<msub><mrow>([^][]*)<\/mrow><mi>(.*?)<\/mi><\/msub>/{$1}_{$2}/g;
	$line =~ s/<msub><mrow>([^][]*)<\/mrow><mn>(.*?)<\/mn><\/msub>/{$1}_{$2}/g;
	$line =~ s/<msub><mrow>([^][]*)<\/mrow><mtext>(.*?)<\/mtext><\/msub>/{$1}_{\\rm $2}/g;
	$line =~ s/<msub><mrow>([^][]*)<\/mrow><mrow>([^][]*)<\/mrow><\/msub>/{$1}_{$2}/g;
	$line =~ s/<msub><mstyle mathvariant=\'bold\' mathsize=\'normal\'><mi>([a-zA-Z]+)<\/mi><\/mstyle><mn>(\d+)<\/mn><\/msub>/\\bm{\\rm $1}_{$2}/g;
	$line =~ s/<msub><mstyle mathvariant = \'bold\' mathsize = \'normal\'><mi>([a-zA-Z]+)<\/mi><\/mstyle><mn>(\d+)<\/mn><\/msub>/\\bm{\\rm $1}_{$2}/g;

	#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBSUPSCRIPTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><mo>\\(\w+)<\/mo><\/msubsup>/{$1}_{$2}^{\\$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><mo> \\(\w+)<\/mo><\/msubsup>/{$1}_{$2}^{\\$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><mo>\\(\w+) <\/mo><\/msubsup>/{$1}_{$2}^{\\$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><mo> \\(\w+) <\/mo><\/msubsup>/{$1}_{$2}^{\\$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><mi>\\(\w+)<\/mi><\/msubsup>/{$1}_{$2}^{\\$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><mi> \\(\w+)<\/mi><\/msubsup>/{$1}_{$2}^{\\$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><mi>\\(\w+) <\/mi><\/msubsup>/{$1}_{$2}^{\\$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><mi> \\(\w+) <\/mi><\/msubsup>/{$1}_{$2}^{\\$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>\\(\w+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{$1}_{\\$2}^{$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi> \\(\w+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{$1}_{\\$2}^{$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>\\(\w+) <\/mi><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{$1}_{\\$2}^{$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi> \\(\w+) <\/mi><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{$1}_{\\$2}^{$3}/g;
	$line =~ s/<msubsup><mi>\\(\w+)<\/mi><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi> \\(\w+)<\/mi><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>\\(\w+) <\/mi><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi> \\(\w+) <\/mi><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>\\(\w+)<\/mi><mn>(\d+)<\/mn><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi> \\(\w+)<\/mi><mn>(\d+)<\/mn><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>\\(\w+) <\/mi><mn>(\d+)<\/mn><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi> \\(\w+) <\/mi><mn>(\d+)<\/mn><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>\\(\w+)<\/mi><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi> \\(\w+)<\/mi><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>\\(\w+) <\/mi><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi> \\(\w+) <\/mi><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>\\(\w+)<\/mi><mn>(\d+)<\/mn><mn>(\d+)<\/mn><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi> \\(\w+)<\/mi><mn>(\d+)<\/mn><mn>(\d+)<\/mn><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>\\(\w+) <\/mi><mn>(\d+)<\/mn><mn>(\d+)<\/mn><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi> \\(\w+) <\/mi><mn>(\d+)<\/mn><mn>(\d+)<\/mn><\/msubsup>/{\\$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><\/msubsup>/{$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><mn>(\d+)<\/mn><\/msubsup>/{$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mtext>(\w+)<\/mtext><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{\\rm $1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mtext>(\w+)<\/mtext><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><\/msubsup>/{\\rm $1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mtext>(\w+)<\/mtext><mn>(\d+)<\/mn><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{\\rm $1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mtext>(\w+)<\/mtext><mn>(\d+)<\/mn><mn>(\d+)<\/mn><\/msubsup>/{\\rm $1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mrow>([^][]*)<\/mrow><mi>([a-zA-Z]+)<\/mi><\/msubsup>/{$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mrow>([^][]*)<\/mrow><mn>(\d+)<\/mn><\/msubsup>/{$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><mrow>([^][]*)<\/mrow><\/msubsup>/{$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><mrow>([^][]*)<\/mrow><\/msubsup>/{$1}_{$2}^{$3}/g;
	$line =~ s/<msubsup><mi>([a-zA-Z]+)<\/mi><mrow>([^][]*)<\/mrow><mrow>([^][]*)<\/mrow><\/msubsup>/{$1}_{$2}^{$3}/g;
	
	############################################ FRACTIONS ###########################################
	$line =~ s/<mfrac><mn>(\d+)<\/mn><mi>([a-zA-Z]+)<\/mi><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mn>(\d+)<\/mn><mn>(\d+)<\/mn><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mi>([a-zA-Z]+)<\/mi><mi>([a-zA-Z]+)<\/mi><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mn>(\d+)<\/mn><mtext>(\w+)<\/mtext><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mi>([a-zA-Z]+)<\/mi><mtext>(\w+)<\/mtext><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mtext>(\w+)<\/mtext><mi>([a-zA-Z]+)<\/mi><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mtext>(\w+)<\/mtext><mn>(\d+)<\/mn><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mtext>(\w+)<\/mtext><mtext>(\w+)<\/mtext><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mtext>(.*?)<\/mtext><mrow>([^][]*)<\/mrow><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mi>([a-zA-Z]+)<\/mi><mrow>([^][]*)<\/mrow><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mn>(\d+)<\/mn><mrow>([^][]*)<\/mrow><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mrow>([^][]*)<\/mrow><mi>([a-zA-Z]+)<\/mi><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mrow>([^][]*)<\/mrow><mn>(\d+)<\/mn><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mrow>([^][]*)<\/mrow><mrow>([^][]*)<\/mrow><\/mfrac>/\\frac{$1}{$2}/g;
	$line =~ s/<mfrac><mrow>([^][]*)<\/mrow><mi>\\(\w+)<\/mi><\/mfrac>/\\frac{$1}{\\$2}/g;
	$line =~ s/<mfrac><mrow>([^][]*)<\/mrow><mi>\\(\w+) <\/mi><\/mfrac>/\\frac{$1}{\\$2}/g;
	$line =~ s/<mfrac><mrow>([^][]*)<\/mrow><mi> \\(\w+)<\/mi><\/mfrac>/\\frac{$1}{\\$2}/g;
	$line =~ s/<mfrac><mrow>([^][]*)<\/mrow><mi> \\(\w+) <\/mi><\/mfrac>/\\frac{$1}{\\$2}/g;
	$line =~ s/<mfrac><mi>\\(\w+)<\/mi><mrow>([^][]*)<\/mrow><\/mfrac>/\\frac{\\$1}{$2}/g;
	$line =~ s/<mfrac><mi>\\(\w+) <\/mi><mrow>([^][]*)<\/mrow><\/mfrac>/\\frac{\\$1}{$2}/g;
	$line =~ s/<mfrac><mi> \\(\w+)<\/mi><mrow>([^][]*)<\/mrow><\/mfrac>/\\frac{\\$1}{$2}/g;
	$line =~ s/<mfrac><mi> \\(\w+) <\/mi><mrow>([^][]*)<\/mrow><\/mfrac>/\\frac{\\$1}{$2}/g;

	#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MISCELLENOUS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	$line =~ s/<mstyle mathvariant=\'bold\' mathsize=\'normal\'><mi>([a-zA-Z]+)<\/mi><\/mstyle>/\\bm{\\rm $1}/g;
	$line =~ s/<mstyle mathvariant = \'bold\' mathsize = \'normal\'><mi>([a-zA-Z]+)<\/mi><\/mstyle>/\\bm{\\rm $1}/g;

	$line =~ s/<mfracbevelled=\'true\'><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><\/mfrac>/{$1\/$2}/g;
	$line =~ s/<mfrac bevelled=\'true\'><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><\/mfrac>/{$1\/$2}/g;
	$line =~ s/<mfrac bevelled = \'true\'><mi>([a-zA-Z]+)<\/mi><mn>(\d+)<\/mn><\/mfrac>/{$1\/$2}/g;
	
	$line =~ s/<msup><mover accent=\'true\'><mi>([a-zA-Z]+)<\/mi><mo>\\dot<\/mo><\/mover><mn>(\d+)<\/mn><\/msup>/\\dot{$1}^{$2}/g;
	
	###########################################################
	
	$line =~ s/<mi>sin<\/mi>/\\sin/g;
	$line =~ s/{sin}/{\\sin}/g;
	$line =~ s/<mi>cos<\/mi>/\\cos/g;
	$line =~ s/{cos}/{\\cos}/g;
	$line =~ s/<mi>sec<\/mi>/\\sec/g;
	$line =~ s/{sec}/{\\sec}/g;
	$line =~ s/<mi>cot<\/mi>/\\cot/g;
	$line =~ s/{cot}/{\\cot}/g;
	$line =~ s/<mi>cosec<\/mi>/\\cosec/g;
	$line =~ s/{cosec}/{\\cosec}/g;
	$line =~ s/<mi>tan<\/mi>/\\tan/g;
	$line =~ s/{tan}/{\\tan}/g;

	######################################### MISCELLENOUS2 ################################################
	$line =~ s/<\/mtext><mtext>//g;
	$line =~ s/<mtext>(\w+)&nbsp\;(\w+)<\/mtext>/ \\mbox\{$1 $2\}/g;
	$line =~ s/<mtext>([a-zA-Z])<\/mtext>/\\,\\mbox{$1} /g;
	$line =~ s/<mtext>(\w+)<\/mtext>/ \\mbox{$1} /g;
	$line =~ s/<mtext>(.*?)<\/mtext>/ \\mbox{$1} /g;
	$line =~ s/<mtext>(.*?)<\/mtext>/ \\mbox{$1} /g;
	$line =~ s/<mtext>:&nbsp\;(\w+)<\/mtext>/: \\mbox{$1} /g;
	$line =~ s/<mtext>,&nbsp\;(\w+)<\/mtext>/, \\mbox{$1} /g;
	$line =~ s/<mi> \\(\w+) <\/mi><mi>([a-zA-Z]+)<\/mi>/\\$1 $2/g;
	$line =~ s/\{\\,/\\,\{/g;
	########################################################################################################

	$line =~ s/<mtext>\s(.*?)<\/mtext>/ \\mbox{$1} /g;
	$line =~ s/<mtext>(.*?)\s<\/mtext>/ \\mbox{$1} /g;
	$line =~ s/<mtext>\s(.*?)\s<\/mtext>/ \\mbox{$1} /g;
	$line =~ s/<mtext>(.*?)<\/mtext>/ \\mbox{$1} /g;
	$line =~ s/<mo>([^][]*)<\/mo>/$1/g;
	$line =~ s/<mn>(.*?)<\/mn>/$1/g;
	$line =~ s/<mi>([a-zA-Z]+)<\/mi>/$1/g;
	$line =~ s/<mi>(.*?)<\/mi>/$1/g;
	############################################
	$line =~ s/<mtext>&nbsp\;<\/mtext>/ /g;
	$line =~ s/<mtext>//g;
	$line =~ s/<\/mtext>//g;
	$line =~ s/&nbsp\;/ /g;
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
	$line =~ s/=/ = /g;
	$line =~ s/,\{/, \{/g;
	$line =~ s/ ,/,/g;
	$line =~ s/ :/: /g;
	$line =~ s/{ - (\d+)}/{-$1}/g;
	$line =~ s/<msqrt>/\\sqrt{/g;
	$line =~ s/<\/msqrt>/}/g;
	
	
	$line =~ s/<mo> \\minus <\/mo>/ - /g;
	$line =~ s/ &(\w+)\; / &$1\; /g;
	$line =~ s/<mfrac>{/\\frac{/g;
	$line =~ s/}<\/mfrac>/}/g;
	$line =~ s/<\/msup>//g;
	$line =~ s/\\mbox{}//g;
	$line =~ s/ \\mbox{,} /, /g;
	$line =~ s/\\mbox{ - (\d+)}/\\mbox{-$1}/g;
	$line =~ s/{ - (\w+)}/{-$1}/g;
	$line =~ s/{ /{/g;
	$line =~ s/ }/}/g;
	$line =~ s/  / /g;
	$line =~ s/,(\w+)/, $1/g;
	$line =~ s/,(\d+)/, $1/g;
	$line =~ s/\\, /\\,/g;
	$line =~ s/ <\/mi>//g;
	$line =~ s/<mi>//g;
	$line =~ s/{max}/{\\rm max}/g;
	$line =~ s/{min}/{\\rm min}/g;
	$line =~ s/\\minus/-/g;
	$line =~ s/\{- /\{-/g;
	$line =~ s/\{\\rm ([a-zA-Z]+)([0-9]+)/\{\\rm $1\} $2 \{\\rm /g;
	$line =~ s/([a-zA-Z]+)([0-9]+)/$1 $2/g;

	return $line;
}

1;