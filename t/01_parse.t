use strict;
use Test::More;

use Smart::Options;

subtest 'long option' => sub {
    my $opts = Smart::Options::parse(qw(--rif=55 --xup=9.52));

    is $opts->{rif}, 55;
    is $opts->{xup}, 9.52;
};

subtest 'short option' => sub {
    my $opts = Smart::Options::parse(qw(-x 10 -y 21));

    is $opts->{x}, 10;
    is $opts->{y}, 21;
};

done_testing;
