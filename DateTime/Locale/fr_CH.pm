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
# This file was generated from the source file fr_CH.xml.
# The source file version number was 1.47, generated on
# 2007/07/19 22:31:39.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::fr_CH;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::fr;

@DateTime::Locale::fr_CH::ISA = qw(DateTime::Locale::fr);

my $date_parts_order = "dmy";


sub full_date_format               { "\%A\,\ \%\{day\}\ \%B\ \%\{ce_year\}" }
sub short_date_format              { "\%d\.\%m\.\%y" }
sub full_time_format               { "\%H\.\%M\:\%S\ h\ v" }
sub date_parts_order               { $date_parts_order }



1;

