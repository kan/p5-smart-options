package Smart::Options;
use strict;
use warnings;
use 5.010001;
our $VERSION = '0.01';

sub parse {
    my $argv = {};

    for my $arg (@_) {
        if ($arg =~ /^--(\w+)=(.+)$/) {
            $argv->{$1} = $2;
        }
    }

    $argv;
}

sub argv { parse(@ARGV) }

1;
__END__

=encoding utf8

=head1 NAME

Smart::Options - A module for you

=head1 SYNOPSIS

  use Smart::Options;

=head1 DESCRIPTION

Smart::Options is

=head1 AUTHOR

Kan Fushihara E<lt>kan.fushihara@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Kan Fushihara

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
