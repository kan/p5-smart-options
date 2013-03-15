use strict;
use warnings;
use Module::Build::Pluggable (
    'CPANfile'
);

my $build = Module::Build::Pluggable->new(
    license               => 'perl',
    dynamic_config        => 0,
                          
    requires             => {
        perl => '5.010001',
    },

    no_index    => { 'directory' => [ 'inc' ] },
    name        => 'Smart-Options',
    module_name => 'Smart::Options',

    # script_files => [''],

    test_files => (-d '.git' || $ENV{RELEASE_TESTING}) ? 't/ xt/' : 't/',
    recursive_test_files => 1,
   
    create_readme  => 1,
    create_license => 1,
);
$build->create_build_script();
