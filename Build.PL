use Module::Build;
my $build = new Module::Build
(
    module_name => 'GDS2',
    license => 'perl',
    requires => {
        perl => '5.6.0',
    },
    PL_files => {
        'lib/GDS2.pm.PL' => 'lib/GDS2.pm.original',
    },
    sign => 1,
);
$build -> create_build_script;

