use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Simo::Util',
    license             => 'perl',
    dist_author         => 'Yuki Kimoto <kimoto.yuki@gmail.com>',
    dist_version_from   => 'lib/Simo/Util.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'Simo::Wrapper' => 0.0207,
        'Simo::Error' => 0.0205,
        'Carp' => 0,
    },
    add_to_cleanup      => [ 'Simo-Util-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
