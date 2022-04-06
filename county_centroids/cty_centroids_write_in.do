/**************************************
County Centroids Write-in

Prepared by Riley Wilson
			Thomas Barden
Start Date: September 21st, 2021

****************************************/


//global data "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
//global output "C:\Users\rwilson9\Box\Research\ssi_statesupplement\output"
//global data "/Users/t.j.barden/Box/ssi_statesupplement/data"
//global output "/Users/t.j.barden/Box/ssi_statesupplement/output"

global data "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/data"
global output "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/output"



//Using Centroids from the 2000 Census
/*
cd $data/county_centroids
clear 
set obs 1
gen drop = 1
save cty_pop_centroids, replace

local stfips = "01 02 04 05 06 08 09 10 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56"
local stabbs = "al ak az ar ca co ct de fl ga hi id il in ia ks ky la me md ma mi mn ms mo mt ne nv nh nj nm ny nc nd oh ok or pa ri sc sd tn tx ut vt va wa wv wi wy"


local n: word count `stfips'
forval i = 1/`n' {
	local stfip: word `i' of `stfips'
	local stabb: word `i' of `stabbs'
	import delim using "https://www2.census.gov/geo/docs/reference/cenpop2000/county/cou_`stfip'_`stabb'.txt", clear
	append using cty_pop_centroids
	save cty_pop_centroids, replace
}

clear
import delim using county_centroid_11_dc.txt, clear
rename _x _X
rename _y _Y
save county_centroid_11_dc, replace

use cty_pop_centroids, clear
drop drop
rename v1 st_fips
rename v2 cty_fips
rename v3 cty_name
rename v4 cty_pop
rename v5 _Y
rename v6 _X
drop if st_fips == .
append using county_centroid_11_dc
rename _Y cty_lat
rename _X cty_long
sort st_fips cty_fips
compress
save cty_pop_centroids, replace
*/



//Using Centroids from the 2010 Census

cd $data/county_centroids
clear 
set obs 1
gen drop = 1
save cty_pop_centroids2010, replace

local stfips = "01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56"
local n: word count `stfips'

forval i = 1/`n' {
	local stfip: word `i' of `stfips'
	import delim using "https://www2.census.gov/geo/docs/reference/cenpop2010/county/CenPop2010_Mean_CO`stfip'.txt", clear
	append using cty_pop_centroids2010
	save cty_pop_centroids2010, replace
}

use cty_pop_centroids2010, clear
drop drop 
rename statefp st_fips
rename countyfp cty_fips
rename couname cty_name
rename stname st_name
rename population cty_pop
rename latitude cty_lat
rename longitude cty_long
sort st_fips cty_fips
compress
save cty_pop_centroids2010, replace


