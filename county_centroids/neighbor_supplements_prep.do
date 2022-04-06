/**************************************
Simple County Neighbor Supplement Data

Prepared by Riley Wilson
			Thomas Barden
Start Date: November 5th, 2021

****************************************/


//global data "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
//global output "C:\Users\rwilson9\Box\Research\ssi_statesupplement\output"
//global data "/Users/t.j.barden/Box/ssi_statesupplement/data"
//global output "/Users/t.j.barden/Box/ssi_statesupplement/output"

global data "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/data"
global output "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/output"


cd $data
use state_SSI_supplements_full, clear
drop if year > 2016
rename stname st_name
merge m:1 year using pce_inflator2020
drop if year < 2002 | year > 2016
drop _m
gen supplement_individual_2020 = individual * pceindex2020
gen supplement_couple_2020 = couple * pceindex2020
gen supplement_indwsomeone_2020 = indwsomeone * pceindex2020
gen supplement_couplewsomeone_2020 = couplewsomeone * pceindex2020
drop pce*

rename fips st_fips
drop if st_fips == 2 | st_fips == 15
order year st_fips st_name
replace st_fips = 4 if st_name == "ARIZONA"
replace st_fips = 5 if st_name == "ARKANSAS" 
rename st_fips st_fips_away

foreach var of varlist _all {
        rename `var' n_`var'
}
rename n_st_fips_away st_fips_away
rename n_year year

sort st_fips_away year

cd $data/county_centroids
save neighbor_supplements, replace

/*
cd $data
use r_inflation_02_16, clear
foreach var of varlist _all {
        rename `var' n_`var'
}
rename n_st_fips st_fips_away
rename n_year year
order year st_fips_away n_st_name n_cty_fips
sort st_fips_away year n_cty_fips

cd $data/county_centroids
save neighbor_supplements, replace
*/
