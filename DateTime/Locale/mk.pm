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
# This file was generated from the source file mk.xml.
# The source file version number was 1.69, generated on
# 2007/07/19 22:31:39.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::mk;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::root;

@DateTime::Locale::mk::ISA = qw(DateTime::Locale::root);

my @day_names = (
"понеделник",
"вторник",
"среда",
"четврток",
"петок",
"сабота",
"недела",
);

my @day_abbreviations = (
"пон\.",
"вт\.",
"сре\.",
"чет\.",
"пет\.",
"саб\.",
"нед\.",
);

my @day_narrows = (
"п",
"в",
"с",
"ч",
"п",
"с",
"н",
);

my @month_names = (
"јануари",
"февруари",
"март",
"април",
"мај",
"јуни",
"јули",
"август",
"септември",
"октомври",
"ноември",
"декември",
);

my @month_abbreviations = (
"јан\.",
"фев\.",
"мар\.",
"апр\.",
"мај\.",
"јун\.",
"јул\.",
"авг\.",
"септ\.",
"окт\.",
"ноем\.",
"декем\.",
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

my @era_abbreviations = (
"пр\.н\.е\.",
"ае\.",
);

my $date_before_time = "1";
my $date_parts_order = "dmy";


sub day_names                      { \@day_names }
sub day_abbreviations              { \@day_abbreviations }
sub day_narrows                    { \@day_narrows }
sub month_names                    { \@month_names }
sub month_abbreviations            { \@month_abbreviations }
sub quarter_names                  { \@quarter_names }
sub quarter_abbreviations          { \@quarter_abbreviations }
sub am_pms                         { \@am_pms }
sub era_abbreviations              { \@era_abbreviations }
sub full_date_format               { "\%A\,\ \%d\ \%B\ \%\{ce_year\}" }
sub long_date_format               { "\%d\ \%B\ \%\{ce_year\}" }
sub medium_date_format             { "\%d\.\%\{month\}\.\%\{ce_year\}" }
sub short_date_format              { "\%d\.\%\{month\}\.\%y" }
sub full_time_format               { "\%H\:\%M\:\%S\ v" }
sub long_time_format               { "\%H\:\%M\:\%S\ \%\{time_zone_long_name\}" }
sub medium_time_format             { "\%H\:\%M\:\%S" }
sub short_time_format              { "\%H\:\%M" }
sub date_before_time               { $date_before_time }
sub date_parts_order               { $date_parts_order }



1;
