#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use lib 'blib/lib';
use lib 'blib/arch';
use Image::PNG::Libpng 'supports';
print supports ('iTXt');
print "\n";
