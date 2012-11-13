use strict;
use warnings;
use Smart::Options::Declare;
use Test::More;
use Try::Tiny;
use Capture::Tiny ':all';

my $out = capture_stderr {
    try {
        @ARGV = qw(--help);
        foo();
    }
};

is $out, <<EOS, 'help message';
Usage: t/declare/10_help.t

Options:
  -h, --help    Show help             
  -p, --pi, -q                        
  -r, --radius  Radius of circle      

EOS

done_testing;


sub foo {
    opts my $pi => { isa => 'Num', alias => 'q' },
         my $radius => { isa => 'Num', comment => 'radius of circle' };
    is $pi, 3.14;
}
