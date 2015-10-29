#!/usr/bin/perl

#using Named Entity Recognizer module...
use Named::NERA;
use Named::NERB;
#using Date::Calc, to calculate the difference of time...
#use Date::Calc qw(Delta_Days);
use DateTime;

#Here the main progaram starts...
$fname = $ARGV[0];
$dirname = $fname."_data";
mkdir $dirname;
open (IN,"<$fname") or die "Cannot open the file\n";
open (STOPWORDS,"<stopwords.txt") or die "Cannot open stopwords.txt file\n";
open (LOGRECORD,">$dirname/logrecord.txt") or die "Cannot open $dirname/logrecord.txt file\n";

$linecount=0;
%record = ();
%keyrecord = ();
%stopwords = ();
%entityrecord = ();
%staticsrecord = ();

$lasttime = 0;
$lastdate = "";
$flags = "00000000000";

while($line=<IN>)
{
	chomp($line);

	# This is the line number we are processing...
	$linecount++;

	if($line eq "")
	{
		print LOGRECORD "\n";
		next;
	}

	#Detect the entities...
	if( $linecount < 6)
	{
		$newline = Named::NERA::detectentities($line);
		#Delete the flags send by NERA module
		@splittedline = split(/\s+/,$newline);
		$flags = shift @splittedline;
		$newline =~ s/$flags\s//g;
	}
	else
	{
		$newline = Named::NERB::detectentities($line, $flags);
	}

	#Get the date and time difference...
	$lin = &datedifference($newline);
	#$lin = $line;
	#print $lin."\n";

	#Write Logs to file...
	print LOGRECORD "$lin\n";
	

	##################################################################################
	#Get all the entities in @entities...
	###################################################################################
	@entities = ();

	#Add date, ipadd, email entities to @entities...
	while($lin =~ m/==(date|ipadd|email).+?=/g)
	{
		push @entities, $&;
	}
	#Add time to @entities, removes milli-seconds in time...
	#Just indexing by minutes...
	while($lin =~ m/==time.+?=/g)
	{
		$a = $&;
		$a =~ m/==time(.*):(.*):(.*)=/;
		$hour = $1; $minute = $2; $seconds = $3;
		#my @seco = split(//,$seconds);
		#$seconds = "$seco[0]$seco[1]";
		push @entities, "==time$hour:$minute=";

	}
	#Remove the added entities and other unused entities...
	$lin =~ s/==(time|date|pod|ipadd|zonediff|email).+?=//g;
	$lin =~ s/==m([0-1][0-9])[A-Za-z]{3,10}\.?=//g;  #Removes month identifications...
	$lin =~ s/==w[1-7][A-Za-z]{3,9}\.?=//g; #Removes weekday identification...

	#Get all URL entities...
	while($lin =~ m/==urlstart.+?=urlend/g)
	{
		$uri = $&;
		$uri =~ m/==urlstart(.+)==scheme(.*)==host(.*)==path(.*)==params(.*)==query(.*)==frag(.*)==port(.*)=urlend/;
		$url = $1;
		$scheme = $2;
		$host = $3;
		$path = $4;
		$params = $5;
		$query = $6;
		$frag = $7;
		$port = $8;
		push @entities, "==urlstart$url=urlend";
		if($scheme ne "") {	push @entities,"==scheme$scheme=";	}
		if($host ne "") {     push @entities,"==host$host=";      }
		if($path ne "") {     push @entities,"==path$path=";      }
		if($params ne "") {     push @entities,"==params$params=";      }
		if($query ne "") {     push @entities,"==query$query=";      }
		if($frag ne "") {     push @entities,"==frag$frag=";      }
		if($port ne "") {     push @entities,"==port$port=";      }

	}
	#########################################################################################
	#End of collecting the entities in @entitites array...
	#########################################################################################

	#Replace URLs for some understanding...
	$lin =~ s/(==urlstart.+?=urlend)/___someurl___/g;

	##############################################################
	# Tokenizer statements...
	##############################################################
	@words = split(/[\s\[\]\-\=\:\,\;\"\<\>\(\)]+/,$lin);
	@words = grep /[^\s]+/,@words;

	#Exclude first two, since they are the timediff and daysdiff values...
	shift @words;
	shift @words;

	######################################################################
	#Indexer Module...
	######################################################################

	#Index the words...(Inverted Index)
	#print "@words\n";

	foreach $word (@words)
	{
		$word = lc($word);
		if(exists $record{$word})
		{
			if($record{$word}!~/(^| )$linecount( |$)/g)
			{
				$record{$word} .= " ".$linecount;
			}
		}
		else
		{
			$record{$word} = $linecount;
		}
	}

	#Index the @entities to the same Inverted Index...
	foreach $entity (@entities)
	{
		if(exists $entityrecord{$entity})
		{
			if($entityrecord{$entity}!~/(^| )$linecount( |$)/g)
			{
				$entityrecord{$entity} .= " ".$linecount;
			}
		}
		else
		{
			$entityrecord{$entity} = $linecount;
		}
	}
	######################################################################
}
close(IN);
#Index stopwords...
foreach $stopword (<STOPWORDS>)
{
	chomp($stopword);
	if(! exists $stopwords{$stopword})
	{
		$stopwords{$stopword} = "";
	}
}
close(STOPWORDS);
close(LOGRECORD);
#############################################
#Now it indexes the keyvalues in keyrecord...
#############################################
open(RECORD,">$dirname/record.txt") or die "Cannot open $dirname/record.txt\n";
foreach $word (keys %record)
{
	#Save record(Index) to file...
	print RECORD "$word\t$record{$word}\n";

	if(&isentity($word))
	{
		next;
	}
	if(exists $stopwords{$word})
	{
		next;
	}

	@logs = split(/ /,$record{$word});
	$logno = @logs;

	$logno = $logno." ".$record{$word};

	if(exists $keyrecord{$logno})
	{
		$keyrecord{$logno} = $keyrecord{$logno}." ".$word;
	}
	else
	{
		$keyrecord{$logno} = $word;
	}
}
#close(RECORD);

#Save entityrecord also to record.txt...
foreach $word (keys %entityrecord)
{
	#Save entityrecord also to record.txt...
	print RECORD "$word\t$entityrecord{$word}\n";
	@logs = split(/ /,$entityrecord{$word});
	$logno = @logs;
	#add the count to the starting of the list of lognumbers...
	$entityrecord{$word} = $logno." ".$entityrecord{$word};
}
close(RECORD);

#Save keyrecord to file...
open(KEYRECORD,">$dirname/keyrecord.txt") or die "Cannot open $dirname/keyrecord.txt\n";
foreach $word (keys %keyrecord)
{
	print KEYRECORD "$word\n";
}
close(KEYRECORD);

##########################################################
#Print Module...
##########################################################
$keyrecordsize = keys(%keyrecord);

#Calculate the 'totalpercentile' and 'totalavgtimediff'.
$totalpercentile = 0;
$totalavgtimediff = 0;
#for($i = 1; $i <= $keyrecordsize; $i++)
$i=1;
foreach $word (keys %keyrecord)
{
	
	#For getting totalpercentile...
	$percentile = $i/$keyrecordsize;
	if($percentile > 0.5)
	{
		$percentile = $percentile - 0.5;
		$percentile = $percentile*2;
	}
	else
	{
		$percentile = 0.5 - $percentile;
		$percentile = $percentile*2;
	}
	$totalpercentile += $percentile;

	#For getting totalavgtimediff...
	$statics = &getstatistics($word);
	$staticsrecord{$word} = $statics;
	@statss = split(/ /,$statics);
	$totalavgtimediff += $statss[0];
	$i++;
}

#Calculate the totalprobability of each keyrecord...
$keycount = 0;
foreach $word (sort { $a <=> $b } keys %keyrecord)
{
	$keycount++;
	
	#Calculates the percentile probability...
	$percentile = $keycount/$keyrecordsize;
	if($percentile > 0.5)
	{
		$percentile = $percentile - 0.5;
		$percentile = $percentile*2;
	}
	else
	{
		$percentile = 0.5 - $percentile;
		$percentile = $percentile*2;
	}
	$percentileprob = $percentile/$totalpercentile;

	#Calculate the averagetimediff probability...
	#$statics = &getstatistics($word);
	#For optimal speed, we used a hash to retrieve statics which are retrieved before.
	if(exists $staticsrecord{$word})
	{
		$statics = $staticsrecord{$word};
	}
	else
	{
		$statics = &getstatistics($word);
	}
	@stats = split(/ /,$statics);

	#To avoid divide by zero problem...
	if($totalavgtimediff == 0)
	{
		$avgtimediffprob = 0;
	}
	else
	{
		$avgtimediffprob = $stats[0]/$totalavgtimediff;
	}
	
	$totalprob = $percentileprob + $avgtimediffprob;
	$keyrecord{$word} = $totalprob." ".$keyrecord{$word};
}

#Get top Hostnames, Email-ids, IP-addresses, URL-Schemes, URL-ports, Queries in the log...
$hostnamecount = 0; $emailidcount = 0; $ipaddcount = 0; $urlschemecount = 0; $urlportcount = 0; $querycount = 0;
$hostnames = ""; $emailids = ""; $ipadds = ""; $urlschemes = ""; $urlports = ""; $queries = "";
foreach $word (sort { $entityrecord{$b} <=> $entityrecord{$a} } keys %entityrecord)
{
	$realword = $word;
	$urlword = $word;
	#print "$word $entityrecord{$word}\n";
	$realword =~ s/==(host|email|ipadd|scheme|port|query)(.+)=/$2/g;
	$urlword =~ s/=/%3D/g;
	
	if($hostnamecount < 10 && $word =~ m/==host.+?=/g)
	{
		$hostnames .= "<a href=\"LogSummarizer.cgi?q=$urlword&btnG=Search\" >$realword</a><br>";
		$hostnamecount++;
	}
	if($emailidcount < 10 && $word =~ m/==email+?=/g)
	{
		$emailids .= "<a href=\"LogSummarizer.cgi?q=$urlword&btnG=Search\" >$realword</a><br>";
		$emailidcount++;
	}
	if($ipaddcount < 10 && $word =~ m/==ipadd.+?=/g)
	{
		$ipadds .= "<a href=\"LogSummarizer.cgi?q=$urlword&btnG=Search\" >$realword</a><br>";
		$ipaddcount++;
	}
	if($urlschemecount < 10 && $word =~ m/==scheme.+?=/g)
	{
		$urlschemes .= "<a href=\"LogSummarizer.cgi?q=$urlword&btnG=Search\" >$realword</a><br>";
		$urlschemecount++;
	}
	if($urlportcount < 10 && $word =~ m/==port.+?=/g)
	{
		$urlports .= "<a href=\"LogSummarizer.cgi?q=$urlword&btnG=Search\" >$realword</a><br>";
		$urlportcount++;
	}
	if($querycount < 10 && $word =~ m/==query.+?=/g)
	{
		$queries .= "<a href=\"LogSummarizer.cgi?q=$urlword&btnG=Search\" >$realword</a><br>";
		$querycount++;
	}

}



#####Actual Printing Module...###############

#List the top 20 results in the pattern list...
$patterncount = 0;
open(STATISTICS,">$dirname/statistics.txt") or die "Cannot open $dirname/statistics.txt\n";
print STATISTICS "<table border='1'>";
print STATISTICS "<th>Top Events in the Log</th><th>No. of times event occurred</th><th>Average time taken</th><th>Maximum time taken</th><th>Minimum time taken</th>";
foreach $word(sort {$keyrecord{$b} <=> $keyrecord{$a} } keys %keyrecord)
{
	$patterncount++;
	@filenos = split(/ /,$word);
	@patternwords = split(/ /,$keyrecord{$word});
	$pattern = &extractpattern_with_logid($word);
	if(exists $staticsrecord{$word})
	{
		$statistics = $staticsrecord{$word};
	}
	else
	{
		$statistics = &getstatistics($word);
	}
	#$statistics = &getstatistics($word);
	@stats = split(/ /,$statistics);
	$stats[0] =~ s/(.*)\.([0-9]{4})(.*)/$1\.$2/g;
	print STATISTICS "<tr><td>$pattern</td><td>$filenos[0]</td><td>$stats[0] Secs.</td><td>$stats[1] Secs.</td><td>$stats[2] Secs.</td><tr>";
	if($patterncount >= 20)
	{
		last;
	}
}
print STATISTICS "</table>";

if($hostnames ne ""){ print STATISTICS "<h3>Top Hostnames in the log</h3>$hostnames";}
if($emailids ne "") { print STATISTICS "<h3>Top Email-ids in the log</h3>$emailids";}
if($ipadds ne "") { print STATISTICS "<h3>Top IP-Addresses in the log</h3>$ipadds";}
if($urlschemes ne "") { print STATISTICS "<h3>Top URL-Schemes in the log</h3>$urlschemes";}
if($urlports ne "") { print STATISTICS "<h3>Top URL-Ports in the log</h3>$urlports";}
if($queries ne "") { print STATISTICS "<h3>Top Queries in the log</h3>$queries";}

close(STATISTICS);

###############################################################################
#Sub-Functions...
###############################################################################

################################################
#Get statistics...
sub getstatistics
{
	my ($logids) = @_;
	my ($logid, @logs);
	my $averagetimediff =0;
	@logs = split(/ /,$logids);
	my $logcount = shift @logs;
	my $totaltimediff = 0;
	my $maxtimediff = 0;
	my $mintimediff = 0;
	
	#open logrecord.txt file instead of from the logrecord index....
	open (LOGRECORD,"<$dirname/logrecord.txt") or die "Cannot open $dirname/logrecord.txt file\n";
	$loglinecount = 1;
	foreach $logid (@logs)
	{
		#get the logline from logrecord.txt using logid.
		while($loglinecount <= $logid)
		{
			$loglinecount++;
			$logline = "";
			$logline = <LOGRECORD>;
			chomp($logline);
		}
		
		#get timediff of $logid
		@logwords = split(/\s+/,$logline);
		#@logwords = split(/\s+/,$logrecord{$logid});
		$timediff = $logwords[0];
		if($timediff > $maxtimediff)
		{
			$maxtimediff = $timediff;
		}
		if($timediff < $mintimediff)
		{
			$mintimediff = $timediff;
		}
		$totaltimediff += $timediff;
	}
	close(LOGRECORD);
	$averagetimediff = $totaltimediff/$logcount;
	return "$averagetimediff $maxtimediff $mintimediff";	
}


################################################
#Extract a pattern with a given logid...
sub extractpattern_with_logid
{
	my ($logid) = @_;
	my $pattern = "";
	my ($logno,$firstlogid,$firstlog,$logword,$splitcount,@logs,@logwords,@splitwords);

	@logs = split(/ /,$logid);
	$firstlogid = $logs[1];

	##Read the logfile to get the first logline...
	open (LOGRECORD,"<$dirname/logrecord.txt") or die "Cannot open $dirname/logrecord.txt file\n";
	$loglinecount = 0;
	while($term=<LOGRECORD>)
	{
		$loglinecount++;
		if($firstlogid == $loglinecount)
		{
			chomp($term);
			$firstlog = $term;
			last;
		}
	}
	close(LOGRECORD);

	#$firstlog = $logrecord{$firstlogid};

	#Remove the count infront of logid and get a newid...
	shift @logs;
	$newlogid = join(' ',@logs);

	#Remove entities from the log...
	$firstlog = &removeentities($firstlog);

	#Tokenize the logs...
	@logwords = split(/[\s\[\]\-\=\:\,\;\"\<\>\(\)]+/,$firstlog);
	#@logwords = grep /[^\s]+/,@logwords; #This is commented because, we have to get the actual splitter location...

	#Get the splitters in to an array...
	@splitwords = split(/[^\s\[\]\-\=\:\,\;\"\<\>\(\)]+/,$firstlog);
	my $splitcount = -1;
	my @splitword = ();
	my $nextsplitter = "";
	
	#Remove the first two words, since they are timediff and daysdiff...
	shift @logwords;
	shift @logwords;
	$splitcount++; $splitcount++;

	#Extract a pattern...
	$pattern = "";
	foreach $logword (@logwords)
	{
		$splitcount++;
		if($logword !~ /[\s]+/ )
		{
			$lclogword = lc($logword);
			if(!exists $record{$lclogword})
			{
				next;
			}
			#since logid contains logcount at the starting, remove it...
			if($newlogid eq $record{$lclogword} || &issubsequence($newlogid,$record{$lclogword}))
			{
				if($pattern ne "")
				{
					$pattern = $pattern." ".$logword;
					push @splitword, $splitwords[$splitcount];
					$nextsplitter = $splitwords[$splitcount+1];
					
				}
				else
				{
					$pattern = $logword;
				}
			}
			else
			{
				if($pattern ne "")
				{
					$pattern = $pattern." xxxxxxxx";
					push @splitword,$splitwords[$splitcount];
					$nextsplitter = $splitwords[$splitcount+1];
				}
			}
		}
	}
	push @splitword, $nextsplitter;#add the last element of the array...

	$pattern = &clean_xxxxx_at_end($pattern);
	#Construct real pattern...
	my @patterns = split(/ /,$pattern);
	my $realpattern = shift @patterns;
	#Add bold if the word represents entire pattern
	if($keyrecord{$logid} =~ m/(^|\s)$realpattern(\s|$)/i)
	{
		$realpattern = "<b><a href=\"LogSummarizer.cgi?q=$realpattern&btnG=Search\" >$realpattern</a></b>";
	}
	else
	{
		$realpattern = "<a href=\"LogSummarizer.cgi?q=$realpattern&btnG=Search\" >$realpattern</a>";
	}
	my ($pat);
	my $splitcnt = 0;
	foreach $pat (@patterns)
	{
		$realpattern .= $splitword[$splitcnt++];
		if($pat ne "xxxxxxxx")
		{
			#keep bold for words which represent pattern
			if($keyrecord{$logid} =~ m/(^|\s)$pat(\s|$)/i)
			{
				$pat="<b><a href=\"LogSummarizer.cgi?q=$pat&btnG=Search\" >$pat</a></b>";
			}
			else
			{
				$pat="<a href=\"LogSummarizer.cgi?q=$pat&btnG=Search\" >$pat</a>";

			}
		}
		$realpattern .= $pat;
	}
	#Few addings at the pattern to look good...
	$splitword[$splitcnt] =~ s/[\s\(\:\<]+//;
	if($#patterns < 1)
	{
		$splitword[$splitcnt] = "";
	}
	$realpattern .= $splitword[$splitcnt];
	return $realpattern;
}
################End of pattern extraction...

#Returns true if the given word is entity...
sub isentity
{
	my ($givenword) = @_;
	if($givenword =~ /^==.+=(urlend)?$/)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}


#Clean patterns at the end...
sub clean_xxxxx_at_end
{
	my($pattern) = @_;
	my ($patcount,@patwords);
	@patwords = split(/ /,$pattern);
	$patcount = @patwords;
	my $i;
	for($i=$patcount-1;$i>=0;$i--)
	{
		if($patwords[$i] ne "xxxxxxxx")
		{
			last;
		}
		else
		{
			pop @patwords;
		}
	}
	my $finalpattern = join(' ',@patwords);
	return $finalpattern;
}

#Remove entities from the word...
#Doesn't remove IPaddress and Email entities...
sub removeentities
{
	my ($log) = @_;
	#Remove the added entities and other unused entities...
	$log =~ s/==(time|date|pod|zonediff).+?=//g;
	$log =~ s/==m([0-1][0-9])[A-Za-z]{3,10}\.?=//g;  #Removes month identifications...
	$log =~ s/==w[1-7][A-Za-z]{3,9}\.?=//g; #Removes weekday identification...
	#Replace URLs for some understanding...
	$log =~ s/(==urlstart.+?=urlend)/___someurl___/g;
	return $log;
}

#Is one string a subsequence of other.
#Is word1 is subsequence of word2 or not...
sub issubsequence
{
	my ($word1,$word2) = @_;
	my @lognos1 = split(/ /,$word1);
	my @lognos2 = split(/ /,$word2);
	my $i = 0;
	my $log;
	my $logcount1 = @lognos1;
	my $logcount2 = @lognos2;
	my $j = 0;
	for($i = 0; $i < $logcount1; $i++ )
	{
		while($j < $logcount2 && $lognos2[$j] < $lognos1[$i])
		{
			$j++;
		}
		if($lognos2[$j] != $lognos1[$i])
		{
			return 0;
		}
	}
	return 1;
}

# Calculate difference in time...
# Uses global variables lasttime, lastdate...
sub datedifference
{
	my ($newlog) = @_;
	my $wordcount = 0;
	my $date = ""; 
	my $time = "";
	my $hours = "";
	my $minutes = "";
	my $seconds = "";
	my $epochtime = "";
	my $epochdate = "";
	my $timediff = 0;
	my $daysdiff = 0;
	
	#Assign a date difference between previous log and new log...
	#Get the date and time of the current log...
	@newwords = split(/\s+/,$newlog);
	foreach $newword (@newwords)
	{
		if($date eq "" && $newword =~ /(==date.+?=)/)
		{
			$date = $1;
		}
		if($time eq "" && $newword =~ /(==time.+?=)/)
		{
			$time = $1;
		}
		#if date and time is found after 5 words, it is not considered as log date...
		if($wordcount > 4)
		{
			last;
		}
		$wordcount++;
	}

	# If no time found, assign the last time...
	if($time eq "")
	{
		$epochtime = $lasttime;
		$epochdate = $lastdate;
	}
	else
	{
		#Get the current time...
		$time =~ s/\,//g;
		if($time =~ /==time([0-9:,]{5,15})=/)
		{
			my $a = $1;
			($hour,$minute,$seconds) = split(/:/,$a);
			my @seco = split(//,$seconds);
			$seconds = "$seco[0]$seco[1]";
		}
		#Write in current time in Epochtime...
		$hour =~ s/^([0])([0-9])$/$2/;
		$minute =~ s/^([0])([0-9])$/$2/;
		$seconds =~ s/^([0])([0-9])$/$2/;
		$epochtime = ($hour*3600)  + ($minute * 60) + $seconds;

		#If no date found in log record...
		if($date eq "")
		{
			# Handles the case where, the log starts...
			if($lasttime == 0 && $lastdate eq "")
			{
				$timediff  = 0;
			}
			else
			{
				#Calculate the time difference...
				$timediff = $epochtime - $lasttime;
			}
			$epochdate = $lastdate;
		}
		else
		{

			if($date =~ /==date([0-9\/]{5,10})=/)
			{
				my $b = $1;
				($year,$month,$day) = split(/\//,$b);
				$year =~ s/^([0])([0-9])$/$2/;
				$month =~ s/^([0])([0-9])$/$2/;
				$day =~ s/^([0])([0-9])$/$2/;
				if($year < 50)
				{
					$year = $year+2000;
				}
				#Comment this 'if' section, if 2050 is crossed...
				if($year <100 && $year >= 50)
				{
					$year = $year+1900;
				}
			}
			if($lastdate ne "")
			{
				($lastyear,$lastmonth,$lastday) = split(/\//,$lastdate);
				#Get the date difference with previous date...
				#$daysdiff = Delta_Days($lastyear,$lastmonth,$lastday,$year,$month,$day);
				my $dt1 = DateTime->new(year => $lastyear , month => $lastmonth , day => $lastday );
				my $dt2 = DateTime->new(year => $year , month => $month , day => $day );
				my $cmp = DateTime->compare($dt2, $dt1);
				my $dtdiff = $dt2->delta_days($dt1);
				$daysdiff = $dtdiff->delta_days;
				$daysdiff = $daysdiff*$cmp;

				#Get the time difference...
				$timediff = ($epochtime + $daysdiff * 24 * 3600) - $lasttime;
			}
			else
			{
				# Handles the case of log starting...
				if($lasttime == 0)
				{
					$timediff = 0;
				}
				else
				{
					$timediff = $epochtime - $lasttime;
				}
			}

			# If lastdate is empty, the daysdiff is 0, which is taken by default...
			$epochdate = "$year/$month/$day";
		}
	}

	#Assign the current date and time as lastdate and lasttime...
	$lasttime = $epochtime;
	$lastdate = $epochdate;

	#Save current timediff and daysdiff in record and return...
	return "$timediff $daysdiff ".$newlog;
}
