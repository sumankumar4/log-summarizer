package Named::NERB;

####Get todays date
($Second, $Minute, $Hour, $Day, $Mon, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time);
$Year += 1900; #Gives the number of years since 1900.
$Mon  += 1;    #Gives number of months from the start of year.
$WeekDay += 1; #Gives the number of days passed over the last sunday.

#IP address definitions...
$ipnum="25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?";

#Date definitions...
$dateseperator="[\/\-]";
$num_day="[1-9]|[012][0-9]|[3][0-1]";
$num_m="[0][1-9]|[1][0-2]";
$num_y="[0-9][0-9]";
$four_digit_year="[1][9][0-9][0-9]|[2][0][0-6][0-9]";

#Month defintions...
$jan="[Jj][Aa][Nn][Uu][Aa][Rr][Yy]|[Jj][Aa][Nn]";
$feb="[Ff][Ee][Bb][Rr][Uu][Aa][Rr][Yy]|[Ff][Ee][Bb]";
$mar="[Mm][Aa][Rr][Cc][Hh]|[Mm][Aa][Rr]";
$apr="[Aa][Pp][Rr][Ii][Ll]|[Aa][Pp][Rr]";
$may="[Mm][Aa][Yy]";
$jun="[Jj][Uu][Nn][Ee]|[Jj][Uu][Nn]";
$jul="[Jj][Uu][Ll][Yy]|[Jj][Uu][Ll]";
$aug="[Aa][Uu][Gg][Uu][Ss][Tt]|[Aa][Uu][Gg]";
$sep="[Ss][Ee][Pp][Tt][Ee][Mm][Bb][Ee][Rr]|[Ss][Ee][Pp][Tt]|[Ss][Ee][Pp]";
$oct="[Oo][Cc][Tt][Oo][Bb][Ee][Rr]|[Oo][Cc][Tt]";
$nov="[Nn][Oo][Vv][Ee][Mm][Bb][Ee][Rr]|[Nn][Oo][Vv]";
$dec="[Dd][Ee][Cc][Ee][Mm][Bb][Ee][Rr]|[Dd][Ee][Cc]";

#Week definitions...
$mon="Monday|MONDAY|monday|[Mm][Oo][Nn]";
$tue="Tuesday|TUESDAY|tuesday|[Tt][Uu][Ee][Ss]|[Tt][Uu][Ee]";
$wed="Wednesday|WEDNESDAY|wednesday|[Ww][Ee][Dd]";
$thu="Thursday|THURSDAY|thursday|[Tt][Hh][Uu][Rr][Ss]|[Tt][Hh][Uu][Rr]|[Tt][Hh][Uu]";
$fri="Friday|FRIDAY|friday|[Ff][Rr][Ii]";
$sat="Saturday|SATURDAY|saturday|[Ss][Aa][Tt]";
$sun="Sunday|SUNDAY|sunday|[Ss][Uu][Nn]";

#More Definitions...
$Month="==m[0-1][0-9][A-Za-z]{3,10}\\.?=";
$Wkday="==w[0-7][A-Za-z]{3,10}\\.?=";
$Yr="[1][9][0-9][0-9]|[03-9][0-9]";

#Time Definitions...
$am="a\\.?m\\.?|A\\.?M\\.?";
$pm="p\\.?m\\.?|P\\.?M\\.?";
$timeseperator="[:]";
$pod="==pod[1-2]=";
$hr="[0-9]|[0-2][0-9]";
$min="[0-5][0-9]";
$sec="[0-5][0-9][,\\.]?[0-9]{2,5}|[0-5][0-9]";
$zonediff="\\+[0-9]{1,2}[:\\.]?[0-9][0-9]|\\-[0-9]{1,2}[:\\.]?[0-9][0-9]";
$time="==time[0-9:,]{7,15}=";

#URL extraction definitions
use URI::Find;
$finder = URI::Find->new(\&callback);

#Email extraction definitions
use Email::Find;
$emailfinder = Email::Find->new(\&emailcallback);


sub detectentities
{
	my $word = $_[0];
	my $allflags = $_[1];
	my @flags = split(//,$allflags);

	#Detecting URLs
	$finder->find(\$word);

	#Removing detected URL entities...
	@detectedurlentities = ($word =~ m/(==urlstart.+?=urlend)/g);
	$urlcount=1;
	$wordext=$word;
	while($word =~ m/(==urlstart.+?=urlend)/g)
	{
		$wordext =~ s/(==urlstart.+?=urlend)/{{{url$urlcount}}}/;
		$urlcount++;
	}
	$word=$wordext;


	#Detecting Email URL...
	$emailfinder->find(\$word);
	#Removing detected Emails...
	@detectedemails = ($word =~ m/(==email.+?=)/g);
	$emailcount = 1;
	$wordext = $word;
	while ($word =~ m/(==email.+?=)/g)
	{
		$wordext =~ s/(==email.+?=)/{{{email$emailcount}}}/;
	}
	$word=$wordext;

	#Detecting IP address...
	$word=~s/\b($ipnum)\.($ipnum)\.($ipnum)\.($ipnum)\b/==ipadd$1\.$2\.$3\.$4=/g;

	#Removing detected IP entities...
	@detectedipentities = ($word =~ m/(==ipadd.+?=)/g);
	$ipaddcount=1;
	$wordext=$word;
	while($word =~ m/(==ipadd.+?=)/g)
	{
		$wordext =~ s/(==ipadd.+?=)/{{{ipadd$ipaddcount}}}/;
		$ipaddcount++;
	}
	$word=$wordext;


	#Detecting Dates....


	#Substituting Month names with ==m<monthno.><monthname>=
	#Each substitute is used twice because, if there are two occurences side by side, it won't detect the 2nd occurence, because the charecter which is before the second occuerence is already processed.
	if($flags[0] eq "1")
	{
		$word=~s/(^|[^A-Za-z])($jan\.?)([^A-Za-z]|$)/$1==m01$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($jan\.?)([^A-Za-z=\.]|$)/$1==m01$2=$3/g;

		$word=~s/(^|[^A-Za-z])($feb\.?)([^A-Za-z]|$)/$1==m02$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($feb\.?)([^A-Za-z=\.]|$)/$1==m02$2=$3/g;

		$word=~s/(^|[^A-Za-z])($mar\.?)([^A-Za-z]|$)/$1==m03$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($mar\.?)([^A-Za-z=\.]|$)/$1==m03$2=$3/g;

		$word=~s/(^|[^A-Za-z])($apr\.?)([^A-Za-z]|$)/$1==m04$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($apr\.?)([^A-Za-z=\.]|$)/$1==m04$2=$3/g;

		$word=~s/(^|[^A-Za-z])($may\.?)([^A-Za-z]|$)/$1==m05$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($may\.?)([^A-Za-z=\.]|$)/$1==m05$2=$3/g;

		$word=~s/(^|[^A-Za-z])($jun\.?)([^A-Za-z]|$)/$1==m06$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($jun\.?)([^A-Za-z=\.]|$)/$1==m06$2=$3/g;

		$word=~s/(^|[^A-Za-z])($jul\.?)([^A-Za-z]|$)/$1==m07$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($jul\.?)([^A-Za-z=\.]|$)/$1==m07$2=$3/g;

		$word=~s/(^|[^A-Za-z])($aug\.?)([^A-Za-z]|$)/$1==m08$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($aug\.?)([^A-Za-z=\.]|$)/$1==m08$2=$3/g;

		$word=~s/(^|[^A-Za-z])($sep\.?)([^A-Za-z]|$)/$1==m09$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($sep\.?)([^A-Za-z=\.]|$)/$1==m09$2=$3/g;

		$word=~s/(^|[^A-Za-z])($oct\.?)([^A-Za-z]|$)/$1==m10$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($oct\.?)([^A-Za-z=\.]|$)/$1==m10$2=$3/g;

		$word=~s/(^|[^A-Za-z])($nov\.?)([^A-Za-z]|$)/$1==m11$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($nov\.?)([^A-Za-z=\.]|$)/$1==m11$2=$3/g;

		$word=~s/(^|[^A-Za-z])($dec\.?)([^A-Za-z]|$)/$1==m12$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($dec\.?)([^A-Za-z=\.]|$)/$1==m12$2=$3/g;
	}

	#Substituting Week names with ==w<weekno.><weekname>=
	#Here also twice substitution...
	if($flags[1] eq "1")
	{
		$word=~s/(^|[^A-Za-z])($sun\.?)([^A-Za-z]|$)/$1==w1$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($sun\.?)([^A-Za-z=\.]|$)/$1==w1$2=$3/g;
		$word=~s/(^|[^A-Za-z])($mon\.?)([^A-Za-z]|$)/$1==w2$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($mon\.?)([^A-Za-z=\.]|$)/$1==w2$2=$3/g;
		$word=~s/(^|[^A-Za-z])($tue\.?)([^A-Za-z]|$)/$1==w3$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($tue\.?)([^A-Za-z=\.]|$)/$1==w3$2=$3/g;
		$word=~s/(^|[^A-Za-z])($wed\.?)([^A-Za-z]|$)/$1==w4$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($wed\.?)([^A-Za-z=\.]|$)/$1==w4$2=$3/g;
		$word=~s/(^|[^A-Za-z])($thu\.?)([^A-Za-z]|$)/$1==w5$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($thu\.?)([^A-Za-z=\.]|$)/$1==w5$2=$3/g;
		$word=~s/(^|[^A-Za-z])($fri\.?)([^A-Za-z]|$)/$1==w6$2=$3/g;
		$word=~s/(^|[^A-Za-z=])($fri\.?)([^A-Za-z=\.]|$)/$1==w6$2=$3/g;
		$word=~s/(^|[^A-Za-z])($sat\.?)([^A-Za-z]|$)/$1==w7$2=$3/g; 
		$word=~s/(^|[^A-Za-z=])($sat\.?)([^A-Za-z=\.]|$)/$1==w7$2=$3/g;
	}

	#Covers date with formats 2007/apr/07 2008-apr-07 2008/04/7 08/04/7 08/apr/7
	if($flags[2] eq "1")
	{
		$word=~s/(^|[^0-9A-Za-z])($num_y|$four_digit_year)($dateseperator|\.)($num_m|$Month)($dateseperator|\.)($num_day)([^0-9A-Za-z]|$)/$1==date$2\/$4\/$6=$7/g;
		$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;

		$word=~s/(^|[^0-9A-Za-z=])($num_y|$four_digit_year)($dateseperator|\.)($num_m|$Month)($dateseperator|\.)($num_day)([^0-9A-Za-z=]|$)/$1==date$2\/$4\/$6=$7/g;
		$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;
	}

	#Covers 07/apr/2007 07-apr-2008 07/04/2008 7/04/2008
	if($flags[3] eq "1")
	{
		$word=~s/(^|[^0-9A-Za-z])($num_day)($dateseperator|\.)($num_m|$Month)($dateseperator|\.)($num_y|$four_digit_year)([^0-9A-Za-z]|$)/$1==date$6\/$4\/$2=$7/g;
		$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;

		$word=~s/(^|[^0-9A-Za-z=])($num_day)($dateseperator|\.)($num_m|$Month)($dateseperator|\.)($num_y|$four_digit_year)([^0-9A-Za-z=]|$)/$1==date$6\/$4\/$2=$7/g;
		$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;
	}

	#Covers apr/07/2007 04/24/2007 04-24-07
	if($flags[4] eq "1")
	{
		$word=~s/(^|[^0-9A-Za-z])($num_m|$Month)($dateseperator|\.)($num_day)($dateseperator|\.)($num_y|$four_digit_year)([^0-9A-Za-z]|$)/$1==date$6\/$2\/$4=$7/g;
		$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;

		$word=~s/(^|[^0-9A-Za-z=])($num_m|$Month)($dateseperator|\.)($num_day)($dateseperator|\.)($num_y|$four_digit_year)([^0-9A-Za-z=]|$)/$1==date$6\/$2\/$4=$7/g;
		$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;
	}

	#Covers 08apr, 2008 etc...
	if($flags[5] eq "1")
	{
		$word=~s/(^|[^A-Za-z0-9])($num_day)([ ]*)($Month)([, ]*)($four_digit_year|[03-9][0-9])([^0-9A-Za-z]|$)/$1==date$6\/$4\/$2=$7/g;
		$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;

		$word=~s/(^|[^0-9A-Za-z=])($num_day)([ ]*)($Month)([, ]*)($four_digit_year|[03-9][0-9])([^0-9A-Za-z=]|$)/$1==date$6\/$4\/$2=$7/g;
		$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;
	}

	#Covers apr 13 2008  apr13, 2008 etc...
	if($flags[6] eq "1")
	{
		$word=~s/(^|[^A-Za-z0-9])($Month)([ ]*)($num_day)([, ]*)($four_digit_year)([^0-9A-Za-z]|$)/$1==date$6\/$2\/$4=$7/g;
		$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;

		$word=~s/(^|[^0-9A-Za-z=])($Month)([ ]*)($num_day)([, ]*)($four_digit_year)([^0-9A-Za-z=]|$)/$1==date$6\/$2\/$4=$7/g;
		$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;
	}

	#Covers 13apr  13,apr  13 apretc. ---- Here since year is not matched, we will give the current year or last year.
	if($flags[7] eq "1")
	{
		if($word=~/(^|[^A-Za-z0-9])($num_day)([ ,]*)($Month)([^0-9A-Za-z]|$)/)
		{
			$tmp = $4;
			$tmp=~/==m([0-1][0-9])[A-Za-z]{3,10}\.?=/g;
			$logmonth=$1;

			if($logmonth <= $Mon)
			{
				$logyear = $Year;
			}
			else
			{
				$logyear = $Year - 1;
			}

			#	print "LogMonth=$logmonth CurrentMonth=$Mon Logyear=$logyear CurrentYear=$Year\n";

			#Covers 13apr  13,apr.
			$word=~s/(^|[^A-Za-z0-9])($num_day)([ ,]*)($Month)([^0-9A-Za-z]|$)/$1==date$logyear\/$4\/$2=$5/g;
			$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;

			$word=~s/(^|[^0-9A-Za-z=])($num_day)([ ,]*)($Month)([^0-9A-Za-z=]|$)/$1==date$logyear\/$4\/$2=$5/g;
			$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;
		}
	}



	#Covers apr13 apr, 13  apr 13---- Here since year is not matched, we will give the current year or last year.
	if($flags[8] eq "1")
	{
		if($word=~/(^|[^A-Za-z0-9])($Month)([ ,]*)($num_day)([^0-9A-Za-z]|$)/)
		{
			$tmp = $2;
			$tmp=~/==m([0-1][0-9])[A-Za-z]{3,10}\.?=/g;
			$logmonth=$1;

			$logmonth=~s/([0])([0-9])/$2/g;

			if($logmonth <= $Mon)
			{
				$logyear = $Year;
			}
			else
			{
				$logyear = $Year - 1;
			}

			#Covers apr 13 apr,13.
			$word=~s/(^|[^A-Za-z0-9])($Month)([ ,]*)($num_day)([^0-9A-Za-z]|$)/$1==date$logyear\/$2\/$4=$5/g;
			$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;

			$word=~s/(^|[^0-9A-Za-z=])($Month)([ ,]*)($num_day)([^0-9A-Za-z=]|$)/$1==date$logyear\/$2\/$4=$5/g;
			$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;
		}
	}

	$word=~s/(==date[0-9]{2,4})\/==m([0-1][0-9])[A-Za-z]{3,10}\.?=\/([0-9]{1,2}=)/$1\/$2\/$3/g;


	#Detecting Time...
	# $pod --- Part of the day....
	if($flags[9] eq "1")
	{
		#detecting A.M am
		$word=~s/(^|[^A-Za-z])($am)([^A-Za-z]|$)/$1==pod1=$3/g;
		$word=~s/(^|[^A-Za-z])($am)([^A-Za-z]|$)/$1==pod1=$3/g;

		#detecting P.M pm
		$word=~s/(^|[^A-Za-z])($pm)([^A-Za-z]|$)/$1==pod2=$3/g;
		$word=~s/(^|[^A-Za-z])($pm)([^A-Za-z]|$)/$1==pod2=$3/g;
	}

	#Covers 11:12:30   11 : 12 : 30
	$word=~s/(^|[^A-Za-z0-9\+\-])($hr)([ ]*)?($timeseperator)([ ]*)?($min)([ ]*)?($timeseperator)([ ]*)?($sec)([^A-Za-z0-9:]|$)/$1==time$2:$6:$10=$11/g;
	$word=~s/(^|[^A-Za-z0-9\+\-])($hr)([ ]*)?($timeseperator)([ ]*)?($min)([ ]*)?($timeseperator)([ ]*)?($sec)([^A-Za-z0-9=:]|$)/$1==time$2:$6:$10=$11/g;

	#Covers 11:12
	$word=~s/(^|[^A-Za-z0-9:\.\+\-])($hr)($timeseperator|\.)($min)([^A-Za-z0-9:]|$)/$1==time$2:$4:00=$5/g;
	$word=~s/(^|[^A-Za-z0-9:\.\+\-])($hr)($timeseperator|\.)($min)([^A-Za-z0-9:=]|$)/$1==time$2:$4:00=$5/g;


	#Converting PM to equivalent in time...
	if($flags[9] eq "1")
	{
		$wordex=$word;
		while($word=~/==time([0-9]{1,2}):(.+?=)([ :\,\t]*)?(==pod2=)/g)
		{
			$a=$1;
			$b=$2;
			$c=$3;
			$d=$4;
			$aa=$a;
			$aa=~s/([0])([0-9])/$2/g;
			$aa=$aa+12;
			$wordex=~s/==time$a:$b$c$d/==time$aa:$b/;
		}
		$word=$wordex;
	}

	#Cover Zonediff +0530
	if($flags[10] eq "1")
	{
		$word=~s/(==time[0-9:,]{6,15}=)([ :\,\t]*)?($zonediff)([^0-9]|$)/$1$2==zonediff$3=$4/g;
	}


	#Adding the removed ipadds, emails and urls
	$worden = $word;
	while($word =~ /\{\{\{ipadd([0-9]+)\}\}\}/g)
	{
		$tt = $1;
		$worden =~ s/\{\{\{ipadd$tt\}\}\}/$detectedipentities[$tt-1]/;
	}
	while($word =~ /\{\{\{email([0-9]+)\}\}\}/g)
	{
		$tt = $1;
		$worden =~ s/\{\{\{email$tt\}\}\}/$detectedemails[$tt-1]/;
	}
	while($word =~ /\{\{\{url([0-9]+)\}\}\}/g)
	{
		$tt = $1;
		$worden =~ s/\{\{\{url$tt\}\}\}/$detectedurlentities[$tt-1]/g;
	}
	$word = $worden;

	#Just to know that is going on....
	#print "$word\n";
	return ($word);

}


# Callback function when an URL is found...
sub callback
{
	my ($uri,$orig_uri) = @_;
	my $scheme   = $uri->scheme;
	my $netloc   = $uri->netloc; # gets user,password,host,port
	my $path     = $uri->path;
	my $params   = $uri->params;
	my $query    = $uri->query;
	my $frag     = $uri->frag;
	my $port     = $uri->port;
	my $host     = $uri->host;
	my $url = "";
	$url = "==urlstart".$orig_uri."==scheme$scheme"."==host$netloc"."==path$path"."==params$params"."==query$query"."==frag$frag"."==port$port"."=urlend";
	return $url;
}

# Callback function when an Email is found...
sub emailcallback
{
	my ($email, $orig_email) = @_;
	return "==email$orig_email=";
}

1;


