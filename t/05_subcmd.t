use strict;
use Test::More;

use Smart::Options;

subtest 'support subcommand' => sub {
    my $opt = Smart::Options->new();
    $opt->subcmd(add => Smart::Options->new()->demand(qw(x y)));
    $opt->subcmd(minus => Smart::Options->new()->demand(qw(x y)));
    my $argv = $opt->parse(qw(add -x 10 -y 5));

    is $argv->{command}, 'add';
    is $argv->{option}->{x}, 10;
    is $argv->{option}->{y}, 5;
};


done_testing;
