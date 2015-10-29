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
# This file was generated from the source file ha.xml.
# The source file version number was 1.23, generated on
# 2007/07/19 22:31:39.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::ha;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::root;

@DateTime::Locale::ha::ISA = qw(DateTime::Locale::root);

my @day_names = (
"Littinin",
"Talata",
"Laraba",
"Alhamis",
"Jumma\'a",
"Asabar",
"Lahadi",
);

my @day_abbreviations = (
"Lit",
"Tal",
"Lar",
"Alh",
"Jum",
"Asa",
"Lah",
);

my @day_narrows = (
"2",
"3",
"4",
"5",
"6",
"7",
"1",
);

my @month_names = (
"Janairu",
"Fabrairu",
"Maris",
"Afrilu",
"Mayu",
"Yuni",
"Yuli",
"Agusta",
"Satumba",
"Oktoba",
"Nuwamba",
"Disamba",
);

my @month_abbreviations = (
"Jan",
"Fab",
"Mar",
"Afr",
"May",
"Yun",
"Yul",
"Agu",
"Sat",
"Okt",
"Nuw",
"Dis",
);

my @month_narrows = (
"1",
"2",
"3",
"4",
"5",
"6",
"7",
"8",
"9",
"10",
"11",
"12",
);

my @quarter_names = (
"Q1",
"Q2",
"Q3",
"Q4",
);

my @quarter_abbreviations = (
"Q1",
"Q2",
"Q3",
"Q4",
);

my @am_pms = (
"AM",
"PM",
);

my @era_names = (
"Gabanin\ Miladi",
"Miladi",
);

my @era_abbreviations = (
"GM",
"M",
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
sub full_date_format               { "\%A\,\ \%\{ce_year\}\ \%B\ \%d" }
sub long_date_format               { "\%\{ce_year\}\ \%B\ \%\{day\}" }
sub medium_date_format             { "\%\{ce_year\}\ \%b\ \%\{day\}" }
sub short_date_format              { "\%y\/\%m\/\%d" }
sub full_time_format               { "\%H\:\%M\:\%S\ v" }
sub long_time_format               { "\%H\:\%M\:\%S\ \%\{time_zone_long_name\}" }
sub medium_time_format             { "\%H\:\%M\:\%S" }
sub short_time_format              { "\%H\:\%M" }
sub date_before_time               { $date_before_time }
sub date_parts_order               { $date_parts_order }



1;

