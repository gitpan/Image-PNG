#line 2 "tmpl/Libpng.xs.tmpl"
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

/* There is some kind of collision between a file included by "perl.h"
   and "png.h" for very old versions of libpng, like the one used on
   Ubuntu Linux. */

#define PNG_SKIP_SETJMP_CHECK
#include <png.h>
#include "perl-libpng.h"
#include "const-c.inc"

MODULE = Image::PNG PACKAGE = Image::PNG::Libpng PREFIX = perl_png_

PROTOTYPES: ENABLE

INCLUDE: const-xs.inc

Image::PNG::Libpng::t * perl_png_create_read_struct ()
        CODE:
        RETVAL = perl_png_create_read_struct ();
        OUTPUT:
        RETVAL

Image::PNG::Libpng::t * perl_png_create_write_struct ()
        CODE:
        RETVAL = perl_png_create_write_struct ();
        OUTPUT:
        RETVAL

void perl_png_destroy_read_struct (Png)
        Image::PNG::Libpng::t *  Png
        CODE:
        perl_png_destroy_read_struct (Png);
        OUTPUT:

void perl_png_destroy_write_struct (Png)
        Image::PNG::Libpng::t *  Png
        CODE:
        perl_png_destroy_write_struct (Png);
        OUTPUT:

void perl_png_write_png (Png, transforms = PNG_TRANSFORM_IDENTITY)
        Image::PNG::Libpng::t *  Png
        int transforms
        CODE:
        perl_png_write_png (Png, transforms);
        OUTPUT:

void perl_png_init_io (Png, fp)
        Image::PNG::Libpng::t *  Png
        FILE * fp
        CODE:
        png_init_io (Png->png, fp);
        OUTPUT:

void perl_png_read_info (Png)
        Image::PNG::Libpng::t *  Png
        CODE:
        png_read_info (Png->png, Png->info);
        OUTPUT:

void perl_png_read_png (Png, transforms = PNG_TRANSFORM_IDENTITY)
        Image::PNG::Libpng::t *  Png
        int transforms
        CODE:
        png_read_png (Png->png, Png->info, transforms, 0);
        OUTPUT:

SV * perl_png_get_IHDR (Png)
        Image::PNG::Libpng::t *  Png
        CODE:
        RETVAL = perl_png_get_IHDR (Png);
        OUTPUT:
        RETVAL

SV * perl_png_get_tIME (Png)
        Image::PNG::Libpng::t *  Png
        CODE:
        RETVAL = perl_png_get_time (Png);
        OUTPUT:
        RETVAL

void perl_png_set_tIME (Png, time = &PL_sv_undef)
        Image::PNG::Libpng::t *  Png
        SV * time
        CODE:
        perl_png_set_time (Png, time);
        OUTPUT:

SV * perl_png_get_text (Png)
        Image::PNG::Libpng::t *  Png
        CODE:
        RETVAL = perl_png_get_text (Png);
        OUTPUT:
        RETVAL

void perl_png_set_text (Png, text)
        Image::PNG::Libpng::t *  Png
        AV * text
        CODE:
        perl_png_set_text (Png, text);
        OUTPUT:

int perl_png_sig_cmp (sig, start = 0, num_to_check = 8)
        SV * sig
        int start
        int num_to_check
        CODE:
        RETVAL = perl_png_sig_cmp (sig, start, num_to_check);
        OUTPUT:
        RETVAL

void perl_png_read_from_scalar (Png, scalar, transforms = 0)
        Image::PNG::Libpng::t * Png
        SV * scalar
        int transforms
        CODE:
        perl_png_read_from_scalar (Png, scalar, transforms);
        OUTPUT:

const char * perl_png_color_type_name (color_type)
        int color_type
        CODE:
        RETVAL = perl_png_color_type_name (color_type);
        OUTPUT:
        RETVAL

const char * perl_png_text_compression_name (text_compression)
        int text_compression
        CODE:
        RETVAL = perl_png_text_compression_name (text_compression);
        OUTPUT:
        RETVAL

const char * perl_png_get_libpng_ver ()
        CODE:
        RETVAL = png_get_libpng_ver (0);
        OUTPUT:
        RETVAL

int perl_png_access_version_number ()
        CODE:
        RETVAL = png_access_version_number ();
        OUTPUT:
        RETVAL

SV * perl_png_get_rows (Png)
        Image::PNG::Libpng::t *  Png
        CODE:
        RETVAL = perl_png_get_rows (Png);
        OUTPUT:
        RETVAL

int perl_png_get_rowbytes (Png)
        Image::PNG::Libpng::t *  Png
        CODE:
        RETVAL = png_get_rowbytes (Png->png, Png->info);
        OUTPUT:
        RETVAL

SV * perl_png_get_PLTE (Png)
        Image::PNG::Libpng::t *  Png
        CODE:
        RETVAL = perl_png_get_PLTE (Png);
        OUTPUT:
        RETVAL

void perl_png_set_PLTE (Png, colors)
        Image::PNG::Libpng::t *  Png
        AV * colors
        CODE:
        perl_png_set_PLTE (Png, colors);

SV * perl_png_get_bKGD (Png)
        Image::PNG::Libpng::t *  Png
        CODE:
        RETVAL = perl_png_get_bKGD (Png);
        OUTPUT:
        RETVAL

SV * perl_png_get_cHRM (Png)
        Image::PNG::Libpng::t *  Png
        CODE:
        RETVAL = perl_png_get_cHRM (Png);
        OUTPUT:
        RETVAL

int perl_png_get_channels (Png)
        Image::PNG::Libpng::t * Png
        CODE:
        RETVAL = png_get_channels (Png->png, Png->info);
        OUTPUT:
        RETVAL


SV * perl_png_get_sBIT (Png, sig_bit)
        Image::PNG::Libpng::t * Png
        CODE:
        RETVAL = perl_png_get_sBIT (Png);
        OUTPUT:
        RETVAL


SV * perl_png_get_oFFs (Png)
        Image::PNG::Libpng::t * Png
        CODE:
        RETVAL = perl_png_get_oFFs (Png);
        OUTPUT:
        RETVAL


SV * perl_png_get_pHYs (Png)
        Image::PNG::Libpng::t * Png
        CODE:
        RETVAL = perl_png_get_pHYs (Png);
        OUTPUT:
        RETVAL


int perl_png_get_sRGB (Png)
        Image::PNG::Libpng::t * Png
        CODE:
        RETVAL = perl_png_get_sRGB (Png);
        OUTPUT:
        RETVAL


SV * perl_png_get_valid (Png)
        Image::PNG::Libpng::t * Png
        CODE:
        RETVAL = perl_png_get_valid (Png);
        OUTPUT:
        RETVAL

void perl_png_set_rows (Png, rows)
        Image::PNG::Libpng::t * Png
        AV * rows
        CODE:
        perl_png_set_rows (Png, rows);
        OUTPUT:

void perl_png_set_IHDR (Png, IHDR)
        Image::PNG::Libpng::t * Png
        HV * IHDR
        CODE:
        perl_png_set_IHDR (Png, IHDR);
        OUTPUT:
        
SV * perl_png_write_to_scalar (Png, transforms = 0)
        Image::PNG::Libpng::t * Png
        int transforms;
        CODE:
        RETVAL = perl_png_write_to_scalar (Png, transforms);
        OUTPUT:
        RETVAL

void perl_png_set_filter (Png, filters)
        Image::PNG::Libpng::t * Png
        int filters;
        CODE:
        png_set_filter (Png->png, 0, filters);
        OUTPUT:

void perl_png_set_verbosity (Png, verbosity = 0)
        Image::PNG::Libpng::t * Png
        int verbosity; 
        CODE:
        perl_png_set_verbosity (Png, verbosity);
        OUTPUT:
        
void perl_png_set_unknown_chunks (Png, unknown_chunks)
        Image::PNG::Libpng::t * Png
        AV * unknown_chunks
        CODE:
        perl_png_set_unknown_chunks (Png, unknown_chunks);
        OUTPUT:

SV * perl_png_get_unknown_chunks (Png)
        Image::PNG::Libpng::t * Png
        CODE:
        RETVAL = perl_png_get_unknown_chunks (Png);
        OUTPUT:
        RETVAL

int perl_png_supports (what)
        const char * what
        CODE:
        RETVAL = perl_png_supports (what);
        OUTPUT:
        RETVAL

void perl_png_set_keep_unknown_chunks (Png, keep, chunk_list = 0)
        Image::PNG::Libpng::t * Png
        int keep
        SV * chunk_list
        CODE:
        perl_png_set_keep_unknown_chunks (Png, keep, chunk_list);
        OUTPUT:
