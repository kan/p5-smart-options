use strict;
use Test::More;

use Smart::Options;

subtest 'alias' => sub {
    my $opts = Smart::Options->new(qw(--r=55 --xup=9.52));
    $opts->alias(r => 'rif');

    is $opts->argv->{rif}, 55;
    is $opts->argv->{xup}, 9.52;
};

subtest 'default' => sub {
    my $opts = Smart::Options->new(qw(-x 5));
    $opts->default(x => 10);
    $opts->default(y => 10);

    is $opts->argv->{x}, 5;
    is $opts->argv->{y}, 10;
};

done_testing;
