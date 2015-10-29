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
# This file was generated from the source file ar_QA.xml.
# The source file version number was 1.44, generated on
# 2007/07/19 22:31:38.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::ar_QA;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::ar;

@DateTime::Locale::ar_QA::ISA = qw(DateTime::Locale::ar);

my @day_abbreviations = (
"الاثنين",
"الثلاثاء",
"الأربعاء",
"الخميس",
"الجمعة",
"السبت",
"الأحد",
);



sub day_abbreviations              { \@day_abbreviations }



1;
