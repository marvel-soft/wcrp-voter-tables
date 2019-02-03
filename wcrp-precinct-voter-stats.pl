#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# wcrp-precinct-voter-stats
#
#
#
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#use strict;
use warnings;
$| = 1;
use File::Basename;
use DBI;
use Data::Dumper;
use Getopt::Long qw(GetOptions);
use Time::Piece;

=head1 Function
=over
=head2 Overview
	This program will analyze a washoe-county-voter file
		a) file is sorted by precinct ascending
		b)
	Input: county voter registration file.
	       
	Output: a csv file containing the extracted fields 
=cut

my $records;

#my $inputFile = "../test-in/2019 1st Free List 1.7.19.csv";    
#my $inputFile = "../test-in/2019 1st Free List 5pre.csv";    
#my $inputFile = "../test-in/2018 4th Free-NO DEMS-1100.csv";    
my $inputFile = "../test-in/2018 4th Free-NO DEMS-100.csv";    

#my $inputFile = "../test-in/2018 4th Free List Sample.csv";    

#my $inputFile = "../test-in/voter-leans-test.csv";    #
#my $inputFile = "../test-in/2018-3rd Free List.csv";#
#my $inputFile = "../test-in/2012 Voter List 10-4-12.csv";
#my $inputFile = "../test-in/2016 Voter List 9.27.16.csv";
#my $inputFile = "../test-in/2018-2nd-Free-500-PARTIES.csv";

my $adPoliticalFile = "../test-in/adall-precincts-jul.csv";

my $fileName       = "";
my $outputFile     = "precinct-voters-.csv";
my $precinctFile   = "precinct-stats-.csv";
my $precinctFileh;
my $printFile      = "precinct-print-.txt";
my $printFileh;

my @adPoliticalHash = ();
my %adPoliticalHash;
my $adPoliticalHeadings = "";
my $helpReq            = 0;
my $maxLines           = "300000";
my $voteCycle          = "";
my $fileCount          = 1;
my $csvHeadings        = "";
my @csvHeadings;
my $i;
my $line1Read    = '';
my $line2Read    = '';
my $linesRead    = 0;
my $printData;
my $linesWritten = 0;
my %newLine      = ();
my $generalCount;
my $party;
my $primaryCount;
my $pollCount;
my $precinctPolitical;
my @precinctPolitical;
my $absenteeCount   = 0;
my $leansRepCount   = 0;
my $leansDemCount   = 0;
my $leanRep         = 0;
my $leanDem         = 0;
my $leans           = "";
my $activeVOTERS    = 0;
my $activeREP       = 0;
my $activeDEM       = 0;
my $activeOTHR      = 0;
my $totalVOTERS     = 0;
my $totalAMER       = 0;
my $totalAMEL       = 0;
my $totalDEM        = 0;
my $totalDUO        = 0;
my $totalFED        = 0;
my $totalGRN        = 0;
my $totalIA         = 0;
my $totalIAP        = 0;
my $totalIND        = 0;
my $totalINAC       = 0;
my $totalLIB        = 0;
my $totalLPN        = 0;
my $totalNL         = 0;
my $totalNP         = 0;
my $totalORGL       = 0;
my $totalOTH        = 0;
my $totalPF         = 0;
my $totalPOP        = 0;
my $totalREP        = 0;
my $totalRFM        = 0;
my $totalSOC        = 0;
my $totalTEANV      = 0;
my $totalUWS        = 0;
my $totalGENERALS   = 0;
my $totalPRIMARIES  = 0;
my $totalPOLLS      = 0;
my $totalABSENTEE   = 0;
my $totalSTRDEM     = 0;
my $totalMODDEM     = 0;
my $totalWEAKDEM    = 0;
my $percentSTRGRDEM = 0;
my $totalSTRREP     = 0;
my $totalMODREP     = 0;
my $totalWEAKREP    = 0;
my $percentSTRGREP  = 0;
my $totalSTROTHR    = 0;
my $totalMODOTHR    = 0;
my $totalWEAKOTHR   = 0;
my $percentSTRGOTHR = 0;
my $totalOTHR       = 0;
my $totalLEANREP    = 0;
my $totalLEANDEM    = 0;

#my $csvRowHash;
my @csvRowHash;
my %csvRowHash = ();
my @partyHash;
my %partyHash  = ();
my %schRowHash = ();
my @schRowHash;
my @values1;
my @values2;
my @date;
my $voterRank;
my @voterProfile;
my $voterHeading = "";
my @voterHeading = (
	"Precinct",        "Voter ID",
	"Voter Status",    "Last Name",
	"Sfx",             "First",
	"Middle",          "Birthdate",
	"Registerdate",    "RegisterDateOrig",
	"Address",         "Zip",
	"Phone",           "Party",
	"Gender",          "Military",
	"Days Registered", "Generals",
	"Primaries",       "Polls",
	"Absentee",        "LeansDEM",
	"LeansREP",        "Leans",
	"Rank"
);
my $precinct = "000000";
my @precinctSummary;
my $precinctsWritten = 0;
my $precinctHeading  = "";
my @precinctHeading  = (
	"PRECINCT", "SENATE",
	"ASSEMBLY", "BOARDOFEDU",
	"REGENTS",  "COMMISSION",
	"RWARDS",   "SWARDS",
	"SCHBOARD", "SCHBRDATLRG",
	"GID",      "TOWNSHIP",
	"MP",       "FPD",
	"AMER",     "AMEL",
	"DUO",      "FED",
	"GRN",      "IA",
	"IAP",      "IND",
	"IN AC",    "LIB",
	"LPN",      "NL",
	"NP",       "ORG L",
	"OTH",      "PF",
	"POP",      "RFM",
	"SOC",      "TEANV",
	"UWS",
	"GENERALS",  "PRIMARIES",
	"POLLS",     "ABSENTEE",
	"REG-VOTER", "ACT-VOTER",

	#"MALES",     "FEMALES",
	"REG-DEM",  "ACT-DEM",  "%DEM",
	"REG-REP",  "ACT-REP",  "%REP",
	"REG-OTHR", "ACT-OTHR", "%OTHR",
	"LEAN-DEM", "LEAN-REP",
	"STR-DEM",  "MOD-DEM",  "WEAK-DEM",
	"STR-REP",  "MOD-REP",  "WEAK-REP",
	"STR-OTHR", "MOD-OTHR", "WEAK-OTHR"
);
my @newLine;

#my %newLine;
my $newLine;
my @precinctLine;
my %precinctLine;
my $precinctLine;

#
# main program controller
#
sub main {
	#Open file for messages and errors
	$fileName = basename( $inputFile, ".csv" );
	$printFile = "precinct-print-" . $fileName . ".txt";
	open( $printFileh, ">$printFile" )
	  or die "Unable to open PRINT: $printFile Reason: $!";

	# Parse any parameters
	GetOptions(
		'infile=s'  => \$inputFile,
		'outile=s'  => \$outputFile,
		'lines=s'   => \$maxLines,
		'votecycle' => \$voteCycle,
		'help!'     => \$helpReq,
	) or die "Incorrect usage!\n";
	if ($helpReq) {
		print "Come on, it's really not that hard.\n";
	}
	else {
		printLine ("My inputfile is: $inputFile.\n");
	}
	unless ( open( INPUT, $inputFile ) ) {
		die "Unable to open INPUT: $inputFile Reason: $!\n";
	}

	# pick out the heading line and hold it and remove end character
	$csvHeadings = <INPUT>;
	chomp $csvHeadings;
	chop $csvHeadings;

	# headings in an array to modify
	# @csvHeadings will be used to create the files
	@csvHeadings = split( /\s*,\s*/, $csvHeadings );

	# Build heading for new voter record
	$voterHeading = join( ",", @voterHeading );
	$voterHeading = $voterHeading . "\n";

	# Build heading for new precinct record
	$precinctHeading = join( ",", @precinctHeading );
	$precinctHeading = $precinctHeading . "\n";
	#
	# Initialize process loop
	$fileName = basename( $inputFile, ".csv" );
	$outputFile = "precinct-voters-" . $fileName . ".csv";
	printLine ("Voter Profile file: $outputFile\n");
	open( OUTPUT, ">$outputFile" )
	  or die "Unable to open OUTPUT: $outputFile Reason: $!";
	print OUTPUT $voterHeading;

	# initialize the precinct-all table
	adPoliticalAll(@adPoliticalHash);

	#build name for precinct stats file
	$fileName = basename( $inputFile, ".csv" );
	$precinctFile = "precinct-stats-" . $fileName . ".csv";
	printLine ("Precinct Summary file: $precinctFile\n");
	open( $precinctFileh, ">>$precinctFile" )
	  or die "Unable to open OUTPUT: $precinctFile Reason: $!";
	print $precinctFileh $precinctHeading;
	$i = 0;
	close $precinctFileh;

	# Process loop
	# Read the entire input and
	# 1) edit the input lines
	# 2) transform the data
	# 3) write out transformed line
  NEW:
	while ( $line1Read = <INPUT> ) {
		$linesRead++;
		#
		# Get the data into an array that matches the headers array
		chomp $line1Read;

		# replace commas from in between double quotes with a space
		$line1Read =~ s/(?:\G(?!\A)|[^"]*")[^",]*\K(?:,|"(*SKIP)(*FAIL))/ /g;

		# then create the values array
		@values1 = split( /\s*,\s*/, $line1Read, -1 );

		# Create hash of line for transformation
		@csvRowHash{@csvHeadings} = @values1;

		# determine in precinctSummary needs writing
		if ( $precinct eq "000000" ) {
			$precinct = substr $csvRowHash{"precinct"}, 0, 4 . "00";
		}
		elsif ( $csvRowHash{"precinct"} != $precinct ) {

			# write new precinctSummary
			print "At line: $linesRead - Precinct Summary for: $precinct\n";

			# Create Precinct Summary
			precinctSummary();
			$precinct = substr $csvRowHash{"precinct"}, 0, 4 . "00";
		}

		# Assemble Basic New Voter Line
		%newLine = ();
		$newLine{"Precinct"}     = substr $csvRowHash{"precinct"}, 0, 6;
		$newLine{"Voter Status"} = $csvRowHash{"status"};
		$newLine{"Voter ID"}     = $csvRowHash{"voter_id"};
		$newLine{"Last Name"}    = $csvRowHash{"name_last"};
		$newLine{"Sfx"}          = $csvRowHash{"name_suffix"};
		$newLine{"First"}        = $csvRowHash{"name_first"};
		$newLine{"Middle"}       = $csvRowHash{"name_middle"};
		$newLine{"Gender"}       = "";
		if ( $csvRowHash{"gender"} eq 'M' ) {
			$newLine{"Gender"} = "Male";
		}
		if ( $csvRowHash{"gender"} eq 'F' ) {
			$newLine{"Gender"} = "Female";
		}
		$newLine{"Military"} = "";
		if ( $csvRowHash{"military"} eq 'Y' ) {
			$newLine{"Military"} = "Y";
		}
		$newLine{"Party"} = $csvRowHash{"party"};
		countParty();
		$newLine{"Phone"} = $csvRowHash{"phone_1"};
		@date = split( /\s*\/\s*/, $csvRowHash{"birth_date"}, -1 );
		my $mm = sprintf( "%02d", $date[0] );
		my $dd = sprintf( "%02d", $date[1] );
		my $yy = sprintf( "%02d", $date[2] );
		$newLine{"Birthdate"} = "$mm/$dd/$yy";
		@date = split( /\s*\/\s*/, $csvRowHash{"reg_date"}, -1 );
		$mm = sprintf( "%02d", $date[0] );
		$dd = sprintf( "%02d", $date[1] );
		$yy = sprintf( "%02d", $date[2] );
		$newLine{"Registerdate"} = "$mm/$dd/$yy";

		# then the originl registration and days total
		@date = split( /\s*\/\s*/, $csvRowHash{"reg_date_original"}, -1 );
		$mm = sprintf( "%02d", $date[0] );
		$dd = sprintf( "%02d", $date[1] );
		$yy = sprintf( "%02d", $date[2] );
		$newLine{"RegisterDateOrig"} = "$mm/$dd/$yy";
		my $before =
		  Time::Piece->strptime( $newLine{"RegisterDateOrig"}, "%m/%d/%y" );
		my $now            = localtime;
		my $daysRegistered = $now - $before;
		$daysRegistered = ( $daysRegistered / ( 1440 * 24 ) );
		$newLine{"Days Registered"} = int($daysRegistered);

		# Assemble Street Address
		$newLine{"Address"} = join( ' ',
			$csvRowHash{house_number},
			$csvRowHash{street}, $csvRowHash{type} );
		$newLine{"Zip"} = $csvRowHash{zip};
		evaluateVoter();
		$newLine{"Primaries"} = $primaryCount;
		$newLine{"Generals"}  = $generalCount;
		$newLine{"Polls"}     = $pollCount;
		$newLine{"Absentee"}  = $absenteeCount;
		$newLine{"LeansREP"}  = $leansRepCount;
		$newLine{"LeansDEM"}  = $leansDemCount;
		$newLine{"LeanREP"}   = $leanRep;
		$newLine{"LeanDEM"}   = $leanDem;
		if ($leanDem) {
			$leans = "DEM";
		}
		if ($leanRep) {
			$leans = "REP";
		}
		$newLine{"Leans"} = $leans;
		$leans            = "";
		$newLine{"Rank"}  = $voterRank;

		# Line processed- write it and go on....
		$i++;
		@voterProfile = ();
		foreach (@voterHeading) {
			push( @voterProfile, $newLine{$_} );
		}
		print OUTPUT join( ',', @voterProfile ), "\n";
		$linesWritten++;
		#
		# For now this is the in-elegant way I detect completion
		if ( eof(INPUT) ) {
			goto EXIT;
		}
		next;
	}
	#
	goto NEW;
}
#
# call main program controller
main();
#
# Common Exit
EXIT:

# write FINAL precinctSummary
precinctSummary();


printLine ("<===> Completed conversion of: $inputFile \n");
printLine ("<===> Output available in file: $outputFile \n");
printLine ("<===> Total Records Read: $linesRead \n");
printLine ("<===> Total Records written: $linesWritten \n");
printLine ("<===> Total Preincts written: $precinctsWritten \n");

close(INPUT);
close(OUTPUT);
close($precinctFile);
close($precinctFileh);
close($printFileh);
exit;

#
# Print report line
#
sub printLine  {
	($printData) = @_;
	print $printFileh $printData;
	print $printData;
}


# routine: evaluateVoter
# determine if reliable voter by voting pattern over last five cycles
# tossed out special elections and mock elections
#  voter reg_date is considered
#  weights: strong, moderate, weak
# if registered < 2 years       gen >= 1 and pri <= 0   = STRONG
# if registered > 2 < 4 years   gen >= 1 and pri >= 0   = STRONG
# if registered > 4 < 8 years   gen >= 4 and pri >= 0   = STRONG
# if registered > 8 years       gen >= 6 and pri >= 0   = STRONG
sub evaluateVoter {
	my $generalPollCount     = 0;
	my $generalAbsenteeCount = 0;
	my $generalNotVote       = 0;
	my $notElegible          = 0;
	my $primaryPollCount     = 0;
	my $primaryAbsenteeCount = 0;
	my $primaryNotVote       = 0;
	$leansRepCount = 0;
	$leansDemCount = 0;
	$leanRep       = 0;
	$leanDem       = 0;
	$generalCount  = 0;
	$primaryCount  = 0;
	$pollCount     = 0;
	$absenteeCount = 0;
	$voterRank     = '';

	#set first vote in list
	my $vote = 55;
	my $cyc;
	my $daysRegistered = $newLine{"Days Registered"};
	for ( my $cycle = 1 ; $cycle < 20 ; $cycle++, $vote += 1 ) {
		$cyc = $cycle;

		#skip mock election
		my $h1 = $csvHeadings[$vote];
		if ( ( $csvHeadings[$vote] ) =~ m/mock/ ) {
			next;
		}

		#skip special election
		if ( ( $csvHeadings[$vote] ) =~ m/special/ ) {
			next;
		}

		#skip sparks election
		if ( ( $csvHeadings[$vote] ) =~ m/sparks/ ) {
			next;
		}
		if ( ( $csvHeadings[$vote] ) =~ m/general/ ) {
			if ( $csvRowHash{ $csvHeadings[$vote] } eq '' ) {
				$notElegible += 1;
				next;
			}
			if ( $csvRowHash{ $csvHeadings[$vote] } eq ' ' ) {
				$notElegible += 1;
				next;
			}
			if ( $csvRowHash{ $csvHeadings[$vote] } eq 'N' ) {
				$generalNotVote += 1;
				next;
			}
			if ( $csvRowHash{ $csvHeadings[$vote] } eq 'V' ) {
				$generalPollCount += 1;
				$generalCount     += 1;
				$pollCount        += 1;
				next;
			}
			if ( $csvRowHash{ $csvHeadings[$vote] } eq 'A' ) {
				$generalAbsenteeCount += 1;
				$generalCount         += 1;
				$absenteeCount        += 1;
				next;
			}
		}
		if ( ( $csvHeadings[$vote] ) =~ m/primary/ ) {
			if ( $csvRowHash{ $csvHeadings[$vote] } eq '' ) {
				$notElegible += 1;
				next;
			}
			if ( $csvRowHash{ $csvHeadings[$vote] } eq ' ' ) {
				$notElegible += 1;
				next;
			}
			if ( $csvRowHash{ $csvHeadings[$vote] } eq 'N' ) {
				$primaryNotVote += 1;
				next;
			}
			if ( $csvRowHash{ $csvHeadings[$vote] } =~ /V\([A-Z]*\)/ ) {
				$primaryPollCount += 1;
				$primaryCount     += 1;
				$pollCount        += 1;
				if ( $party ne "DEM" and $party ne "REP" ) {
					if ( $csvRowHash{ $csvHeadings[$vote] } eq 'V(REP)' ) {
						$leansRepCount += 1;
					}
					if ( $csvRowHash{ $csvHeadings[$vote] } eq 'V(DEM)' ) {
						$leansDemCount += 1;
					}
				}
				next;
			}
			if ( $csvRowHash{ $csvHeadings[$vote] } =~ /A\([A-Z]*\)/ ) {
				$primaryAbsenteeCount += 1;
				$primaryCount         += 1;
				$absenteeCount        += 1;
				if ( $party ne "DEM" and $party ne "REP" ) {
					if ( $csvRowHash{ $csvHeadings[$vote] } eq 'A(REP)' ) {
						$leansRepCount += 1;
					}
					if ( $csvRowHash{ $csvHeadings[$vote] } eq 'A(DEM)' ) {
						$leansDemCount += 1;
					}
				}
				next;
			}
		}
	}

  # Likely voter score:
   # if registered < 2 years       gen <= 1 || notelig >= 1            = WEAK
   # if registered < 2 years       gen == 1 ||                         = MODERATE
   # if registered < 2 years       gen == 2 ||                         = STRONG

   # if registered > 2 < 4 years   gen <= 0 || notelig >= 1            = WEAK
   # if registered > 2 < 4 years   gen >= 2 && pri >= 0                = MODERATE
   # if registered > 2 < 4 years   gen >= 3 && pri >= 1                = STRONG

   # if registered > 4 < 8 years   gen >= 0 || notelig >= 1            = WEAK
   # if registered > 4 < 8 years   gen >= 0 && gen <= 2  and pri == 0  = WEAK
   # if registered > 4 < 8 years   gen >= 2 && gen <= 5  and pri >= 0  = MODERATE
   # if registered > 4 < 8 years   gen >= 3 && gen <= 12 and pri >= 0  = STRONG

   # if registered > 8 years   gen >= 0 && gen <= 2 || notelig >= 1    = WEAK
   # if registered > 8 years   gen >= 0 && gen <= 4  and pri == 0      = WEAK
   # if registered > 8 years   gen >= 3 && gen <= 9  and pri >= 0      = MODERATE
   # if registered > 8 years   gen >= 6 && gen <= 12 and pri >= 0      = STRONG

	if ( $daysRegistered < ( 365 * 2 + 1 ) ) {
		if ( $generalCount <= 1 or $notElegible >= 1 ) {
			$voterRank = "WEAK";
		}
		if ( $generalCount >= 1 ) {
			$voterRank = "MODERATE";
		}
		if ( $generalCount >= 2 ) {
			$voterRank = "STRONG";
		}
	}

	# if registered > 2 years and < 4 years>
	if ( $daysRegistered > ( 365 * 2 ) and $daysRegistered < ( 365 * 4 ) ) {
		if ( $generalCount == 0 or $notElegible >= 1 ) {
			$voterRank = "WEAK";
		}
		if ( $generalCount >= 2 ) {
			$voterRank = "MODERATE";
		}
		if ( $generalCount >= 3 and $primaryCount >= 1 ) {
			$voterRank = "STRONG";
		}
	}

	# if registered > 4 < 8 years   gen gt 4 && pri gt 3   = STRONG
	if ( $daysRegistered > ( 365 * 4 ) and $daysRegistered < ( 365 * 8 ) ) {
		if ( $generalCount >= 0 or $notElegible >= 1 ) {
			$voterRank = "WEAK";
		}
		if ( $generalCount >= 1 and $generalCount <= 2 and $primaryCount = 0 ) {
			$voterRank = "WEAK";
		}
		if ( $generalCount >= 2 and $generalCount <= 5 and $primaryCount >= 0 )
		{
			$voterRank = "MODERATE";
		}
		if ( $generalCount >= 3 and $generalCount <= 12 and $primaryCount >= 0 )
		{
			$voterRank = "STRONG";
		}
	}

	# if registered > 8 years       gen gt 6 && pri gt 4   = STRONG
	if ( $daysRegistered > ( 365 * 8 ) ) {
		if ( $generalCount >= 0 and $generalCount <= 2 or $notElegible >= 1 ) {
			$voterRank = "WEAK";
		}
		if ( $generalCount >= 0 and $generalCount <= 4 and $primaryCount >= 0 )
		{
			$voterRank = "WEAK";
		}
		if (    $generalCount >= 3
			and $generalCount <= 9
			and $primaryCount >= 0 )
		{
			$voterRank = "MODERATE";
		}
		if ( $generalCount >= 6 and $generalCount <= 12 and $primaryCount >= 0 )
		{
			$voterRank = "STRONG";
		}
	}
	#
	# Set voter strength rating
	#
	if ( $party eq 'DEM' ) {
		if    ( $voterRank eq 'STRONG' )   { $totalSTRDEM++; }
		elsif ( $voterRank eq 'MODERATE' ) { $totalMODDEM++; }
		elsif ( $voterRank eq 'WEAK' )     { $totalWEAKDEM++; }
	}

	elsif ( $party eq 'REP' ) {
		if    ( $voterRank eq 'STRONG' )   { $totalSTRREP++; }
		elsif ( $voterRank eq 'MODERATE' ) { $totalMODREP++; }
		elsif ( $voterRank eq 'WEAK' )     { $totalWEAKREP++; }

	}
	else {
		if    ( $voterRank eq 'STRONG' )   { $totalSTROTHR++; }
		elsif ( $voterRank eq 'MODERATE' ) { $totalMODOTHR++; }
		elsif ( $voterRank eq 'WEAK' )     { $totalWEAKOTHR++; }
	}

	if ( $primaryCount != 0 ) {
		if ( $leansDemCount != 0 ) {
			if ( $leansDemCount / $primaryCount > .5 ) {
				$leanDem = 1;
			}
		}
		if ( $leansRepCount != 0 ) {
			if ( $leansRepCount / $primaryCount > .5 ) {
				$leanRep = 1;
			}
		}
	}
	$totalGENERALS  = $totalGENERALS + $generalCount;
	$totalPRIMARIES = $totalPRIMARIES + $primaryCount;
	$totalPOLLS     = $totalPOLLS + $pollCount;
	$totalABSENTEE  = $totalABSENTEE + $absenteeCount;
	$totalLEANREP   = $totalLEANREP + $leanRep;
	$totalLEANDEM   = $totalLEANDEM + $leanDem;
}

# create and write precinct Summary
#	"PRECINCT", "DEM","REP","AMER","AMEL","DUO","FED","GRN", "IAP",
#   "INAP","IND", "LPN","NL","NP","ORGL","OTH","POP","RFM","SOC","UWS",
#   "GENERALS", "PRIMARIES", "POLLS", "ABSENTEE",
#	"STRONG",   "MODERATE", "WEAK"
sub precinctSummary {
	@precinctSummary = ();
	@precinctPolitical = $adPoliticalHash{$precinct};
	open( $precinctFileh, ">>$precinctFile" )
	  or die "Unable to open OUTPUT: $precinctFile Reason: $!";
	$precinctLine{"PRECINCT"}    = $precinct;
	$precinctLine{"SENATE"}      = $precinctPolitical[0][1];
	$precinctLine{"ASSEMBLY"}    = $precinctPolitical[0][2];
	$precinctLine{"BOARDOFEDU"}  = $precinctPolitical[0][3];
	$precinctLine{"REGENTS"}     = $precinctPolitical[0][4];
	$precinctLine{"COMMISSION"}  = $precinctPolitical[0][5];
	$precinctLine{"RWARDS"}      = $precinctPolitical[0][6];
	$precinctLine{"SWARDS"}      = $precinctPolitical[0][7];
	$precinctLine{"SCHBOARD"}    = $precinctPolitical[0][8];
	$precinctLine{"SCHBRDATLRG"} = $precinctPolitical[0][9];
	$precinctLine{"GID"}         = $precinctPolitical[0][10];
	$precinctLine{"TOWNSHIP"}    = $precinctPolitical[0][10];
	$precinctLine{"MP"}          = $precinctPolitical[0][11];
	$precinctLine{"FPD"}         = $precinctPolitical[0][12];
	$precinctLine{"REG-VOTER"}   = $totalVOTERS;
	$precinctLine{"ACT-VOTER"}   = $activeVOTERS;
	$precinctLine{"AMER"}        = $totalAMER;
	$precinctLine{"AMEL"}        = $totalAMEL;
	$precinctLine{"DEM"}         = $totalDEM;
	$precinctLine{"DUO"}         = $totalDUO;
	$precinctLine{"FED"}         = $totalFED;
	$precinctLine{"GRN"}         = $totalGRN;
	$precinctLine{"IA"}          = $totalIA;
	$precinctLine{"IAP"}         = $totalIAP;
	$precinctLine{"IND"}         = $totalIND;
	$precinctLine{"IN AC"}       = $totalINAC;
	$precinctLine{"LIB"}         = $totalLIB;
	$precinctLine{"LPN"}         = $totalLPN;
	$precinctLine{"NL"}          = $totalNL;
	$precinctLine{"NP"}          = $totalNP;
	$precinctLine{"ORG L"}       = $totalORGL;
	$precinctLine{"OTH"}         = $totalOTH;
	$precinctLine{"PF"}          = $totalPF;
	$precinctLine{"POP"}         = $totalPOP;
	$precinctLine{"RFM"}         = $totalRFM;
	$precinctLine{"REP"}         = $totalREP;
	$precinctLine{"SOC"}         = $totalSOC;
	$precinctLine{"TEANV"}       = $totalTEANV;
	$precinctLine{"UWS"}         = $totalUWS;
	$totalOTHR =
	  $totalAMER +
	  $totalAMEL +
	  $totalDUO +
	  $totalFED +
	  $totalGRN +
	  $totalIA +
	  $totalIAP +
	  $totalINAC +
	  $totalIND +
	  $totalLIB +
	  $totalLPN +
	  $totalNL +
	  $totalNP +
	  $totalORGL +
	  $totalOTH +
	  $totalPF +
	  $totalPOP +
	  $totalRFM +
	  $totalSOC +
	  $totalTEANV +
	  $totalUWS;
	$precinctLine{"OTHR"}      = $totalOTHR;
	$precinctLine{"GENERALS"}  = $totalGENERALS;
	$precinctLine{"PRIMARIES"} = $totalPRIMARIES;
	$precinctLine{"POLLS"}     = $totalPOLLS;
	$precinctLine{"ABSENTEE"}  = $totalABSENTEE;
	$precinctLine{"STR-DEM"}   = $totalSTRDEM;
	$precinctLine{"MOD-DEM"}   = $totalMODDEM;
	$precinctLine{"WEAK-DEM"}  = $totalWEAKDEM;
	$precinctLine{"REG-DEM"}   = $totalDEM;
	$precinctLine{"ACT-DEM"}   = $activeDEM;

	if ( $totalDEM != 0 ) {
		$precinctLine{"%DEM"} =
		  sprintf( "%.2f", ( ($totalDEM) / $totalVOTERS * 100 ) ) . "%";
	}
	$precinctLine{"STR-REP"}  = $totalSTRREP;
	$precinctLine{"MOD-REP"}  = $totalMODREP;
	$precinctLine{"WEAK-REP"} = $totalWEAKREP;
	$precinctLine{"REG-REP"}  = $totalREP;
	$precinctLine{"ACT-REP"}  = $activeREP;
	if ( $totalREP != 0 ) {
		$precinctLine{"%REP"} =
		  sprintf( "%.2f", ( ($totalREP) / $totalVOTERS * 100 ) ) . "%";
	}
	$precinctLine{"STR-OTHR"}   = $totalSTROTHR;
	$precinctLine{"MOD-OTHR"}   = $totalMODOTHR;
	$precinctLine{"WEAK-OTHR"}  = $totalWEAKOTHR;
	$precinctLine{"%STRG-OTHR"} = 0;
	$precinctLine{"REG-OTHR"}   = $totalOTHR;
	$precinctLine{"ACT-OTHR"}   = $activeOTHR;
	if ( $totalOTHR != 0 ) {
		$precinctLine{"%OTHR"} =
		  sprintf( "%.2f", ( ($totalOTHR) / $totalVOTERS * 100 ) ) . "%";
	}
	$precinctLine{"LEAN-REP"} = $totalLEANREP;
	$precinctLine{"LEAN-DEM"} = $totalLEANDEM;
	foreach (@precinctHeading) {
		push( @precinctSummary, $precinctLine{$_} );
	}
	print $precinctFileh join( ',', @precinctSummary ), "\n";
	$precinctsWritten++;

	#reset the totals
	$activeVOTERS               = 0;
	$activeREP                  = 0;
	$activeDEM                  = 0;
	$activeOTHR                 = 0;
	$totalVOTERS                = 0;
	$totalAMER                  = 0;
	$totalAMEL                  = 0;
	$totalDEM                   = 0;
	$totalDUO                   = 0;
	$totalFED                   = 0;
	$totalGRN                   = 0;
	$totalIA                    = 0;
	$totalIAP                   = 0;
	$totalINAC                  = 0;
	$totalIND                   = 0;
	$totalLIB                   = 0;
	$totalLPN                   = 0;
	$totalNL                    = 0;
	$totalNP                    = 0;
	$totalORGL                  = 0;
	$totalOTH                   = 0;
	$totalPF                    = 0;
	$totalPOP                   = 0;
	$totalREP                   = 0;
	$totalRFM                   = 0;
	$totalTEANV                 = 0;
	$totalSOC                   = 0;
	$totalUWS                   = 0;
	$totalGENERALS              = 0;
	$totalPRIMARIES             = 0;
	$totalPOLLS                 = 0;
	$totalABSENTEE              = 0;
	$totalSTRDEM                = 0;
	$totalMODDEM                = 0;
	$totalWEAKDEM               = 0;
	$totalSTRREP                = 0;
	$totalMODREP                = 0;
	$totalWEAKREP               = 0;
	$totalSTROTHR               = 0;
	$totalMODOTHR               = 0;
	$totalWEAKOTHR              = 0;
	$totalOTHR                  = 0;
	$totalLEANREP               = 0;
	$totalLEANDEM               = 0;
	$precinctLine{"%STRG-DEM"}  = 0;
	$precinctLine{"%STRG-REP"}  = 0;
	$precinctLine{"%STRG-OTHR"} = 0;
	close ($precinctFileh);
}
#
# open and prime next file
#
sub preparefile {
	print "New output file: $outputFile\n";
	open( OUTPUT, ">$outputFile" )
	  or die "Unable to open OUTPUT: $outputFile Reason: $!";
	print OUTPUT $voterHeading;
}

#
# count party memebers
#
sub countParty {
	$party = $csvRowHash{"party"};
	$totalVOTERS++;

	if ( $csvRowHash{"status"} eq "A" ) {
		$activeVOTERS++;
		if    ( $party eq 'REP' ) { $activeREP++; }
		elsif ( $party eq 'DEM' ) { $activeDEM++; }
		else                      { $activeOTHR++; }
	}
	if    ( $party eq 'AMEL' )  { $totalAMEL++; }
	elsif ( $party eq 'AMER' )  { $totalAMER++; }
	elsif ( $party eq 'DEM' )   { $totalDEM++; }
	elsif ( $party eq 'DUO' )   { $totalDUO++; }
	elsif ( $party eq 'FED' )   { $totalFED++; }
	elsif ( $party eq 'GRN' )   { $totalGRN++; }
	elsif ( $party eq 'IA' )    { $totalIA++; }
	elsif ( $party eq 'IAP' )   { $totalIAP++; }
	elsif ( $party eq 'IND' )   { $totalIND++; }
	elsif ( $party eq 'IN AC' ) { $totalINAC++; }
	elsif ( $party eq 'LIB' )   { $totalLIB++; }
	elsif ( $party eq 'LPN' )   { $totalLPN++; }
	elsif ( $party eq 'NL' )    { $totalNL++; }
	elsif ( $party eq 'NP' )    { $totalNP++; }
	elsif ( $party eq 'ORG L' ) { $totalORGL++; }
	elsif ( $party eq 'OTH' )   { $totalOTH++; }
	elsif ( $party eq 'PF' )    { $totalPF++; }
	elsif ( $party eq 'POP' )   { $totalPOP++; }
	elsif ( $party eq 'REP' )   { $totalREP++; }
	elsif ( $party eq 'RFM' )   { $totalRFM++; }
	elsif ( $party eq 'SOC' )   { $totalSOC++; }
	elsif ( $party eq 'TEANV' ) { $totalTEANV++; }
	elsif ( $party eq 'UWS' )   { $totalUWS++; }
}
#
# calculate percentage
sub percentage {
	my $val = $_;
	return ( sprintf( "%.2f", ( $- * 100 ) ) . "%" . $/ );
}

#
# create the precinct-all hash
#
sub adPoliticalAll() {
	$adPoliticalHeadings = "";
	my @adPoliticalHeadings;
	open( my $adPoliticalFileh, $adPoliticalFile )
	  or die "Unable to open INPUT: $adPoliticalFile Reason: $!";
	$adPoliticalHeadings = <$adPoliticalFileh>;
	chomp $adPoliticalHeadings;
	chop $adPoliticalHeadings;

	# headings in an array to modify
	@adPoliticalHeadings = split( /\s*,\s*/, $adPoliticalHeadings );

	# Build the UID->survey hash
	while ( $line1Read = <$adPoliticalFileh> ) {
		chomp $line1Read;
		my @values1 = split( /\s*,\s*/, $line1Read, -1 );

		# Create hashes of line for searches
		@adPoliticalHash{@adPoliticalHeadings} = @values1;
		my $PRECINCT = $adPoliticalHash{"PRECINCT"};
		@adPoliticalHash{ $adPoliticalHash{"PRECINCT"} } = \@values1;
	}
	close $adPoliticalFileh;
	return @adPoliticalHash;
}
