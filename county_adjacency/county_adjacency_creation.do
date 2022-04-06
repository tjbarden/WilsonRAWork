/*****************************************
County Adjacency Combination

Prepared by Riley Wilson
			Thomas Barden
Start Date: October 28th, 2021

******************************************/


//global data "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
//global output "C:\Users\rwilson9\Box\Research\ssi_statesupplement\output"

global data "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/data"
global output "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/output"


/************************
County Adjacency Merge

Start Date July 28th, 2021
Prepared by Riley Wilson
            TJ Barden

************************/


//"Home" and "Away" files are created and then merged together. 1 and 2 are used to denote the associated variables in order to facilitate future reshapes.
cd $data
use r_inflation_02_16, clear
foreach var of varlist _all {
        rename `var' `var'1
}
rename cty_fips1 cty_fips
rename year1 year
save h_r_inflation_02_16, replace

use r_inflation_02_16, clear
foreach var of varlist _all {
        rename `var' `var'2
}
rename cty_fips2 fipsneighbor
rename year2 year
save a_r_inflation_02_16, replace


cd $data
use county_adjacency2010.dta, clear
destring fipscounty fipsneighbor, replace
rename fipscounty cty_fips
drop if cty_fips > 57000
drop if fipsneighbor > 57000
replace cty_fips = 46102 if cty_fips == 46113 // South Dakota Shannon County was renamed and its code changed
replace cty_fips = 51019 if cty_fips == 51515 // Virginia Bedford City was absorbed into Bedford County
replace fipsneighbor = 46102 if fipsneighbor == 46113
replace fipsneighbor = 51019 if fipsneighbor == 51515

drop if cty_fips == fipsneighbor

expand 15
sort cty_fips fipsneighbor
gen year = mod(_n, 15)
replace year = year + 2002
sort cty_fips fipsneighbor year

duplicates drop
gen double id = (cty_fips * fipsneighbor) + ((cty_fips + 3) * (fipsneighbor + 3))

bysort id year: gen num = _N
tab num

cd $data
save county_adjacency_refined, replace



/*
County Adjacency Merge
Here we merge our data set with the county adjacency list to create adjacent county pairs.
*/
cd $data
use county_adjacency_refined, clear

merge m:1 cty_fips year using h_r_inflation_02_16
drop if (cty_fips < 3000 & cty_fips > 2000) //Alaska
drop if (cty_fips < 16000 & cty_fips > 15000) //Hawaii
tab _m
drop _m
merge m:1 fipsneighbor year using n_r_inflation_02_16
drop if (fipsneighbor < 3000 & fipsneighbor > 2000) //Alaska
drop if (fipsneighbor < 16000 & fipsneighbor > 15000) //Hawaii
tab _m
drop _m

order id year cty_fips fipsneighbor countyname neighborname
sort id cty_fips year fipsneighbor

rename cty_fips cty_fips1
rename fipsneighbor cty_fips2
drop countyname neighborname

compress

save ssi_analysis_pre_reshape, replace
