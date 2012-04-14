/* This is a Cfunctions (version 0.28) generated header file.
   Cfunctions is a free program for extracting headers from C files.
   Get Cfunctions from 'http://www.lemoda.net/cfunctions/'. */

/* This file was generated with:
'cfunctions -i -n -c perl-libpng.c' */
#ifndef CFH_PERL_LIBPNG_H
#define CFH_PERL_LIBPNG_H

/* From 'perl-libpng.c': */

#line 13 "tmpl/perl-libpng.c.tmpl"
typedef struct perl_libpng {
    png_structp png;
    png_infop info;
    png_infop end_info;
    enum {perl_png_unknown_obj, perl_png_read_obj, perl_png_write_obj} type;
    /* Allocated memory which holds the rows. */
    png_bytepp  row_pointers;
    /* Allocated memory which holds the image data. */
    png_bytep image_data;
    /* Number of times we have called calloc. */
    int memory_gets;

    /* Jive for reading from a scalar */

    /* Points to the raw data from a Perl scalar. */
    void * scalar_data;
    /* Contains what Perl says the length of the data in "image_data"
       is. */
    unsigned int data_length;
    /* How much of the data in "image_data" we have read. */
    int read_position;


    /* If the following variable is set to a true value, the module
       prints messages about what it is doing. */
    int verbosity : 1;
    /* If the following variable is set to a true value, the module
       raises an error (die) if there is an error other than something
       being undefined. */
    int raise_errors : 1;
    /* Print error messages. */
    int print_errors : 1;
    /* Raise an error (die) if something is undefined. */
    int raise_undefined : 1;
    /* Print a message on STDERR if something is undefined. */
    int print_undefined : 1;
}
perl_libpng_t;
typedef perl_libpng_t Image__PNG__Libpng__t;
typedef perl_libpng_t * Image__PNG__Libpng;

#line 220 "tmpl/perl-libpng.c.tmpl"
#line 1 "/home/ben/software/install/share/cfunctions/c-extensions.h"
/* Macro definitions for C extensions for Cfunctions. */

/* 
   Copyright (C) 1998 Ben K. Bullock.

   This header file is free software; Ben K. Bullock gives unlimited
   permission to copy, modify and distribute it. 

   This header file is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/


#ifndef C_EXTENSIONS_H
#define C_EXTENSIONS_H

/* Only modern GNU C's have `__attribute__'.  The keyword `inline'
   seems to have been around since the beginning, but it does not work
   with the `-ansi' option, which defines `__STRICT_ANSI__'.  I expect
   that `__attribute__' does not work with `-ansi' either.  Anyway
   both of these failure cases are being lumped together here for the
   sake of brevity. */

#if defined (__GNUC__) && ( __GNUC__ >= 2 ) && ( __GNUC_MINOR__ > 4 ) && \
   ! defined (__STRICT_ANSI__)

/* Macro definitions for Gnu C extensions to C. */

#define X_NO_RETURN __attribute__((noreturn))
#define X_PRINT_FORMAT(a,b) __attribute__((format(printf,a,b)))
#define X_CONST __attribute__((const))
#define X_INLINE

#else /* Not a modern GNU C */

#define X_NO_RETURN 
#define X_PRINT_FORMAT(a,b) 
#define X_CONST

#endif /* GNU C */

/* The following `#define' is not a mistake.  INLINE is defined to
   nothing for both GNU and non-GNU compilers.  When Cfunctions sees
   `INLINE' it copies the whole of the function into the header file,
   prefixed with `extern inline' and surrounded by an `#ifdef
   X_INLINE' wrapper.  In order to inline the function in GNU C, only
   `X_INLINE' needs to be defined. There is also a normal prototype
   for the case that X_INLINE is not defined.  The reason for copying
   the function with a prefix `extern inline' into the header file is
   explained in the GNU C manual and the Cfunctions manual. */

#define INLINE
#define NO_RETURN void
#define NO_SIDE_FX
#define PRINT_FORMAT(a,b)
#define LOCAL

/* Prototype macro for `traditional C' output. */

#ifndef PROTO
#if defined(__STDC__) && __STDC__ == 1
#define PROTO(a) a
#else
#define PROTO(a) ()
#endif /* __STDC__ */
#endif /* PROTO */

#endif /* ndef C_EXTENSIONS_H */
perl_libpng_t * perl_png_create_write_struct PROTO ((void));

#line 232 "tmpl/perl-libpng.c.tmpl"
perl_libpng_t * perl_png_create_read_struct PROTO ((void));

#line 266 "tmpl/perl-libpng.c.tmpl"
void perl_png_destroy_write_struct (perl_libpng_t * png );

#line 273 "tmpl/perl-libpng.c.tmpl"
void perl_png_destroy_read_struct (perl_libpng_t * png );

#line 280 "tmpl/perl-libpng.c.tmpl"
void perl_png_destroy (perl_libpng_t * png );

#line 460 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_text (perl_libpng_t * png );

#line 599 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_text (perl_libpng_t * png , AV * text_chunks );

#line 678 "tmpl/perl-libpng.c.tmpl"
void perl_png_timep_to_hash (const png_timep mod_time , HV * time_hash );

#line 700 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_tIME (perl_libpng_t * png );

#line 719 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_tIME (perl_libpng_t * png , SV * input_time );

#line 764 "tmpl/perl-libpng.c.tmpl"
int perl_png_sig_cmp (SV * png_header , int start , int num_to_check );

#line 838 "tmpl/perl-libpng.c.tmpl"
void perl_png_scalar_as_input (perl_libpng_t * png , SV * image_data , int transforms );

#line 861 "tmpl/perl-libpng.c.tmpl"
void perl_png_read_from_scalar (perl_libpng_t * png , SV * image_data , int transforms );

#line 885 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_write_to_scalar (perl_libpng_t * png , int transforms );

#line 902 "tmpl/perl-libpng.c.tmpl"
void perl_png_write_png (perl_libpng_t * png , int transforms );

#line 917 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_IHDR (perl_libpng_t * png );

#line 953 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_IHDR (perl_libpng_t * png , HV * IHDR );

#line 1005 "tmpl/perl-libpng.c.tmpl"
const char * perl_png_color_type_name (int color_type );

#line 1029 "tmpl/perl-libpng.c.tmpl"
const char * perl_png_text_compression_name (int text_compression );

#line 1057 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_PLTE (perl_libpng_t * png );

#line 1089 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_PLTE (perl_libpng_t * png , AV * perl_colors );

#line 1130 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_PLTE_pointer (perl_libpng_t * png , png_colorp colors , int n_colors );

#line 1178 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_bKGD (perl_libpng_t * png );

#line 1192 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_bKGD (perl_libpng_t * png , HV * bKGD );

#line 1200 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_pCAL (perl_libpng_t * png );

#line 1210 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_pCAL (perl_libpng_t * png , HV * pCAL );

#line 1214 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_sPLT (perl_libpng_t * png );

#line 1224 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_sPLT (perl_libpng_t * png , HV * sPLT );

#line 1228 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_gAMA (perl_libpng_t * png );

#line 1240 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_gAMA (perl_libpng_t * png , double gamma );

#line 1245 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_iCCP (perl_libpng_t * png );

#line 1255 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_iCCP (perl_libpng_t * png , HV * iCCP );

#line 1259 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_tRNS (perl_libpng_t * png );

#line 1269 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_tRNS (perl_libpng_t * png , HV * tRNS );

#line 1273 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_tRNS_pointer (perl_libpng_t * png , png_bytep trans , int num_trans );

#line 1278 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_sCAL (perl_libpng_t * png );

#line 1288 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_sCAL (perl_libpng_t * png , HV * sCAL );

#line 1296 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_sBIT (perl_libpng_t * png );

#line 1308 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_sBIT (perl_libpng_t * png , HV * sBIT );

#line 1315 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_oFFs (perl_libpng_t * png );

#line 1333 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_oFFs (perl_libpng_t * png , HV * oFFs );

#line 1344 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_pHYs (perl_libpng_t * png );

#line 1361 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_pHYs (perl_libpng_t * png , HV * pHYs );

#line 1374 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_tRNS_palette (perl_libpng_t * png );

#line 1403 "tmpl/perl-libpng.c.tmpl"
int perl_png_get_sRGB (perl_libpng_t * png );

#line 1415 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_sRGB (perl_libpng_t * png , int sRGB );

#line 1419 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_valid (perl_libpng_t * png );

#line 1445 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_rows (perl_libpng_t * png );

#line 1497 "tmpl/perl-libpng.c.tmpl"
void perl_png_read_image (perl_libpng_t * png );

#line 1528 "tmpl/perl-libpng.c.tmpl"
void * perl_png_get_row_pointers (perl_libpng_t * png );

#line 1543 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_row_pointers (perl_libpng_t * png , void * row_pointers );

#line 1551 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_rows (perl_libpng_t * png , AV * rows );

#line 1593 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_verbosity (perl_libpng_t * png , int verbosity );

#line 1602 "tmpl/perl-libpng.c.tmpl"
void perl_png_handle_undefined (perl_libpng_t * png , int die , int raise );

#line 1611 "tmpl/perl-libpng.c.tmpl"
void perl_png_handle_error (perl_libpng_t * png , int die , int raise );

#line 1637 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_unknown_chunks (perl_libpng_t * png );

#line 1690 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_unknown_chunks (perl_libpng_t * png , AV * chunk_list );

#line 1760 "tmpl/perl-libpng.c.tmpl"
int perl_png_supports (const char * what );

#line 1777 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_keep_unknown_chunks (perl_libpng_t * png , int keep , SV * chunk_list );

#line 1846 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_expand (perl_libpng_t * png );

#line 1852 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_gray_to_rgb (perl_libpng_t * png );

#line 1858 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_filler (perl_libpng_t * png , int filler , int flags );

#line 1864 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_strip_16 (perl_libpng_t * png );

#line 1869 "tmpl/perl-libpng.c.tmpl"
SV * perl_png_get_cHRM (perl_libpng_t * png );

#line 1904 "tmpl/perl-libpng.c.tmpl"
void perl_png_set_cHRM (perl_libpng_t * png , HV * cHRM );

#endif /* CFH_PERL_LIBPNG_H */
