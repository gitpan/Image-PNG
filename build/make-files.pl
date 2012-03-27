#!/home/ben/software/install/bin/perl

# This turns the template files into their distribution-ready forms.

use warnings;
use strict;
use Template;
BEGIN {
    use FindBin;
    use lib "$FindBin::Bin";
    use ImagePNGBuild;
    use LibpngInfo 'template_vars', '@chunks';
};
use autodie;

my %config = ImagePNGBuild::read_config ();

my $tt = Template->new (
    ABSOLUTE => 1,
    INCLUDE_PATH => $config{tmpl_dir},
#    STRICT => 1,
);

my @libpng_diagnostics = ImagePNGBuild::libpng_diagnostics (\%config);

my @files = qw/
                  Const.pm
                  Const.t
                  Container.pm
                  Libpng.pm
                  Libpng.t
                  Libpng.xs
                  META.json
                  META.yml
                  Makefile.PL
                  PLTE.t
                  PNG.pm
                  PNG.t
                  Util.pm
                  perl-libpng.c
                  typemap
              /;

my %vars;
$vars{config} = \%config;
my $functions = ImagePNGBuild::get_functions (\%config);
for my $chunk (@chunks) {
    if ($chunk->{auto_type}) {
        my $name = $chunk->{name};
        push @$functions, ("get_$name", "set_$name");
    }
}
$vars{functions} = $functions;
$vars{self} = $0;
$vars{date} = scalar gmtime ();
$vars{libpng_diagnostics} = \@libpng_diagnostics;

# Get lots of stuff about libpng from the module LibpngInfo in the
# same directory as this script, used to build documentation etc.

template_vars (\%vars);
for my $x (@{$vars{chunk}{cHRM}{fields}}) {
    print $x, "\n";
}
#for my $x (@{$vars{ihdr_fields}}) {
#    print $x->{name}, "\n";
#}

# These files go in the top directory

my %top_dir = (
    'Makefile.PL' => 1,
    'Libpng.xs' => 1,
    'typemap' => 1,
    'perl-libpng.c' => 1,
    'META.json' => 1,
    'META.yml' => 1,
);

my @outputs;

for my $file (@files) {
    my $template = "$file.tmpl";
    my $output;
    if ($top_dir{$file}) {
        $output = $file;
    }
    elsif ($file eq 'PNG.pm') {
        $output = $config{main_module_out};
    }
    elsif ($file =~ /.t$/) {
        $output = "t/$file";
    }
    else {
        $output = "$config{submodule_dir}/$file";
    }
    push @outputs, $output;

    print "$output\n";
#    print "Processing $template into $output.\n";
    $vars{input} = $template;
    $vars{output} = $output;
    if (-f $output) {
        chmod 0644, $output;
    }
    $tt->process ($template, \%vars, $output)
        or die '' . $tt->error ();
    chmod 0444, $output;
}

# These PNGs are used in the tests. Many of them are from
# http://libpng.org/pub/png/pngsuite.html.

my @test_pngs = qw!
t/test.png
t/with-text.png
t/with-time.png
t/tantei-san.png
t/bgyn6a16.png
t/xlfn0g04.png
t/ccwn2c08.png
t/cdun2c08.png
t/saru-fs8.png
!;

# Other files which aren't made from templates.

my @extras = qw!
my-xs.c
tmpl/author
tmpl/config
tmpl/Const.pm.tmpl
tmpl/examples_doc
tmpl/generated
tmpl/libpng_doc
tmpl/other_modules
tmpl/png_doc
tmpl/pngspec
tmpl/version
tmpl/warning
build/ImagePNGBuild.pm
build/LibpngInfo.pm
build/make-files.pl
Changes
MANIFEST
MANIFEST.SKIP
my-xs.h
perl-libpng.h
t/bKGD.t
t/cHRM.t
t/pHYs.t
t/tRNS.t
README
!;
my @mani;
push @mani, map {"tmpl/$_.tmpl"} @files;
push @mani, @outputs;
push @mani, @test_pngs;
push @mani, @extras;
push @mani, 'makeitfile';

my $output = 'MANIFEST';
if (-f $output) {
    chmod 0644, $output;
}
open my $out, '>', $output;
for my $file (sort @mani) {
    print $out "$file\n";
}
close $out;
chmod 0444, $output;
exit;
