#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# wcrp-voter-tables
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
use Math::Round;
#use DateTime;
#use DateTime::Duration;
#use DateTime::Format::ISO8601;

no warnings "uninitialized";


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
#my $inputFile = "../test-in/2019 1st Free stopped proc.csv";    
#my $inputFile = "../test-in/2018 4th Free-NO DEMS-100.csv";    
#my $inputFile = "../test-in/2018 4th Free-NO DEMS-1100.csv";    
my $inputFile = "../test-in/2018 4th Free-NO DEMS-100.csv";    

#my $inputFile = "../test-in/2019 1st Free List 1.7.19.csv";    

#my $inputFile = "../test-in/voter-leans-test.csv";    #
#my $inputFile = "../test-in/2018-3rd Free List.csv";#
#my $inputFile = "../test-in/2012 Voter List 10-4-12.csv";
#my $inputFile = "../test-in/2016 Voter List 9.27.16.csv";
#my $inputFile = "../test-in/2018-2nd-Free-500-PARTIES.csv";

my $adPoliticalFile = "../test-in/adall-precincts-jul.csv";
#my $stateVoterFile = "../test-in/nv-state-voter-list-20190218.csv";
my $stateVoterFile = "../test-in/nv-washoe-id-last-20190219.csv";

my $fileName         = "";
my $baseFile         = "base.csv";
my $baseFileh;
my %baseLine         = ();
my $contactFile      = "contact.csv";
my $contactFileh;
my %contactLine      = ();
my $politicalFile    = "political.csv";
my $politicalFileh;
my %politicalLine    = ();
my $printFile        = "print-.txt";
my $printFileh;
my $votingFile       = "voting.csv";
my $votingFileh;
my %votingLine       = ();


my @adPoliticalHash = ();
my %adPoliticalHash;
my $adPoliticalHeadings = "";
my @stateVoterHash = ();
my %stateVoterHash;
my $stateVoterHeadings = "";my $helpReq            = 0;
my $maxLines           = "300000";
my $voteCycle          = "";
my $fileCount          = 1;
my $csvHeadings        = "";
my @csvHeadings;
my $line1Read    = '';
my $linesRead    = 0;
my $linesIncRead    = 0;
my $printData;
my $linesWritten = 0;


my $selParty;
my $skipRecords     = 0;
my $skippedRecords  = 0;
my $maintainDate;

my $party;
my $primaryCount;
my $generalCount;
my $pollCount;
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

my @baseLine;
my $baseLine;
my @baseProfile;
my $baseHeading = "";
my @baseHeading = (
    "voter_id",        "st_voter_id",     
	"precinct",       "asm_dist",
	"v_status",       "name_prefix",     
  "name_first",      "name_last",
	"name_middle",     "name_suffix",       
	"birth_place",     "birth_date",
	"gender",          "military",
	"drivers_license", "affidavit",
	"address",
	"pre_dir",         "post_dir",
	"street",          "type",
	"city",            "state",
	"zip", 
	"house_number",    "house_fraction",
	"apartment_number", "building_number"
);
my @contactLine;
my $contactLine;
my @contactProfile;
my $contactHeading = "";
my @contactHeading = (
	"voter_id",
	"care_of",         
	"phone",           "phone_type",
	"email",           "mail_city",
	"mail_state",      "mail_country",
	"mail_street",     "mail_zip",
);
my @politicalLine;
my $politicalLine;
my @politicalProfile;
my $politicalHeading = "";
my @politicalHeading = (
	"voter_id",
	"reg_date",        "reg_date_original",
	"alpha_split",     "consolodation",
	"party",           "portion",
	"precinct",        "precinct_name",
  "days_registered", "Generals",
	"Primaries",       "Polls",
	"Absentee",        "LeansDEM",
	"LeansREP",        "Leans",
	"Rank"
);
my @votingLine;
my $votingLine;
my @votingProfile;
my $votingHeading = "";
my @votingHeading = (
	"voter_id",
	"publish_date", 
	"act_date", 
	"party",      
	"election01",   "vote01",  	
	"election02",	"vote02",
	"election03",   "vote03",    
	"election04",	"vote04",
	"election05",   "vote05",    
	"election06",	"vote06",
  "election07", 	"vote07", 	
	"election08",	"vote08",
	"election09",   "vote09",   
	"election10",	"vote10",
	"election11",   "vote11",   
	"election12", 	"vote12",
	"election13",   "vote13",   
	"election14",	"vote14",
	"election15",   "vote15",    
	"election16",	"vote16", 
	"election17",   "vote17",    
	"election18",	"vote18",
	"election19",   "vote19",    
	"election20",	"vote20"
	);

my $precinct = "000000";

#
# main program controller
#
sub main {
	#Open file for messages and errors
	open( $printFileh, ">$printFile" )
	  or die "Unable to open PRINT: $printFile Reason: $!";

	# Parse any parameters
	GetOptions(
		'infile=s'  => \$inputFile,
		'outile=s'  => \$baseFile,
		'lines=s'   => \$maxLines,
		'votecycle' => \$voteCycle,
		'help!'     => \$helpReq,
		'party'     => \$selParty,
		'skip'      => \$skipRecords,
		'maintainDt' => \$maintainDate,

	) or die "Incorrect usage!\n";
	if ($helpReq) {
		print "Come on, it's really not that hard.\n";
	}
	else {
		printLine ("My inputfile is: $inputFile.\n");
	}
	unless ( open( INPUT, $inputFile ) ) {
		printLine ("Unable to open INPUT: $inputFile Reason: $!\n");
		die;
	}

	# pick out the heading line and hold it and remove end character
	$csvHeadings = <INPUT>;
	chomp $csvHeadings;
	chop $csvHeadings;

	# headings in an array to modify
	# @csvHeadings will be used to create the files
  @csvHeadings = split( /\s*,\s*/, $csvHeadings );

	# Build heading for new voter record
	$baseHeading = join( ",", @baseHeading );
	$baseHeading = $baseHeading . "\n";

	# Build heading for new contact record
	$contactHeading = join( ",", @contactHeading );
	$contactHeading = $contactHeading . "\n";

	# Build heading for new political record
	$politicalHeading = join( ",", @politicalHeading );
	$politicalHeading = $politicalHeading . "\n";	

	# Build heading for new voting record
	$votingHeading = join( ",", @votingHeading );
	$votingHeading = $votingHeading . "\n";	
	#
	# Initialize process loop and open files
	printLine ("Voter Base-table file: $baseFile\n");
	open( $baseFileh, ">$baseFile" )
	  or die "Unable to open baseFile: $baseFile Reason: $!";
	print $baseFileh $baseHeading;

	printLine ("Voter Contact-table file: $contactFile\n");
	open( $contactFileh, ">$contactFile" )
	  or die "Unable to open contactFile: $contactFile Reason: $!";
	print $contactFileh $contactHeading;

	printLine ("Voter Political-table file: $politicalFile\n");
	open( $politicalFileh, ">$politicalFile" )
	  or die "Unable to open politicalFileh: $politicalFile Reason: $!";
	print $politicalFileh $politicalHeading;

	printLine ("Voter Voting-table file: $votingFile\n");
	open( $votingFileh, ">$votingFile" )
	  or die "Unable to open votingFileh: $votingFile Reason: $!";
	print $votingFileh $votingHeading;

	# initialize the precinct-all table
	adPoliticalAll(@adPoliticalHash);
	stateVoterList(@stateVoterHash);

	# Process loop
	# Read the entire input and
	# 1) edit the input lines
	# 2) transform the data
	# 3) write out transformed line
  NEW:
	while ( $line1Read = <INPUT> ) {
		$linesRead++;
		$linesIncRead++;
		if ($linesIncRead == 1000) {
			printLine ("$linesRead lines processed\n");
			$linesIncRead = 0;
		}
		if ($skipRecords > 0) {
			$skippedRecords = $skippedRecords+1;
			if ($skippedRecords > $skipRecords) {
					$skippedRecords = 0;
			} else {
					goto NEW;	
			}
		}
		
		# Get the data into an array that matches the headers array
		chomp $line1Read;

		# replace commas from in between double quotes with a space
		$line1Read =~ s/(?:\G(?!\A)|[^"]*")[^",]*\K(?:,|"(*SKIP)(*FAIL))/ /g;

		# then create the values array
		@values1 = split( /\s*,\s*/, $line1Read, -1 );

		# Create hash of line for transformation
		@csvRowHash{@csvHeadings} = @values1;

		#- - - - - - - - - - - - - - - - - - - - - - - - - - 
		# Assemble database load  for base segment
		#- - - - - - - - - - - - - - - - - - - - - - - - - - 
		%baseLine = ();
		$baseLine{"precinct"}     = substr $csvRowHash{"precinct"}, 0, 6;
		my $precinct              = substr $csvRowHash{"precinct"}, 0, 6;
		$baseLine{"asm_dist"}     = $adPoliticalHash{$precinct}[2];
		$baseLine{"v_status"}     = $csvRowHash{"status"};
		$baseLine{"voter_id"}     = $csvRowHash{"voter_id"};
		$baseLine{"name_last"}    = $csvRowHash{"name_last"};
		$baseLine{"name_suffix"}  = $csvRowHash{"name_suffix"};
		$baseLine{"name_first"}   = $csvRowHash{"name_first"};
		$baseLine{"name_middle"}  = $csvRowHash{"name_middle"};
		$baseLine{"address"}  = join( ' ',
			$csvRowHash{house_number},
			$csvRowHash{street}, $csvRowHash{type} );
		$baseLine{"pre_dir"}      = $csvRowHash{"pre_dir"};
		$baseLine{"post_dir"}     = $csvRowHash{"post_dir"};
		$baseLine{"street"}       = $csvRowHash{"street"};
		$baseLine{"type"}         = $csvRowHash{"type"};
		$baseLine{"city"}         = $csvRowHash{"city"};
		$baseLine{"state"}        = $csvRowHash{"state"};
		$baseLine{"zip"}          = $csvRowHash{"zip"};
		$baseLine{"house_number"}  = $csvRowHash{"house_number"};
		$baseLine{"house_fraction"}  = $csvRowHash{"house_fraction"};
		$baseLine{"apartment_number"}  = $csvRowHash{"apartment_number"};
		$baseLine{"building_number"}  = $csvRowHash{"building_number"};
		$baseLine{"gender"}       = ""; 
		if ( $csvRowHash{"gender"} eq 'M' ) {
			$baseLine{"gender"} = "Male";
		}
		if ( $csvRowHash{"gender"} eq 'F' ) {
			$baseLine{"gender"}   = "Female";
		}
		$baseLine{"military"}     = "";
		if ( $csvRowHash{"military"} eq 'Y' ) {
			$baseLine{"military"} = "Y";
		}
		@date = split( /\s*\/\s*/, $csvRowHash{"reg_date"}, -1 );
		$mm = sprintf( "%02d", $date[0] );
		$dd = sprintf( "%02d", $date[1] );
		$yy = sprintf( "%02d", $date[2] );
		$baseLine{"birth_date"}   = "$mm/$dd/$yy";
		
		@baseProfile = ();
		foreach (@baseHeading) {
			push( @baseProfile, $baseLine{$_} );
		}
		print $baseFileh join( ',', @baseProfile ), "\n";

		#- - - - - - - - - - - - - - - - - - - - - - - - - - 
		# Assemble database load  for contact segment
		#- - - - - - - - - - - - - - - - - - - - - - - - - - 
		%contactLine = ();
		$contactLine{"voter_id"}      = $csvRowHash{"voter_id"};
		# Assemble Street Address
		$contactLine{"Address"}       = join( ' ',
			$csvRowHash{house_number},
			$csvRowHash{street}, $csvRowHash{type} );
		$contactLine{"care_of"}       = $csvRowHash{"care_of"};
		$contactLine{"mail_street"}   = $csvRowHash{"mail_street"};
		$contactLine{"mail_city"}     = $csvRowHash{"mail_city"};
		$contactLine{"mail_state"}    = $csvRowHash{"mail_state"};
		$contactLine{"mail_zip"}      = $csvRowHash{"mail_zip"};
		$contactLine{"mail_country"}  = $csvRowHash{"mail_country"};
		$contactLine{"phone"}         = $csvRowHash{"phone_1"};

		@contactProfile = ();
		foreach (@contactHeading) {
			push( @contactProfile, $contactLine{$_} );
		}
		print $contactFileh join( ',', @contactProfile ), "\n";


		#- - - - - - - - - - - - - - - - - - - - - - - - - - 
		# Assemble database load  for political segment
		#- - - - - - - - - - - - - - - - - - - - - - - - - - 
		%politicalLine = ();
		$politicalLine{"voter_id"}  = $csvRowHash{"voter_id"};
		$politicalLine{"party"}     = $csvRowHash{"party"};
		$politicalLine{"precinct"}  = $csvRowHash{"precinct"};
		$politicalLine{"precinct_name"}  = $csvRowHash{"precinct_name"};
		countParty();
		@date = split( /\s*\/\s*/, $csvRowHash{"reg_date"}, -1 );
		my $mm = sprintf( "%02d", $date[0] );
		my $dd = sprintf( "%02d", $date[1] );
		my $yy = sprintf( "%02d", $date[2] );
		$politicalLine{"reg_date"}  = "$mm/$dd/$yy";
		# then the originl registration and days total
		@date = split( /\s*\/\s*/, $csvRowHash{"reg_date_original"}, -1 );
		$mm = sprintf( "%02d", $date[0] );
		$dd = sprintf( "%02d", $date[1] );
		$yy = sprintf( "%02d", $date[2] );
		$politicalLine{"reg_date_original"} = "$mm/$dd/$yy";
	
		if ($yy <= "30") {$yy = 2000 + $yy}
		elsif ($yy > 30) {$yy = 1900 + $yy};
		my $adjustedDate = "$mm/$dd/$yy";
		my $before = Time::Piece->strptime( $adjustedDate, "%m/%d/%Y" );		
		my $now            = localtime;
		my $daysRegistered = $now - $before;
		$daysRegistered = ( $daysRegistered / (86400) );
		$daysRegistered = round($daysRegistered);
		if ($daysRegistered < 0 ) {
			print $daysRegistered;
		}
		$politicalLine{"days_registered"} = int($daysRegistered);

		evaluateVoter();
		
		$politicalLine{"Primaries"} = $primaryCount;
		$politicalLine{"Generals"}  = $generalCount;
		$politicalLine{"Polls"}     = $pollCount;
		$politicalLine{"Absentee"}  = $absenteeCount;
		$politicalLine{"LeansREP"}  = $leansRepCount;
		$politicalLine{"LeansDEM"}  = $leansDemCount;
		$politicalLine{"LeanREP"}   = $leanRep;
		$politicalLine{"LeanDEM"}   = $leanDem;
		if ($leanDem) {
			$leans = "DEM";
		}
		if ($leanRep) {
			$leans = "REP";
		}
		$politicalLine{"Leans"} = $leans;
		$leans            = "";
		$politicalLine{"Rank"}  = $voterRank;
		
		@politicalProfile = ();
		foreach (@politicalHeading) {
			push( @politicalProfile, $politicalLine{$_} );
		}
		print $politicalFileh join( ',', @politicalProfile ), "\n";

		#- - - - - - - - - - - - - - - - - - - - - - - - - - 
		# Assemble database load  for voting segment
		#- - - - - - - - - - - - - - - - - - - - - - - - - - 
		%votingLine = ();
		$votingLine{"voter_id"}  = $csvRowHash{"voter_id"};
		$votingLine{"party"}     = $csvRowHash{"party"};
		$votingLine{"actdate"}   = "01/01/01";
		$votingLine{"election01"}  = substr($csvHeadings[55],3,14);
		$votingLine{"vote01"}     = $csvRowHash{$csvHeadings[55]};
		$votingLine{"election02"}  = substr($csvHeadings[56],3,14);
		$votingLine{"vote02"}     = $csvRowHash{$csvHeadings[56]};
		$votingLine{"election03"}  = substr($csvHeadings[57],3,14);
		$votingLine{"vote03"}     = $csvRowHash{$csvHeadings[57]};
		$votingLine{"election04"}  = substr($csvHeadings[58],3,14);
		$votingLine{"vote04"}     = $csvRowHash{$csvHeadings[58]};
		$votingLine{"election05"}  = substr($csvHeadings[59],3,14);
		$votingLine{"vote05"}     = $csvRowHash{$csvHeadings[59]};
		$votingLine{"election06"}  = substr($csvHeadings[60],3,14);
		$votingLine{"vote06"}     = $csvRowHash{$csvHeadings[60]};
		$votingLine{"election07"}  = substr($csvHeadings[61],3,14);
		$votingLine{"vote07"}     = $csvRowHash{$csvHeadings[61]};
		$votingLine{"election08"}  = substr($csvHeadings[62],3,14);
		$votingLine{"vote08"}     = $csvRowHash{$csvHeadings[62]};
		$votingLine{"election09"}  = substr($csvHeadings[63],3,14);
		$votingLine{"vote09"}     = $csvRowHash{$csvHeadings[63]};
		$votingLine{"election10"}  = substr($csvHeadings[64],3,14);
		$votingLine{"vote10"}     = $csvRowHash{$csvHeadings[64]};		
		$votingLine{"election11"}  = substr($csvHeadings[65],3,14);
		$votingLine{"vote11"}     = $csvRowHash{$csvHeadings[65]};		
		$votingLine{"election12"}  = substr($csvHeadings[66],3,14);
		$votingLine{"vote12"}     = $csvRowHash{$csvHeadings[66]};		
		$votingLine{"election13"}  = substr($csvHeadings[67],3,14);
		$votingLine{"vote13"}     = $csvRowHash{$csvHeadings[67]};		
		$votingLine{"election14"}  = substr($csvHeadings[68],3,14);
		$votingLine{"vote14"}     = $csvRowHash{$csvHeadings[68]};		
		$votingLine{"election15"}  = substr($csvHeadings[69],3,14);
		$votingLine{"vote15"}     = $csvRowHash{$csvHeadings[69]};		
		$votingLine{"election16"}  = substr($csvHeadings[70],3,14);
		$votingLine{"vote16"}     = $csvRowHash{$csvHeadings[70]};		
		$votingLine{"election17"}  = substr($csvHeadings[71],3,14);
		$votingLine{"vote17"}     = $csvRowHash{$csvHeadings[71]};		
		$votingLine{"election18"}  = substr($csvHeadings[72],3,14);
		$votingLine{"vote18"}     = $csvRowHash{$csvHeadings[72]};		
		$votingLine{"election19"}  = substr($csvHeadings[73],3,14);
		$votingLine{"vote19"}     = $csvRowHash{$csvHeadings[73]};		
		$votingLine{"election20"}  = substr($csvHeadings[74],3,14);
		$votingLine{"vote20"}     = $csvRowHash{$csvHeadings[74]};		
		@votingProfile = ();
		foreach (@votingHeading) {
			push( @votingProfile, $votingLine{$_} );
		}
		print $votingFileh join( ',', @votingProfile ), "\n";
	
		$linesWritten++;
		#
		# For now this is the in-elegant way I detect completion
	}
		if ( eof(INPUT) ) {
			goto EXIT;
		}
		next;
	}
	#
	#goto NEW;

#
# call main program controller
main();
#
# Common Exit
EXIT:

printLine ("<===> Completed transformation of: $inputFile \n");
printLine ("<===> BASE      SEGMENTS available in file: $baseFile \n");
printLine ("<===> CONTACT   SEGMENTS available in file: $contactFile \n");
printLine ("<===> POLITICAL SEGMENTS available in file: $politicalFile \n");
printLine ("<===> VOTING    SEGMENTS available in file: $votingFile \n");
printLine ("<===> Total Records Read: $linesRead \n");
printLine ("<===> Total Records written: $linesWritten \n");

close(INPUT);
close($baseFileh);
close($contactFileh);
close($politicalFileh);
close($votingFileh);
close($printFileh);
exit;

#
# Print report line
#
sub printLine  {
	my $datestring = localtime();
	($printData) = @_;
	print $printFileh $datestring . ' ' . $printData;
	print $datestring . ' ' . $printData;
}


# routine: evaluateVoter
# determine if reliable voter by voting pattern over last five cycles
# tossed out special elections and mock elections
#  voter reg_date is considered
#  weights: strong, moderate, weak
# if registered < 2 years       gen >= 1 and pri <= 0   = NEW
# if registered > 2 < 4 years   gen >= 1 and pri >= 1   = STRONG
# if registered > 4 < 8 years   gen >= 2 and pri >= 2   = STRONG
# if registered > 8 years       gen >= 4 and pri >= 4   = STRONG
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
	my $daysRegistered = $politicalLine{"days_registered"};
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
			if ( $csvRowHash{ $csvHeadings[$vote] } eq ' ' ) {
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
			if ( $csvRowHash{ $csvHeadings[$vote] } eq ' ' ) {
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
   # if registered < 2 years       gen <= 1 || notelig >= 1            = NEW
   # if registered < 2 years       gen == 1 ||                         = NEW
   # if registered < 2 years       gen == 2 ||                         = NEW

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

	if (3775 < ( 365 * 2 + 1 )) {
		print "true";
	}
	if ($daysRegistered < ( 365 * 2 + 1 ))  {
		if ( $generalCount <= 1 or $notElegible >= 1 ) {
			$voterRank = "WEAK";
		}
		if ( $generalCount >= 1 ) {
			$voterRank = "NEW";
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

#
# open and prime next file
#
sub preparefile {
	print "New output file: $baseFile\n";
	open( baseFileh, ">$baseFile" )
	  or die "Unable to open output: $baseFile Reason: $!";
	print baseFileh $baseHeading;
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
#
# create the precinct-all hash
#
sub stateVoterList() {
	$stateVoterHeadings = "";
	my @stateVoterHeadings;
	open( my $stateVoterFileh, $stateVoterFile )
	  or die "Unable to open INPUT: $stateVoterFile Reason: $!";
	$stateVoterHeadings = <$stateVoterFileh>;
	chomp $stateVoterHeadings;
	chop $stateVoterHeadings;

	# headings in an array to modify
	@stateVoterHeadings = split( /\s*,\s*/, $stateVoterHeadings );

	# Build the UID->survey hash
	while ( $line1Read = <$stateVoterFileh> ) {
		chomp $line1Read;
		my @values1 = split( /\s*,\s*/, $line1Read, -1 );

		# Create hashes of line for searches
		@stateVoterHash{@stateVoterHeadings} = @values1;
		my $PRECINCT = $stateVoterHash{"cnty_id"};
		@stateVoterHash{ $stateVoterHash{"cnty_id"} } = \@values1;
	}
	close $stateVoterFileh;
	return @stateVoterHash;
}
