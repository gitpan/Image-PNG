#line 2 "tmpl/perl-libpng.c.tmpl"
#include <stdarg.h>
#include <png.h>
#include <time.h>

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "perl-libpng.h"
#include "my-xs.h"

#ifdef HEADER

/* Common structure for carrying around all our baggage. */

typedef struct perl_libpng {
    png_structp png;
    png_infop info;
    png_infop end_info;
    enum {perl_png_unknown_obj, perl_png_read_obj, perl_png_write_obj} type;
    /* Number of rows. */
    void * row_pointers;
    /* Number of times we have called calloc. */
    int memory_gets;
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

#endif

/* Convenient macro for libpng function arguments. */

#define pngi png->png, png->info

/* The following macro is used to indicate to programmers reading this
   which arguments are "useless" (ignored) arguments from libpng which
   are always set to zero. It is not used for arguments which are set
   to zero for some other reason than because they are useless
   (e.g. flush functions which are set to zero because we don't need
   them). */

#define UNUSED_ZERO_ARG 0

/* Return an undefined value. */

#define UNDEF {                                 \
        if (png->raise_undefined) {             \
        }                                       \
        return &PL_sv_undef;                    \
    }
/* Send a message. */

#if 1
#define MESSAGE(x...) {                                 \
        if (png->verbosity) {                           \
            printf ("%s:%d: ", __FILE__, __LINE__);     \
            printf (x);                                 \
        }                                               \
    }
#else
#define MESSAGE(x...)
#endif

/*  _____                         
   | ____|_ __ _ __ ___  _ __ ___ 
   |  _| | '__| '__/ _ \| '__/ __|
   | |___| |  | | | (_) | |  \__ \
   |_____|_|  |_|  \___/|_|  |___/ */
                               


/* Print a warning message. */

static void perl_png_warn (perl_libpng_t * png, const char * format, ...)
{
    va_list ap;
    va_start (ap, format);
    /* Undocumented Perl function "vwarn" */
    vwarn (format, & ap);
    va_end (ap);
}

/* Print a warning message. */

static void perl_png_error (perl_libpng_t * png, const char * format, ...)
{
    va_list ap;
    va_start (ap, format);
    /* Undocumented Perl function "vcroak" */
    vcroak (format, & ap);
    va_end (ap);
}

/*  _ _ _                                                  
   | (_) |__  _ __  _ __   __ _    ___ _ __ _ __ ___  _ __ 
   | | | '_ \| '_ \| '_ \ / _` |  / _ \ '__| '__/ _ \| '__|
   | | | |_) | |_) | | | | (_| | |  __/ |  | | | (_) | |   
   |_|_|_.__/| .__/|_| |_|\__, |  \___|_|  |_|  \___/|_|   
             |_|          |___/                            
    _                     _ _               
   | |__   __ _ _ __   __| | | ___ _ __ ___ 
   | '_ \ / _` | '_ \ / _` | |/ _ \ '__/ __|
   | | | | (_| | | | | (_| | |  __/ |  \__ \
   |_| |_|\__,_|_| |_|\__,_|_|\___|_|  |___/ */
                                         

/* The following things are used to handle errors from libpng. See the
   create_read_struct and create_write_struct calls below. */


/* Error handler for libpng. */

static void
perl_png_error_fn (png_structp png_ptr, png_const_charp error_msg)
{
    perl_libpng_t * png = png_get_error_ptr (png_ptr);
    perl_png_error (png, "libpng error: %s\n", error_msg);
}

/* Warning handler for libpng. */

static void
perl_png_warning_fn (png_structp png_ptr, png_const_charp warning_msg)
{
    perl_libpng_t * png = png_get_error_ptr (png_ptr);
    perl_png_warn (png, "libpng warning: %s\n", warning_msg);
}


/*   ____      _      ___      __               
    / ___| ___| |_   ( _ )    / _|_ __ ___  ___ 
   | |  _ / _ \ __|  / _ \/\ | |_| '__/ _ \/ _ \
   | |_| |  __/ |_  | (_>  < |  _| | |  __/  __/
    \____|\___|\__|  \___/\/ |_| |_|  \___|\___|
                                                
        _                   _                       
    ___| |_ _ __ _   _  ___| |_ _   _ _ __ ___  ___ 
   / __| __| '__| | | |/ __| __| | | | '__/ _ \/ __|
   \__ \ |_| |  | |_| | (__| |_| |_| | | |  __/\__ \
   |___/\__|_|   \__,_|\___|\__|\__,_|_|  \___||___/ */
                                                 


/* Get memory using the following in order to keep count of the number
   of objects in use at the end of execution, to ensure that there are
   no memory leaks. All allocation is done via "calloc" rather than
   "malloc". */

#define GET_MEMORY(thing, number) {                                     \
        thing = calloc (number, sizeof (*thing));                       \
        if (! thing) {                                                  \
            perl_png_error (png, "%s:%d: Call to calloc for "           \
                            "%d '%s' failed: out of memory",            \
                            __FILE__, __LINE__, number, #thing);        \
        }                                                               \
        png->memory_gets++;                                             \
    }

/* Free memory using the following in order to keep count of the
   number of objects still in use. */

#define PERL_PNG_FREE(thing) {                  \
        png->memory_gets--;                     \
        free (thing);                           \
    }

static perl_libpng_t *
perl_png_allocate ()
{
    perl_libpng_t * png;
    GET_MEMORY (png, 1);
    return png;
}

# define CREATE_ARGS                                            \
    PNG_LIBPNG_VER_STRING,                                      \
    png,                                                        \
    perl_png_error_fn,                                          \
    perl_png_warning_fn

perl_libpng_t *
perl_png_create_write_struct ()
{
    perl_libpng_t * png = perl_png_allocate ();
    png->png = png_create_write_struct (CREATE_ARGS);
    png->info = png_create_info_struct (png->png);
    png->end_info = 0;
    png->row_pointers = 0;
    png->type = perl_png_write_obj;
    return png;
}

perl_libpng_t *
perl_png_create_read_struct ()
{
    perl_libpng_t * png = perl_png_allocate ();
    png->png = png_create_read_struct (CREATE_ARGS);
    png->info = png_create_info_struct (png->png);
    png->row_pointers = 0;
    png->type = perl_png_read_obj;
    return png;
}

#undef CREATE_ARGS

/* Free the structure and do a simple memory leak check. */

static void free_png (perl_libpng_t * png)
{
    MESSAGE ("Freeing PNG memory.\n");
    if (png->memory_gets != 1) {
        perl_png_warn (png, "Memory leak detected: there are %d "
                       "allocated pieces of memory which have not "
                       "been freed.\n", png->memory_gets - 1);
    }
    free (png);
}

void
perl_png_destroy_write_struct (perl_libpng_t * png)
{
    png_destroy_write_struct (& png->png, & png->info);
    if (png->row_pointers) {
        PERL_PNG_FREE (png->row_pointers);
    }
    free_png (png);
}

void
perl_png_destroy_read_struct (perl_libpng_t * png)
{
    png_destroy_read_struct (& png->png, & png->info, & png->end_info);
    free_png (png);
}

void
perl_png_destroy (perl_libpng_t * png)
{
    //    printf ("Destroying png %p\n", png);
    if (! png) {
        //        printf ("Destroy called with a null pointer.\n");
        return;
    }
    //#    printf ("Destroying %p.\n", png);
    if (png->type == perl_png_write_obj) {
        perl_png_destroy_write_struct (png);
    }
    else if (png->type == perl_png_read_obj) {
        perl_png_destroy_read_struct (png);
    }
    else {
        perl_png_error (png, "Attempt to destroy an object of unknown type");
    }
}

/*  _____         _   
   |_   _|____  _| |_ 
     | |/ _ \ \/ / __|
     | |  __/>  <| |_ 
     |_|\___/_/\_\\__| */
                   

/* Create a scalar value from the "text" field of the PNG text chunk
   contained in "text_ptr". */

static SV * make_text_sv (perl_libpng_t * png, const png_textp text_ptr)
{
    SV * sv;
    char * text = 0;
    int length = 0;

    if (text_ptr->text) {
        text = text_ptr->text;
        if (text_ptr->text_length != 0) {
            length = text_ptr->text_length;
        }
#ifdef PNG_iTXt_SUPPORTED
        else if (text_ptr->itxt_length != 0) {
            length = text_ptr->itxt_length;
        }
#endif /* iTXt */
    }
    if (text && length) {

        /* "is_itxt" contains a true value if the text claims to be
           ITXT (international text) and also validates as UTF-8
           according to Perl. The PNG specifications require that ITXT
           text is UTF-8 encoded, but this routine checks that here
           using Perl's "is_utf8_string" function. */

        int is_itxt = 0;

        sv = newSVpvn (text, length);
        
        if (text_ptr->compression == PNG_ITXT_COMPRESSION_NONE ||
            text_ptr->compression == PNG_ITXT_COMPRESSION_zTXt) {

            is_itxt = 1;

            if (! is_utf8_string ((unsigned char *) text, length)) {
                perl_png_warn (png, "According to its compression type, a text chunk in the current PNG file claims to be ITXT but Perl's 'is_utf8_string' says that its encoding is invalid.");
                is_itxt = 0;
            }
        }
        if (is_itxt) {
            SvUTF8_on (sv);
        }
    }
    else {
        sv = newSV (0);
    }
    return sv;
}

/* Convert the "lang_key" field of a "png_text" structure into a Perl
   scalar. */

static SV * lang_key_to_sv (perl_libpng_t * png, const char * lang_key)
{
    SV * sv;
    if (lang_key) {
        int length;
        /* "lang_key" is supposed to be UTF-8 encoded. */
        int is_itxt = 1;

        length = strlen (lang_key);
        sv = newSVpv (lang_key, length);
        if (! is_utf8_string ((unsigned char *) lang_key, length)) {
            perl_png_warn (png, "A language key 'lang_key' member of a 'png_text' structure in the file failed Perl's 'is_utf8_string' test, which says that its encoding is invalid.");
            is_itxt = 0;
        }
        if (is_itxt) {
            SvUTF8_on (sv);
        }
    }
    else {
        sv = newSV (0);
    }
    return sv;
}

/* "text_fields" contains the names of the various fields in a
   "png_text" structure. The following routine uses these names to put
   the values of the png_text structure into a Perl hash. */

static const char * text_fields[] = {
    "compression",
    "key",
    "text",
    "lang",
    "lang_key",
    "text_length",
    "itxt_length",
};

/* "N_TEXT_FIELDS" is the number of text fields in a "png_text"
   structure which we want to preserve. */

#define N_TEXT_FIELDS (sizeof (text_fields) / sizeof (const char *))

/* "perl_png_textp_to_hash" creates a new Perl associative array from
   the PNG text values in "text_ptr". */

static HV *
perl_png_textp_to_hash (perl_libpng_t * png, const png_textp text_ptr)
{
    int i;
    /* Scalar values which will be added to elements of "text_hash". */
    SV * f[N_TEXT_FIELDS];
    HV * text_hash;

    text_hash = newHV ();
    f[0] = newSViv (text_ptr->compression);
    f[1] = newSVpv (text_ptr->key, strlen (text_ptr->key));
    /* Depending on whether the "text" field of "text_ptr" is a string
       or a null value, create an SV copy of it or create an SV which
       contains the undefined value. */
    f[2] = make_text_sv (png, text_ptr);
#ifdef PNG_iTXt_SUPPORTED
    if (text_ptr->lang) {
        /* According to section 4.2.3.3 of the PNG specification, the
           "lang" field of the "png_text" structure contains a
           language code according to the conventions of RFC 1766 (now
           superceded by RFC 3066), which is an ASCII based standard
           for describing languages, so it is not necessary to mark
           this as being in UTF-8. */
        f[3] = newSVpv (text_ptr->lang, strlen (text_ptr->lang));
    }
    else {
        /* The language code may be empty. */
        f[3] = newSV (0);
    }
    f[4] = lang_key_to_sv (png, text_ptr->lang_key);
#endif /* iTXt */
    f[5] = newSViv (text_ptr->text_length);
#ifdef PNG_iTXt_SUPPORTED
    f[6] = newSViv (text_ptr->itxt_length);
#endif /* iTXt */

    for (i = 0; i < N_TEXT_FIELDS; i++) {
        //printf ("%d:%s\n", i, text_fields[i]);
        if (!hv_store (text_hash, text_fields[i],
                       strlen (text_fields[i]), f[i], 0)) {
            fprintf (stderr, "hv_store failed.\n");
        }
    }

    return text_hash;
}

/*
  This is the C part of Image::PNG::get_text.
 */

SV *
perl_png_get_text (perl_libpng_t * png)
{
    int num_text = 0;
    png_textp text_ptr;

    png_get_text (pngi, & text_ptr, & num_text);
    if (num_text > 0) {
        int i;
        SV * text_ref;
        AV * text_chunks;

        MESSAGE ("Got some text:\n");
        text_chunks = newAV ();
        for (i = 0; i < num_text; i++) {
            HV * hash;
            SV * hash_ref;

            MESSAGE ("text %d:\n", i);
            
            hash = perl_png_textp_to_hash (png, text_ptr + i);
            hash_ref = newRV_inc ((SV *) hash);
            av_push (text_chunks, hash_ref);
        }
        text_ref = newRV_inc ((SV *) text_chunks);
        return text_ref;
    } else {
        MESSAGE ("There is no text:\n");
        UNDEF;
    }
}

/* True value if successful. */

static int
perl_png_set_text_from_hash (perl_libpng_t * png, png_text * text_out, HV * chunk)
{
    int compression;
    char * keyword;
    int keyword_length;
    char * language_tag;
    int language_tag_length;
    char * translated_keyword;
    int translated_keyword_length;
    int is_itxt = 0;
    char * text;
    int text_length;
    int ok = 1;

    MESSAGE ("Putting it into something.\n");
    /* Check the compression field of the chunk */
#define FETCH_IV(field) {                                       \
        SV * field_sv;                                          \
        SV ** field_sv_ptr = hv_fetch (chunk, #field,           \
                                       strlen (#field), 0);     \
        if (! field_sv_ptr) {                                   \
            fprintf (stderr, "You don't have no %s sucker.\n",  \
                     #field);                                   \
            return 0;                                           \
        }                                                       \
        field_sv = * field_sv_ptr;                              \
        field = SvIV (field_sv);                                \
    }
    FETCH_IV (compression);
    switch (compression) {
    case PNG_TEXT_COMPRESSION_NONE:
        break;
    case PNG_TEXT_COMPRESSION_zTXt:
        break;
    case PNG_ITXT_COMPRESSION_NONE:
        is_itxt = 1;
        break;
    case PNG_ITXT_COMPRESSION_zTXt: 
        is_itxt = 1;
        break;
    default:
        ok = 0;
        fprintf (stderr, "Unknown compression %d\n", 
                 compression);
        return 0;
        break;
    }

#define FETCH_PV(field) {                                       \
        SV * field_sv;                                          \
        SV ** field_sv_ptr = hv_fetch (chunk, #field,           \
                                       strlen (#field), 0);     \
        if (! field_sv_ptr) {                                   \
            fprintf (stderr, "You don't have no %s sucker.\n",  \
                     #field);                                   \
            field = "";                                         \
        }                                                       \
        else {                                                  \
            field_sv = * field_sv_ptr;                          \
            field = SvPV (field_sv, field ## _length);          \
        }                                                       \
    }

    MESSAGE ("Getting keyword.\n");
    FETCH_PV (keyword);
    if (keyword_length < 1 || keyword_length > 79) {
        /* Keyword is too long or empty */
        MESSAGE ("Bad length of keyword.\n");

        ok = 0;
        return 0;
    }
    MESSAGE ("Getting text.\n");
    FETCH_PV (text);
    if (ok) {
        MESSAGE ("Copying.\n");
        text_out->compression = compression;
        text_out->key = keyword;
        text_out->text = text;
        text_out->text_length = text_length;
#ifdef PNG_iTXt_SUPPORTED
        if (is_itxt) {
            FETCH_PV (language_tag);
            text_out->lang = language_tag;
            text_out->lang_key = translated_keyword;
        }
#endif
    }
    else {
            /* Compression method unknown. */
        ;
    }

    return ok;
}

/* Set the text chunks in the PNG. This actually pushes text chunks
   into the object rather than setting them (so it does not destroy
   already-set ones). */

void
perl_png_set_text (perl_libpng_t * png, AV * text_chunks)
{
    int num_text;
    int num_ok = 0;
    int i;
    png_text * png_texts;

    num_text = av_len (text_chunks) + 1;
    MESSAGE ("You have %d text chunks.\n", num_text);
    if (num_text <= 0) {
        /* Complain to the user */
        return;
    }
    GET_MEMORY (png_texts, num_text);
    for (i = 0; i < num_text; i++) {
        int ok = 0;
        SV ** chunk_pointer;

        MESSAGE ("Fetching chunk %d.\n", i);
        chunk_pointer = av_fetch (text_chunks, i, 0);
        if (! chunk_pointer) {
            /* Complain */
            MESSAGE ("Chunk pointer null.\n");
            continue;
        }
        if (SvROK (* chunk_pointer) && 
            SvTYPE (SvRV (* chunk_pointer)) == SVt_PVHV) {
            MESSAGE ("Looks like a hash.\n");
            ok = perl_png_set_text_from_hash (png, & png_texts[num_ok],
                                              (HV *) SvRV (* chunk_pointer));
            if (ok) {
                MESSAGE ("This chunk is OK.\n");
                num_ok++;
            }
            else {
                MESSAGE ("The chunk is not OK.\n");
            }
        }
    }
    if (num_ok > 0) {
        MESSAGE ("Writing %d text chunks to your PNG.\n",
                num_ok);
        png_set_text (pngi, png_texts, num_ok);
    }
    else {
        perl_png_warn (png, "None of your text chunks was allowed");
    }
    PERL_PNG_FREE (png_texts);
}

/*  _____ _                
   |_   _(_)_ __ ___   ___ 
     | | | | '_ ` _ \ / _ \
     | | | | | | | | |  __/
     |_| |_|_| |_| |_|\___| */
                        


/* The following time fields are used in "perl_png_timep_to_hash" for
   converting the PNG modification time structure ("png_time") into a
   Perl associative array. */

static const char * time_fields[] = {
    "year",
    "month",
    "day",
    "hour",
    "minute",
    "second"
};

#define N_TIME_FIELDS (sizeof (time_fields) / sizeof (const char *))

/* "perl_png_timep_to_hash" converts a PNG time structure to a Perl
   associative array with named fields of the same name as the members
   of the C structure. */

void perl_png_timep_to_hash (const png_timep mod_time, HV * time_hash)
{
    int i;
    SV * f[N_TIME_FIELDS];
    f[0] = newSViv (mod_time->year);
    f[1] = newSViv (mod_time->month);
    f[2] = newSViv (mod_time->day);
    f[3] = newSViv (mod_time->hour);
    f[4] = newSViv (mod_time->minute);
    f[5] = newSViv (mod_time->second);
    for (i = 0; i < N_TIME_FIELDS; i++) {
        if (!hv_store (time_hash, time_fields[i],
                       strlen (time_fields[i]), f[i], 0)) {
            fprintf (stderr, "hv_store failed.\n");
        }
    }
}

/* If the PNG contains a valid time, put the time into a Perl
   associative array. */

SV *
perl_png_get_time (perl_libpng_t * png)
{
    png_timep mod_time = 0;
    int status;
    HV * time;

    time = newHV ();
    status = png_get_tIME (pngi, & mod_time);
    if (status && mod_time) {
        perl_png_timep_to_hash (mod_time, time);
        return newRV_inc ((SV *) time);
    }
    else {
        UNDEF;
    }
}

/* Set the time in the PNG from "time". */

void
perl_png_set_time (perl_libpng_t * png, SV * input_time)
{
    png_time mod_time = {0};
    SV * ref;

    ref = SvRV(input_time);
    if (ref && SvTYPE (ref) == SVt_PVHV) {
        HV * time_hash = (HV *) SvRV (input_time);
        MESSAGE ("Setting time from a hash.\n");
#define SET_TIME(field) {                                               \
            SV ** field_sv_ptr = hv_fetch (time_hash, #field,           \
                                           strlen (#field), 0);         \
            if (field_sv_ptr) {                                         \
                SV * field_sv = * field_sv_ptr;                         \
                MESSAGE ("OK for %s\n", #field);                        \
                mod_time.field = SvIV (field_sv);                       \
            }                                                           \
            else {                                                      \
                mod_time.field = 0;                                     \
            }                                                           \
        }
        SET_TIME(year);
        SET_TIME(month);
        SET_TIME(day);
        SET_TIME(hour);
        SET_TIME(minute);
        SET_TIME(second);
#undef SET_TIME    
    }
    else {
        /* There is no valid time argument, so just set it to the time
           now, according to the system clock. */
        time_t now;

        MESSAGE ("The modification time doesn't look OK so I am going to set the modification time to the time now instead.\n");
        now = time (0);
        png_convert_from_time_t (& mod_time, now);
    }
    png_set_tIME (pngi, & mod_time);
}

int
perl_png_sig_cmp (SV * png_header, int start, int num_to_check)
{
    unsigned char * header;
    unsigned int length;
    int ret_val;
    header = (unsigned char *) SvPV (png_header, length);
    ret_val = png_sig_cmp (header, start, num_to_check);
    return ret_val;
}

/*  ___                   _      __          _               _   
   |_ _|_ __  _ __  _   _| |_   / /__  _   _| |_ _ __  _   _| |_ 
    | || '_ \| '_ \| | | | __| / / _ \| | | | __| '_ \| | | | __|
    | || | | | |_) | |_| | |_ / / (_) | |_| | |_| |_) | |_| | |_ 
   |___|_| |_| .__/ \__,_|\__/_/ \___/ \__,_|\__| .__/ \__,_|\__|
             |_|                                |_|               */


/* Scalar as image stores information for the conversion of Perl
   scalar data into or out of the PNG structure. */

typedef struct {
    SV * png_image;
    const char * data; 
    int read_position;
    unsigned int length;
}
scalar_as_image_t;

/* Read some bytes from a Perl scalar into a png->png as requested. */

static void
perl_png_scalar_read (png_structp png,
                      png_bytep out_bytes,
                      png_size_t byte_count_to_read)
{
    scalar_as_image_t * si;
    const char * read_point;

    si = png_get_io_ptr (png);
#if 0
    fprintf (stderr, "Reading %d bytes from image at position %d.\n",
             byte_count_to_read, si->read_position);
#endif
    if (si->read_position + byte_count_to_read > si->length) {
        fprintf (stderr, "Request for too many bytes %d on an image "
                 "of length %d at read position %d.\n",
                 byte_count_to_read, si->length, si->read_position);
        return;
    }
    read_point = si->data + si->read_position;
    memcpy (out_bytes, read_point, byte_count_to_read);
    si->read_position += byte_count_to_read;
}

/* Read a PNG from a Perl scalar "image_data". */

void
perl_png_read_from_scalar (perl_libpng_t * png,
                           SV * image_data,
                           int transforms)
{
    scalar_as_image_t si = {0};

    /* We don't need the following anywhere. However we probably
       should keep track of where the data comes from. */
    si.png_image = image_data;
    si.data = SvPV (si.png_image, si.length);
    /* Check it is a valid PNG here using png_sig_cmp. */

    /* Set the reader for png->png to our function. */
    png_set_read_fn (png->png, & si, perl_png_scalar_read);
    png_read_png (png->png, png->info, transforms, UNUSED_ZERO_ARG);
}

static void
perl_png_scalar_write (png_structp png, png_bytep bytes_to_write,
                       png_size_t byte_count_to_write)
{
    scalar_as_image_t * si;

    si = png_get_io_ptr (png);
    if (si->png_image == 0) {
        si->png_image = newSVpv ((char *) bytes_to_write, byte_count_to_write);
    }
    else {
        sv_catpvn (si->png_image, (char *) bytes_to_write, byte_count_to_write);
    }
}

/* Write the PNG image data into a Perl scalar. */

SV *
perl_png_write_to_scalar (perl_libpng_t * png, int transforms)
{
    scalar_as_image_t * si;
    SV * image_data;

    GET_MEMORY (si, 1);
    MESSAGE ("Setting up the image.\n");
    /* Set the writer for png->png to our function. */
    png_set_write_fn (png->png, si, perl_png_scalar_write,
                      0 /* No flush function */);
    png_write_png (pngi, transforms, UNUSED_ZERO_ARG);
    image_data = si->png_image;
    PERL_PNG_FREE (si);
    return image_data;
}

void
perl_png_write_png (perl_libpng_t * png, int transforms)
{
    MESSAGE ("Trying to write your crap.\n");
    png_write_png (pngi, transforms, UNUSED_ZERO_ARG);
}

/*  _   _                _           
   | | | | ___  __ _  __| | ___ _ __ 
   | |_| |/ _ \/ _` |/ _` |/ _ \ '__|
   |  _  |  __/ (_| | (_| |  __/ |   
   |_| |_|\___|\__,_|\__,_|\___|_|    */
                                  


SV *
perl_png_get_IHDR (perl_libpng_t * png)
{
    png_uint_32 width;
    png_uint_32 height;
    int bit_depth;
    int color_type;
    int interlace_method;
    int compression_method;
    int filter_method;
    /* libpng return value */
    int status;
    /* The return value. */
    HV * IHDR;

    IHDR = newHV ();
    status = png_get_IHDR (pngi, & width, & height,
                           & bit_depth, & color_type, & interlace_method,
                           & compression_method, & filter_method);
#define STORE(x) {                                                      \
        if (!hv_store (IHDR, #x, strlen (#x), newSViv (x), 0)) {        \
            fprintf (stderr, "hv_store failed.\n");                     \
        }                                                               \
    }
    STORE (width);
    STORE (height);
    STORE (bit_depth);
    STORE (color_type);
    STORE (interlace_method);
    STORE (compression_method);
    STORE (filter_method);
#undef STORE

    return newRV_inc ((SV *) IHDR);
}

void 
perl_png_set_IHDR (perl_libpng_t * png, HV * IHDR)
{
    /* The first four are set to illegal values. We really should
       check the values going in to this routine. */
    png_uint_32 width = 0;
    png_uint_32 height = 0;
    int bit_depth = 0;
    int color_type = 0;
    int interlace_method = PNG_INTERLACE_NONE;
    const int compression_type = PNG_COMPRESSION_TYPE_DEFAULT;
    const int filter_type = PNG_FILTER_TYPE_DEFAULT;


#define FETCH(x) {                                              \
        SV ** fetched = hv_fetch (IHDR, #x, strlen (#x), 0);    \
        if (fetched) {                                          \
            x = SvIV (*fetched);                                \
        }                                                       \
    }
    FETCH (width);
    FETCH (height);
    FETCH (bit_depth);
    FETCH (color_type);
    FETCH (interlace_method);
    if (width == 0 || height == 0 || bit_depth == 0) {
        perl_png_error (png, "Bad values for width (%d), height (%d), or bit depth (%d)",
                        width, height, bit_depth);
        return;
    }
    png_set_IHDR (pngi, width, height, bit_depth, color_type,
                  interlace_method, compression_type, filter_type);
}



/*  _   _      _                     
   | | | | ___| |_ __   ___ _ __ ___ 
   | |_| |/ _ \ | '_ \ / _ \ '__/ __|
   |  _  |  __/ | |_) |  __/ |  \__ \
   |_| |_|\___|_| .__/ \___|_|  |___/
                |_|                   */


#define PERL_PNG_COLOR_TYPE(x)                  \
 case PNG_COLOR_TYPE_ ## x:                     \
     name = #x;                                 \
     break

/* Convert a PNG colour type number into its name. */

const char * perl_png_color_type_name (int color_type)
{
    const char * name;

    switch (color_type) {
        PERL_PNG_COLOR_TYPE (GRAY);
        PERL_PNG_COLOR_TYPE (PALETTE);
        PERL_PNG_COLOR_TYPE (RGB);
        PERL_PNG_COLOR_TYPE (RGB_ALPHA);
        PERL_PNG_COLOR_TYPE (GRAY_ALPHA);
    default:
        /* Moan about not knowing this colour type. */
        name = "";
    }
    return name;
}

#define PERL_PNG_TEXT_COMP(x,y)                  \
    case PNG_ ## x ## _COMPRESSION_ ## y:        \
    name = #x "_" #y;                            \
    break

/* Convert a libpng text compression number into its name. */

const char * perl_png_text_compression_name (int text_compression)
{
    const char * name;
    switch (text_compression) {
        PERL_PNG_TEXT_COMP(TEXT,NONE);
        PERL_PNG_TEXT_COMP(TEXT,zTXt);
        PERL_PNG_TEXT_COMP(ITXT,NONE);
        PERL_PNG_TEXT_COMP(ITXT,zTXt);
    default:
        /* Moan about not knowing this text compression type. */
        name = "";
    }
    return name;
}

#undef PERL_PNG_COLOR_TYPE

/*  ____       _      _   _       
   |  _ \ __ _| | ___| |_| |_ ___ 
   | |_) / _` | |/ _ \ __| __/ _ \
   |  __/ (_| | |  __/ |_| ||  __/
   |_|   \__,_|_|\___|\__|\__\___| */
                               


/* Return an array of hashes containing the colour values of the palette. */

SV *
perl_png_get_PLTE (perl_libpng_t * png)
{
    png_colorp colours;
    int n_colours;
    png_uint_32 status;
    int i;
    AV * perl_colours;

    status = png_get_PLTE (pngi, & colours, & n_colours);
    if (status != PNG_INFO_PLTE) {
        UNDEF;
    }
    perl_colours = newAV ();
    for (i = 0; i < n_colours; i++) {
        HV * palette_entry;

        MESSAGE ("Palette entry %d\n", i);
        palette_entry = newHV ();
#define PERL_PNG_STORE_COLOUR(x) hv_store (palette_entry, #x, strlen (#x), \
                           newSViv (colours[i].x), 0)
        PERL_PNG_STORE_COLOUR (red);
        PERL_PNG_STORE_COLOUR (green);
        PERL_PNG_STORE_COLOUR (blue);
#undef PERL_PNG_STORE_COLOUR
        av_push (perl_colours, newRV ((SV *) palette_entry));
    }
    return newRV_inc ((SV *) perl_colours);
}

void
perl_png_set_PLTE (perl_libpng_t * png, AV * perl_colors)
{
    int n_colors;
    png_colorp colors;
    int i;

    n_colors = av_len (perl_colors) + 1;
    if (n_colors == 0) {
        perl_png_error (png, "Empty array of colours in set_PLTE");
    }
    MESSAGE ("There are %d colours in the palette.\n", n_colors);

    GET_MEMORY (colors, n_colors);

    /* Put the colours from Perl into the libpng structure. */

#define PERL_PNG_FETCH_COLOR(x) {                                       \
        SV * rgb_sv = * (hv_fetch (palette_entry, #x, strlen (#x), 0)); \
        colors[i].x = SvIV (rgb_sv);                                    \
    }
    for (i = 0; i < n_colors; i++) {
        HV * palette_entry;
        SV * color_i;

        color_i = * av_fetch (perl_colors, i, 0);
        palette_entry = (HV *) SvRV (color_i);

        PERL_PNG_FETCH_COLOR (red);
        PERL_PNG_FETCH_COLOR (green);
        PERL_PNG_FETCH_COLOR (blue);
    }

#undef PERL_PNG_FETCH_COLOR

    png_set_PLTE (pngi, colors, n_colors);
    PERL_PNG_FREE (colors);
}

/* Create a hash containing the colour values of a pointer to a
   png_color_16 structure. */

static HV * perl_png_color_16_to_hv (png_color_16p colour)
{
    HV * perl_colour;
    perl_colour = newHV ();
#define PERL_COLOUR(x) \
    hv_store (perl_colour, #x, strlen (#x), newSViv (colour->x), 0)
    PERL_COLOUR(index);
    PERL_COLOUR(red);
    PERL_COLOUR(green);
    PERL_COLOUR(blue);
    PERL_COLOUR(gray);
#undef PERL_COLOUR
    return perl_colour;
}

/*   ___  _   _                      _                 _        
    / _ \| |_| |__   ___ _ __    ___| |__  _   _ _ __ | | _____ 
   | | | | __| '_ \ / _ \ '__|  / __| '_ \| | | | '_ \| |/ / __|
   | |_| | |_| | | |  __/ |    | (__| | | | |_| | | | |   <\__ \
    \___/ \__|_| |_|\___|_|     \___|_| |_|\__,_|_| |_|_|\_\___/ */
                                                             


#define VALID(x) png_get_valid (pngi, PNG_INFO_ ## x)

SV * perl_png_get_bKGD (perl_libpng_t * png)
{
    if (VALID(bKGD)) {
        png_color_16p background;
        if (png_get_bKGD (pngi, & background)) {
            return newRV_inc ((SV *) perl_png_color_16_to_hv (background));
        }
    }
    UNDEF;
}

SV * perl_png_get_cHRM (perl_libpng_t * png)
{
    if (VALID (cHRM)) {
        HV * ice;
        ice = newHV ();
        return newRV_inc ((SV *) ice);
    }
    UNDEF;
}

SV * perl_png_get_sBIT (perl_libpng_t * png)
{
    if (VALID (sBIT)) {
        HV * sig_bit;
        sig_bit = newHV ();
        return newRV_inc ((SV *) sig_bit);
    }
    UNDEF;
}

SV * perl_png_get_oFFs (perl_libpng_t * png)
{
    if (VALID (oFFs)) {
        HV * offset;
        
        offset = newHV ();
        return newRV_inc ((SV *) offset);
     }
     UNDEF;
 }
 
SV * perl_png_get_pHYs (perl_libpng_t * png)
{
    if (VALID (pHYs)) {
        HV * phys;
        phys = newHV ();
        return newRV_inc ((SV *) phys);
    }
    UNDEF;
}

int perl_png_get_sRGB (perl_libpng_t * png)
{
    /* I'm not sure what to return if there is no valid sRGB value. */

    int intent = 0;

    if (VALID (sRGB)) {
        png_get_sRGB (pngi, & intent);
    }
    return intent;
}

SV * perl_png_get_valid (perl_libpng_t * png)
{
    HV * perl_valid;
    unsigned int valid;

    perl_valid = newHV ();
    valid = png_get_valid (pngi, 0xFFFFFFFF);
#define V(x) \
    hv_store (perl_valid, #x, strlen (#x), newSViv (valid & PNG_INFO_ ## x), 0)

    V(gAMA);
    V(sBIT);
    V(cHRM);
    V(PLTE);
    V(tRNS);
    V(bKGD);
    V(hIST);
    V(pHYs);
    V(oFFs);
    V(tIME);
    V(pCAL);
    V(sRGB);
    V(iCCP);
    V(sPLT);
    V(sCAL);
    V(IDAT);

#undef V

    return newRV_inc ((SV *) perl_valid);
}

/*  ___                                  _       _        
   |_ _|_ __ ___   __ _  __ _  ___    __| | __ _| |_ __ _ 
    | || '_ ` _ \ / _` |/ _` |/ _ \  / _` |/ _` | __/ _` |
    | || | | | | | (_| | (_| |  __/ | (_| | (_| | || (_| |
   |___|_| |_| |_|\__,_|\__, |\___|  \__,_|\__,_|\__\__,_|
                        |___/                              */


SV *
perl_png_get_rows (perl_libpng_t * png)
{
    png_bytepp rows;
    int rowbytes;
    int height;
    SV ** row_svs;
    int r;
    AV * perl_rows;

    /* Get the information from the PNG. */

    height = png_get_image_height (pngi);
    if (height == 0) {
        perl_png_error (png, "Image has no height");
    }
    else {
        MESSAGE ("Image has height %d\n", height);
    }
    rows = png_get_rows (pngi);
    if (rows == 0) {
        perl_png_error (png, "Image has no rows");
    }
    else {
        MESSAGE ("Image has some rows\n");
    }
    rowbytes = png_get_rowbytes (pngi);
    if (rowbytes == 0) {
        perl_png_error (png, "Image rows have zero length");
    }
    else {
        MESSAGE ("Image rows are length %d\n", rowbytes);
    }

    /* Create Perl stuff to put the row info into. */

    GET_MEMORY (row_svs, height);
    MESSAGE ("Making %d scalars.\n", height);
    for (r = 0; r < height; r++) {
        row_svs[r] = newSVpvn ((char *) rows[r], rowbytes);
    }
    perl_rows = av_make (height, row_svs);
    MESSAGE ("There are %u elements in the array.\n", av_len (perl_rows));
    PERL_PNG_FREE (row_svs);
    return newRV_inc ((SV *) perl_rows);
}

/* Set the rows of the image to "rows". */

void perl_png_set_rows (perl_libpng_t * png, AV * rows)
{
    unsigned char ** row_pointers;
    int i;
    int n_rows;

    if (png->row_pointers) {
        perl_png_error (png, "Row pointers already allocated");
    }
    /* Need to check that this is the same as the height of the image. */
    n_rows = av_len (rows) + 1;
    MESSAGE ("%d rows.\n", n_rows);
    GET_MEMORY (row_pointers, n_rows);
    for (i = 0; i < n_rows; i++) {
        /* Need to check that this is the same as the width of the image. */
        unsigned int length;
        SV * row_i;
        row_i = * av_fetch (rows, i, 0);
        row_pointers[i] = (unsigned char *) SvPV (row_i, length);
        MESSAGE ("%d %d\n", i, length);
    }
    png_set_rows (pngi, row_pointers);
    /* "png" keeps a record of the allocated memory in order to free
       it. */
    png->row_pointers = row_pointers;
}

/*  __  __                                                                      
   |  \/  | ___  ___ ___  __ _  __ _  ___  ___      ___ _ __ _ __ ___  _ __ ___ 
   | |\/| |/ _ \/ __/ __|/ _` |/ _` |/ _ \/ __|    / _ \ '__| '__/ _ \| '__/ __|
   | |  | |  __/\__ \__ \ (_| | (_| |  __/\__ \_  |  __/ |  | | | (_) | |  \__ \
   |_|  |_|\___||___/___/\__,_|\__, |\___||___( )  \___|_|  |_|  \___/|_|  |___/
                               |___/          |/                                
                    _                            _                 
     __ _ _ __   __| | __      ____ _ _ __ _ __ (_)_ __   __ _ ___ 
    / _` | '_ \ / _` | \ \ /\ / / _` | '__| '_ \| | '_ \ / _` / __|
   | (_| | | | | (_| |  \ V  V / (_| | |  | | | | | | | | (_| \__ \
    \__,_|_| |_|\__,_|   \_/\_/ \__,_|_|  |_| |_|_|_| |_|\__, |___/
                                                         |___/      */

void perl_png_set_verbosity (perl_libpng_t * png, int verbosity)
{
    png->verbosity = verbosity;
    MESSAGE ("You have asked me to print messages saying what I'm doing.\n");
}

/* What should we do when there is an undefined variable, print an
   error message, raise an error, or nothing at all? */

void perl_png_handle_undefined (perl_libpng_t * png, int die, int raise)
{
    png->print_undefined = !! raise;
    png->raise_undefined = !! die;
}

/* What should we do for other errors, print an error message, raise
   an error, or nothing at all? */

void perl_png_handle_error (perl_libpng_t * png, int die, int raise)
{
    png->print_errors = !! raise;
    png->raise_errors = !! die;
}

#undef UNDEF
#define UNDEF return &PL_sv_undef


/* PNG chunks have to be four bytes in length. The following macro is
   defined solely in order to make this program more readable to human
   programmers. */

#define PERL_PNG_CHUNK_NAME_LENGTH 4

/*  ____       _            _              _                 _        
   |  _ \ _ __(_)_   ____ _| |_ ___    ___| |__  _   _ _ __ | | _____ 
   | |_) | '__| \ \ / / _` | __/ _ \  / __| '_ \| | | | '_ \| |/ / __|
   |  __/| |  | |\ V / (_| | ||  __/ | (__| | | | |_| | | | |   <\__ \
   |_|   |_|  |_| \_/ \__,_|\__\___|  \___|_| |_|\__,_|_| |_|_|\_\___/ */
                                                                   


/* Get any unknown chunks from the program. */

SV * perl_png_get_unknown_chunks (perl_libpng_t * png)
{
    png_unknown_chunkp unknown_chunks;
    int n_chunks;
    n_chunks = png_get_unknown_chunks (pngi, & unknown_chunks);
    MESSAGE ("There are %d private chunks.\n", n_chunks);
    if (n_chunks == 0) {
        UNDEF;
    }
    else {
        AV * chunk_list;
        int i;

        chunk_list = newAV ();
        for (i = 0; i < n_chunks; i++) {
            HV * perl_chunk;
            SV * perl_chunk_ref;
            png_unknown_chunk * png_chunk;
            /* These hold the chunk info from the PNG chunk */
            SV * name;
            SV * data;
            SV * location;

            png_chunk = unknown_chunks + i;
            perl_chunk = newHV ();
            if (strlen (png_chunk->name) != PERL_PNG_CHUNK_NAME_LENGTH) {
                perl_png_error (png, "Chunk name '%s' has wrong number of "
                                "characters: %d required",
                                png_chunk->name,
                                PERL_PNG_CHUNK_NAME_LENGTH);
                /* PANIC */
            }
            name = newSVpvn (png_chunk->name, PERL_PNG_CHUNK_NAME_LENGTH);
            data = newSVpvn (png_chunk->name, png_chunk->size);
            location = newSViv (png_chunk->location);
#define STORE(x) hv_store (perl_chunk, #x, strlen (#x), x, 0);
            STORE(name);
            STORE(data);
            STORE(location);
#undef STORE
            perl_chunk_ref = newRV_inc ((SV *) perl_chunk);
            av_push (chunk_list, perl_chunk_ref);
        }
        return newRV_inc ((SV *) chunk_list);
    }
}

void perl_png_set_unknown_chunks (perl_libpng_t * png, AV * chunk_list)
{
    /* n_chunks is the number of chunks the user proposes to add to
       the PNG. */
    int n_chunks;
    /* n_ok_chunks is the number of chunks which are acceptable to add
       to the PNG. */
    int n_ok_chunks;
    int i;
    png_unknown_chunkp unknown_chunks;

    n_chunks = av_len (chunk_list) + 1;
   
    if (n_chunks == 0) {
        perl_png_error (png, "Number of unknown chunks is zero");
    }
    GET_MEMORY (unknown_chunks, n_chunks);
    n_ok_chunks = 0;
    MESSAGE ("OK.\n");
    for (i = 0; i < n_chunks; i++) {
        HV * perl_chunk;
        png_unknown_chunk * png_chunk;
        char * name;
        int name_length;
        char * data;
        int data_length;
        int location;

        MESSAGE ("%d.\n", i);
        /* Get the chunk name and check it is four bytes long. */

        HASH_FETCH_PV (perl_chunk, name);
        if (name_length != PERL_PNG_CHUNK_NAME_LENGTH) {
            perl_png_warn (png, "Illegal PNG chunk name length, "
                           "chunk names must be %d characters long",
                           PERL_PNG_CHUNK_NAME_LENGTH);
            continue;
        }
        strncpy (png_chunk->name, name, PERL_PNG_CHUNK_NAME_LENGTH);

        /* Get the data part of the unknown chunk. */

        HASH_FETCH_PV (perl_chunk, data);
        png_chunk = unknown_chunks + n_ok_chunks;
        
        png_chunk->data = data;
        png_chunk->size = data_length;

        /* Get the proposed location of the unknown chunk. */

        HASH_FETCH_IV (perl_chunk, location);
        if (location == 0) {
            /* warn this means "don't write the chunk". */
            perl_png_warn (png, "Unknown chunk location is zero, which means 'don't write the chunk'");
        }
        png_chunk->location = location;
        n_ok_chunks++;
    }
    MESSAGE ("sending %d chunks.\n", n_ok_chunks);
    png_set_unknown_chunks (pngi, unknown_chunks, n_ok_chunks);
    PERL_PNG_FREE (unknown_chunks);
}

/* Does the libpng support "what"? */

int perl_png_supports (const char * what)
{
    if (strcmp (what, "iTXt") == 0) {
#ifdef PNG_iTXt_SUPPORTED
        return 1;
#else
        return 0;
#endif /* iTXt */
    }
}

void
perl_png_set_keep_unknown_chunks (perl_libpng_t * png, int keep,
                                  SV * chunk_list)
{
#if defined(PNG_UNKNOWN_CHUNKS_SUPPORTED)
    if (chunk_list && 
        SvROK (chunk_list) && 
        SvTYPE (SvRV (chunk_list)) == SVt_PVAV) {
        int num_chunks;
        char * chunk_list_text;
        AV * chunk_list_av;
        int i;
        const int len = (PERL_PNG_CHUNK_NAME_LENGTH + 1);

        chunk_list_av = (AV *) SvRV (chunk_list);
        num_chunks = av_len (chunk_list_av) + 1;
        MESSAGE ("There are %d chunks in your list.\n", num_chunks);
        if (num_chunks == 0) {
            goto empty_chunk_list;
        }
        chunk_list_text = calloc (len * num_chunks, sizeof (char));
        png->memory_gets++;
        for (i = 0; i < num_chunks; i++) {
            const char * chunk_i_name;
            int chunk_i_length;
            SV ** chunk_i_sv_ptr;
            int j;
            chunk_i_sv_ptr = av_fetch (chunk_list_av, i, 0);
            if (! chunk_i_sv_ptr) {
                perl_png_error (png, "undefined chunk name at offset %d in chunk list", i);
            }
            chunk_i_name = SvPV (*chunk_i_sv_ptr, chunk_i_length);
            if (chunk_i_length != PERL_PNG_CHUNK_NAME_LENGTH) {
                perl_png_error (png, "chunk %i has bad length %d: should be %d in chunk list", i, chunk_i_length, PERL_PNG_CHUNK_NAME_LENGTH);
            }
            MESSAGE ("Keeping chunk '%s'\n", chunk_i_name);
            for (j = 0; j < PERL_PNG_CHUNK_NAME_LENGTH; j++) {
                chunk_list_text [ i * len + j ] = chunk_i_name [ j ];
            }
            chunk_list_text [ i * len + PERL_PNG_CHUNK_NAME_LENGTH ] = '\0';
        }
        png_set_keep_unknown_chunks (png->png, keep,
                                     chunk_list_text, num_chunks);
#if 0
            if (! png->png->chunk_list) {
                fprintf (stderr, "Zero.\n");
            }
        for (i = 0; i < num_chunks * len; i++) {
            printf ("%02X", png->png->chunk_list[i]);
        }
        printf ("\n");
        for (i = 0; i < num_chunks * len; i++) {
            printf ("%02X", chunk_list_text[i]);
        }
        printf ("\n");
#endif
        free (chunk_list_text);
        png->memory_gets--;
    }
    else {
        MESSAGE ("There is no valid chunk list.\n");
    empty_chunk_list:
        png_set_keep_unknown_chunks (png->png, keep, 0, 0);
    }
#else
    perl_png_error ("This function is not supported in your libpng");
#endif
}
                                  

/*
   Local Variables:
   mode: c
   end: 
*/
