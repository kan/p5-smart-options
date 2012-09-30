use strict;
use Test::More;

use Smart::Options;
use Capture::Tiny ':all';
use Try::Tiny;

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

subtest 'boolean' => sub {
    my $opts = Smart::Options->new(qw(-x -z one two three));
    $opts->boolean('x', 'y', 'z');

    ok $opts->argv->{x};
    ok !$opts->argv->{y};
    ok $opts->argv->{z};
    is_deeply $opts->argv->{_}, [qw(one two three)];
};

subtest 'demand' => sub {
    my $opts = Smart::Options->new(qw(-x 4.91 -z 2.51));
    $opts->usage("Usage: $0 -x [num] -y [num]");
    $opts->demand('x', 'y');

    my $out = capture_stderr { try { $opts->argv } };
    is $out, <<"EOS";
Usage: $0 -x [num] -y [num]

Options:
   -x      [required]
   -y      [required]

Missing required arguments: y
EOS
};

subtest 'describe' => sub {
    my $opts = Smart::Options->new(qw(-x 4.91 -z 2.51));
    $opts->usage("Usage: $0 -x [num] -y [num]");
    $opts->demand('x', 'y');
    $opts->describe(f => 'Load a file', y => 'year');

    my $out = capture_stderr { try { $opts->argv } };
    is $out, <<"EOS";
Usage: $0 -x [num] -y [num]

Options:
   -f   Load a file             
   -x                 [required]
   -y   year          [required]

Missing required arguments: y
EOS
};


done_testing;
