package Smart::Options;
use strict;
use warnings;
use 5.010001;
our $VERSION = '0.01';

sub new {
    my $pkg = shift;

    bless { args => \@_ }, $pkg;
}

sub argv {
    my $self = shift;

    my $argv = {};
    my @args;

    my $key;
    for my $arg (@{$self->{args}}) {
        if ($arg =~ /^--(\w+)=(.+)$/) {
            $argv->{$1} = $2;
        }
        elsif ($arg =~ /^-(\w+)$/) {
            if ($key) {
                $argv->{$key} = 1;
            }
            $key = $1;
        }
        elsif ($arg =~ /^--(\w+)$/) {
            if ($key) {
                $argv->{$key} = 1;
                $key = undef;
            }
            $argv->{$1} = 1;
        }
        else {
            if ($key) {
                $argv->{$key} = $arg;
                $key = undef; # reset
            }
            else {
                push @args, $arg;
            }
        }
    }
    $argv->{_} = \@args;

    $argv;
}


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
