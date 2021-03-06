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
# This file was generated from the source file hr.xml.
# The source file version number was 1.79, generated on
# 2007/07/19 23:30:28.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::hr;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::root;

@DateTime::Locale::hr::ISA = qw(DateTime::Locale::root);

my @day_names = (
"ponedjeljak",
"utorak",
"srijeda",
"četvrtak",
"petak",
"subota",
"nedjelja",
);

my @day_abbreviations = (
"pon",
"uto",
"sri",
"čet",
"pet",
"sub",
"ned",
);

my @day_narrows = (
"p",
"u",
"s",
"č",
"p",
"s",
"n",
);

my @month_names = (
"siječanj",
"veljača",
"ožujak",
"travanj",
"svibanj",
"lipanj",
"srpanj",
"kolovoz",
"rujan",
"listopad",
"studeni",
"prosinac",
);

my @month_abbreviations = (
"sij",
"vel",
"ožu",
"tra",
"svi",
"lip",
"srp",
"kol",
"ruj",
"lis",
"stu",
"pro",
);

my @month_narrows = (
"s",
"v",
"o",
"t",
"s",
"l",
"s",
"k",
"r",
"l",
"s",
"p",
);

my @quarter_names = (
"1\.\ kvartal",
"2\.\ kvartal",
"3\.\ kvartal",
"4\.\ kvartal",
);

my @quarter_abbreviations = (
"1kv",
"2kv",
"3kv",
"4kv",
);

my @am_pms = (
"AM",
"PM",
);

my @era_names = (
"Prije\ Krista",
"Poslije\ Krista",
);

my @era_abbreviations = (
"pr\.n\.e\.",
"AD",
);

my $date_before_time = "1";
my $date_parts_order = "ymd";


sub day_names                      { \@day_names }
sub day_abbreviations              { \@day_abbreviations }
sub day_narrows                    { \@day_narrows }
sub month_names                    { \@month_names }
sub month_abbreviations            { \@month_abbreviations }
sub month_narrows                  { \@month_narrows }
sub quarter_names                  { \@quarter_names }
sub quarter_abbreviations          { \@quarter_abbreviations }
sub am_pms                         { \@am_pms }
sub era_names                      { \@era_names }
sub era_abbreviations              { \@era_abbreviations }
sub full_date_format               { "\%A\,\ \%d\ \%B\ \%\{ce_year\}\." }
sub long_date_format               { "\%d\.\ \%B\ \%\{ce_year\}\." }
sub medium_date_format             { "\%\{ce_year\}\.\%m\.\%d" }
sub short_date_format              { "\%\{ce_year\}\.\%m\.\%d" }
sub full_time_format               { "\%H\:\%M\:\%S\ v" }
sub long_time_format               { "\%H\:\%M\:\%S\ \%\{time_zone_long_name\}" }
sub medium_time_format             { "\%H\:\%M\:\%S" }
sub short_time_format              { "\%H\:\%M" }
sub date_before_time               { $date_before_time }
sub date_parts_order               { $date_parts_order }



1;

