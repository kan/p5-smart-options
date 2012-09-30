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

subtest 'boolean option' => sub {
    my $opts = Smart::Options::parse(qw(-s --fr));

    ok $opts->{s};
    ok $opts->{fr};
    ok !$opts->{sp};
};

subtest 'non-hyponated options' => sub {
    my $opts = Smart::Options::parse(qw(-x 6.82 -y 3.35 moo));

    is $opts->{x}, 6.82;
    is $opts->{y}, 3.35;
    is_deeply $opts->{_}, ['moo'];

    my $opts2 = Smart::Options::parse(qw(foo -x 0.54 bar -y 1.12 baz));

    is $opts2->{x}, 0.54;
    is $opts2->{y}, 1.12;
    is_deeply $opts2->{_}, ['foo','bar','baz'];
};

done_testing;
