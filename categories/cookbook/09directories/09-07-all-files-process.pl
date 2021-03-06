use v6;

=begin pod

=TITLE Process files recursively

=AUTHOR stmuk

You want to recurse over all files in and under a directory

=end pod

use File::Find;

sub MAIN(:$dir = "/etc") {
    # note binding := for a list

    my @files := find(:dir($dir), :type('file'));

    #  returns a list of IO::Path objects

    for @files.sort -> $io {
        say $io.abspath;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
