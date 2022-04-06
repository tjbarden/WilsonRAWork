/************************
State Data

Start Date March 29th, 2022
Prepared by Riley Wilson
			TJ Barden
			
************************/



//global data "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
//global output "C:\Users\rwilson9\Box\Research\ssi_statesupplement\output"

global data "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/data"
global output "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/output"


/************************************
QWI Population Data
*************************************/


cd $data/qwi/sex_age
use qwi_age_all, clear
drop if ctyfips > 100
rename ctyfips st_fips
save st_qwi_age_all, replace

cd $data/qwi/sex_education
use qwi_education_all, clear
drop if ctyfips > 100
rename ctyfips st_fips
save st_qwi_education_all, replace


/************************************
SEER Population Data
*************************************/

cd $data
use seer_pop02_16, clear
gen st_fips = floor(ctyfips/1000)
order st_fips
drop ctyfips


collapse (sum) totalpop pop_female pop_male pop_14_18 pop_19_21 pop_22_24 pop_25_34 pop_35_44 pop_45_54 pop_55_64 pop_65_99 pop_over25 pop_female_14_18 pop_female_19_21 pop_female_22_24 pop_female_25_34 pop_female_35_44 pop_female_45_54 pop_female_55_64 pop_female_65_99 pop_female_over25 pop_male_14_18 pop_male_19_21 pop_male_22_24 pop_male_25_34 pop_male_35_44 pop_male_45_54 pop_male_55_64 pop_male_65_99 pop_male_over25, by(st_fips year)

save st_seer_pop02_16, replace


/************************************
Education-Population
*************************************/

cd $data/census_educshares
use educ_shares, clear

gen st_fips = floor(cty_fips/1000)
order st_fips

collapse (sum) total_pop_18_24 total_no_high_school_18_24 total_high_school_18_24 total_some_college_18_24 total_college_18_24 total_pop_over25 total_no_ninth_over25 total_some_high_school_over25 total_high_school_over25 total_some_college_over25 total_associates_over25 total_college_over25 total_gradschool_over25 total_pop_25_34 total_high_school_25_34 total_college_25_34 total_pop_35_44 total_high_school_35_44 total_college_35_44 total_pop_45_64 total_high_school_45_64 total_college_45_64 total_pop_65_99 total_high_school_65_99 total_college_65_99 male_pop_18_24 male_no_high_school_18_24 male_high_school_18_24 male_some_college_18_24 male_college_18_24 male_pop_over25 male_no_ninth_over25 male_some_high_school_over25 male_high_school_over25 male_some_college_over25 male_associates_over25 male_college_over25 male_gradschool_over25 male_pop_25_34 male_high_school_25_34 male_college_25_34 male_pop_35_44 male_high_school_35_44 male_college_35_44 male_pop_45_64 male_high_school_45_64 male_college_45_64 male_pop_65_99 male_high_school_65_99 male_college_65_99 female_pop_18_24 female_no_high_school_18_24 female_high_school_18_24 female_some_college_18_24 female_college_18_24 female_pop_over25 female_no_ninth_over25 female_some_high_school_over25 female_high_school_over25 female_some_college_over25 female_associates_over25 female_college_over25 female_gradschool_over25 female_pop_25_34 female_high_school_25_34 female_college_25_34 female_pop_35_44 female_high_school_35_44 female_college_35_44 female_pop_45_64 female_high_school_45_64 female_college_45_64 female_pop_65_99 female_high_school_65_99 female_college_65_99, by(st_fips)

cd $data
save st_educ_shares, replace


/**************************
Prep County Level Unemployment Rates (LAUS) - Collapse to States
***************************/
insheet using "https://download.bls.gov/pub/time.series/la/la.data.64.County", clear

gen ctyfips = substr(series_id,6,5)

gen month = substr(period,-2,.)

gen t = substr(series_id,-1,1)

replace value = regexr(value,"-","")

destring ctyfips month t value, replace

keep year month value footnote ctyfips t

keep if month == 13
reshape wide value footnote, i(ctyfips year month) j(t)

rename value3 urate
rename value4 unemp
rename value5 emp
rename value6 labforce

drop footnote*
keep if year<=2018 //this will continue to be updated so we will restrict
keep if year>=2000
rename ctyfips cty_fips
compress

gen st_fips = floor(cty_fips/1000)
drop cty_fips
drop urate
drop month
collapse (sum) unemp emp labforce, by(year st_fips)

gen urate = (unemp/labforce)*100

cd $data
save st_annualemp2000_2018, replace

/***************************
State Sales Tax Rates
https://taxfoundation.org/state-and-local-sales-tax-rates-in-2017/
***************************/
cd $data
import excel using state_salestax2017.xlsx, first clear

rename State statename
replace statename = regexr(statename,"\([a-z]\)","")
replace statename = strtrim(statename)
replace statename = upper(statename)

replace statename = "DISTRICT OF COLUMBIA" if statename == "D.C."

rename StateTaxRate st_staxrate
rename AvgL ave_localstax
rename CombinedRate stloc_staxrate
drop Rank Combined MaxL
rename statename stname
merge 1:1 stname using fips_states
drop if _m == 2 // Territories
drop _m
rename stname st_name

cd $data
save st_salestax2017, replace


/**********************************
 State Transfer Policy Measures in 2017 (collected by Adam. See Data Information sheet in statepolicy folder
 **********************************/
 cd $data
 cd statepolicy
 import excel using "state benefit data.xlsx", clear first
 
 replace EITC2017 = regexr(EITC2017,"\*","")
 rename MinWage minwage2017
 rename EITC2017 eitc2017
 rename TANF tanf_maxben2kid 
 rename State state
 replace state = upper(state)
 destring eitc2017, replace
 gen eitc_refundable = EITCR == "yes"
 gen medicaid_exp = Medic == "yes"
 drop EITCR Medic
 
 replace minwage2017 = 7.25 if minwage<7.25 //we want to have the effective minimum wage (which is the Federal if it higher)
 
 cd $data
 rename state stname
 merge 1:1 stname using fips_states
 drop if _m == 2 //territories
 drop _m
 rename stname st_name

 gen year = 2017
 compress
 cd $data
 save state_transferpolicy2017, replace
 
 


/************************************
Read in County SSA SSI data

Start date: Sept 4, 2020
Prepared by Riley Wilson
			TJ Barden
			
*************************************/

//Note: Source data is incomplete for Georgia-2007, Kentucky-2007, Texas-2004

cd $data
cd ssa_ssirecipients


foreach yr in 02 {
	foreach st in "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" "Nevada" "New Hampshire" "New Jersey" "New Mexico" "New York" "North Carolina" "North Dakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" "Rhode Island" "South Carolina" "South Dakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" "Washington" "West Virginia" "Wisconsin" "Wyoming" {
		cd $data
		cd ssa_ssirecipients
		import excel using ssi_sc`yr'.xlsx, clear sheet("`st'")
		//clean data
		rename A st_name
		rename B ssi_tot
		rename C ssi_aged
		rename D ssi_disabled
		rename E ssi_under18
		rename F ssi_18_64
		rename G ssi_above64
		rename H ssi_alsoOASDI
		rename I ssi_paymenttot
		keep if _n==9 //State totals
		foreach var of varlist ssi_* {
			cap tostring `var', replace
			replace `var' = "" if `var' == "b"
			replace `var' = "" if `var' == "a"
		}
		destring ssi_*, replace
		
		drop if st_name=="Unknown"
		
		drop if st_name=="."

		gen year = 20`yr'
		local st1="`st'"
		if "`st'" == "New Hampshire" {
			local st1 = "New_Hampshire"
		}
		if "`st'" == "New Jersey" {
			local st1 = "New_Jersey"
		}
		if "`st'" == "New Mexico" {
			local st1 = "New_Mexico"
		}
		if "`st'" == "New York" {
			local st1 = "New_York"
		}
		if "`st'" == "North Carolina" {
			local st1 = "North_Carolina"
		}
		if "`st'" == "North Dakota" {
			local st1 = "North_Dakota"
		}
		if "`st'" == "Rhode Island" {
			local st1 = "Rhode_Island"
		}
		if "`st'" == "South Carolina" {
			local st1 = "South_Carolina"
		}
		if "`st'" == "South Dakota" {
			local st1 = "South_Dakota"
		}
		if "`st'" == "West Virginia" {
			local st1 = "West_Virginia"
		}
		if "`st'" == "District of Columbia" {
			local st1 = "District_of_Columbia"
		}
		
	
	
	//Various county names were changed or were recorded incorrectly/inconsistently. The following represent changes to county names in order to allow for a proper merge with the Commuting Zones Data used below.
	
		replace st_name = regexr(st_name," "," ") //The format of the space changed after 2002.
		replace st_name = regexr(st_name,"Total, ","")
		
		compress
		cd $data
		cd ssa_ssirecipients
		save st_ssicases_`st1'_20`yr', replace
	}
}


foreach yr in 03 04 05 06 07 08 {
	foreach st in "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" "Nevada" "New Hampshire" "New Jersey" "New Mexico" "New York" "North Carolina" "North Dakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" "Rhode Island" "South Carolina" "South Dakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" "Washington" "West Virginia" "Wisconsin" "Wyoming" {
		
		if "`yr'" == "08" {
			local st2 = "Table 3 - `st'"
		}
		if "`yr'" ~= "08" {
			local st2 = "`st'"
		}
		cd $data
		cd ssa_ssirecipients
		import excel using ssi_sc`yr'.xlsx, clear sheet("`st2'")
		//clean data
		
		display "`st'""`yr'"
		gen st_name = "`st'"
		drop B
		rename C ssi_tot
		rename D ssi_aged
		rename E ssi_disabled
		rename F ssi_under18
		rename G ssi_18_64
		rename H ssi_above64
		rename I ssi_alsoOASDI
		rename J ssi_paymenttot
		
		keep if _n==5 //State totals
		
		
		gen cty = 1 if ssi_tot == "Counties" | ssi_tot == "Counties (cont.)" 
		gen city = 1 if ssi_tot == "Independent cities" | ssi_tot == "Independent city" | ssi_tot == ""
		replace cty = 1 if cty[_n-1] == 1 & city ~= 1
		replace city = 1 if city[_n-1] == 1 & cty ~= 1
		
		
		drop if ssi_tot == "Independent cities"
		drop if ssi_tot== "Counties"
		drop if ssi_tot== "Counties (cont.)"
		drop if ssi_tot== "County"
		drop if ssi_tot== "Total"
		drop if ssi_tot== "Independent cities"
		drop if ssi_tot== "Independent city"
		drop if ssi_tot== "Independent cities (cont.)"
		
		foreach var of varlist ssi_* {
			replace `var' = "" if `var' == "b"
		}
		foreach var of varlist ssi_* {
			replace `var' = "" if `var' == "a"
		}
		
		if "`yr'"== "07" {
			if "`st'"=="Delaware" {
				drop K L M N O P Q R
			}
		}
		capture {
			drop J K L M
		}
	
		destring ssi_*, replace
		
		//add year, state 
		gen year = 20`yr'
		
		local st3="`st'"
		if "`st'" == "New Hampshire" {
			local st3 = "New_Hampshire"
		}
		if "`st'" == "New Jersey" {
			local st3 = "New_Jersey"
		}
		if "`st'" == "New Mexico" {
			local st3 = "New_Mexico"
		}
		if "`st'" == "New York" {
			local st3 = "New_York"
		}
		if "`st'" == "North Carolina" {
			local st3 = "North_Carolina"
		}
		if "`st'" == "North Dakota" {
			local st3 = "North_Dakota"
		}
		if "`st'" == "Rhode Island" {
			local st3 = "Rhode_Island"
		}
		if "`st'" == "South Carolina" {
			local st3 = "South_Carolina"
		}
		if "`st'" == "South Dakota" {
			local st3 = "South_Dakota"
		}
		if "`st'" == "West Virginia" {
			local st3 = "West_Virginia"
		}
		drop city
		drop cty
		drop A
	
		compress
		//saving before reading in the next state
		cd $data
		cd ssa_ssirecipients
		save st_ssicases_`st3'_20`yr', replace
		
	}
}


//Writing in Washington D.C. — which is not included in these data as its own sheet.
//Note: Washington D.C. data for 2002-2008 and 2010 does not include ssi_paymenttot
cd $data
cd ssa_ssirecipients
import excel using ssi_sc02.xlsx, clear sheet("Sheet1")
keep if _n==25 //drop heading
drop A
rename B ssi_tot
rename C ssi_aged
rename D ssi_disabled
rename E ssi_under18
rename F ssi_18_64
rename G ssi_above64
rename H ssi_alsoOASDI
gen year = 2002
gen st_name = "District of Columbia"
destring ssi_*, replace	
compress
cd $data
cd ssa_ssirecipients
save st_ssicases_District_of_Columbia_2002, replace



foreach yr in 03 04 05 06 07 08 10 {
	display `yr'
	cd $data
	cd ssa_ssirecipients
	import excel using ssi_sc`yr'.xlsx, clear sheet("Table 1")
	rename D ssi_tot
	rename E ssi_aged
	rename F ssi_disabled
	rename G ssi_under18
	rename H ssi_18_64
	rename I ssi_above64
	rename J ssi_alsoOASDI
	drop B C //drop empty columns
	keep if A == "District of Columbia"

	gen year = 20`yr'
	gen st_name = "District of Columbia"
	drop A
	
	destring ssi*, replace
	
	compress
	cd $data
	cd ssa_ssirecipients
	save st_ssicases_District_of_Columbia_20`yr', replace
}


//combine all the states and years together
foreach yr in 02 03 04 05 06 07 08 {
	foreach st in "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "District_of_Columbia" "Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" "Nevada" "New_Hampshire" "New_Jersey" "New_Mexico" "New_York" "North_Carolina" "North_Dakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" "Rhode_Island" "South_Carolina" "South_Dakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" "Washington" "West_Virginia" "Wisconsin" "Wyoming"  {
		cd $data
		cd ssa_ssirecipients
		capture {
			drop J K L M
		}
		capture {
			drop K L
		}
		display "`st'`yr'"
		compress
		append using st_ssicases_`st'_20`yr'
	}
}
	
cd $data
cd ssa_ssirecipients	
append using st_ssicases_09_16

drop ssi_paymenttot

//Get state and county codes
replace st_name = upper(st_name)
cd $data
rename st_name stname
merge m:1 stname using fips_states

drop if stname=="AMERICAN SAMOA"
drop if stname=="GUAM"
drop if stname=="PUERTO RICO"
drop if stname=="VIRGIN ISLANDS"

drop _m

order st_fips
collapse (sum) ssi_tot ssi_aged ssi_disabled ssi_under18 ssi_18_64 ssi_above64 ssi_alsoOASDI, by(st_fips year stname)

save st_ssicases_02_16, replace
