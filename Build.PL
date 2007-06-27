use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'MasonX::MiniMVC',
    license             => 'perl',
    dist_author         => 'Kirrily "Skud" Robert <skud@cpan.org>',
    dist_version_from   => 'lib/MasonX/MiniMVC.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'MasonX-MiniMVC-*' ],
);

$builder->create_build_script();
