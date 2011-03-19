use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'HoN::Client',
    AUTHOR        => q{"Cafe" <"cafe@q1software.com">},
    VERSION_FROM  => 'lib/HoN/Client.pm',
    ABSTRACT_FROM => 'lib/HoN/Client.pm',
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002
        ? ( 'LICENSE' => 'perl' )
        : () ),
    PL_FILES  => {},
    PREREQ_PM => {
        'Test::More'                        => 0,
        'Convert::Binary::C'             => 0,
        'Data::Hexdumper'             => 0,
        'Digest::MD5'                      => 0,
        'AnyEvent'                          => 0,
        'PHP::Serialization'               => 0,
        'Moose'                               => 0,
        'MooseX::ClassAttribute '     => 0.24,
        'namespace::autoclean'       => 0,
        'Module::Pluggable::Object'   => 0

    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'HoN-Client-*' },
);

