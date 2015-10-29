###########################################################################
#
# This file is auto-generated by the Perl DateTime Suite time locale
# generator (0.04).  This code generator comes with the
# DateTime::Locale distribution in the tools/ directory, and is called
# generate_from_cldr.
#
# This file as generated from the CLDR XML locale data.  See the
# LICENSE.cldr file included in this distribution for license details.
#
# This file was generated from the source file uz_Arab.xml.
# The source file version number was 1.24, generated on
# 2007/07/19 22:31:40.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::uz_Arab;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::uz;

@DateTime::Locale::uz_Arab::ISA = qw(DateTime::Locale::uz);

my @day_names = (
"دوشنبه",
"سه‌شنبه",
"چهارشنبه",
"پنجشنبه",
"جمعه",
"شنبه",
"یکشنبه",
);

my @day_abbreviations = (
"د\.",
"س\.",
"چ\.",
"پ\.",
"ج\.",
"ش\.",
"ی\.",
);

my @month_names = (
"جنوری",
"فبروری",
"مارچ",
"اپریل",
"می",
"جون",
"جولای",
"اگست",
"سپتمبر",
"اکتوبر",
"نومبر",
"دسمبر",
);

my @month_abbreviations = (
"جنو",
"فبر",
"مار",
"اپر",
"مـی",
"جون",
"جول",
"اگس",
"سپت",
"اکت",
"نوم",
"دسم",
);

my @era_abbreviations = (
"ق\.م\.",
"م\.",
);

my $date_parts_order = "ymd";


sub day_names                      { \@day_names }
sub day_abbreviations              { \@day_abbreviations }
sub month_names                    { \@month_names }
sub month_abbreviations            { \@month_abbreviations }
sub era_abbreviations              { \@era_abbreviations }
sub full_date_format               { "\%\{ce_year\}\ نچی\ ییل\ \%\{day\}\ نچی\ \%B\ \%A\ کونی" }
sub long_date_format               { "\%\{day\}\ نچی\ \%B\ \%\{ce_year\}" }
sub medium_date_format             { "\%\{day\}\ \%b\ \%\{ce_year\}" }
sub short_date_format              { "\%\{ce_year\}\/\%\{month\}\/\%\{day\}" }
sub full_time_format               { "\%\{hour\}\:\%M\:\%S\ \(v\)" }
sub long_time_format               { "\%\{hour\}\:\%M\:\%S\ \(\%\{time_zone_long_name\}\)" }
sub medium_time_format             { "\%\{hour\}\:\%M\:\%S" }
sub short_time_format              { "\%\{hour\}\:\%M" }
sub date_parts_order               { $date_parts_order }



1;

