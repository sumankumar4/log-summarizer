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
# This file was generated from the source file he.xml.
# The source file version number was 1.88, generated on
# 2007/07/24 01:06:03.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::he;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::root;

@DateTime::Locale::he::ISA = qw(DateTime::Locale::root);

my @day_names = (
"יום\ שני",
"יום\ שלישי",
"יום\ רביעי",
"יום\ חמישי",
"יום\ שישי",
"יום\ שבת",
"יום\ ראשון",
);

my @day_abbreviations = (
"שני",
"שלישי",
"רביעי",
"חמישי",
"שישי",
"שבת",
"ראשון",
);

my @day_narrows = (
"ב",
"ג",
"ד",
"ה",
"ו",
"ש",
"א",
);

my @month_names = (
"ינואר",
"פבואר",
"מרס",
"אפריל",
"מאי",
"יוני",
"יולי",
"אוגוסט",
"ספטמבר",
"אוקטובר",
"נובמבר",
"דצמבר",
);

my @month_abbreviations = (
"ינו",
"פבר",
"מרץ",
"אפר",
"מאי",
"יונ",
"יול",
"אוג",
"ספט",
"אוק",
"נוב",
"דצמ",
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
"רבעון\ ראשון",
"רבעון\ שני",
"רבעון\ שלישי",
"רבעון\ רביעי",
);

my @am_pms = (
"לפה\"צ",
"אחה\"צ",
);

my @era_names = (
"לפנה\"ס",
"CE",
);

my @era_abbreviations = (
"לפנה״ס",
"לסה״נ",
);

my $date_parts_order = "dmy";


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
sub full_date_format               { "\%A\ \%\{day\}\ \%B\ \%\{ce_year\}" }
sub long_date_format               { "\%\{day\}\ \%B\ \%\{ce_year\}" }
sub medium_date_format             { "\%d\/\%m\/\%\{ce_year\}" }
sub short_date_format              { "\%d\/\%m\/\%y" }
sub full_time_format               { "\%H\:\%M\:\%S\ v" }
sub long_time_format               { "\%H\:\%M\:\%S\ \%\{time_zone_long_name\}" }
sub medium_time_format             { "\%H\:\%M\:\%S" }
sub short_time_format              { "\%H\:\%M" }
sub date_parts_order               { $date_parts_order }



1;

