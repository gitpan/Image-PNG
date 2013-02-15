# This file contains tests for the PNG.pm module (the simplified OO
# version of PNG access).

use warnings;
use strict;
use utf8;
use FindBin;
use Test::More;

# Set up outputs to not print wide character warnings (this is for
# debugging this file, not for the end-user's benefit).

my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";

use Image::PNG;

# "Supports" is imported to test whether the underlying library
# supports iTXt chunks and skip some of the tests if not.

use Image::PNG::Libpng qw/supports/;

my $png = Image::PNG->new ({verbosity => undef});
my $file = "$FindBin::Bin/test.png";
$png->read ($file);

# Test the reading of the PNG file's header.

ok ($png->width () == 100, "oo-width");
ok ($png->height () == 100, "oo-height");
ok ($png->color_type () eq 'RGB', "oo colour type");
ok ($png->bit_depth () == 8, "oo bit depth");

# Test writing out the file.

my $out_file = "$FindBin::Bin/out.png";
if (-f $out_file) {
    unlink $out_file or die $!;
}
$png->write ($out_file);
ok (-f $out_file, "Write output file");
eval {
    unlink ($out_file) or die $!;
};

# Test the documentation's claim that a PNG with no time returns the
# undefined value.

my $png2 = Image::PNG->new ({verbosity => undef});
my $time2 = $png2->time ();
ok (! defined $time2, "Time () is not defined for empty PNG");
my $time = $png->time ();
ok (! defined $time, "Time () is not defined for PNG with no time");

# Get some text from a PNG file.

SKIP: {
    skip "Your libpng does not have iTXt support", 2
        unless 0;#(Image::PNG::Libpng::supports ("iTXt"));
    my $text_png = Image::PNG->new ();
    $text_png->read ("$FindBin::Bin/with-text.png");
    my @text = $text_png->text ();
    # my %h = %{$text[1]};
    # binmode STDOUT, ":utf8";
    # for my $k (keys %h) {
    #     print "$k $h{$k}\n";
    # }
    ok ($text[1]->{text} eq 'Leonardo DaVinci', "read ASCII text from PNG");
    ok ($text[2]->{text} eq '工藤俊作', "read Unicode text from PNG");
};

done_testing ();

# Local Variables:
# mode: perl
# End:
