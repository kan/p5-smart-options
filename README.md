Smart::Options
==============

Smart::Options is a library for option parsing for people tired option parsing.
This module is analyzed as people interpret an option intuitively.

[![build status](https://secure.travis-ci.org/kan/p5-smart-options.png)](http://travis-ci.org/kan/p5-smart-options)

examples
=======

````perl
use Smart::Options;

my $argv = Smart::Options->new->argv;

if ($argv->{rif} - 5 * $argv->{xup} > 7.138) {
    say 'Buy more fiffiwobbles';
}
else {
   say 'Sell the xupptumblers';
}
````

***

    $ ./example.pl --rif=55 --xup=9.52
    Buy more fiffiwobbles

    $ ./example.pl --rif 12 --xup 8.1
    Sell the xupptumblers

