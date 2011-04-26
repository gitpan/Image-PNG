# This file is just a list of exports and documentation. The source
# code for this file is in Libpng.xs in the top directory.

package Image::PNG::Libpng;
require Exporter;
require DynaLoader;
@ISA = qw(Exporter);
@EXPORT_OK = qw/
	create_read_struct
	create_write_struct
	destroy_read_struct
	destroy_write_struct
	write_png
	init_io
	read_info
	read_png
	get_IHDR
	get_tIME
	set_tIME
	get_text
	set_text
	sig_cmp
	read_from_scalar
	color_type_name
	text_compression_name
	get_libpng_ver
	access_version_number
	get_rows
	get_rowbytes
	get_PLTE
	set_PLTE
	get_bKGD
	get_cHRM
	get_channels
	get_sBIT
	get_oFFs
	get_pHYs
	get_sRGB
	get_valid
	set_rows
	set_IHDR
	write_to_scalar
	set_filter
	set_verbosity
	set_unknown_chunks
	get_unknown_chunks
	supports
	set_keep_unknown_chunks
/;

%EXPORT_TAGS = (
    all => \@EXPORT_OK,
);

require XSLoader;
our $VERSION = 0.03;

XSLoader::load('Image::PNG', $VERSION);

1;

=pod









=head1 NAME

Image::PNG::Libpng - Perl interface to the C library "libpng".

=head1 WARNING

This version of the module is solely for evaluation and testing. This
module is currently incomplete and untested, and contains errors,
bugs, and inconsistencies, including unresolved memory corruption
errors which can crash Perl. The documentation below refers to
functions which may or may not exist in the completed module and
contains links to things which do not exist and may never exist.




=head1 SYNOPSIS

     use Image::PNG::Libpng;
     my $png = Image::PNG::Libpng::create_read_struct ();
     open my $file, '<:raw', 'nice.png';
     Image::PNG::Libpng::init_io ($png, $file);
     Image::PNG::Libpng::read_png ($png);
     close $file;
     Image::PNG::Libpng::destroy_read_struct ($png);

Image::PNG::Libpng enables Perl to use the "libpng" library for
reading and writing files in the PNG (Portable Network Graphics)
format.

Image::PNG::Libpng consists of Perl subroutines which mirror
the C functions in libpng, plus helper subroutines to make it easier
to read and write PNG data in Perl. 

For an easy way to access PNG files, try the companion module L<Image::PNG>, which offers a simplified interface to the functions
in this module.

For those who are familiar with libpng, to know what the differences
between this module and libpng are, please go to the section
L</Differences from libpng>.

=head1 FUNCTIONS

=head2 create_read_struct

     my $png = create_read_struct ();

Create a structure for reading a PNG.

=head3 Correspondence to libpng

This function corresponds to C<png_create_read_struct> plus C<create_info_struct> (see L</No info structure>) with the error and warning handler variables set up to use
Perl's error reporting.

=head2 create_write_struct

     my $png = create_write_struct ();

Create a structure for writing a PNG.

=head3 Correspondence to libpng

This function corresponds to C<png_create_write_struct> plus C<create_info_struct> (see L</No info structure>)  with the error and warning handler variables set up to use
Perl's error reporting.

=head2 destroy_read_struct

     destroy_read_struct ($png);

This frees the memory associated with C<$png>. 

=head3 Correspondence to libpng

This function corresponds to C<png_destroy_read_struct>, without the
info and end_info arguments. See L</No info structure>.

=head2 destroy_write_struct

     destroy_write_struct ($png);

This frees the memory associated with C<$png>.

=head3 Correspondence to libpng

This function corresponds to C<png_destroy_write_struct>.

=head1 Input and output

=head2 init_io

     open my $file, "<", 'nice.png';
     init_io ($png, $file);

Set the file which C<$png> reads or writes to C<$file>. C<$file> must
be an already-opened Perl file handle. If C<$png> was created with
L<create_write_struct>, C<$file> must be opened for writing. If
C<$png> was created with L<create_read_struct>, C<$file> must be open
for reading.

Since PNG files are binary files, it's safest to specify the "raw"
pragma or use "binmode" with the file in order to override any default
text file encoding which Perl might be using:

     open my $file, ">:raw", 'output.png';

or

     open my $file, ">", 'output.png';
     binmode $file;

=head3 Correspondence to libpng

This function corresponds to C<png_init_io>, with a Perl
file handle substituting for the C C<FILE *>.

=head2 read_from_scalar

     my $png = create_read_struct ();
     read_from_scalar ($png, $string);

This subroutine sets the image data of C<$png> to be the contents of a
Perl scalar variable C<$string>. The first argument, C<$png>, is a PNG structure created with 
L</create_read_struct>. It reads in all the
data from the structure on being called.

This is useful when image data is stored in a Perl scalar. For example

     use LWP::Simple;
     my $image_data = get 'http://www.example.com/example.png';
     # Now $image_data contains the PNG file
     my $png = create_read_struct ();
     read_from_scalar ($png, $image_data);
     # Now $png contains the PNG information from the image.

=head3 Correspondence to libpng

This uses C<png_set_read_fn> to set the reading function of C<$png> to
a routine which reads data from Perl scalars. It then uses
C<png_read_png> to read all the data.

The C function which does this is called C<perl_png_scalar_read>, 
L<in the file C<perl-libpng.c> in the top directory of the distribution|http://cpansearch.perl.org/src/BKB/Image-PNG-0.03/perl-libpng.c>.

See also L</Input/output manipulation functions>.

=head2 write_to_scalar

    my $image_data = write_to_scalar ($png);

This writes the PNG image data in C<$png> into a Perl scalar. So, for
example,

    my $img = write_to_scalar ($png);
    open my $output, ">:raw", "test-write-scalar.png";
    print $output $img;
    close $output;

creates a PNG file called C<test-write-scalar.png> from the PNG data
in C<$png>.

The first argument, C<$png>, is a writeable PNG structure created with 
L</create_write_struct>. The return value of the subroutine is the Perl scalar
containing the image data.

=head3 Correspondence to libpng

This subroutine doesn't correspond directly to anything in libpng. It
uses C<png_set_write_fn> to set the writing function of C<$png> to be
its own function, which writes data to the Perl scalar.

The C function which does this is called C<perl_png_scalar_write>, 
L<in the file C<perl-libpng.c> in the top directory of the distribution|http://cpansearch.perl.org/src/BKB/Image-PNG-0.03/perl-libpng.c>.

See also L</Input/output manipulation functions>.

=head2 read_png

     read_png ($png);

Read the entire PNG file. You can provide a second argument containing
transformations to apply to the image:

     use Image::PNG::Const qw/PNG_TRANSFORM_STRIP_ALPHA/;
     read_png ($png, PNG_TRANSFORM_STRIP_ALPHA);

In the absence of any third argument, the default value of
C<PNG_TRANSFORM_IDENTITY> is applied. The possible transformations
which can be applied are

=over

=item PNG_TRANSFORM_IDENTITY

No transformation

=item PNG_TRANSFORM_STRIP_16

Strip 16-bit samples to 8 bits

=item PNG_TRANSFORM_STRIP_ALPHA

Discard the alpha channel

=item PNG_TRANSFORM_PACKING

Expand 1, 2 and 4-bit samples to bytes

=item PNG_TRANSFORM_PACKSWAP

Change order of packed pixels to LSB first

=item PNG_TRANSFORM_EXPAND

Expand paletted images to RGB, grayscale to 8-bit images and tRNS chunks to alpha channels

=item PNG_TRANSFORM_INVERT_MONO

Invert monochrome images

=item PNG_TRANSFORM_SHIFT

Normalize pixels to the sBIT depth

=item PNG_TRANSFORM_BGR

Flip RGB to BGR, RGBA to BGRA

=item PNG_TRANSFORM_SWAP_ALPHA

Flip RGBA to ARGB or GA to AG

=item PNG_TRANSFORM_INVERT_ALPHA

Change alpha from opacity to transparency

=item PNG_TRANSFORM_SWAP_ENDIAN

Byte-swap 16-bit samples

=back

=head3 Correspondence to libpng

This function corresponds to C<png_read_png> with a default value for the third
argument. The fourth, unused, argument to C<png_read_png> does not
need to be supplied. See L<Unused arguments omitted>.

It does not take a second "info" argument. No info structure

=head2 write_png

    write_png ($png);

This writes the PNG to the file stream. Before using this, open a file
for writing and set it up with L</init_io>. For example,

    open my $output, ">:raw", 'out.png';
    init_io ($png, $output);
    write_png ($png);
    close $output;

There is an optional second argument consisting of transformations to
apply to the PNG image before writing it:

    use Image::PNG::Const qw/PNG_TRANSFORM_STRIP_ALPHA/;
    write_png ($png, PNG_TRANSFORM_STRIP_ALPHA);

The transformations which can be applied are as follows:


=over

=item PNG_TRANSFORM_IDENTITY

No transformation

=item PNG_TRANSFORM_STRIP_16

Strip 16-bit samples to 8 bits

=item PNG_TRANSFORM_STRIP_ALPHA

Discard the alpha channel

=item PNG_TRANSFORM_PACKING

Expand 1, 2 and 4-bit samples to bytes

=item PNG_TRANSFORM_PACKSWAP

Change order of packed pixels to LSB first

=item PNG_TRANSFORM_EXPAND

Expand paletted images to RGB, grayscale to 8-bit images and tRNS chunks to alpha channels

=item PNG_TRANSFORM_INVERT_MONO

Invert monochrome images

=item PNG_TRANSFORM_SHIFT

Normalize pixels to the sBIT depth

=item PNG_TRANSFORM_BGR

Flip RGB to BGR, RGBA to BGRA

=item PNG_TRANSFORM_SWAP_ALPHA

Flip RGBA to ARGB or GA to AG

=item PNG_TRANSFORM_INVERT_ALPHA

Change alpha from opacity to transparency

=item PNG_TRANSFORM_SWAP_ENDIAN

Byte-swap 16-bit samples

=back


(NOTE: this list might be wrong, it is just copied from the linux lib
pages & the linux lib pages have different transformations for the
read and write png functions.)

=head3 Correspondence to libpng

This function corresponds to C<png_write_png>.

=head1 The image header

See L<http://www.w3.org/TR/PNG/#11IHDR> for information on the PNG standards for
the image header.


=head2 sig_cmp

    if (sig_cmp ($should_be_png)) {
        print "Your data does not have a PNG signature.\n";
    }

This subroutine looks at C<$should_be_png> and checks whether its
first bytes correspond to a valid PNG signature. It returns a true
value if they do not. It can also take two further arguments
consisting of a byte offset and a number of bytes to check
respectively:

    sig_cmp ($should_be_png, 0, 8);

If these arguments are not supplied, the byte offset is assumed
to be zero, and the number of bytes to check is assumed to be eight.

=head3 Correspondence to libpng

This function corresponds to C<png_sig_cmp>, with default arguments of
0 and 8 if second and third arguments are not supplied.

=head2 get_valid

    my $valid = get_valid ($png);
    if ($valid->{oFFs}) {
        print "The PNG has valid screen offsets.\n";
    }

This function returns a hash with a key for each possible chunk which
may or may not be valid. The chunks which you can test for are

=over

=item gAMA

=item sBIT

=item cHRM

=item PLTE

=item tRNS

=item bKGD

=item hIST

=item pHYs

=item oFFs

=item tIME

=item pCAL

=item sRGB

=item iCCP

=item sPLT

=item sCAL

=item IDAT

=back

The first argument, C<$png>, is a PNG structure created with 
L</create_read_struct>.

=head3 Correspondence to libpng

This function corresponds to C<png_get_valid>, with the difference being that the
return value is a hash containing a key for each possible chunk.

=head2 get_IHDR

    my $IHDR = get_IHDR ($png);

Read the IHDR information from the PNG file. The return value is a
reference to a hash.

The hash reference contains the following fields:

=over


=item width

The width of the image in pixels.


=item height

The height of the image in pixels.


=item bit_depth

The bit depth of the image (the number of bits used for each colour in a pixel).
This can take the values 1, 2, 4, 8, 16.

=item color_type

The colour type.
This can take the values PNG_COLOR_TYPE_GRAY, PNG_COLOR_TYPE_GRAY_ALPHA, PNG_COLOR_TYPE_PALETTE, PNG_COLOR_TYPE_RGB, PNG_COLOR_TYPE_RGB_ALPHA.

=item interlace_method

The method of interlacing.
This can take the values PNG_INTERLACE_NONE, PNG_INTERLACE_ADAM7.




=back

So, for example, to get the width and height of an image,

    my $ihdr = get_IHDR ($png);
    printf "Your image is %d x %d\n", $ihdr->{width}, $ihdr->{height};

=head3 Correspondence to libpng

This function corresponds to C<png_get_IHDR>, with a single Perl hash reference
used instead of the several pointers to integers used in libpng.

=head2 set_IHDR

    my $ihdr = { width => 10, height => 10, bit_depth => 8,
                 color_type => PNG_COLOR_TYPE_RGB };
    set_IHDR ($png, $ihdr);

Set the IHDR chunk (the image header) of the PNG image. 

The first argument, C<$png>, is a writeable PNG structure created with 
L</create_write_struct>. The second argument is a hash with the following values:

=over


=item width

The width of the image in pixels.


=item height

The height of the image in pixels.


=item bit_depth

The bit depth of the image (the number of bits used for each colour in a pixel).
This can have the values 1, 2, 4, 8, 16.

=item color_type

The colour type.
This can have the values PNG_COLOR_TYPE_GRAY, PNG_COLOR_TYPE_GRAY_ALPHA, PNG_COLOR_TYPE_PALETTE, PNG_COLOR_TYPE_RGB, PNG_COLOR_TYPE_RGB_ALPHA.

=item interlace_method

The method of interlacing.
This can have the values PNG_INTERLACE_NONE, PNG_INTERLACE_ADAM7.




=back

Other fields in the hash are ignored.

=head3 Correspondence to libpng

This function corresponds to C<png_set_IHDR>, with a single Perl hash reference
used instead of the seven integers. The variables
C<compression_method>, C<filter_method>, 
in C<png_set_IHDR> can only take one possible value, so the routine
ignores them. See L<Unused arguments omitted>.

=head2 get_color_type

    my $color_type;
    Image::PNG::Libpng::get_color_type ($png, \$color_type);

This returns an integer value. If you want to get a name for the
colour type, use L</color_type_name>.

=head3 Correspondence to libpng

This function corresponds to C<png_get_color_type>.

=head1 PNG timestamps

See L<http://www.w3.org/TR/PNG/#11timestampinfo> for information on the PNG standards for
time stamp information.

=head2 get_tIME

    my $time = Image::PNG::Libpng::get_tIME ($png);
    if ($time && $time->{year} < 2005) {
        warn "Your PNG is now getting old. Don't forget to oil it to prevent rust.";
    }

This subroutine gets the modification time value of the PNG image and
puts it into fields labelled "year", "month", "day", "hour", "minute"
and "second" of the hash reference given as the third argument. If
there is no modification time it returns an undefined value.

=head3 Correspondence to libpng

This function corresponds to C<png_get_tIME>, with a Perl hash reference
substituted for the C struct C<png_timep> used in libpng.

=head2 set_tIME

    # Set the time to "now"
    set_tIME ($png);
    # Set the time
    set_tIME ($png, {year => 1999, month => 12});

Set the modification time of the PNG to the hash value given by the
second argument. If the second argument is omitted, the time is set to
the current time. If any of year, month, day, hour, minute or second
is omitted, these are set to zero.

=head3 Correspondence to libpng

This function corresponds to C<png_set_tIME>, with a Perl hash reference
substituted for the C struct C<png_timep> used in libpng.

=head1 Text chunks

See L<http://www.w3.org/TR/PNG/#11textinfo> for information on the PNG standards for
text information.

=head2 get_text

    my $text_chunks = Image::PNG::Libpng::get_text ($png);

This subroutine gets all the text chunks in the PNG image and returns
them as an array reference. Each element of the array represents one
text chunk. The element representing one chunk is a hash reference
with the text fields such as "key", "lang_key", "compression" taken
from the PNG's information.

The text data is uncompressed by libpng. If it is international text,
Image::PNG::Libpng automatically puts it into Perl's internal
Unicode encoding (UTF-8). 

Note that PNG international text is required to be in the UTF-8
encoding, and non-international text is required to contain whitespace
and printable ASCII characters only. See L</The PNG specification> for more on
the requirements of a PNG text section.

=head3 Correspondence to libpng

This function corresponds to C<png_get_text>, with a Perl array of hash
references substituted for the C array of structs used in libpng.

=head2 set_text

    set_text ($png, $text_chunks);

This sets the text chunks in an array reference C<$text_chunks>. . If you call it more than once, the chunks are appended
to the existing ones rather than replacing them.

    set_text ($png, [{compression => PNG_TEXT_COMPRESSION_NONE,
                      keyword => "Copyright",
                      text => "Copyright (C) 1997 The Dukes of Hazzard",
              }]);

=head3 Correspondence to libpng

This function corresponds to C<png_set_text>.

=head1 Private chunks

=head2 set_keep_unknown_chunks

    use Image::PNG::Const 'PNG_HANDLE_CHUNK_ALWAYS';
    set_keep_unknown_chunks ($png, PNG_HANDLE_CHUNK_ALWAYS);

Tell libpng not to discard unknown chunks when reading the file.

=head2 get_unknown_chunks

    my $private_chunks = get_unknown_chunks ($png);
    # Get some data from a private chunk
    my $chunk_three_data = $private_chunks->[3]->{data};
    # Get the size of the data
    print length $chunk_three_data;

This gets all of the private chunks from the image. You need to call
L</set_keep_unknown_chunks> with an appropriate value before reading
the file, otherwise libpng discards unknown chunks when reading the
file.

The return value is an array reference containing hash references. If
there are no private chunks, this returns an undefined value. There is
one element of the array for each chunk member.

Each member hash reference has the following keys:

=over

=item name

The name of the unknown chunk, in the PNG chunk format (four bytes).


=item location

The location of the unknown chunk.


=item data

The data of the unknown chunk


=back

The "size" field of the PNG structure is not stored, because the
"data" member of the hash contains information on its length.

=head3 Correspondence to libpng

This function corresponds to C<png_get_unknown_chunks>

=head2 set_unknown_chunks

    set_unknown_chunks ($png, $private_chunks);

=head3 Correspondence to libpng

This function corresponds to C<png_set_unknown_chunks>

=head1 Helper functions

These helper functions assist the programmer in the transition from
libpng, which uses C conventions such as upper case macros standing
for numerical constants and C structures, to Perl's string-based
conventions.

=head2 color_type_name

    my $name = Image::PNG::Libpng::color_type_name ($color_type);

Given a numerical colour type in C<$color_type>, return the equivalent
name. The name is in upper case, with words separated by underscores,
as in C<RGB_ALPHA>.

=head3 Correspondence to libpng

This function does not correspond to anything in libpng. The names of
the colour types are taken from those defined in the libpng header
file, C<png.h>.

=head2 text_compression_name

    my $name = Image::PNG::Libpng::text_compression_name ($text->{compression});

Given a numerical text compression type, return the equivalent
name. The name is in upper case. The possible return values are

=over

=item TEXT_NONE

=item TEXT_zTXt

=item ITXT_NONE

=item ITXT_zTXt

=item an empty string

if the compression method is unknown.

=back

For some reason the compression field is also used to store the
information about whether the text is "international text" in UTF-8 or
not.

=head3 Correspondence to libpng

This function does not correspond to anything in libpng. The names of
the text compression types are based on those in C<png.h>, but without
the word "COMPRESSION", so for example the libpng constant
C<PNG_ITXT_COMPRESSION_zTXt> corresponds to a return value of
C<ITXT_zTXt>.

=head1 Library version functions

=head2 get_libpng_ver

    my $libpng_version = Image::PNG::Libpng::get_libpng_ver ();

This function returns the version of the libpng library which the
module is using.

=head3 Correspondence to libpng

This function corresponds to C<png_get_libpng_ver>. However, it
doesn't require the C<png_structp> argument of the C function. See
L</About libpng>.

=head2 access_version_number

    my $libpng_version_number = Image::PNG::Libpng::access_version_number ();

This function returns the version of the libpng library which the
module is using as an integer number.

=head3 Correspondence to libpng

This function corresponds to C<png_access_version_number>.

=head1 Palettes

See L<http://www.w3.org/TR/PNG/#11PLTE> for information on the PNG standards for
the palette chunk.

=head2 get_PLTE

     my $colours = Image::PNG::Libpng::get_PLTE ($png);
     # Get the green value of the twentieth entry in the palette.
     my $green = $colours->[20]->{green};

This function gets the palette from the PNG. The return value is an
array reference containing the palette. This array contains hash
references with the values "green", "blue" and "red" for the colour of
each pixel in the palette. If the PNG has no palette, it returns an
undefined value.

A PNG image may or may not contain a palette. To check whether the
image contains a palette, use something of the following form:

     use Image::PNG::Const ':all';
     my $color_type = Image::PNG::Libpng::get_color_type ($png);
     if ($color_type == PNG_COLOR_TYPE_PALETTE) {
         # The PNG uses a palette.
     }

A PNG image may also contain a palette even when the "color_type" does
not indicate that. To check for that case, use L</get_valid>.

=head3 Correspondence to libpng

This function corresponds to C<png_get_PLTE>.

=head2 set_PLTE

    set_PLTE ($png, $palette);

Set the palette of C<$png>. The first argument, C<$png>, is a writeable PNG structure created with 
L</create_write_struct>. The second argument is an
array reference containing hash references. There is one hash
reference for each palette entry. The hash references contain three
fields, red, green, and blue, corresponding to the pixel value for
that palette entry. Other values in the hash references are
ignored. For example,

    set_PLTE ($png, [{red => 1, green => 99, blue => 0x10},
                     {red => 0xFF, green => 0xFF, blue => 0xFF}]);

creates a palette with two entries in C<$png>.

=head3 Correspondence to libpng

This function corresponds to C<png_set_PLTE>.

=head1 Image data

=head2 get_rows

    my $rows = Image::PNG::Libpng::get_rows ($png);
    my $pixel = substr ($rows->[10], 20, 1);

This returns the rows of the PNG image, after uncompressing and
unfiltering, as binary data. The return value, C<$rows> in the
example, is an array reference with a number of rows equal to the
height of the PNG image. Each row consists of the actual binary data,
which you will need to cut out using a routine like L<substr> or
L<unpack> to access pixel values. This binary data is likely to
contain bytes equal to zero.

You can get the number of bytes in each row using L</get_rowbytes>.

Each row is a Perl string. Perl terminates each row of data with an
extra zero byte at the end.

=head3 Correspondence to libpng

This function corresponds to C<png_get_rows>.

=head2 set_rows

     set_rows ($png, \@rows);

Set the rows of data to be written in to the PNG to C<@rows>. C<@rows>
needs to contain at least the same number of rows of data as the
height of the PNG image, and the length of each entry needs to be at
least the width of the entry times the number of bytes required for
each pixel.

Please also note that this is a bit unreliable. 
See L</set_rows is unreliable>.
I recommend that you only use this immediately before calling L</write_png> 
in order to prevent problems occuring.

=head3 Correspondence to libpng

This function corresponds to C<png_set_rows>.

=head2 get_rowbytes

    my $bytes_in_a_row = get_rowbytes ($png);

=head3 Correspondence to libpng

This function corresponds to C<png_get_rowbytes>.

=head1 Compression and filtering

=head2 set_filter

    use Image::PNG::Const 'PNG_FILTER_NONE';
    set_filter ($png, PNG_FILTER_NONE);

This sets the filters which are allowed to be used for writing a PNG
image. The possible values are

=over

=item PNG_NO_FILTERS

=item PNG_FILTER_NONE

=item PNG_FILTER_SUB

=item PNG_FILTER_UP

=item PNG_FILTER_AVG

=item PNG_FILTER_PAETH

=item PNG_ALL_FILTERS

=back

These can be combined using C<|> (logical or):

    use Image::PNG::Const ':all';
    set_filter ($png, PNG_FILTER_UP | PNG_FILTER_AVG);

Please see L<http://www.w3.org/TR/PNG/#9Filter-types> for the meanings of these
filter types.

=head3 Correspondence to libpng

This function corresponds to C<png_set_filter> with the second (unused)
argument omitted. See L<Unused arguments omitted>.

=head1 EXPORTS

Nothing is exported by default, but all the functions in this module
can be exported on request. The export tag 'all' exports everything in
the module:

    use Image::PNG::Libpng ':all';
    # Now everything in the module has been imported

=head1 Differences from libpng

The procedures in Image::PNG::Libpng are closely based on
those of libpng, with the following differences.

=head2 No info structure

This module, C<Image::PNG::Libpng> does not use the "info"
structure of libpng. Almost all libpng functions require two initial
arguments, a C<png_structp> and a C<png_infop>. However, in 
Image::PNG::Libpng, both the "png" and the "info" are contained in
the first argument to each function.

=head2 Unused arguments omitted

This module eliminates all the unevaluated arguments of libpng. For
example, libpng requires the user to pass a pointer to a C<png_struct>
before calling the library to ask for its version number (see
L</get_libpng_ver>), but the library ignores the this structure
anyway, so this module does not duplicate this. There are many similar
instances of unevaluated arguments, which have all been eliminated
from this module.

If you are interested in exactly which libpng arguments are omitted,
you can find each instance L<in the file C<perl-libpng.c> in the top directory of the distribution|http://cpansearch.perl.org/src/BKB/Image-PNG-0.03/perl-libpng.c> in the macro
C<UNUSED_ZERO_ARG>.

=head2 Function return values are used to return values

In libpng, some functions return results using references, and some
return results using the function's return value. For example
C<png_get_rows> (see L</get_rows>) uses the return value of the
function to return an array of pointers, but C<png_get_PLTE> (see
L</get_PLTE>) uses a pointer reference to return an array of pointers,
and the return value to indicate errors. 

Image::PNG::Libpng uses only the return value. Errors and
non-existence are indicated by a return value of the undefined
value. You can also choose to raise errors or print errors using the
L</raise_error> and L</print_error> options.

In libpng, some functions use the return value to indicate errors, and
some of the functions don't indicate errors but fail silently. Some of
the functions which use the return value to indicate an error use a
non-zero value to indicate an error, and some of them use a zero value
to indicate an error.

=head2 Other unimplemented parts of libpng

=head3 Memory management functions

This module does not offer an interface to C<png_malloc> and C<png_free>.

=head3 Error handling functions

This module does not offer an interface to C<png_error> and
C<png_get_error_ptr>. It redirects the error and warning handlers to
Perl's error stream.

=head3 Input/output manipulation functions

This module does not offer a direct interface to C<png_set_write_fn>
and C<png_set_read_fn>. However, it is possible to use their
functionality to access Perl data via L</read_from_scalar> and
L</write_to_scalar>.

=head3 Partial read/write functions

This module does not yet offer an interface to the partial read and
write functions of libpng. The reason is because I don't know enough
about Perl's internal structures to be able to create a memory-safe
interface to these functions. The partial read/write functions would
rely on preserving pointers to data structures within the Perl
program's data area between calls. So this module doesn't deal with
png_write_chunk, png_write_end, png_write_info, png_write_row, or
png_write_rows.


=head1 BUGS

This section documents some known deficiencies in the module.

=head2 set_rows is unreliable

The method L</set_rows> doesn't actually copy or write any
information. All it does is set a pointer to the pointers to the rows
in the PNG data structure. The actual data is only written when you
ask to write it. So if you "set_rows" to some data, then delete or
change that data before asking to write the png with L</write_png>,
you will get a memory error.

=head2 Conditional compilation

It is possible to compile a version of the libpng library without
support for, for example, text chunks by undefining a macro
(C<PNG_TEXT_SUPPORTED>). However, this module ignores your libpng
compilation choices, so it won't compile if you have such a libpng.

I don't know whether many people in practice actually have such a
libpng without text support or the other optional facilities, but if
you encounter problems using this Perl module because of your
conditionally-compiled libpng, then please let me know and I'll
consider adding that facility to the module.

=head1 SEE ALSO

=head2 The PNG specification

L<The PNG specification|http://www.w3.org/TR/PNG/> (link to W3
consortium) explains the details of the PNG format.


=head2 The libpng documentation

=head3 "Official" documentation

The starting point is the plain text libpng manual at
L<http://libpng.org/pub/png/libpng-manual.txt> and the manual page
libpng.3, which you can read using "man 3 libpng".

Be warned that the documentation which comes with libpng is rather
sketchy. See L</Differences from libpng>. It doesn't contain full
specifications (prototypes, return values) for all of the functions in
the library. If you are considering programming in C using libpng, you
will definitely also need to look at the header file "png.h".  In some
cases you will also need to look at the source code of the library.

=head3 Unofficial documentation

There is a collection of function definitions under the title
"Interface Definitions for libpng12" at
L<http://refspecs.freestandards.org/LSB_3.1.1/LSB-Desktop-generic/LSB-Desktop-generic/libpng12man.html>
as part of the "Linux Standard Base Desktop Specification". These
contain extensive information on the prototypes and return values for
the libpng routines, something which is often only available elsewhere
by actually looking at the libpng source code. These pages are usually
the first hits on search engines if you search for a function name in
libpng.

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

If you want to alter this module, please note very carefully that the
distributed files are not actually the source code of the module. If
you wish to obtain the source code of Image::PNG, please access
http://www.lemoda.net/projects/image-png/repo/ using the "git" source control system.

The original files of this distribution make very heavy use of the
L<Template> Perl module in order to cut down the amount of repetitive
stuff which needs to be put into various source and documentation
files. If you plan to alter the C file, you also need a program called
"cfunctions" which you can download from sourceforge.



=cut

# Local Variables:
# mode: perl
# End:



# Local Variables:
# mode: perl
# End:
