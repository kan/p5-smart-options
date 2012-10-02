use strict;
use Test::More;

use Smart::Options;

subtest 'stop parsing' => sub {
    my $argv = Smart::Options->new(qw(-a 1 -b 2 -- -c 3 -d 4))->argv;

    is $argv->{a}, 1;
    is $argv->{b}, 2;
    is_deeply $argv->{_}, ['-c', '3', '-d', '4'];
};

subtest 'negate fields' => sub {
    my $argv = Smart::Options->new(qw(-a --no-b))->argv;

    ok $argv->{a};
    ok !$argv->{b};
};

done_testing;
