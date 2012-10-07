package Smart::Options;
use strict;
use warnings;
use 5.010001;
our $VERSION = '0.01';

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(argv);

use List::MoreUtils qw(uniq);
use Text::Table;

sub new {
    my $pkg = shift;

    bless {
        alias    => {},
        default  => {},
        boolean  => {},
        demand   => {},
        usage    => "Usage: $0",
        describe => {},
    }, $pkg;
}

sub argv {
    Smart::Options->new->parse(@_);
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

sub _set_v2a {
    my ($argv, $key, $value) = @_;

    if (exists $argv->{$key}) {
        if (ref($argv->{$key})) {
            push @{$argv->{$key}}, $value;
        }
        else {
            $argv->{$key} = [ $argv->{$key}, $value ];
        }
    }
    else {
        $argv->{$key} = $value;
    }
}

sub parse {
    my $self = shift;
    push @_, @ARGV unless @_;

    my $argv = {};
    my @args;
    my $alias = $self->{alias};
    my $boolean = $self->{boolean};

    my $key;
    my $stop = 0;
    for my $arg (@_) {
        if ($stop) {
            push @args, $arg;
            next;
        }
        if ($arg =~ /^--(\w+)=(.+)$/) {
            my $option = $alias->{$1} // $1;
            _set_v2a($argv, $option, $2);
        }
        elsif ($arg =~ /^(-(\w+)|--(\w+))$/) {
            if ($key) {
                $argv->{$key} = 1;
            }
            my $opt = $2 // $3;
            my $option = $alias->{$opt} // $opt;
            if ($boolean->{$option}) {
                $argv->{$option} = 1;
            }
            else {
                $key = $option;
            }
        }
        elsif ($arg =~ /^--$/) {
            # stop parsing
            $stop = 1;
            next;
        }
        else {
            if ($key) {
                _set_v2a($argv, $key, $arg);
                $key = undef; # reset
            }
            else {
                push @args, $arg;
            }
        }
    }
    if ($key) {
        $argv->{$key} = 1;
    }
    $argv->{_} = \@args;

    while (my ($key, $val) = each %{$self->{default}}) {
        $argv->{$key} //= $val;
    }

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

Smart::Options - smart command line options processor

=head1 SYNOPSIS

  use Smart::Options;

  my $argv = Smart::Options->new->argv;

  if ($argv->{rif} - 5 * $argv->{xup} > 7.138) {
      say 'Buy more fiffiwobbles';
  }
  else {
     say 'Sell the xupptumblers';
  }

  # $ ./example.pl --rif=55 --xup=9.52
  # Buy more fiffiwobbles
  #
  # $ ./example.pl --rif 12 --xup 8.1
  # Sell the xupptumblers

=head1 DESCRIPTION

Smart::Options is a library for option parsing for people tired option parsing.
This module is analyzed as people interpret an option intuitively.

=head1 METHOD

=head2 new()

Create a parser object.

  use Smart::Options;

  my $argv = Smart::Options->new->parse(qw(-x 10 -y 2));

=head2 parse(@args)

parse @args. return hashref of option values.
if @args is empty Smart::Options use @ARGV

=head2 argv(@args)

shortcut method. this method auto export.

  use Smart::Options;
  say argv(qw(-x 10))->{x};

is the same as

  use Smart::Options ();
  Smart::Options->new->parse(qw(-x 10))->{x};

=head2 alias($alias, $option)

set alias for option. you can use "$option" field of argv.

  use Smart::Options;
  
  my $argv = Smart::Options->new->alias(f => 'file')->parse(qw(-f /etc/hosts));
  $argv->{file} # => '/etc/hosts'

=head2 default($option, $default_value)

set default value for option.

  use Smart::Options;
  
  my $argv = Smart::Options->new->default(y => 5)->parse(qw(-x 10));
  $argv->{x} + $argv->{y} # => 15

=head2 describe($option, $msg)

set option help message.

  use Smart::Options;
  my $opt = Smart::Options->new()->alias(f => 'file')->describe('Load a file');
  say $opt->help;

  # Usage: ./example.pl
  #
  # Options:
  #    -f, --file  Load a file
  #

=head2 boolean($option, $option2, ...)

interpret 'option' as a boolean.

  use Smart::Options;
  
  my $argv = Smart::Options->new->parse(qw(-x 11 -y 10));
  $argv->{x} # => 11
  
  my $argv2 = Smart::Options->new->boolean('x')->parse(qw(-x 11 -y 10));
  $argv2->{x} # => true (1)

=head2 demand($option, $option2, ...)

show usage (showHelp()) and exit if $option wasn't specified in args.

  use Smart::Options;
  my $opt = Smart::Options->new()->alias(f => 'file')
                                 ->demand('file')
                                 ->describe('Load a file');
  $opt->argv(); # => exit

  # Usage: ./example.pl
  #
  # Options:
  #    -f, --file  Load a file [required]
  #

=head2 options($key => $settings, ...)

  use Smart::Options;
  my $opt = Smart::Options->new()
    ->options( f => { alias => 'file', default => '/etc/passwd' } );

is the same as

  use Smart::Options;
  my $opt = Smart::Options->new()
              ->alias(f => 'file')
              ->default(f => '/etc/passwd');

=head2 usage

set a usage message to show which command to use. default is "Usage: $0".

=head2 help

return help message string

=head2 showHelp($fh)

print usage message. default output STDERR.

=head1 PARSING TRICKS

=head2 stop parsing

use '--' to stop parsing.

  use Smart::Options;
  use Data::Dumper;

  my $argv = argv(qw(-a 1 -b 2 -- -c 3 -d 4));
  warn Dumper($argv);

  # $VAR1 = {
  #        'a' => '1',
  #        'b' => '2',
  #        '_' => [
  #                 '-c',
  #                 '3',
  #                 '-d',
  #                 '4'
  #               ]
  #      };

=head2 negate fields

'--no-key' set false to $key.

  use Smart::Options;
  argv(qw(-a --no-b))->{b}; # => 0

=head2 duplicates

If set flag multiple times it will get arrayref.

  use Smart::Options;
  argv(qw(-x 1 -x 2 -x 3))->{x}; # => [1, 2, 3]

=head1 AUTHOR

Kan Fushihara E<lt>kan.fushihara@gmail.comE<gt>

=head1 SEE ALSO

https://github.com/substack/node-optimist

L<GetOpt::Casual>, L<opts>, L<GetOpt::Compat::WithCmd>

=head1 LICENSE

Copyright (C) Kan Fushihara

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
