package Smart::Options::Declare;
use strict;
use warnings;

use Exporter 'import';
use Smart::Options;
use PadWalker qw/var_name/;

our @EXPORT = qw(opts);

my %is_invocant = map{ $_ => undef } qw($self $class);

sub opts {
    {
        package DB;
        () = caller(1);
    }

    if ( exists $is_invocant{ var_name( 1, \$_[0] ) || '' } ) {
        $_[0] = shift @DB::args;
        shift;
    }

    my $opt = Smart::Options->new();

    for ( my $i = 0 ; $i < @_ ; $i++ ) {
        ( my $name = var_name( 1, \$_[$i] ) )
          or Carp::croak('usage: opts my $var => TYPE, ...');

        $name =~ s/^\$//;

        if ($name =~ /_/) {
            (my $newname = $name) =~ s/_/-/g;
            $opt->alias($newname => $name);

            $name = $newname;
        }

        my $rule = $_[$i+1];

        if ($rule) {
            if (ref($rule) && ref($rule) eq 'HASH') {

                if ($rule->{default}) {
                    $opt->default($name => $rule->{default});
                }

                if ($rule->{required}) {
                    $opt->demand($name);
                }

                if ($rule->{alias}) {
                    $opt->alias($rule->{alias} => $name);
                }

                if ($rule->{comment}) {
                    $opt->describe($name => $rule->{comment});
                }
            }
        }

        #auto set alias
        if (length($name) > 1) {
            $opt->alias(substr($name,0,1) => $name);
        }

        $i++ if defined $_[$i+1]; # discard type info
    }

    my $argv = $opt->parse;
    for ( my $i = 0 ; $i < @_ ; $i++ ) {
        ( my $name = var_name( 1, \$_[$i] ) )
          or Carp::croak('usage: opts my $var => TYPE, ...');

        $name =~ s/^\$//;

        $_[$i] = $argv->{$name};
        $i++ if defined $_[$i+1]; # discard type info
    }
}

1;
__END__

=encoding utf8

=head1 NAME

Smart::Options::Declare - DSL for Smart::Options

=head1 SYNOPSIS

  use Smart::Options::Declare;

  opts my $rif, my $xup;

  if ($rif - 5 * $xup > 7.138) {
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

Smart::Options::Declare is a library which offers DSL for Smart::Options. 

=head1 AUTHOR

Kan Fushihara E<lt>kan.fushihara@gmail.comE<gt>

=head1 SEE ALSO

L<opts>

=head1 LICENSE

Copyright (C) Kan Fushihara

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
