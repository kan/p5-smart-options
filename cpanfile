
    build_requires        => {
        'Test::More' => '0.98',
        'Test::Requires'  => 0,
    },
requires 'Exporter';
requires 'Text::Table';
requires 'List::MoreUtils';
requires 'PadWalker';

on 'configure' => sub {
    requires 'Module::Build' => '0.38';
    requires 'Module::Build::Pluggable';
    requires 'Module::Build::Pluggable::CPANfile';
};

on 'test' => sub {
    requires 'Test::More' => '0.98';
    requires 'Test::Requires' =>  0;
    requires 'Test::TCP';
    requires 'Capture::Tiny'   => '0.12';
    requires 'Try::Tiny';
    requires 'Test::Exception';
    requires 'File::Spec';
    requires 'File::Slurp';
};
