use Module::Build;
my $build = new Module::Build
(
    module_name => 'GDS2',
    license => 'artistic',
    requires => {
        perl => '5.6.0',
    },
    sign => 1,
);
$build -> create_build_script;

