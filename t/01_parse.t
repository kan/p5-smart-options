use strict;
use Test::More;

use Smart::Options;

my $opts = Smart::Options::parse(qw(--rif=55 --xup=9.52));

is $opts->{rif}, 55;
is $opts->{xup}, 9.52;

done_testing;
