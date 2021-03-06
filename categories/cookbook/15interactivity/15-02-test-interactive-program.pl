use v6;

=begin pod

=TITLE Test whether program is interactive or not

=AUTHOR stmuk

Test whether program is interactive or not
running from terminal or in batch mode (like cron on UNIX)

=end pod

# this doesn't currently (Aug 2015) work on MoarVM since
# isatty isn't implemented
# https://rt.perl.org/Ticket/Display.html?id=123347 
#
sub I-am-interactive {
    return  $*IN.t && -t $*OUT.t;
}

# vim: expandtab shiftwidth=4 ft=perl6
