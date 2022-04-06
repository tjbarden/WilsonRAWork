
global data "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/data"
global output "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/output"


foreach n in 3 /*4 5 6 7 8 9 10*/ {
	cd
	cd Downloads
	import excel using "table01 (`n').xlsx", clear
	display `n'
	rename A st_name
	/*drop B C
	drop if _n <=4
	drop if _n > 51
	rename D ssi_tot
	rename E ssi_aged
	rename F ssi_disabled
	rename G ssi_under18
	rename H ssi_18_64
	rename I ssi_above64
	rename J ssi_alsoOASDI
	gen year = 2019 - `n'
	
	destring ssi*, replace
	compress
	
	cd $data
	cd ssa_ssirecipients
	save st_ssicases_20`n', replace*/
}

foreach n in 3 4 5 6 7 8 9 {	
	cd $data
	cd ssa_ssirecipients
	append using st_ssicases_20`n'
	
	save st_ssicases_09_16, replace
}

