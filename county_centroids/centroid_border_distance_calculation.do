/**************************************
Centroid to Border Distance Calcuation

Prepared by Riley Wilson
			Thomas Barden
Start Date: October 14th, 2021

****************************************/



//global data "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
//global output "C:\Users\rwilson9\Box\Research\ssi_statesupplement\output"
//global data "/Users/t.j.barden/Box/ssi_statesupplement/data"
//global output "/Users/t.j.barden/Box/ssi_statesupplement/output"

global data "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/data"
global output "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/output"


cd $data/county_centroids

//Using Centroids from the 2000 Census
/*
foreach state in 01 04 05 06 08 09 10 11 12 13 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {
	use cty_pop_centroids, clear 
	//use cty_pop_centroids2010, clear
	keep if st_fips == `state'
	gen id = _n
	sum id
	local n = r(max)
	tempfile cty_centroid_temp
	save `cty_centroid_temp', replace
	
	use stateborder_eachstborder_latlon, clear
	gen ob = _n
	gen st_fips_away = stfips[ob-1] if num == 2
	replace st_fips_away = stfips[ob+1] if num == 1
	drop ob
	rename stfips st_fips
	keep if st_fips == `state'
	expand `n'
	rename _Y border_lat
	rename _X border_long
	bys border_lat border_long: gen id = _n
	display "State `state'"
	merge m:1 id using `cty_centroid_temp'
	drop _m
	geodist cty_lat cty_long border_lat border_long, generate(distance)
	order st_fips cty_fips cty_name border_id distance cty_pop cty_l* border_l*
	compress
	collapse (min) distance, by(st_fips cty_fips cty_name cty_pop border_id st_fips_away)
	sort st_fips cty_fips
	if (`state' == 01) {
		save unique_counties_and_borders, replace 
	}
	else {
		append using unique_counties_and_borders
		//append using unique_counties_and_borders2010
		save unique_counties_and_borders, replace
		//save unique_counties_and_borders2010, replace
	}
}
*/

//Using Centroids from the 2010 Census

foreach state in 01 04 05 06 08 09 10 11 12 13 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {
	use cty_pop_centroids2010, clear
	keep if st_fips == `state'
	gen id = _n
	sum id
	local n = r(max)
	tempfile cty_centroid_temp
	save `cty_centroid_temp', replace
	
	use stateborder_eachstborder_latlon, clear
	gen ob = _n
	gen st_fips_away = stfips[ob-1] if num == 2
	replace st_fips_away = stfips[ob+1] if num == 1
	drop ob
	rename stfips st_fips
	keep if st_fips == `state'
	expand `n'
	rename _Y border_lat
	rename _X border_long
	bys border_lat border_long: gen id = _n
	display "State `state'"
	merge m:1 id using `cty_centroid_temp'
	drop _m
	geodist cty_lat cty_long border_lat border_long, generate(distance) mile
	order st_fips cty_fips cty_name border_id distance cty_pop cty_l* border_l*
	compress
	collapse (min) distance, by(st_fips cty_fips cty_name cty_pop border_id st_fips_away)
	sort st_fips cty_fips
	if (`state' == 01) {
		save unique_counties_and_borders, replace 
	}
	else {
		append using unique_counties_and_borders2010
		save unique_counties_and_borders2010, replace
	}
}

