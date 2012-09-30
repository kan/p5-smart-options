package Smart::Options;
use strict;
use warnings;
use 5.010001;
our $VERSION = '0.01';

use List::MoreUtils qw(uniq);
use Text::Table;

sub new {
    my $pkg = shift;

    bless {
        args     => \@_,
        alias    => {},
        default  => {},
        boolean  => {},
        demand   => {},
        usage    => "Usage: $0",
        describe => {},
    }, $pkg;
}

sub _set {
    my $self = shift;
    my $param = shift;

    my %args = @_;
    for my $option (keys %args) {
        $self->{$param}->{$option} = $args{$option};
    }

    $self;
}

sub alias { shift->_set('alias', @_) }
sub default { shift->_set('default', @_) }
sub describe { shift->_set('describe', @_) }

sub _set_flag {
    my $self = shift;
    my $param = shift;

    for my $option (@_) {
        $self->{$param}->{$option} = 1;
    }

    $self;
}

sub boolean { shift->_set_flag('boolean', @_) }
sub demand { shift->_set_flag('demand', @_) }

sub options {
    my $self = shift;

    my %args = @_;
    while (my($opt, $setting) = each %args) {
        for my $key (keys %$setting) {
            $self->$key($opt, $setting->{$key});
        }
    }

    $self;
}

sub usage { $_[0]->{usage} = $_[1]; $_[0] }

sub _get_opt_desc {
    my ($self, $option) = @_;

    my $desc = (length($option) == 1 ? '-' : '--') . $option;
    if (my $alias = $self->{alias}->{$option}) {
        $desc .= ", " . (length($alias) == 1 ? '-' : '--') . $alias;
    }

    $desc;
}

sub help {
    my $self = shift;

    my $demand = $self->{demand};
    my $describe = $self->{describe};
    my $default = $self->{default};
    my $help = $self->{usage} . "\n";

    if (scalar(keys %$demand) or scalar(keys %$describe)) {
        my @opts;
        for my $opt (uniq sort keys %$demand, keys %$describe) {
            push @opts, [
                $self->_get_opt_desc($opt),
                $describe->{$opt} || '',
                $self->{boolean}->{$opt} ? '[boolean]' : '',
                $demand->{$opt} ? '[required]' : '',
                $default->{$opt} ? "[default: @{[$default->{$opt}]}]" : '',
            ];
        }

        my $sep = \'  ';
        $help .= "\nOptions:\n";
        $help .= Text::Table->new( $sep, '', $sep, '', $sep, '', $sep, '', $sep, '' )
                            ->load(@opts)->stringify;
    }
}

sub showHelp {
    my ($self, $fh) = @_;
    $fh //= *STDERR;

    print $fh $self->help;

}

sub argv {
    my $self = shift;

    my $argv = {%{$self->{default}}};
    my @args;
    my $alias = $self->{alias};
    my $boolean = $self->{boolean};

    my $key;
    my $stop = 0;
    for my $arg (@{$self->{args}}) {
        if ($stop) {
            push @args, $arg;
            next;
        }
        if ($arg =~ /^--(\w+)=(.+)$/) {
            my $option = $alias->{$1} // $1;
            $argv->{$option} = $2;
        }
        elsif ($arg =~ /^-(\w+)$/) {
            if ($key) {
                $argv->{$key} = 1;
            }
            my $option = $alias->{$1} // $1;
            if ($boolean->{$option}) {
                $argv->{$option} = 1;
            }
            else {
                $key = $option;
            }
        }
        elsif ($arg =~ /^--(\w+)$/) {
            if ($key) {
                $argv->{$key} = 1;
                $key = undef;
            }
            my $option = $alias->{$1} // $1;
            $argv->{$option} = 1;
        }
        elsif ($arg =~ /^--$/) {
            # stop parsing
            $stop = 1;
            next;
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

    for my $opt (keys %{$self->{demand}}) {
        if (!$argv->{$opt}) {
            $self->showHelp;
            print STDERR "\nMissing required arguments: $opt\n";
            die;
        }
    }

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
