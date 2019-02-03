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
