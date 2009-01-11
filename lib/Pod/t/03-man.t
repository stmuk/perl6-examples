#!/usr/local/bin/perl6
use Test;
use Pod::to::man;

class Test::Parser is Pod::to::man {
    has @.out is rw;
    # parse source lines from a text document instead of a file
    method parse( $self: $text ) {
        @.out = ();
        self.doc_beg( 'test' );
        for $text.split( "\n" ) -> $line { self.parse_line( $line ); }
        self.doc_end;
        return @.out;
    }
    # capture Pod6Parser output into array @.out for inspection
    method emit( $self: Str $text ) { @.out.push( $text ); }
    # Possible Rakudo bug: calling a base class method ignores other
    # overrides in derived class, such as the above emit() redefine.
    # workaround: redundantly copy base class method here, fails too!
}

plan 7;

my Test::Parser $p .= new; $p.parse_file('/dev/null'); # warming up

my $docdate = Pod::to::man::docdate( time() ); # TODO: replace with mtime when stat() works
my $pod = slurp('t/p01-plain.pod').chomp; # Rakudo slurp appends a "\n"
my $expected = qq(((.TH test 6 "$docdate" "Perl 6" "Plain Old Documentation"
.nh
.ad l
.PP
document 01 plain text
.\\" test end.)));
my $output = $p.parse( $pod ).join("\n");
is( $output, $expected, "p01-plain.pod simplest text" );
#$*ERR.say: "OUTPUT: $output";

$pod = slurp('t/p02-para.pod').chomp; # Rakudo slurp appends a "\n"
$expected = qq(((.TH test 6 "$docdate" "Perl 6" "Plain Old Documentation"
.nh
.ad l
.PP
Document p02-para.pod tests paragraphs.
.PP
After the above one liner, this second paragraph has three lines to verify
that all lines are processed together as one paragraph, and to check word
wrap.
.PP
The third paragraph is declared in the abbreviated style.
.PP
The fourth paragraph is declared in the delimited style.
.\\" test end.)));
$output = $p.parse( $pod ).join("\n");
is( $output, $expected, 'p02-para.pod paragraphs' );
#$*ERR.say: "OUTPUT: $output";

$pod = slurp('t/p03-head.pod').chomp; # Rakudo slurp appends a "\n"
$expected = qq(((.TH test 6 "$docdate" "Perl 6" "Plain Old Documentation"
.nh
.ad l
.SH NAME
.PP
Pod::Parser - stream based parser for Perl 6 Plain Old Documentation
.SH DESCRIPTION
.SS SPECIFICATION
.PP
The specification for Perl 6 POD is Synopsis 26, which can be found at
http://perlcabal.org/syn/S26.html
.\\" test end.)));
$output = $p.parse( $pod ).join("\n");
is( $output, $expected, 'p03-head.pod =head1 and =head2' );
#$*ERR.say: "OUTPUT: $output";

$pod = slurp('t/p04-code.pod').chomp; # Rakudo slurp appends a "\n"
$expected = qq(((.TH test 6 "$docdate" "Perl 6" "Plain Old Documentation"
.nh
.ad l
.SH NAME
.PP
p04-code.pod - test processing of code (verbatim) paragraph
.SH SYNOPSIS
.sp
.nf
 # code, paragraph style
 say 'first';
.fi
.PP
This text is a non code paragraph.
.sp
.nf
# code, delimited block style
say 'second';
.fi
.\\" test end.)));
$output = $p.parse( $pod ).join("\n");
is( $output, $expected, 'p04-code.pod code paragraphs' );
#$*ERR.say: "OUTPUT: $output";

$pod = slurp('t/p05-pod5.pod').chomp; # Rakudo slurp appends a "\n"
$expected = qq(((.TH test 6 "$docdate" "Perl 6" "Plain Old Documentation"
.nh
.ad l
.PP
The =pod is a Perl 5 POD command.
.SH NAME
.PP
p05-pod5.pod - Perl 5 Plain Old Document to test backward compatibility
.SH DESCRIPTION
.PP
This document starts with a marker that indicates POD 5 and not POD 6.
.\\" test end.)));
$output = $p.parse( $pod ).join("\n");
is( $output, $expected, 'p05-pod5.pod legacy compatibility' );
#$*ERR.say: "OUTPUT: $output";

$pod = slurp('t/p07-basis.pod').chomp; # Rakudo slurp appends a "\n"
$expected = qq(((.TH test 6 "$docdate" "Perl 6" "Plain Old Documentation"
.nh
.ad l
.PP
Document p07-basis.pod tests the B formatting code. The B < > formatting
code specifies that the contained text is the basis or focus of the
surrounding text; that it is of fundamental significance. Such content
would typically be rendered in a bold style or in < strong > ... < /strong
> tags.
.PP
One \\fBbasis\\fR word.
.PP
Then \\fBtwo basis\\fR words.
.PP
Third, \\fBa basis phrase\\fR followed by \\fBanother basis phrase\\fR.
.PP
Fourth, \\fBa basis phrase that is so long that it should be word wrapped in
whatever output format it is rendered\\fR.
.\\" test end.)));
$output = $p.parse( $pod ).join("\n");
is( $output, $expected, "p07-basis.pod formatting B<>" );
#$*ERR.say: "OUTPUT: $output";

$pod = slurp('t/p13-link.pod').chomp; # Rakudo slurp appends a "\n"
$expected = qq(((.TH test 6 "$docdate" "Perl 6" "Plain Old Documentation"
.nh
.ad l
.PP
Document p13-link.pod tests the L formatting code. The L < > code is used
to specify all kinds of links, filenames, citations, and cross-references
(both internal and external).
.PP
The simplest link is internal, such as to \\fISCHEMES\\fR.
.PP
A link may also specify an alternate name and a \\fIscheme (SCHEMES)\\fR.
.SH SCHEMES
.PP
The following examples were taken from \\fIS26
(http://perlcabal.org/syn/S26.html)\\fR and then extended.
.SS http: and https:
.PP
\\fIhttp://www.mp3dev.org/mp3/\\fR See also: \\fIhttp:tutorial/faq.html\\fR and
\\fIhttp:../examples/index.html\\fR
.SS file:
.PP
Either \\fI/usr/local/lib/.configrc\\fR or \\fI~/.configrc\\fR. Either 
\\fI.configrc\\fR or \\fICONFIG/.configrc\\fR.
.SS mailto:
.PP
Please forward bug reports to \\fIdevnull@rt.cpan.org\\fR
.SS man:
.PP
Unix \\fIfind(1)\\fR facilities.
.SS doc:
.PP
You may wish to use \\fIData::Dumper\\fR to view the results. See also: 
\\fIperldata\\fR.
.SS defn:
.PP
prone to \\fIlexiphania\\fR : an unfortunate proclivity
.PP
To treat his chronic \\fIlexiphania\\fR the doctor prescribed
.SS isbn: and issn:
.PP
The Perl Journal (\\fI1087-903X\\fR).
.\\" test end.)));
$output = $p.parse( $pod ).join("\n");
is( $output, $expected, "p13-link.pod format L<link>" );
#$*ERR.say: "OUTPUT:\n$output";

