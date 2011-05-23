# This is a wrapper for the png structure to hide some of the details
# of the Libpng interface from the PNG.pm module. An end user should
# never use this, only Image::PNG or Image::PNG::Libpng.

package Image::PNG::Container;
use warnings;
use strict;
use Carp;
use Image::PNG::Const ':all';
use Image::PNG::Libpng ':all';

our $VERSION = 0.04;


sub new
{
    my ($package, $options) = @_;
    my $object = $options;
    if ($object->{read_only}) {
        $object->{png} = create_read_struct ();
    } else {
        $object->{png} = create_write_struct ();
    }
    bless $object;
    return $object;
}

sub has
{
    my ($object, $what);
    return defined $object->{$what};
}

sub get_set
{
    my ($object, $what, $input) = @_;
    if ($object->{read_only}) {
        if ($input) {
            croak "Attempt to set a parameter on a read-only container";
        } else {
            return $object->{$what};
        }
    } else {
        $object->{$what} = $input;
    }
}

sub set_file_name
{
    my ($object, $file_name) = @_;
    if ($object->{file_name}) {
        croak "Attempt to alter container file name";
    }
    $object->{file_name} = $file_name;
}

sub Image::PNG::Container::open
{
    my ($object) = @_;
    if (! $object->{file_name}) {
        croak "File name not set";
    }
    my $file;
    if ($object->{read_only}) {
        open $file, "<:raw", $object->{file_name};
    }
    else {
        open $file, ">:raw", $object->{file_name};
    }
    init_io ($object->{png}, $file);
    $object->{file} = $file;
}

sub read
{
    my ($object) = @_;
    if (! $object->{read_only}) {
        croak "Read on a write file";
    }
    Image::PNG::Libpng::read_png ($object->{png});
    $object->{read_ok} = 1;
    if ($object->{file}) {
        close ($object->{file})
            or die "Can't close '$object->{file_name}': $!";
    }
}

sub png
{
    my ($object) = @_;
    return $object->{png};
}

# Free the memory associated with the object which this contains.

sub DESTROY
{
    my ($object) = @_;
    if ($object->{read_only}) {
        Image::PNG::Libpng::destroy_read_struct ($object->{png});
    }
    else {
        Image::PNG::Libpng::destroy_write_struct ($object->{png});
    }
}

1;

# Local Variables:
# mode: perl
# End:
