use strict;
use warnings;
use ExtUtils::MakeMaker;
use ExtUtils::Constant;

use 5.008001;

WriteMakefile (
    NAME         => 'Image::PNG',
    VERSION      => '0.21',
    ABSTRACT     => 'Read and write PNG files',
    AUTHOR => 'Ben Bullock <bkb@cpan.org>',
    LICENSE => 'perl',
    PREREQ_PM => {
	'Image::PNG::Libpng' => '0.27',
    },
    META_MERGE => {
        resources => {
            "MailingList" => "http://groups.google.com/group/perlimagepng",
            "bugtracker" => "https://github.com/benkasminbullock/Image-PNG/issues",
            "repository" => "https://github.com/benkasminbullock/Image-PNG",
        },
        no_index => {
            directory => ['tmpl', 'build'],
        },
    },
    MIN_PERL_VERSION => '5.008001',
);

# Local Variables:
# mode: perl
# End:
