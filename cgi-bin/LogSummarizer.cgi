#!/usr/bin/perl
$query = $ENV{'QUERY_STRING'};
@queries = split(/&/,$query);
($q,$searchquery) = split(/=/,$queries[0]);

@querywords = split(/[\+]+/,$searchquery);
@querywords = grep /[^\s]+/,@querywords;
$nowords = @querywords;
$noresultsfound = 0;
#$defaultdirname="hadoop.log_data";

print "Content-type: text/html\n\n";

#Get the path of the record.txt...
open(CONFIG,"<CONFIG") or die "Cannot open CONFIG file\n";
$dir = <CONFIG>;
chomp($dir);
close(CONFIG);

if($nowords > 0)
{
	#Index the querywords...
	undef %qwords;
	undef %nqwords;
	$previousword = 0;
	foreach $temp (@querywords)
	{
		#Handles special characters in query...
		$temp =~ s/%([\dA-Fa-f]{2})/pack("C", hex($1))/eg;

		#Handles negative words...
		if($temp eq "-")
		{
			$previousword = 1;
			next;
		} 
		if($temp =~ /^\-.*/ || $previousword == 1)
		{
			$negativeword .= $temp;
			if($temp =~ /^\-?==.+(urlend)?=$/)
			{
				$temp =~ s/^\-(==.+)?=$/$1=/;
				$nqwords{lc($temp)} = "";
				$noofqwords++;
			}
			else
			{
				@ntempwords = split(/[\s\[\]\-\=\:\,\;\"\<\>\(\)]+/,$temp);
				foreach $ntempword(@ntempwords)
				{
					if($ntempword ne "")
					{
						$nqwords{lc($ntempword)} = "";
						$noofqwords++;
					}
				}
			}
		}
		else
		{
			#Non-negative words...
			if($temp =~ /^==.+=(urlend)?$/)
			{
				$qwords{lc($temp)} = "";
				$noofqwords++;
			}
			else
			{
				@tempwords = split(/[\s\[\]\-\=\:\,\;\"\<\>\(\)]+/,$temp);
				foreach $tempword (@tempwords)
				{
					if($tempword ne "")
					{
						$qwords{lc($tempword)} = "";
						$noofqwords++;
					}
				}
			}
		}
		$previousword = 0;
	}

	#Get the path of the record.txt...
	#open(CONFIG,"<CONFIG") or die "Cannot open CONFIG file\n";
	#$dir = <CONFIG>;
	#chomp($dir);
	#close(CONFIG);

	#Search the query in record file...
	$datadir = $dir."record.txt";
	open(DATADIR,"<$datadir") or die "Cannot open $datadir\n";
	$foundcount = 0;
	foreach $term(<DATADIR>)
	{
		chomp($term);
		($qterm,$qdocs) = split(/\t/,$term);
		if(exists $qwords{$qterm} )
		{
			$qwords{$qterm} = $qdocs;
			$foundcount++;
			if($foundcount >= $noofqwords)
			{
				last;#Ends when all the queries are over...
			}
		}
		if(exists $nqwords{$qterm})#For negative words...
		{
			$nqwords{$qterm} = $qdocs;
			$foundcount++;
			if($foundcount >= $noofqwords)
			{
				last;
			}
		}
	}
	close(DATADIR);
	
	#Get the doc-list for each query word in the array...
	$result = "";
	$doclists = "";
	foreach $queryword (keys %qwords)
	{
		if($qwords{$queryword} ne "")
		{
			#$result = $result.$queryword."===".$qwords{$queryword}."\n";
			if($doclists ne "")
			{
				$doclists = $doclists."\t".$qwords{$queryword};
			}
			else
			{
				$doclists = $qwords{$queryword};
			}
		}
		else
		{
			$noresultsfound = 1;
			last;
		}
	}

	#Negative words handling work...
	#Get the doc-list for each 'negative' query word in the array...
	$ndoclists = "";
	foreach $nqueryword (keys %nqwords)
	{
		if($nqwords{$nqueryword} ne "")
		{
			if($ndoclists ne "")
			{
				$ndoclists = $ndoclists."\t".$nqwords{$nqueryword};
			}
			else
			{
				$ndoclists = $nqwords{$nqueryword};
			}
		}
	}


	#Postive words handling work...
	if($noresultsfound == 1)
	{
		$result = "No Matches Found\n";
	}
	else
	{
		#If all the querywords are found in the index,get the common doclist of all the queries...
		$commondoclist = &getcommondoclist($doclists);

		#Removes the negative doclist from common doclist.
		if($commondoclist ne "" && $ndoclists ne "")
		{
			#Merge all the negative word doclists
			$ntotaldoclist = &gettotaldoclist($ndoclists);
			#Subtract negative words doclist from common doclist
			$commondoclist = &subtractlists($commondoclist,$ntotaldoclist);
		}

		if($commondoclist ne "")
		{
			#Got the common document list...
			#Calculate the statistics...
			#if($commondoclist ne "")
			#{

			$pattern = &extractpattern_with_logid($commondoclist);
			$statistics = "";
			$statistics = &getstatistics($commondoclist);
			$searchquery =~ s/%([\dA-Fa-f]{2})/pack("C", hex($1))/eg;
			$searchquery =~ s/\+/ /g;
			$result = "<h3>Results:</h3><b>Query:</b> $searchquery<br><b>Extracted Event:</b> $pattern<br><b>Event Statistics:</b><br>$statistics";
			
		}
		else
		{
			$noresultfound = 1;
			$result = "No Matches Found\n";
		}
	}
}
else
{
	$statsdir = $dir."statistics.txt";
	open(STATSDIR,"<$statsdir") or die "Cannot open $statsdir\n";
	$result = <STATSDIR>;
	close(STATSDIR);
}

print "<head>
       <title> Generic Log Summarizer</title>
</head>
<body>

<hr>
<h1> Generic Log Summarizer </h2>
<hr>

<p>

Welcome to the page of Generic Log Summarizer 
<p>";

#prints the form
print "<form name=logsum method=GET action=LogSummarizer.cgi><font size=-1><input type=text name=q size=45 maxlength=2048 title=\"Search\"> <input type=submit name=btnG value=\"Search\"></font></form>";

print "$result\n";

print "</body>";

#########################################
#####Sub-Functions.......................
#########################################
sub getcommondoclist
{
	my ($doclist) = @_;
	@doclists = split(/\t/,$doclist);
	#my $commonlist = "";
	$commonlist = shift @doclists;
	foreach $dlist (@doclists)
	{
		if($commonlist ne "" && $dlist ne "")
		{
			$commonlist = &get_greatest_common_subsequence($commonlist,$dlist);
		}
	}
	return $commonlist;
}

#Returns the common list of docs in two given doclists...
sub get_greatest_common_subsequence
{
	my ($word1,$word2) = @_;
	my @lognos1 = split(/ /,$word1);
	my @lognos2 = split(/ /,$word2);
	my $i = 0;
	my $log;
	my $logcount1 = @lognos1;
	my $logcount2 = @lognos2;
	my $j = 0;
	my $commondoclist = "";
	for($i = 0; $i < $logcount1; $i++ )
	{
		while($j < $logcount2 && $lognos2[$j] < $lognos1[$i])
		{
			$j++;
		}
		if($j < $logcount2 && $lognos2[$j] == $lognos1[$i])
		{
			if($commondoclist ne "")
			{
				$commondoclist = $commondoclist." ".$lognos1[$i];
			}
			else
			{
				$commondoclist = $lognos1[$i];
			}
		}
	}
	return $commondoclist;
}

#Adds all the doclists given to it
sub gettotaldoclist
{
	my ($doclist) = @_;
	@doclists = split(/\t/,$doclist);
	$totallist = shift @doclists;
	foreach $dlist (@doclists)
	{
		if($totallist ne "" && $dlist ne "")
		{
			$totallist = &merge_two_doclists($totallist,$dlist);
		}
	}
	return $totallist;
}
#Return the sum of two doclists.
sub merge_two_doclists
{
	my ($word1,$word2) = @_;
	my @lognos1 = split(/ /,$word1);
	my @lognos2 = split(/ /,$word2);
	my $commondoclist = shift @lognos1;
	my $logcount1 = @lognos1;
	my $logcount2 = @lognos2;
	my $j = 0;
	for($i = 0; $i < $logcount1; $i++)
	{
		while($j < $logcount2 && $lognos2[$j] < $lognos1[$i])
		{
			$commondoclist = $commondoclist." ".$lognos2[$j];
			$j++;
		}
		if($j < $logcount2 && $lognos2[$j] == $lognos1[$i])
		{
			$commondoclist = $commondoclist." ".$lognos2[$j];
			$j++;
			next;
		}
		$commondoclist = $commondoclist." ".$lognos1[$i];
	}
	while($j < $logcount2)
	{
		$commondoclist = $commondoclist." ".$lognos2[$j];
		$j++;
	}
	return $commondoclist;
}

#Given two lists subtracts one from the other.
sub subtractlists
{
	my ($word1,$word2) = @_;
	my @lognos1 = split(/ /,$word1);
	my @lognos2 = split(/ /,$word2);
	my $logcount1 = @lognos1;
	my $logcount2 = @lognos2;
	my $commondoclist = "";
	my $j = 0;
	for($i = 0; $i < $logcount1; $i++)
	{
		while($j < $logcount2 && $lognos2[$j] < $lognos1[$i])
		{
			$j++;
		}
		if($j < $logcount2 && $lognos2[$j] == $lognos1[$i])
		{
			$j++;
			next;
		}
		if($commondoclist ne "")
		{
			$commondoclist = $commondoclist." ".$lognos1[$i];
		}
		else
		{
			$commondoclist = $lognos1[$i];
		}
	}
	return $commondoclist;
}
################################################
#Extract a pattern with a given logid...
sub extractpattern_with_logid
{
	my ($logid) = @_;
	my $pattern = "";
	my ($logno,$firstlogid,$firstlog,$logword,$splitcount,@logs,@logwords,@splitwords);

	@logs = split(/ /,$logid);
	$firstlogid = $logs[0];

	#Read the logfile to get the data...
	$logfile = $dir."logrecord.txt";
	open(LOGRECORD,"<$logfile") or die "Cannot open $logfile\n";
	my $logcount = 0;
	while ($term=<LOGRECORD>)
	{
		$logcount++;
		if($firstlogid == $logcount)
		{
			chomp($term);
			$firstlog = $term;
			last;
		}
	}
	close(LOGRECORD);

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

	#Index the querywords...
	undef %logrecord;
	my $wcount = 0;
	foreach $temp (@logwords)
	{
		if($temp !~ /[\s]+/ )
		{
			$logrecord{lc($temp)} = "";
			$wcount++;
		}
	}

	#Search for words in record...
	open(DATADIR,"<$datadir") or die "Cannot open $datadir\n";
	my $foundcount = 0;
	foreach $term(<DATADIR>)
	{
		chomp($term);
		my ($qterm,$qdocs) = split(/\t/,$term);
		if(exists $logrecord{$qterm} )
		{
			$logrecord{$qterm} = $qdocs;
			$foundcount++;
			if($foundcount >= $wcount)
			{
				last;#Ends when all the queries are over...
			}
		}
	}
	close(DATADIR);

	#Extract a pattern...
	$pattern = "";
	foreach $logword (@logwords)
	{
		$splitcount++;
		if($logword !~ /[\s]+/ )
		{
			$lclogword = lc($logword);
			if(!exists $logrecord{$lclogword})
			{
				next;
			}
			#since logid contains logcount at the starting, remove it...
			if($logid eq $logrecord{$lclogword} || &issubsequence($logid,$logrecord{$lclogword}))
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
	$realpattern = "<a href=\"LogSummarizer.cgi?q=$realpattern&btnG=Search\" >$realpattern</a>";
	my ($pat);
	my $splitcnt = 0;
	foreach $pat (@patterns)
	{
		$realpattern .= $splitword[$splitcnt++];
		#Add anchor tag to the pattern...
		if($pat ne "xxxxxxxx")
		{
			$pat="<a href=\"LogSummarizer.cgi?q=$pat&btnG=Search\" >$pat</a>";
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

sub removeentities
{
	my ($log) = @_;
	#Remove the added entities and other unused entities...
	$log =~ s/==(time|date|pod|ipadd|zonediff|email).+?=//g;
	$log =~ s/==m([0-1][0-9])[A-Za-z]{3,10}\.?=//g;  #Removes month identifications...
	$log =~ s/==w[1-7][A-Za-z]{3,9}\.?=//g; #Removes weekday identification...
	#Replace URLs for some understanding...
	$log =~ s/(==urlstart.+?=urlend)/___someurl___/g;
	return $log;
}

#################
#GetStatistics...
sub getstatistics
{
	my ($logids) = @_;
	my ($logid, @logs);
	my $averagetimediff =0;
	@logs = split(/ /,$logids);
	my $count = @logs;
	my $totaltimediff = 0;
	my $maxtimediff = 0;
	my $mintimediff = 0;
	my $examplelog = "<br><b>Log Entries:</b>";

	#Read the logfile to get the data...
	$logfile = $dir."logrecord.txt";
	open(LOGRECORD,"<$logfile") or die "Cannot open $logfile\n";
	my $logcount = 0;
	foreach $logid (@logs)
	{
		while($logcount < $logid)
		{
			$logcount++;
			$entirelog = <LOGRECORD>;
		}
		chomp($entirelog);

		#To get the totaltimediff, maximumtimediff and minimumtimediff...
		@logwords = split(/\s+/,$entirelog);
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

		#To get the example logs...
		 #remove first few parts of the logrecord...
		$entirelog =~ s/^[0-9\-]+ [0-9\-]+(.*)$/$1/g;
		$entirelog = &removeentitymarks($entirelog);
		$examplelog .= "<br>$entirelog";

	}
        close(LOGRECORD);
	$averagetimediff = $totaltimediff/$count;
	$avgtimediff = $averagetimediff;
	$avgtimediff =~ s/(.*)\.([0-9]{4})(.*)/$1\.$2/g;
	my $stats = "Total Number of times this Event occurred: $count<br>Average time taken by this Event: $avgtimediff Seconds<br>Maximum time taken by this Event: $maxtimediff Seconds<br>Minimum time taken by this Event: $mintimediff Seconds";
	return $stats.$examplelog;
}


#######################################
## Remove entitymarks in a logrecord...
#######################################
sub removeentitymarks
{
	my $word = $_[0];
	my $wordext;
	my $urlcount;
	my $tt;
	#@duentities = ($word =~ m/(==urlstart.+?=urlend)/g);
	$wordext = $word;
	$urlcount = 0;
	my $url;
	#Removing URL entitiy marks...
	while($word =~ m/(==urlstart.+?=urlend)/g)
	{
		
		$wordext =~ s/(==urlstart.+?=urlend)/{{{url$urlcount}}}/;
		$tt = $1;
		$url = "";
		$tt =~ m/==urlstart(.+)==scheme(.*)==host(.*)==path(.*)==params(.*)==query(.*)==frag(.*)==port(.*)=urlend/;
		$url = $1;
		$wordext =~ s/\{\{\{url$urlcount\}\}\}/$url/g;
		$urlcount++;
	}
	#$word = $wordext;

	#my $url;
	#while($word =~ /\{\{\{url([0-9]+)\}\}\}/g)
	#{
	#	$tt = $1;
	#	$url = "";
	#	$duentities[$tt] =~ m/==urlstart(.+)==scheme(.*)==host(.*)==path(.*)==params(.*)==query(.*)==frag(.*)==port(.*)=urlend/;
	#	$url = $1;
	#	$wordext
	#}

	#Remove IPAddress Tags, Date and Time tags...
	$tagcount = 0;
	while($word =~ m/(==(date|time|ipadd|zonediff|email).+?=)/g)
	{
		$wordext =~ s/(==(date|time|ipadd|zonediff|email).+?=)/{{{tag$tagcount}}}/;
		$tt = $1;
		$tag = "";
		$tt =~ m/==(date|time|ipadd|zonediff|email)(.+)=/;
		$tag = $2;
		$wordext =~ s/\{\{\{tag$tagcount\}\}\}/$tag/g;
		$tagcount++;
	}
	$word = $wordext;	
	return($word);
}
