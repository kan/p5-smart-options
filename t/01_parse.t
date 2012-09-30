use strict;
use Test::More;

use Smart::Options;

subtest 'long option' => sub {
    my $argv = Smart::Options->new(qw(--rif=55 --xup=9.52))->argv;

    is $argv->{rif}, 55;
    is $argv->{xup}, 9.52;
};

subtest 'short option' => sub {
    my $argv = Smart::Options->new(qw(-x 10 -y 21))->argv;

    is $argv->{x}, 10;
    is $argv->{y}, 21;
};

subtest 'boolean option' => sub {
    my $argv = Smart::Options->new(qw(-s --fr))->argv;

    ok $argv->{s};
    ok $argv->{fr};
    ok !$argv->{sp};
};

subtest 'non-hyponated options' => sub {
    my $argv = Smart::Options->new(qw(-x 6.82 -y 3.35 moo))->argv;

    is $argv->{x}, 6.82;
    is $argv->{y}, 3.35;
    is_deeply $argv->{_}, ['moo'];

    my $argv2 = Smart::Options->new(qw(foo -x 0.54 bar -y 1.12 baz))->argv;

    is $argv2->{x}, 0.54;
    is $argv2->{y}, 1.12;
    is_deeply $argv2->{_}, ['foo','bar','baz'];
};

done_testing;
