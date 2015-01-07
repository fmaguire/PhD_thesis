#! /usr/bin/perl -w
#
# Copyright (c) Markus Kohm
# See the pod documentation at the end of the program for more information.
#

eval 'exec perl -S $0 ${1+"$@"}'
    if 0; #$running_under_some_shell

use strict;
use Text::Wrap;
use Getopt::Long;
use Pod::Usage;
use Pod::Html;

my $version = "0.5d";

my @typeareapackage = ( 'geometry', 'typearea', 'vmargin' );
my @languagepackage = ( 'babel', 'german', 'ngerman', 'french' );
my @packagesnottogether = ( \@typeareapackage, \@languagepackage );

my %obsoletepackage = ( 't1enc', '"\usepackage[T1]{fontenc}"',
			'umlaute', 'inputenc',
			'umlaut', '"\usepackage[latin1]{inputenc}"',
			'isolatin', '"\usepackage[isolatin]{inputenc}"',
			'isolatin1', '"\usepackage[latin1]{inputenc}"',
			'fancyheadings', 'fancyhdr',
			'times', '"\usepackage{mathptmx} \usepackage[scaled=.95]{helvet} \usepackage{courier}"',
			'mathptm', 'mathptmx',
			'pslatex', '"\usepackage{mathptmx} \usepackage[scaled=.95]{helvet} \usepackage{courier}"',
			'palatino', '"\usepackage{mathpazo} \usepackage[scaled=.95]{helvet} \usepackage{courier}"',
			'mathpple', 'mathpazo',
			'a4', \@typeareapackage, 
			'a4wide', \@typeareapackage,
			'epsf', 'graphicx',
			'epsfig', 'graphicx',
			'doublespace', 'setspace',
			'scrpage', 'scrpage2' );
my %obsoleteclass = ( 'scrlettr', 'scrlttr2' );
my %fontobsolete = ( '\rm', '\textrm{...}, \mathrm{...}, \rmfamily',
		     '\sf', '\textsf{...}, \mathsf{...}, \sffamily',
		     '\tt', '\texttt{...}, \mathtt{...}, \ttfamily',
		     '\bf', '\textbf{...}, \mathbf{...}, \bfseries',
		     '\it', '\textit{...}, \mathit{...}, \itshape, \emph{...}',
		     '\sl', '\textsl{...}, \slshape',
		     '\sc', '\textsc{...}, \scshape',
		     '\cal', '\mathcal{...}' );

my %obsoletecommand = ( '\def', '\newcommand*, \renewcommand*, \providecommand*, \DeclareRobustCommand*' );

my @classeswithparskip = ( 'scrartcl', 'scrbook', 'scrreprt', 'scrlttr2' );
my @packageswithparskip = ( 'parskip' );

my @typearealength = ( '\columnwidth', '\evensidemargin', '\footskip', 
		       '\headheight', '\headsep', '\hoffset', 
		       '\oddsidemargin', '\textheight', '\textwidth',
		       '\topmargin', '\topskip', '\voffset' );
my @leftmargin = ( '\oddsidemargin', '\evensidemargin' );
my %lengthinsteadoflength = ( '\hoffset', \@leftmargin,
			      '\voffset', '\topmargin' );
my @knownlength = ( '\abovecaptionskip', '\arraycolsep', '\arrayrulewidth',
		    '\belowcaptionskip',
		    '\captionindent', '\columnsep', '\columnseprule',
		    '\doublerulsep',
		    '\fboxrule', '\fboxsep',
		    '\itemsep', '\itemindent',
		    '\labelsep', '\labelwidth', '\leftmargin', '\leftmargini', 
		    '\leftmarginii', '\leftmarginiii', '\leftmarginiv', 
		    '\leftmarginv', '\leftmarginvi', '\lineskip', 
		    '\linewidth', '\listparindent',
		    '\marginparsep', '\marginparwidth', '\@mpfootins',
		    '\normallineskip',
		    '\overfullrule',
		    '\paperwidth', '\paperheight', '\parsep', '\partopsep',
		    '\parskip', '\parindent', '\parfillskip',
		    '\tabbingsep', '\tabcolsep' );

my @commandnotenvironment = ( 'appendix' );

my @legenditem = ( 'MESSAGE', 'WARNING', 'OBSOLETE', 'ERROR', 'FATAL' );

my %message_en = (
		  '<pline>', 'line',
		  '<plines>', 'lines',
		  'line', 'line',
		  'lines', 'lines',
		  'Source', 'Source',
		  'Legend', 'Legend',
		  'Legendpostfix', 
		    "See also <URL:ftp://ftp.ctan.org/tex-archive/info/l2tabu/>.\n",
		  'Legendpostfixhtml',
		    "See also <a href=\"ftp://ftp.ctan.org/tex-archive/info/l2tabu/\">CTAN:&nbsp;info/l2tabu/</a>\n",
		  'Legendprefix',
		    "The analyzation messages are composed of an optional line number, a message class in round brackets and a message text after a colon. Here comes the description of the message classes:\n", 
		  'MESSAGE', '(MESSAGE)',
		  'MESSAGEdescription',
		    "Not an error but an information to the user.\n",
		  'WARNING', '(WARNING)',
		  'WARNINGdescription',
		    "An expert may do this. But a new user should never be told to do so unless he is also told about the dangerous potentiality.\n",
		  'OBSOLETE', '(OBSOLETE)',
		  'OBSOLETEdescription',
		    "Something was detected, which should be done in another manner using LaTeX2e. New users should never spend time in obsolete things. They should ever use current LaTeX2e solutions.\n",
		  'ERROR', '(ERROR)',
		  'ERRORdescription',
		    "There seems to be an error. You should change this.\n",
		  'FATAL', '(FATAL)',
		  'FATALdescription',
		    "This is a very, very dangerous error! You have to fix this!\n",
		  'Done', "Done.\n",
		  'documentclass',
		    "\\documentclass allowed only once (first was at <pline>)!\n",
		  'packagebeforeclass',
		    "package <package> loaded before \\documentclass!\n",
		  'packageagain',
		    "package <package> already loaded at <lines> with options \"<options>\". I'll ignore this load!\n",
		  'endbeforebegin',
		    "\\end{<environment>} read without \\begin{<environment>}!\n",
		  'commandnotenvironment',
		    "\\<environment> is a command, which should never be used as an environment!\n",
		  'typearealengthLaTeX',
		     "You should not change type area length <length> directly until you know, what you are doing. You should use one of the packages <packages>.\n",
		  'samelengthagain',
		    "One more change of <length>, which was changed first time at line <line>.\n",
		  'lengthinsteadoflength',
		    "You should change <length> instead of <notlength>.\n",
		  'TeXlength',
		    "You should use \\setlength to change a length like <length> at LaTeX.\n",
		  'obsoletefontcommand',
		    "You should not use font command <cmd>. Use one of the new font commands (e.g. <new>) instead!\n",
		  'obsoletecommand',
		    "You should not use <cmd> until you must. Use one of <new> instead!\n",
		  'baselinestretch',
		    "You should not redefine \\baselinestretch! Use \\linespread{...} or package setspace to change line spacing.\n",
		  'missingbegindocument',
		     "No \\begin{document} found. This seems to be a preamble only.\n",
		  'multiplebegindocument',
		    "\\begin{document} should be used only once.\n",
		  'missingenddocument',
		    "No \\end{document} found. This is not a preamble only but also no valid document!\n",
		  'missingdocumentclass',
		    "\\documentclass missing!\n",
		  'parskipindent',
		    "You should not change paragraphing (\\parskip and \\parindent) unless you are using a package like <packages> or a class like <classes> which can handle this",
		  'packageatline',
		    "<package> (<pline>)",
		  'oneofpackages',
		    "You should use only one of the packages <packages>.\n",
		  'lengthatline',
		    "<length> (<pline>)",
		  'typeareapackageandlength',
		    "Type area changed using package <packages> and setting up length <length>.\n",
		  'obsoleteclass',
		    "You should use class <new> instead of class <class>.\n",
		  'oneof', "one of ",
		  'obsoletepackage',
		    "You should use <oneof><new> instead of package <package>.\n"
		  );

my %message_de = (
		  '<pline>', 'Zeile',
		  '<plines>', 'Zeilen',
		  'line', 'Zeile',
		  'lines', 'Zeilen',
		  'Source', 'Quelltext',
		  'Legend', 'Legende',
		  'Legendpostfix', 
		    "Siehe außerdem <URL:ftp://ftp.dante.de/tex-archive/info/l2tabu/german/>.\n",
		  'Legendpostfixhtml',
		    "Siehe außerdem <a href=\"ftp://ftp.dante.de/tex-archive/info/l2tabu/german\">CTAN:&nbsp;info/l2tabu/german/</a>\n",
		  'Legendprefix',
		    "Die Analysemeldungen bestehen in der Regel aus einer Zeilennummer oder einem Zeilennummernbereich gefolgt von einer Meldungsklasse in runden Klammern. Der eigentliche Text der Meldung folgt nach einem Doppelpunkt. Im Folgenden werden die einzelnen Meldungsklassen kurz erklärt:\n",
		  'MESSAGE', '(MELDUNG)',
		  'MESSAGEdescription',
		    "Eine Information an den Benutzer, die keinerlei Fehler darstellt.\n",
		  'WARNING', '(WARNUNG)',
		  'WARNINGdescription',
		    "Es wurde etwas entdeckt, was von einem erfahrenen Anwender möglicherweise mit Absicht gemacht wurde. Einem Anfänger sollte aber immer von diesem Vorgehen abgeraten werden. Zumindest sollte der Anfänger über die damit verbundenen Gefahren aufgeklärt werden.\n",
		  'OBSOLETE', '(OBSOLETE)',
		  'OBSOLETEdescription',
		    "Es wurde etwas entdeckt, wofür es bei LaTeX2e neuere und in der Regel auch bessere Lösungen gibt. Anfänger sollten sich nicht mehr mit den veralteten Methoden beschäftigen, sondern grundsätzlich die neue Lösung verwenden.\n",
		  'ERROR', '(FEHLER)',
		  'ERRORdescription',
		    "Hier liegt wirklich ein Fehler vor. Auch erfahrene Anwender sollten diesen Hinweis beachten und für Abhilfe sorgen.\n",
		  'FATAL', '(FATAL)',
		  'FATALdescription',
		    "Hier liegt ein schwerwiegender Fehler vor, der unbedingt behoben werden muss.\n",
		  'Done', "Erledigt.\n",
		  'documentclass',
		    "\\documentclass ist nur einmal erlaubt (das erste Mal war in <pline>)!\n",
		  'packagebeforeclass',
		    "Paket <package> vor \\documentclass geladen!\n",
		  'packageagain',
		    "Paket <package> wurde in <lines> bereits mit Optionen \"<options>\" geladen. Ich werde den fehlerhaften neuerlichen Vorgang im Weiteren ungeachtet lassen!\n",
		  'endbeforebegin',
		    "\\end{<environment>} ohne zugehöriges \\begin{<environment>} entdeckt!\n",
		  'commandnotenvironment',
		    "\\<environment> ist eine Anweisung, die niemals als Umgebung verwendet werden sollte!\n",
		  'typearealengthLaTeX',
		     "Die Satzspiegellänge <length> sollte nur dann direkt geändert werden, wenn Sie genau wissen, was Sie da tun. Anderenfalls sollte besser eines der Pakete <packages> verwendet werden.\n",
		  'samelengthagain',
		    "Erneute Änderung der Länge <length>, die das erste mal in Zeile <line> geändert wurde.\n",
		  'lengthinsteadoflength',
		    "Statt <notlength> sollte immer <length> geändert werden.\n",
		  'TeXlength',
		    "In LaTeX sollte \\setlength zum Ändern einer Länge wie <length> verwendet werden.\n",
		  'obsoletefontcommand',
		    "Es sollte nicht länger die Anweisung <cmd> zur Schriftänderung verwendet werden. Stattdessen sind die entsprechenden LaTeX2e-Anweisungen (beispielsweise <new>) zu verwenden!\n",
		  'obsoletecommand',
		    "Die Anweisung <cmd> sollte nur in ganz besonderen Fällen verwendet werden. Normalerweise ist stattdessen <new> zu verwenden!\n",
		  'baselinestretch',
		    "Es sollte niemals \\baselinestretch umdefiniert werden! Stattdessen sollte \\linespread{...} oder das Paket setspace zur Änderung des Durchschusses verwendet werden.\n",
		  'missingbegindocument',
		     "Kein \\begin{document} gefunden. Dies ist anscheinend nur eine Dokumentpräambel.\n",
		  'multiplebegindocument',
		    "\\begin{document} darf je Dokument nur einmal verwendet werden.\n",
		  'missingenddocument',
		    "Kein \\end{document} gefunden. Dies ist weder eine Dokumentpräambel noch ein gültiges Dokument!\n",
		  'missingdocumentclass',
		    "\\documentclass fehlt!\n",
		  'parskipindent',
		    "Die Absatzformatierung sollte nicht durch Ändern der Längen \\parskip und \\parindent verändert werden, so lange nicht ein Paket wie <packages> oder eine Klasse wie <classes> verwendet wird, bei denen anzunehmen ist, dass sie mit dieser Änderung zurecht kommen.",
		  'packageatline',
		    "<package> (<pline>)",
		  'oneofpackages',
		    "Es sollte nur genau eines der Pakete <packages> verwendet werden.\n",
		  'lengthatline',
		    "<length> (<pline>)",
		  'typeareapackageandlength',
		    "Der Satzspiegel wurde sowohl mit Paket <packages> als auch über Zuweisung an <length> geändert.\n",
		  'obsoleteclass',
		    "An Stelle der Klasse <class> sollte Klasse <new> verwendet werden.\n",
		  'oneof', "eines von ",
		  'obsoletepackage',
		    "An Stelle des Paketes <package> sollte <oneof><new> verwendet werden.\n"
		  );

my $lang;
my %message_lang = ( "de", \%message_de,
		     "en", \%message_en );
my %message=%message_en;

my %packagelines;
my %packageoptions;
my $classname;
my @classlines;
my @classoptions;
my %typearealengthlines;
my @parskiplines;

my $linebuffer="";
my $srcbuffer="";
my $atdocument = 0;
my $debug = 0;
my $showsrc = 0;
my $legend = 0;

my $wrapindent = 8;

my $cmd;

use CGI;

my $cgi = new CGI if ( exists $ENV{'REQUEST_METHOD'} );
my $readbuffer;

# ----------------------------------------------------------------------
# Some subs with prototypes
# ----------------------------------------------------------------------

# Formates line numbers
sub formlinenumbers {
    return $_[0] if ( ( $#_ == 0 ) || ( $_[0] == $_[1] ) );
    return "$_[0]-$_[1]";
}

sub formlineswithprefix {
    return message( "line" ) . " $_[0]" 
	if ( ( $#_ == 0 ) || ( $_[0] == $_[1] ) );
    return message( "lines" ) . "$_[0]-$_[1]";
}

# Formating the message prefixes (e.g. "$. (FATAL):")
# At cgi-mode they will become bold.
sub formprefix( @ ) {
    if ( $cgi ) {
	return $cgi->b("@_:");
    } else {
	return "@_:" ;
    }
}

# Fomrating the output
# At cgi-mode each output is a paragraph.
# At no-cgi-mode the output will pe wrapped.
sub formoutput( @ ) {
    if ( $cgi ) {
	return $cgi->p( @_ );
    } else {
	return wrap( '', 
		     substr( '                ', 0, $wrapindent ), 
		     @_ );
    }
}

# Show message
sub message {
    my $msg = shift;
    local($_) = shift || "";
    my %replace;
    my @pair;
    if ( @_ > 0 ) {
	## Too many arguments - assume that this is a hash and the user
	## forgot to pass a reference to it.
	%replace = ( $_, @_ );
    } elsif ( ref $_ && ref($_) eq 'HASH' ) {
	## User passed a ref to a hash
	%replace = %{$_};
    }
    $msg = $message{$msg} if exists $message{$msg};
    if ( %replace ) {
	while ( @pair = each %replace ) {
	    my $match;
	    if ( ref $pair[1] ) {
		my $result="";
		my $comma="";
		for ( @{$pair[1]} ) {
		    $result .= "$comma$_";
		    $comma = ', ';
		}
		$pair[1] = $result;
	    }
	    $pair[0] =~ s/\\/\\\\/g; # backslash correction for match
	    $pair[1] =~ s/\\/\\\\/g; # backslash correction for match
	    print STDERR "$pair[0] --> $pair[1]\n" if ( $debug );
	    if ( exists $message{$pair[0]} ) {
		$match = "\$msg =~ s/$pair[0]/$message{$pair[0]} $pair[1]/g";
	    } else {
		$match = "\$msg =~ s/$pair[0]/$pair[1]/g";
	    }
	    eval $match;
	}
    }
    return $msg;
}

# ----------------------------------------------------------------------
# Select messages in apropriate language
# ----------------------------------------------------------------------
$lang = $ENV{ 'LC_MESSAGES' } if exists $ENV{ 'LC_MESSAGES' };
$lang = $ENV{ 'LC_ALL' } if ! $lang && exists $ENV{ 'LC_ALL' };
$lang = $ENV{ 'LANG' } if ! $lang && exists $ENV{ 'LANG' };
$lang =~ s/[_@].*// if $lang;
%message = %{$message_lang{$lang}} if $lang && exists $message_lang{$lang};

# ----------------------------------------------------------------------
# Open the files or read the CGI parameters
# ----------------------------------------------------------------------
if ( $cgi ) {
    # >>>>>>>>>>>>>>>>>>>>>>>>> CGI mode <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    my @param;
    $cgi = new CGI;
    @param = $cgi->param;
    $readbuffer = $cgi->param( 'contents' );
    $showsrc = 1 if ( $cgi->param( 'source' ) );
    $lang = $cgi->param( 'lang' ) if ( $cgi->param( 'lang' ) );
    $lang =~ s/[_@].*// if $lang;
    %message = %{$message_lang{$lang}} if $lang && exists $message_lang{$lang};
    $legend = 1 if ( $cgi->param( 'legend' ) );
    $. = 0;
    print $cgi->header(),
    $cgi->start_html('TeXidate');
    print $cgi->comment( "HOST: $ENV{'HTTP_HOST'}" ) 
	if ( exists $ENV{'HTTP_HOST'} );
    print $cgi->comment( "USER-AGENT: $ENV{'HTTP_USER_AGENT'}" ) 
	if ( exists $ENV{'HTTP_USER_AGENT'} );
    print $cgi->comment( "REMOTE-ADDR: $ENV{'REMOTE_ADDR'}" ) 
	if ( exists $ENV{'REMOTE_ADDR' } );
    print '<h1>TeXidate&nbsp;' . 
	$version . 
	'&nbsp<br>Copyright&nbsp;&copy;&nbsp;2003--2004&nbsp;Markus&nbsp;Kohm</h1>';
        
} else {
    # >>>>>>>>>>>>>>>>>>>>>>> no CGI mode <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    Getopt::Long::Configure( "bundling" );
    $Text::Wrap::columns = 80;
    $Text::Wrap::columns = $ENV{'COLUMNS'} if exists ( $ENV{'COLUMNS'} );
    
    # At non CGI mode the programm knows options:

    if ( ! GetOptions( 'debug!' => \$debug,
		       'withsource!' => \$showsrc, 's' => \$showsrc,
		       'wrapwidth|w=i' => \$Text::Wrap::columns,
		       'help|h' => sub { 
			   pod2usage( -verbose => 2, -exitval => 0 ) },
		       'language|l=s' => sub {
			   $lang = $_[1];
			   $lang =~ s/[_@].*// if $lang;
			   %message = %{$message_lang{$lang}} if $lang && exists $message_lang{$lang};
		       },
		       'legend!' => \$legend, 'L' => \$legend,
		       'version' => sub { exit 1 }
		       ) ) {
	pod2usage( -verbose => 0, -exitval => 'noexit', -output => \*STDERR );
	print STDERR "Try \`TeXidate --help' to get more information.\n";
	exit 1;
    }
    
    if ( $#ARGV > 1 ) {
	pod2usage( -message => "To many arguments.\n",
		   -verbose => 0, 
		   -exitval => 'noexit', 
		   -output => \*STDERR );
	print STDERR "Try \`TeXidate --help' to get more information.\n";
	exit 1;
    }
    
    my $filename = $ARGV[0] if ( $#ARGV >= 0 );
    my $toname   = $ARGV[1] if ( $#ARGV >= 1 );
    
    if ( $toname ) {
	open STDOUT, ">$toname" || die "Cannot create file $toname.\n";
    }
    
    print "TeXidate $version\nCopyright (c) 2003--2004 Markus Kohm\n\n";
    
    if ( $filename && $filename ne "-" ) {
	open STDIN, $filename || die "Cannot read file $filename.\n";
	readlinebuffer() || exit 2;
	print "Analyzing $filename:\n\n" if ( $toname );
    }
}

# ----------------------------------------------------------------------
# Read an pre analyze the preamble
# ----------------------------------------------------------------------
while ( ! $atdocument && ( $cmd = nextcmd() ) ) {
    print STDERR "$cmd$linebuffer" if ( $debug );
    if ( $cmd =~ /^(\\documentclass|\\usepackage)$/ ) {
	# \documentclass or \usepackage with one optional and one <<<<<<
	# mandatory argument: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	my @oarg;
	my $marg;
	my $line = $.;
	# read optional argument
	@oarg = readoarg();
        # read mandatory argument
	$marg = readmarg();
	if ( "$cmd" eq "\\documentclass" ) {
	    if ( $classname ) {
		print formoutput( formprefix( formlinenumbers( $line ),
					      message( 'FATAL' ) ),
				  message( 'documentclass',
					   '<pline>' => $classlines[0] ) );
	    } else {
		$classname = $marg;
		@classlines = ($line,$.);
		@classoptions = @oarg;
		print STDERR "Class $classname from lines $classlines[0] to $classlines[1] with options \"@classoptions\"\n" if ( $debug );
	    }
	} else { # its not \documentclass so it must be \usepackage
	    my $arg;
	    while ( $marg ) {
		if ( $marg =~ s/^([^,]+),(.*)/$2/ ) {
		    $arg = $1;
		} else {
		    $arg = $marg;
		    $marg = "";
		}
		print formoutput( formprefix( formlinenumbers( $line, $. ), 
					      message( 'FATAL' ) ),
				  message( 'packagebeforeclass',
					   '<package>' => $arg ) )
#				  "package $arg loaded before \\documentclass!\n" )
		    if ( ! $classname );
		if ( exists $packagelines{$arg} ) {
		    print formoutput( formprefix( formlinenumbers($line,$.), 
						  message( 'ERROR' ) ), 
				      message( 'packageagain',
					       '<package>' => $arg,
					       '<lines>' => formlineswithprefix(@{$packagelines{$arg}}),
					       '<options>' => \@{$packageoptions{$arg}}
					       ) );
		} else {
		    $packagelines{$arg} = [$line,$.];
		    $packageoptions{$arg} = \@oarg;
		    print STDERR "Package $arg from lines $packagelines{$arg}[0] to $packagelines{$arg}[1] with options \"@{$packageoptions{$arg}}\"\n" if ( $debug );
		}
	    }
	}
    } elsif ( $cmd eq "\\end" ) {
	# >>>>>>>>>>>>>>>>>>>>> \end with one mandatory argument <<<<<<
	my $marg = readmarg();
	if ( $marg eq "document" ) {
	    print formoutput( formprefix( formlinenumbers( $. ),
					  message( 'FATAL' ) ),
			      message( 'endbeforebegin',
				       '<environment>' => 'document' ) );
	    analyse();
	}
    } elsif ( $cmd eq "\\begin" ) {
	# >>>>>>>>>>>>>>>>>>> \begin with one mandatory argument <<<<<<<
	my $marg = readmarg();
	if ( $marg eq "document" ) {
	    $atdocument = 1;
	} elsif ( atarray( $marg, \@commandnotenvironment ) ) {
	    print formoutput( formprefix( formlinenumbers( $. ),
					  message( 'FATAL' ) ),
			      message( 'commandnotenvironment',
				       '<environment>' => $marg ) );
	}
    } elsif ( $cmd eq "\\setlength" ) {
	# >>>>>>>>>>>>>>>> \setlength with two mandatory arguments <<<<<
	my $length = readmarg();
        # Search for page style length and warn if found!
	map {
	    if ( $_ eq $length ) {
		print formoutput( formprefix( formlinenumbers( $. ),
					      message( 'WARNING' ) ),
				  message( 'typearealengthLaTeX',
					   '<length>' => $length,
					   '<packages>' => \@typeareapackage ) );
		if ( exists $typearealengthlines{$length} ) {
		    print formoutput( formprefix( formlinenumbers( $. ),
						  message( 'WARNING' ) ),
				      message( 'samelengthagain',
					       '<length>' => $length,
					       '<line>' => $typearealengthlines{$length} ) );
		} else {
		    $typearealengthlines{$length} = $.;
		}
		print formoutput( formprefix( formlinenumbers( $. ),
					      message( 'WARNING' ) ),
				  message( 'lengthinsteadoflength',
					   '<length>' => $lengthinsteadoflength{$length},
					   '<notlength>' => $length ) )
		    if ( exists $lengthinsteadoflength{$length} );
	    }
	} @typearealength;
	if ( $length =~ /\\par(skip|indent)/ ) {
	    $parskiplines[$#parskiplines + 1] = $.;
	} 
	$length = readmarg(); # read the value
    } elsif ( $cmd && atarray($cmd,\@typearealength) &&
	      ( $linebuffer =~ /^ *=? *(\.?[0-9]+|\\)/ ) ) {
	# >>>>>>>>>> direct length manipulation <<<<<<<<<<<<<<<<<<<<<<<<
	print formoutput( formprefix( formlinenumbers( $. ),
				      message( 'WARNING' ) ),
			  message( 'typearealengthLaTeX',
				   '<length>' => $cmd,
				   '<packages>' => \@typeareapackage ) );
	print formoutput( formprefix( formlinenumbers( $. ),
				      message( 'OBSOLETE' ) ),
			  message( 'TeXlength',
				   '<length>' => $cmd ) );
    } elsif ( $cmd && atarray($cmd,\@knownlength) &&
	      ( $linebuffer =~ /^ *=? *(\.?[0-9]+|\\)/ ) ) {
	print formoutput( formprefix( formlinenumbers( $. ),
				      message( 'OBSOLETE' ) ),
			  message( 'TeXlength',
				   '<length>' => $cmd ) );
	if ( $cmd =~ /\\par(skip|indent)/ ) {
	    $parskiplines[$#parskiplines + 1] = $.;
	}
    } elsif ( exists $fontobsolete{$cmd} ) {
	# >>>>>>>>>>>> obsolete font command <<<<<<<<<<<<<<<<<<<<<<<<<<<
	print formoutput( formprefix( formlinenumbers( $. ),
				      message( 'OBSOLETE' ) ),
			  message( 'obsoletefontcommand',
				   '<cmd>' => $cmd,
				   '<new>' => $fontobsolete{$cmd} ) );
    } elsif ( exists $obsoletecommand{ $cmd } ) {
	# >>>>>>> e.g. \def instead of \newcommand or \renewcommand <<<<
	my $marg = readmarg();
	print formoutput( formprefix( formlinenumbers( $. ),
				      message( 'OBSOLETE' ) ),
			  message( 'obsoletecommand',
				   '<cmd>' => $cmd,
				   '<new>' => $obsoletecommand{$cmd} ) );
	print formoutput( formprefix( formlinenumbers( $. ),
				      message( 'OBSOLETE' ) ), 
			  message( 'baselinestretch' ) )
	    if ( ( $cmd eq '\def' ) && ( $marg eq '\baselinestretch' ) );
    } elsif ( $cmd eq '\renewcommand' ) {
	# >>>>>>>>>> \renewcommand maby with \baselinestretch <<<<<<<<<<
	my $marg;
	$linebuffer =~ s/^\*//;
	$marg = readmarg();
	print formoutput( formprefix( formlinenumbers( $. ),
				      message( 'OBSOLETE' ) ), 
			  message( 'baselinestretch' ) )
	    if ( $marg eq '\baselinestretch' );
    }
}

print formoutput( formprefix( message( 'MESSAGE' ) ), 
		  message( 'missingbegindocument' ) )
    if ( ! $atdocument );

# ----------------------------------------------------------------------
# Read an pre-analyze the body
# ----------------------------------------------------------------------
while ( $atdocument && ( $cmd = nextcmd() ) ) {
    my $grouplevel = 1;
    if ( $cmd eq "\\end" ) {
	# >>>>>>>>>>>>>>>>>>>>> \end with one mandatory argument <<<<<<
	my $marg = readmarg();
	if ( $grouplevel-- == 0 ) {
	    $grouplevel = 0;
	    print formoutput( formprefix( formlinenumbers( $. ),
					  message( 'FATAL' ) ),
			      message( 'endbeforebegin',
				       '<environment>' => $marg ) );
	}
	if ( $marg eq "document" ) {
	    $atdocument = 0;
	}
    } elsif ( $cmd eq "\\begin" ) {
	# >>>>>>>>>>>>>>>>>>> \begin with one mandatory argument <<<<<<<
	my $marg = readmarg();
	$grouplevel++;
	print formoutput( formprefix( formlinenumbers( $. ),
				      message( 'FATAL' ) ),
			  message( 'multiplebegindocument' ) )
	    if ( $marg eq "document" );
	print formoutput( formprefix( formlinenumbers( $. ),
				      message( 'FATAL' ) ),
			  message( 'commandnotenvironment',
				   '<environment>' => $marg ) )
	    if ( atarray( $marg, \@commandnotenvironment ) );
    } elsif ( exists $fontobsolete{$cmd} ) {
	# >>>>>>>>>>>> obsolete font command <<<<<<<<<<<<<<<<<<<<<<<<<<<
	print formoutput( formprefix( formlinenumbers( $. ),
				      message( 'OBSOLETE' ) ),
			  message( 'obsoletefontcommand',
				   '<cmd>' => $cmd,
				   '<new>' => $fontobsolete{$cmd} ) );
    } elsif ( exists $obsoletecommand{ $cmd } ) {
	# >>>>>>> e.g. \def instead of \newcommand or \renewcommand <<<<
	my $marg = readmarg();
	print formoutput( formprefix( formlinenumbers( $. ),
				      message( 'OBSOLETE' ) ),
			  message( 'obsoletecommand',
				   '<cmd>' => $cmd,
				   '<new>' => $obsoletecommand{$cmd} ) );
	print formoutput( formprefix( formlinenumbers( $. ),
				      message( 'OBSOLETE' ) ), 
			  message( 'baselinestretch' ) )
	    if ( ( $cmd eq '\def' ) && ( $marg eq '\baselinestretch' ) );
    } elsif ( $cmd eq '\renewcommand' ) {
	# >>>>>>>>>> \renewcommand maby with \baselinestretch <<<<<<<<<<
	my $marg;
	$linebuffer =~ s/^\*//;
	$marg = readmarg();
	print formoutput( formprefix( formlinenumbers( $. ),
				      message( 'OBSOLETE' ) ), 
			  message( 'baselinestretch' ) )
	    if ( $marg eq '\baselinestretch' );
    }
}

print formoutput( formprefix( message( 'FATAL' ) ),
		  message( 'missingenddocument' ) )
    if ( $atdocument );

analyse();

exit 1; # You will never reach this!

# ----------------------------------------------------------------------
# All the other subs
# ----------------------------------------------------------------------

# Test if an scalar is member ob an array
sub atarray {
    my ($value,$array) = @_;
    my $n = 0;
    for ( @$array ) {
	$n++;
	if ( $_ eq $value ) {
	    return $n;
	}
    }
    return 0;
}

# post analyzation
sub analyse {
    # Still do the checks
    print STDERR "$cmd\{document\} found at line $.\n" if ( $debug );
    print formoutput( formprefix( message( 'FATAL' ) ), 
		      message( 'missingdocumentclass' ) )
	if ( ! $classname );
    obsoletesearch();
    typeareasearch();
    nottogethersearch();
    parskipsearch();
    print $cgi->hr if ( $cgi );
    print "\n" if ( ! $cgi );
    print formoutput( message( 'Done' ) );
    printsource();
    printlegend();
    print $cgi->end_html() if ( $cgi );
    exit 0;
}

# print legend if switched in
sub printlegend {
    my $sw = $wrapindent;
    if ( $legend ) {
	print $cgi->hr, $cgi->h2( message( 'Legend' ) ) if ( $cgi );
	print "\n", message( 'Legend' ) . ":\n\n" if ( !$cgi );
	$wrapindent=0;
	print formoutput( message( 'Legendprefix' ) );
	print "\n" if ( !$cgi );
	$wrapindent=4;
	for ( @legenditem ) {
	    print formoutput( formprefix( message( $_ ) ),
			      message( "$_" . "description" ) );
	}
	print $cgi->p( message( 'Legendpostfixhtml' ) ) if ( $cgi );
	print "\n", formoutput( message( 'Legendpostfix' ) ) if ( !$cgi );
    }
    $wrapindent=$sw;
}

# print source if switched on
sub printsource {
    my $sw = $wrapindent;
    print $cgi->hr, $cgi->h2( message( 'Source' ) ), $cgi->pre( $srcbuffer ) 
	if ( $cgi && $showsrc );
    $wrapindent=4;
    print formoutput( message( 'Source' ) . ":\n", $srcbuffer )
	if ( !$cgi && $showsrc );
    $wrapindent=$sw;
}

# Changes of \parskip/\parindent?
sub parskipsearch {
    if ( @parskiplines ) {
	if ( ! exists $packagelines{ "parskip" } &&
	     ( ! $classname ||
	       ! atarray( $classname, \@classeswithparskip ) ) ) {
	    if ( $#parskiplines == 0 ) {
		print formoutput( formprefix ( formlinenumbers( \@parskiplines ),
					       message( 'WARNING') ),
				  message( 'parskipindent',
					   '<packages>' => \@packageswithparskip,
					   '<classes>' => \@classeswithparskip)
				  . ".\n" );
	    } else {
		print formoutput( formprefix ( message( 'WARNING') ),
				  message('parskipindent',
					  '<packages>' => \@packageswithparskip,
					  '<classes>' => \@classeswithparskip),
				  message( '(<plines>)',
					   '<plines>' => \@parskiplines )
				  . ".\n" );
	    }
	}
    }
}

# search if incompatible packages are used
sub nottogethersearch {
    for ( @packagesnottogether ) {
	my @packages = @$_;
	my $cnt = 0;
	my $msg = "";
	my $comma = "";
	for ( @packages ) {
	    my $package=$_;
	    if ( exists $packagelines{$package} ) {
		$msg .= $comma 
		    . message( 'packageatline',
			       '<package>' => $package,
			       '<pline>' => ( $packagelines{$package}[0] == $packagelines{$package}[1] ) ? 
			       $packagelines{$package}[0] :
			       "$packagelines{$package}[0]-$packagelines{$package}[1]" );
		$comma = ", ";
		$cnt++;
	    }
	}
	if ( $cnt > 1 ) {
	    print formoutput( formprefix( message( 'FATAL' ) ),
			      message( 'oneofpackages',
				       '<packages>' => $msg ) );
	}
    }
}

# search if multiple typearea packages are used
sub typeareasearch {
    my $msg = "";
    my $comma = "";
    for ( @typeareapackage ) {
	my $package = $_;
	if ( exists $packagelines{$package} ) {
	    $msg .= $comma
		. message( 'packageatline',
			   '<package>' => $package,
			   '<pline>' => ( $packagelines{$package}[0] == $packagelines{$package}[1] ) ? 
			   $packagelines{$package}[0] :
			   "$packagelines{$package}[0]-$packagelines{$package}[1]" );
	    $comma = ', ';
	}
    }
    if ( ( $comma eq ', ' ) && %typearealengthlines ) {
	my $mmsg = "";
        $comma="";
	while ( @_ = each %typearealengthlines ) {
	    $mmsg .= $comma
		. message( 'lengthatline',
			   '<length>' => $_[0],
			   '<pline>' => $_[1] );
	    $comma = ', ';
	}
	print formoutput( formprefix( message( 'WARNING' ) ),
			  message( 'typeareapackageandlength',
				   '<packages>' => $msg,
				   '<length>' => $mmsg ) );
    }
}

# search if obsolete packages are used
sub obsoletesearch {
    my @names;
    while ( @names = each %obsoleteclass ) {
	print formoutput( formprefix( formlinenumbers(  @classlines ),
				      message( 'OBSOLETE' ) ),
			  message( 'obsoleteclass',
				   '<class>' => $names[0],
				   '<new>' => $names[1] ) )
	    if ( $classname && ( $names[0] eq $classname ) )
    }
    while ( @names = each %obsoletepackage ) {
	print formoutput( formprefix( formlinenumbers( @{$packagelines{$names[0]}} ),
				      message( 'OBSOLETE' ) ),
			  message( 'obsoletepackage',
				   '<package>' => $names[0],
				   '<oneof>' => ( ref $names[1] ) ? message( 'oneof' ) : '',
				   '<new>' => $names[1] ) )
	    if ( exists $packagelines{$names[0]} );
    }
}

# Read linebuffer and remove comments
sub readlinebuffer {
    while ( ! $linebuffer || ! length $linebuffer ) {
	if ( $cgi ) {
	    return 0 if ( ! $readbuffer || ! length $readbuffer );
	    if ( $readbuffer =~ s/^([^\n]*\n)// ) {
		$linebuffer = $1;
	    } else {
		$linebuffer = $readbuffer;
		$readbuffer = "";
	    }
	    $.++;
	} else {
	    return 0 if ( ! ( $linebuffer = <> ) );
	}
	chomp $linebuffer;
	$srcbuffer .= sprintf "%5d: %s\n", $., $linebuffer 
	    if ( $showsrc );
	$linebuffer .= " ";
	$linebuffer =~ s/([^\\])%.*/$1/;
	$linebuffer =~ s/^%.*//;
    }
    return length $linebuffer;
}

# Get next command
sub nextcmd {
    do {
	return if ! readlinebuffer();
	$linebuffer =~ s/^ *//;           # remove trailing space
	$linebuffer =~ s/^[^\\]*//;        # search for macro
    } until ( length $linebuffer != 0 );
    $linebuffer =~ s/^(\\[a-zA-Z]*)(.*)/$2/;
    return $1;
}

# read obligatory argument (if any)
sub readoarg {
    my @oarg;
    my $cnt=0;
    do {
	return if ! readlinebuffer();
	$linebuffer =~ s/^ *//;           # remove trailing space
    } until ( length $linebuffer != 0 );
    if ( $linebuffer =~ /^\[(.*)/ ) {
	# We have an optional argument
	my $grouplevel = 0;
	$linebuffer = $1;
	do {
	    if ( $grouplevel == 0 ) {
		$oarg[$cnt] .= $1 
		    if ( $linebuffer =~ s/^ *([^\]\{,]*)(.*)/$2/ );
	    } else {
		$oarg[$cnt] .= $1
		    if ( $linebuffer =~ s/^([^\}]*)(.*)/$2/ );
	    }
	    print STDERR "Arg-Teil $cnt: \"$oarg[$cnt]\"\n" if ( $debug );
	    while ( length $linebuffer == 0 ) {
		return if ! readlinebuffer();
		$linebuffer =~ s/^ *//;           # remove trailing space
	    }
	    if ( $linebuffer =~ /^\{(.*)/ ) {
		$linebuffer = $1;
		$grouplevel++;
	    } elsif ( $linebuffer =~ /^\}(.*)/ ) {
		$linebuffer = $1;
		print formoutput( formprefix( "$. (FATAL):" ), 
				  "Group level error at optional argument!\n" )
		    if ( $grouplevel-- == 0 );
	    } elsif ( ( $grouplevel == 0 ) && ( $linebuffer =~ /^,(.*)/ ) ) {
		$linebuffer = $1;
		if ( length $oarg[$cnt] == 0 ) {
		    print formoutput( formprefix( "$. (WARNING):" ), 
				      "Empty optional argument!\n" );
		} else {
		    $cnt++;
		}
	    }
	} while ( ( $grouplevel > 0 ) || ( $linebuffer !~ /^\](.*)/ ) );
	$linebuffer=$1;
	print STDERR "@oarg + $linebuffer\n" if ( $debug );
    }
    return @oarg;
}

# read mandatory argument
sub readmarg {
    my $marg;
    my $grouplevel = 0;
    do {
	if ( ! $marg && ! $grouplevel && 
	     ( $linebuffer =~ /^ *(\\[a-zA-Z]+)(.*)/ ) ) {
	    $marg = $1;
	    $linebuffer = $2;
	    print STDERR "Macro: $marg + $linebuffer\n" if ( $debug );
	    return $marg;
	} else {
	    $marg .= $1
		if ( $linebuffer =~ s/^([^\{\}]*)(.*)/$2/ );
	}
	print STDERR "Arg: \"$marg\"\n" if ( $debug );
	while ( length $linebuffer == 0 ) {
	    return if ! readlinebuffer();
	    $linebuffer =~ s/^ *//;           # remove trailing space
	}
	print STDERR "linebuffer: \"$linebuffer\"\n" if ( $debug );
	if ( $linebuffer =~ /^\{(.*)/ ) {
	    $linebuffer = $1;
	    $grouplevel++;
	} 
	if ( $linebuffer =~ /^\}(.*)/ ) {
	    $linebuffer = $1;
	    print formoutput( formprefix("$. (FATAL):"), 
			      "Group level error before argument!\n" )
		if ( $grouplevel-- == 0 );
	}
    } while ( $grouplevel > 0 );
    $marg =~ s/^ *//;
    $marg =~ s/ *$//;
    print STDERR "$marg + $linebuffer\n" if ( $debug );
    return $marg;
}

__END__

=head1 NAME

TeXidate - Heuristical validation of the header of LaTeX files.

=head1 SYNOPSIS

=over 9

=item TeXidate 

[--debug] [--help,-h] [--language,-l F<language>] [--legend|-L] [--version] 
[--withsource,-s] [--wrapwidth,-w F<value>] [F<LaTeX-file> [F<output-file]>]

=back

=head1 OPTIONS

=over 8

=item B<--debug>

Toggle debug mode.  Default is off.

=item B<--help>,B<-h>

Show a help message text and exit.

=item B<--language,-l> F<language>

Set the language of the analyzation output. F<language> should be something
like B<de>, B<de_DE>, B<de_DE@euro>, B<de_CH> or similar. Currently only the 
part before the first "_" or "@" will be used to select the language.
Default language is english, which will be used also, if an unknown language 
was selected. Known languages are:

=over 4

=item B<de>

German

=item B<en>

English

=back

=item B<--legend,-L>

Toggle output of legend.  The legend describes the composition of the 
analyzation messages and the meaning of the message classes.  Default is off.

=item B<--version>

Show version information and exit.

=item B<--withsource,-s>

Toggle output of source with linenumbers at the end of the 
analyzation.  Default is off.

=item B<--wrapwidth,-w> F<value>

Sets the line width to F<value>.  Default is the value of environment variable
C<COLUMNS> or 80 if the variable is not set.

=back

=head1 ARGUMENTS

=over 8

=item F<LaTeX-file>

The name of the file to be analyzed.  You may use "-" for standard input.
Default is standard input.

=item F<output-file>

The name of the file for the diagnostic messages.  Default is standard output.

=back

If only one argument is given, this is the F<LaTeX-file>.  Output is written
to standard output in this case.

If no argument is given, input will be read from standard input and the 
message will be written to standard output.  This is the default.

=head1 DESCRIPTION

B<TeXidate> will read the given F<LaTeX-file> and does some analysis.  Some
typical mistakes are detected, but it doesn't show all the miracles.  It may
even fail completely in its diagnostics, because it searches only for patterns
and doesn't analyze the real structure.  B<TeXidate> doesn't provide a real
TeX parser.

You may also call B<TeXidate> as CGI.  In that case the contents of the file
has to be the value of CGI-parameter C<contents>.

=head1 ENVIRONMENT

B<TeXidate> uses the following environment variables:

=over 8

=item B<COLUMNS>

Default value for the line length of the analyzation output. You may overwrite
this value using option B<--wrapwidth>.

=item B<LC_MESSAGES>

Default value for the language of the analyzation output. You may overwrite
this value using option B<--language>.

=item B<LC_ALL>

Default value for the language if environment variable B<LC_MESSAGES> was not
defined.

=item B<LANG>

Default value for the language if environment variable B<LC_MESSAGES> and
B<LC_ALL> was not defined.

=back

=head1 AUTHOR

Copyright (c) 2003-2004 Markus Kohm E<lt>kohm@gmx.deE<gt>

=cut

