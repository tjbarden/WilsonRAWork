/**************************************
Centroid to Border Distance Merge

Prepared by Riley Wilson
			Thomas Barden
Start Date: October 28th, 2021

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
use unique_counties_and_borders, clear
drop cty_pop
replace cty_fips = st_fips * 1000 + cty_fips
expand 15
sort cty_fips border_id
gen year = mod(_n, 15)
order year
sort cty_fips border_id year 
replace year = year + 2002
replace cty_fips = 51005 if cty_fips == 51560 // Virginia Clifton Forge City was absorbed into Alleghany County
replace cty_name = "ALLEGHANY" if cty_name == "Clifton Forge"
replace cty_fips = 46102 if cty_fips == 46113 // Shannon County SD was remaned and recoded as Oglala Lakota County
replace cty_name = "OGLALA LAKOTA" if cty_name == "Shannon"
replace cty_fips = 51019 if cty_fips == 51515 // Virginia Bedford City was absorbed into Bedford County


cd $data
merge m:1 cty_fips year using r_inflation_02_16
drop if year == 2001
drop if (cty_fips < 3000 & cty_fips > 2000) //Alaska
drop if (cty_fips < 16000 & cty_fips > 15000) //Hawaii
sort cty_fips year border_id
cd $data/county_centroids
save cty_border_distance_merged, replace
*/


//Using Centroids from the 2010 Census

cd $data/county_centroids

use unique_counties_and_borders2010, clear
drop cty_pop
replace cty_fips = st_fips * 1000 + cty_fips
expand 15
sort cty_fips border_id
gen year = mod(_n, 15)
order year
sort cty_fips border_id year 
replace year = year + 2002
replace cty_fips = 51005 if cty_fips == 51560 // Virginia Clifton Forge City was absorbed into Alleghany County
replace cty_name = "ALLEGHANY" if cty_name == "Clifton Forge"
replace cty_fips = 46102 if cty_fips == 46113 // Shannon County SD was remaned and recoded as Oglala Lakota County
replace cty_name = "OGLALA LAKOTA" if cty_name == "Shannon"
replace cty_fips = 51019 if cty_fips == 51515 // Virginia Bedford City was absorbed into Bedford County

cd $data
merge m:1 cty_fips year using r_inflation_02_16
drop if year == 2001
drop if (cty_fips < 3000 & cty_fips > 2000) //Alaska
drop if (cty_fips < 16000 & cty_fips > 15000) //Hawaii
drop _m

cd $data/county_centroids
merge m:1 st_fips_away year using neighbor_supplements 
sort cty_fips year border_id
drop *2012 //Dropping 2012 Supplement Values


drop if n_st_name == "ILLINOIS"
drop if st_name == "ILLINOIS"
foreach t in individual couple indwsomeone couplewsomeone {
        gen dif_`t'_inf2020 = supplement_`t'_2020 - n_supplement_`t'_2020
}

save cty_border_distance_merged2010, replace

/*
gen high = 1 if dif_individual_inf2020 > 0 
replace high = 0 if dif_individual_inf2020 < 0 
order high

drop if high == .
compress
save cty_border_distance_merged2010_h, replace
*/
/*
foreach year in 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 {
        twoway (scatter dif_ssi_rate dif_individual_inf2020 if year == `year' ) ///
        (lift dif_ssi_rate dif_individual_inf2020 if year == `year')
        graph export ssi_diff_`year'.png, width(1000)
}

twoway (scatter dif_ssi_rate dif_individual_inf2020) ///
        (lfit dif_ssi_rate dif_individual_inf2020)
        graph export ssi_diff_couple_test.png, width(1000)
*/


