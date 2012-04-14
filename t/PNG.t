use warnings;
use strict;
use FindBin;
use Test::More tests => 9;
use_ok ("Image::PNG");
use utf8;

use Image::PNG;

my $png = Image::PNG->new ({verbosity => undef});
my $file = "$FindBin::Bin/test.png";
$png->read ($file);
#$png->verbosity (1);
ok ($png->width () == 100, "oo-width");
ok ($png->height () == 100, "oo-height");
ok ($png->color_type () eq 'RGB', "oo colour type");
#print $png->bit_depth (), "\n";
ok ($png->bit_depth () == 8, "oo bit depth");
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
ok (! defined $time2);
my $time = $png->time ();
ok (! defined $time);

# Get some text from a PNG file.

my $text_png = Image::PNG->new ();
$text_png->read ("$FindBin::Bin/with-text.png");
my @text = $text_png->text ();
ok ($text[2]->{text} eq '工藤俊作', "read text from PNG");

# Local Variables:
# mode: perl
# End:
