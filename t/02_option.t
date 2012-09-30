use strict;
use Test::More;

use Smart::Options;

subtest 'alias' => sub {
    my $opts = Smart::Options->new(qw(--r=55 --xup=9.52));
    $opts->alias(r => 'rif');

    is $opts->argv->{rif}, 55;
    is $opts->argv->{xup}, 9.52;
};


done_testing;
