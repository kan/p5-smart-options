# NAME

Smart::Options - smart command line options processor

[![build status](https://secure.travis-ci.org/kan/p5-smart-options.png)](http://travis-ci.org/kan/p5-smart-options)

# SYNOPSIS

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

# DESCRIPTION

Smart::Options is a library for option parsing for people tired option parsing.
This module is analyzed as people interpret an option intuitively.

# METHOD

## new()

Create a parser object.

    use Smart::Options;

    my $argv = Smart::Options->new->parse(qw(-x 10 -y 2));

## parse(@args)

parse @args. return hashref of option values.
if @args is empty Smart::Options use @ARGV

## argv(@args)

shortcut method. this method auto export.

    use Smart::Options;
    say argv(qw(-x 10))->{x};

is the same as

    use Smart::Options ();
    Smart::Options->new->parse(qw(-x 10))->{x};

## alias($alias, $option)

set alias for option. you can use "$option" field of argv.

    use Smart::Options;
    

    my $argv = Smart::Options->new->alias(f => 'file')->parse(qw(-f /etc/hosts));
    $argv->{file} # => '/etc/hosts'

## default($option, $default\_value)

set default value for option.

    use Smart::Options;
    

    my $argv = Smart::Options->new->default(y => 5)->parse(qw(-x 10));
    $argv->{x} + $argv->{y} # => 15

## describe($option, $msg)

set option help message.

    use Smart::Options;
    my $opt = Smart::Options->new()->alias(f => 'file')->describe('Load a file');
    say $opt->help;

    # Usage: ./example.pl
    #
    # Options:
    #    -f, --file  Load a file
    #

## boolean($option, $option2, ...)

interpret 'option' as a boolean.

    use Smart::Options;
    

    my $argv = Smart::Options->new->parse(qw(-x 11 -y 10));
    $argv->{x} # => 11
    

    my $argv2 = Smart::Options->new->boolean('x')->parse(qw(-x 11 -y 10));
    $argv2->{x} # => true (1)

## demand($option, $option2, ...)

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

## options($key => $settings, ...)

    use Smart::Options;
    my $opt = Smart::Options->new()
      ->options( f => { alias => 'file', default => '/etc/passwd' } );

is the same as

    use Smart::Options;
    my $opt = Smart::Options->new()
                ->alias(f => 'file')
                ->default(f => '/etc/passwd');

## usage

set a usage message to show which command to use. default is "Usage: $0".

## help

return help message string

## showHelp($fh)

print usage message. default output STDERR.

# PARSING TRICKS

## stop parsing

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

## negate fields

'--no-key' set false to $key.

    use Smart::Options;
    argv(qw(-a --no-b))->{b}; # => 0

## duplicates

If set flag multiple times it will get arrayref.

    use Smart::Options;
    argv(qw(-x 1 -x 2 -x 3))->{x}; # => [1, 2, 3]

# AUTHOR

Kan Fushihara <kan.fushihara@gmail.com>

# SEE ALSO

https://github.com/substack/node-optimist

[GetOpt::Casual](http://search.cpan.org/perldoc?GetOpt::Casual), [opts](http://search.cpan.org/perldoc?opts), [GetOpt::Compat::WithCmd](http://search.cpan.org/perldoc?GetOpt::Compat::WithCmd)

# LICENSE

Copyright (C) Kan Fushihara

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
