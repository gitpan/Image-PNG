package Image::PNG;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw/display_text/;
use Image::PNG::Const ':all';
use Image::PNG::Libpng;
use Image::PNG::Container;
use warnings;
use strict;
use Carp;

our $VERSION = 0.08;


sub error
{
    my ($png) = @_;
    return $png->{error_string};
}

sub fatal_error
{
    my ($png) = @_;
    return $png->{error_string};
}

my %IHDR_fields = (
    width => {
    },
    height => {
    },
    bit_depth => {
        default => 8,
    },
    color_type => {
    },
    interlace_type => {
        default => PNG_INTERLACE_NONE,
    },
);


sub write_info_error
{
    my ($png) = @_;
    my @unset;
    for my $field (sort keys %IHDR_fields) {
        if (!$IHDR_fields{$field}{default}) {
            push @unset, $field;
        }
        print "Set the following fields: ", join ", ", @unset;
    }
}

sub verbose
{
    my ($png) = @_;
    return $png->{verbosity};
}

sub verbosity
{
    my ($png, $verbosity) = @_;
    if ($verbosity) {
        printf "I am a %s. I am going to print messages about what I'm doing. You can surprsss this by calling \$me->verbosity () or by using an option %s->new ({verbosity} = 0);.\n", (__PACKAGE__) x 2;
    }
    $png->{verbosity} = 1;
}

sub new
{
    my ($package, $options) = @_;
    my $png = {};
    bless $png;
    $png->{read} = undef;
    # The marker "error_string" contains the most recent error.
    $png->{error_string} = '';
    if ($options && ref $options eq 'HASH') {
        if ($options->{verbosity}) {
            $png->verbosity ($options->{verbosity});
        }
        if ($options->{file}) {
            $png->read ($options->{file});
        }
    }
    return $png;
}

sub Image::PNG::read
{
    my ($png, $file_name) = @_;
    if ($png->verbose) {
        print "I am going to try to read a file called '$file_name'.\n";
    }
    if (! defined $file_name) {
        carp __PACKAGE__, ": You called 'read' without giving a file name";
        return;
    }
    my $read = Image::PNG::Container->new ({read_only => 1});
    $read->set_file_name ($file_name);
    $read->open ();
    $read->read ();
    if ($png->verbose) {
        my $ihdr = Image::PNG::Libpng::get_IHDR ($read->png ());
        printf ("The size of the image is %d X %d; its colour type is %s; its bit depth is %d\n", $ihdr->{width}, $ihdr->{height}, Image::PNG::Libpng::color_type_name ($ihdr->{color_type}), $ihdr->{bit_depth});
    }

    $png->{read} = $read;
    return 1;
}

sub handle_error
{
    my ($png, $message) = @_;
    croak $message;
}

sub Image::PNG::write
{
    my ($png, $file_name) = @_;
    if ($png->verbose) {
        print "I am going to try to write a PNG file called '$file_name'.\n";
    }
    if (! $png->{write_ok}) {
        if (! $png->{read}) {
            $png->write_info_error ();
        }
        $png->init_write ();
    }
    my $write = $png->{write};
    $write->{file_name} = $file_name;
    # Check whether the image to be written has all of its IHDR information.
    if (! $write->{ihdr_set}) {
        if ($png->verbose) {
            print "The image to be written doesn't seem to know what its header is supposed to be, so I'm going to try to find a substitute.\n";
        }
        if ($png->{read}) {
            if ($png->verbose) {
                print "I am copying the header from the image which I read in.\n";
            }
            my $ihdr = Image::PNG::Libpng::get_IHDR ($png->{read}->png ());
            if ($png->verbose) {
                print "I've got a header and now I'm going to try to put it into the output.\n";
            }
            Image::PNG::Libpng::set_IHDR ($write->{png}, $ihdr);
            $write->{ihdr} = $ihdr;
        }
        else {
            $png->handle_error ("I have no IHDR (header) data for the image; use the 'IHDR' method to set the IHDR values");
        }
    }
    if ($png->verbose) {
        print "I've got a header to write. Now I'm going to check the image data before writing it out.\n";
    }
    # Check whether the image data (the rows of the image) exist in
    # some form or other.
    if (! $write->{rows_set}) {
        if ($png->verbose) {
            print "You haven't specified what data you want me to write.\n";
        }
        # If the user has not specified what rows to write, assume
        # that he wants to use the rows from a PNG object which has
        # already been read in.
        if ($png->{read}) {
            if ($png->verbose) {
                print "I am setting the image data for the image to write to data which I read in from another image.";
            }
            my $rows = Image::PNG::Libpng::get_rows ($png->{read_png});
            if ($png->verbose) {
                print "I've got the data from the read image and now I'm going to set up the writing to write that data.\n";
            }
            Image::PNG::Libpng::set_rows ($write->{png}, $rows);
        }
        else {
            # There is no row data for the image.
            $png->handle_error ("I have no row data for the image; use the 'rows' method to set the rows.");
            return;
        }
    }
    printf ("Its colour type is %s.\n", Image::PNG::Libpng::color_type_name ($write->{ihdr}->{color_type}));

    if ($write->{ihdr}->{color_type} == PNG_COLOR_TYPE_PALETTE) {
        if ($png->verbose) {
            print "The image you want to write has a palette, so I am going to check whether the palette is ready to be written.\n";
        }
        if (! $write->{palette_set}) {
            print "The image doesn't have a palette set.\n";
            if ($png->{read}) {
                print "I am going to try to get one from the image I read in.\n";
                my $palette = Image::PNG::Libpng::get_PLTE ($png->{read_png});
                for my $color (@$palette) {
                    for my $hue (qw/red green blue/) {
                        printf "%s: %d ", $hue, $color->{$hue};
                    }
                    print "\n";
                }
                Image::PNG::Libpng::set_PLTE ($write->{png}, $palette);
            }
            else {
                $png->handle_error ("You asked me to write an image with a palette, but I don't have any information about the palette for the image.");
            }
        }
    }

    if ($png->verbose) {
        print "I've got the data for the header and the image now so I can write a minimal PNG.\n";
    }
    # Now the rows are set.
    open my $output, ">:raw", $write->{file_name}
        or $png->handle_error ("opening file '$write->{file_name}' failed: $!'");
    Image::PNG::Libpng::init_io ($write->{png}, $output);
    Image::PNG::Libpng::write_png ($write->{png});
}

# Private

sub do_not_write
{
    my ($png, $chunk) = @_;
    push @{$png->{write}->{ignored_chunks}}, $chunk;
}

# Public

sub Image::PNG::delete
{
    my ($png, @chunks) = @_;
    if (! $png->{write_ok}) {
        if (! $png->{read}) {
            $png->write_info_error ();
        }
        $png->init_write ();
    }
    for my $chunk (@chunks) {
        $png->do_not_write ($chunk);
    }
}

sub write_set
{
    my ($png, $key, $value) = @_;
    if (! $png->{write_ok}) {
        $png->init_write ();
    }
    $png->{write}->{$key} = $value;
}

# Initialize the object $png for writing (get the stupid libpng things
# we need to write an image, set a flag "write_ok" in the image.).

sub init_write
{
    my ($png) = @_;
    if ($png->{write_ok}) {
        $png->error ("Writing already initialized");
        return;
    }
    $png->{write} = {};
    $png->{write}->{png} =
        Image::PNG::Libpng::create_write_struct ();
    $png->{write_ok} = 1;
}

sub raise_error
{
    my ($png, $error_level) = @_;
}

sub print_error
{
    my ($png, $error_level) = @_;
}

sub data
{
    my ($png, $data) = @_;
    if (! $data) {
        # Return the existing data
    } else {
        # Put $data into the PNG
        if ($png->{data}) {
            carp __PACKAGE__, ": you have asked me to put a scalar value as the PNG data, but I already have PNG data inside me. Please use a fresh object.";
        } elsif ($png->{read_file_name}) {
            carp __PACKAGE__, ": you have asked me to put a scalar value as the PNG data, but I already contain PNG data from a file called '$png->{read_file_name}. Please use a fresh object.";
        }
    }
    return $png->{data};
}

# Public

sub IHDR
{
    my ($png, $ihdr) = @_;
    if ($ihdr) {
        Image::PNG::Libpng::set_IHDR ($png->{write}->{png},
                                             $ihdr);
        $png->{write}->{ihdr_set} = 1;
    }
    else {
        $ihdr = Image::PNG::Libpng::get_IHDR ($png->{read_png});
    }
    return $ihdr;
}

# Private

sub get_IHDR
{
    my ($png) = @_;
    if ($png->{IHDR}) {
        carp __PACKAGE__, ": I was requested to read the IHDR of the PNG data, but I have already read it.";
        return;
    }
    $png->{IHDR} = Image::PNG::Libpng::get_IHDR ($png->{read}->png ());
}

sub get
{
    my ($png, $key) = @_;
    if (! $png->{IHDR}) {
        $png->get_IHDR ();
    }
    return $png->{IHDR}->{$key};
}

sub width
{
    my ($png, $width) = @_;
    if ($width) {
        write_set ($png, 'width', $width);
    }
    else {
        return get ($png, 'width');
    }
}

sub height
{
    my ($png, $height) = @_;
    if ($height) {
        write_set ($png, 'height', $height);
    }
    else {
        return get ($png, 'height');
    }
}

sub color_type
{
    my ($png, $color_type) = @_;
    if ($color_type) {
        write_set ($png, 'color_type', $color_type);
    }
    else {
        return 
            Image::PNG::Libpng::color_type_name (
                get ($png, 'color_type')
            );
    }
}

sub bit_depth
{
    my ($png, $bit_depth) = @_;
    if ($bit_depth) {
        write_set ($png, 'bit_depth', $bit_depth);
    }
    else {
        return get ($png, 'bit_depth')
    }
}

sub rows
{
    my ($png, $rows) = @_;
    if ($rows) {
        # Set the rows
        if (! $png->{write_ok}) {
            $png->init_write ();
        }
        if (! $png->{write}->{set_IHDR}) {
            $png->{write}->{set_IHDR} = 1;
            Image::PNG::Libpng::set_IHDR ($png->{write}->{png},
                                                 $png->{write}->{IHDR});
        }
        Image::PNG::Libpng::set_rows ($png->{write_png}, $rows);
        $png->{write}->{rows_set} = 1;
    }
    else {
        # Read the rows
        if (! $png->{read}) {
            #        $png->handle_error ("");
            return;
        }
        return Image::PNG::Libpng::get_rows ($png->{read_png});
    }
}

sub rowbytes
{
    my ($png) = @_;
    if (! $png->{read}) {
#        $png->handle_error ("");
        return;
    }
    return Image::PNG::Libpng::get_rowbytes ($png->{read_png});
}

sub text
{
    my ($png, $text) = @_;
    if (! $png->{text}) {
        my $text_ref =
            Image::PNG::Libpng::get_text ($png->{read_png});
        $png->{text} = $text_ref;
        # Change the text compression field to words rather than numbers.
        for my $text (@{$png->{text}}) {
            $text->{compression} =
                Image::PNG::Libpng::text_compression_name ($text->{compression});
        }
    }
    if (! wantarray) {
        carp __PACKAGE__, ": the 'text' method returns an array";
    }
    return @{$png->{text}};
}

sub time
{
    my ($png) = @_;
    return Image::PNG::Libpng::get_tIME ($png->{read_png});
}

# We need to free the memory associated with the C structs allocated
# inside libpng, so this class has a DESTROY method.

sub DESTROY
{
    my ($png) = @_;
    if ($png->{verbose}) {
        print "Freeing the memory of a PNG object.\n";
    }
}

# The text segment of the PNG should probably be an object in its own
# right.

sub display_text
{
    my ($text) = @_;
    if (! $text || ref $text ne 'HASH' || ! $text->{key}) {
        carp __PACKAGE__, "::display_text called with something which doesn't seem to be a PNG text chunk";
        return;
    }
    print "\n";
    print "Key: $text->{key}";
    if ($text->{translated_keyword}) {
        print " [$text->{translated_keyword}";
        if ($text->{lang}) {
            print " in language $text->{lang}";
        }
        print "]";
    }
    print "\n";
    print "Compression: $text->{compression}\n";
    if ($text->{text}) {
        printf "Text";
        if (defined $text->{text_length}) {
            printf " (length %d)", $text->{text_length};
        }
        print ":\n$text->{text}\n"
    }
    else {
        print "Text is empty.\n";
    }
}

1;


=head1 NAME

Image::PNG - Read and write PNG (Portable Network Graphics) files

=head1 WARNING

This version of the module is solely for evaluation and testing. This
module is currently incomplete and untested, and contains errors,
bugs, and inconsistencies, including unresolved memory corruption
errors which can crash Perl. The documentation below refers to
functions which may or may not exist in the completed module and
contains links to things which do not exist and may never exist.




=head1 SYNOPSIS

    my $png = Image::PNG->new ();
    $png->read_file ("crazy.png");
    printf "Your PNG is %d x %d\n", $png->width, $png->height;

=head1 General methods

=head2 read_file

    $png->read_file ("crazy.png")
        or die "Can't read it: " . $png->error ();

=head2 write_file

    $png->write_file ("crazy.png")
        or die "Can't write it: " . $png->error ();

=head2 data

     my $data = $png->data ();

Get the PNG binary data.

=head2 error

Print the most recent error message.

=head1 PNG header-related methods

These methods are related to the PNG header (the IHDR chunk of the PNG
file). 

=head2 width

    my $height = $png->width ();

Get the width of the current PNG image.

=head2 height

    my $height = $png->height ();

Get the height of the current PNG image.

=head2 color_type

    my $color_type = $png->color_type ();

Get the name of the colour type of the current PNG image. The possible
return values are

=over

=item PALETTE

=item GRAY

=item GRAY_ALPHA

=item RGB

=item RGB_ALPHA

=back

=head2 bit_depth

    my $bit_depth = $png->bit_depth ();

Get the bit depth of the current PNG image.

=head2 interlacing_method

    my $interlacing_method = $png->interlacing_method

Get the name of the method of interlacing of the current PNG image.

There is no method for dealing with the compression method
field of the header, since this only has one possible value.

=head1 Image data-related methods

=head2 rowbytes

    my $rowbytes = $png->rowbytes;

This method returns the number of bytes in each row of the image. If
no image has been read yet, it returns the undefined value.

=head2 rows

    my $rows = $png->rows;

This method returns the rows of the image as an array reference which
contains a number of elements equal to the height of the image. Each
element has the length of the number of bytes in one row (as given by
L<rowbytes>) plus one final zero byte. The row data returned is binary
data and may contain several bytes with the value zero.

=head1 Non-image chunks

=head2 text

    my @text = $png->text;

Get the text chunks of the image. Each chunk is a hash reference with
the keys being the fields of the PNG text chunk and the values being
the values of those fields.

=head2 time

    my $time_ref = $png->time;
    print "The PNG was last modified in $time_ref->{year}.\n";

Get the last modified time of the image. The return value is a hash
reference containing six fields,

=over

=item year

=item month

=item day

=item hour

=item minute

=item second

=back

These represent the last modification time of the image. The
modification time of a PNG file is meant to be in the GMT (UCT) time
zone so there is no time zone information in this.

If there is no last modification time, a hash reference is returned
but it doesn't contain any fields.

=head1 FUNCTIONS

There are some convenience functions in this module, exported on request.

=head2 display_text

     use Image::PNG qw/display_text/;
     my @text = $png->text;
     display_text ($text[3]);

Display the text chunk given as an argument on C<STDOUT>.

This is meant as a minimal convenience function for when you are
debugging or something rather than a general-purpose text chunk
display routine.

=head1 SUPPORT

There is a mailing list for this Perl module at Google Groups. If you
have a question or suggestion or bug report, please let me know via
the mailing list. You don't have to join the mailing list to post a
message.

=head1 SEE ALSO

=head2 In this distribution

=head3 Image::PNG::Const

L<Image::PNG::Const> contains the libpng constants taken from the libpng
header file "png.h".

=head3 Image::PNG::Libpng

L<Image::PNG::Libpng> provides a Perl mirror of the interface of the C
PNG library "libpng". Image::PNG is built on top of this module.

=head2 libpng download

If you need to download libpng, see
L<http://www.libpng.org/pub/png/libpng.html>. See also L</Alien::PNG>.

=head2 Other Perl modules on CPAN

=head3 Image::ExifTool

L<Image::ExifTool> is a pure Perl (doesn't require a C compiler)
solution for accessing the text segments of images. It has extensive
support for PNG text segments.

=head3 Alien::PNG

L<Alien::PNG> claims to be a way of "building, finding and using PNG
binaries". It may help in installing libpng. I didn't use it as a
dependency for this module because it seems not to work in batch mode,
but stop and prompt the user. I'm interested in hearing feedback from
users whether this works or not on various platforms.

=head3 Image::PNG::Rewriter

L<Image::PNG::Rewriter> is a utility for unpacking and recompressing
the IDAT (image data) part of a PNG image. The main purpose seems to
be to recompress the image data with the module author's other module
L<Compress::Deflate7>. Unfortunately that only works with Perl
versions 5.12.

=head3 Image::Pngslimmer

L<Image::Pngslimmer> reduces the size of dynamically created PNG
images. It's very, very slow at reading PNG data, but seems to work
OK.

=head3 Image::Info

L<Image::Info> is a module for getting information out of various
types of images. It has good support for PNG and is written in pure
Perl (doesn't require a C compiler). As well as basics such as height,
width, and colour type, it can get text chunks, modification time,
palette, gamma (gAMA chunk), resolution (pHYs chunk), and significant
bits (sBIT chunk). At the time of writing (version 1.31) it doesn't
support other chunks.



=head2 About the PNG format

=head3 The PNG specification

L<The PNG specification|http://www.w3.org/TR/PNG/> (link to W3
consortium) explains the details of the PNG format.


=head3 PNG The Definitive Guide by Greg Roelofs

The book "PNG - The Definitive Guide" by Greg Roelofs, published in
1999 by O'Reilly is available online at
L<http://www.faqs.org/docs/png/>. I didn't refer to this book at all
in making Image::PNG, so I can't vouch for it, but looking at the
contents pages it appears to contain a lot of useful information,
although it is definitely showing its age, with chapters about
software such as Netscape Navigator and BeOS.

=head1 EXAMPLES

There is a collection of demonstrations and example scripts online at
L<http://www.lemoda.net/image-png/>. This currently contains

=over

=item PNG inspector L<http://www.lemoda.net/png/inspect/>

This demonstration downloads a PNG file you specify from the internet
and prints out its contents.

=item PNG quantizer L<http://www.lemoda.net/png/quantize/>

This demonstration downloads a PNG file you specify from the internet
and quantizes it with as many colours as you want (from two to 256) in
order to reduce its size. The quantized image is uploaded to imgur.com
using L<WWW::Imgur>.

=back



=head1 AUTHOR

Ben Bullock, <bkb@cpan.org>

=head1 COPYRIGHT & LICENCE

The Image::PNG package and associated files are copyright (C)
2011 Ben Bullock.

You can use, copy, modify and redistribute Image::PNG and
associated files under the Perl Artistic Licence or the GNU General
Public Licence.

=head1 SUPPORT

=head2 Mailing list

There is a mailing list at
L<http://groups.google.com/group/perlimagepng>. You don't need to be a
member of the list to post messages to the list or participate in
discussions. Your messages may be held for moderation though.

If you have anything at all to say about the module, whether it is bug
reports, feature requests, or anything else, I'd prefer to discuss it
on the mailing list because that way there is a public record which
everyone can access, rather than being restricted to email. That means
that, for example, if someone else takes over maintaining this module,
they can easily access records of previous discussions.

=head2 CPAN stuff

There is a bug tracker at .

=head1 FOR PROGRAMMERS

(This section is only for people who want to fix a bug or add an
improvement to this module, and who want to share the change with
other people by adding it to the public version of this module.)

If you want to alter this module, note very carefully that the
distributed files are not actually the source code of the module. The
source code lives in the "tmpl" directory of the distribution and the
distribution is created via scripts.

The original files of this distribution make very heavy use of the
L<Template> Perl module in order to cut down the amount of repetitive
stuff which needs to be put into various source and documentation
files. If you plan to alter the C file, you may also need a program
called "cfunctions" which you can download from sourceforge, which
generates the header file perl-libpng.h from perl-libpng.c.



=cut


# Local Variables:
# mode: perl
# End:


# Local Variables:
# mode: perl
# End:
