/*****************************************
Data Generation

Prepared by Riley Wilson
			Thomas Barden
Start Date: October 28th, 2021

******************************************/


//global data "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
//global output "C:\Users\rwilson9\Box\Research\ssi_statesupplement\output"

global data "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/data"
global output "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/output"


/**************************
Prep County Level Unemployment Rates (LAUS)
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

cd $data
save cty_annualemp2000_2018, replace


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


/*****************************
County to County Commute Data from LODES
*****************************/
cd $data
use allcty_bysource2002_2017, clear
drop if drop == 1 
drop drop
rename workctyfips dest_ctyfips
rename homectyfips orig_ctyfips
drop if orig_ctyfips == dest_ctyfips
drop if dest_ctyfips == . | orig_ctyfips == .

compress
cd $data
save lodes_ctycommute_2002_2017, replace


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

/* example
clear
set obs 10

gen obnum = .
forval i = 1/10 {	
	replace obnum = `i' if _n == `i'
}

gen test = .
forval i = 2(2)10 {	
	replace test= `i' if _n == `i'
}
*/
//Work with the 2009-2018 data
cd $data
cd ssa_ssirecipients
import excel recipients_by_county_2018-2009.xlsx, clear
rename A stname
rename B cty_name_lc
rename C cty_fips
rename D ssi_tot
rename E ssi_aged
rename F ssi_disabled
rename G ssi_under18
rename H ssi_18_64
rename I ssi_above64
rename J ssi_alsoOASDI
rename K ssi_paymenttot
rename L year
gen cty_name=upper(cty_name_lc)
gen state=upper(stname)

drop if _n<=3
foreach var of varlist ssi_* {
			replace `var' = "" if `var' == "b"
		}
		destring ssi_*, replace
foreach var of varlist ssi_* {
			replace `var' = "" if `var' == "a"
		}
		destring ssi_*, replace
foreach var of varlist ssi_* {
			replace `var' = "" if `var' == "(X)"
		}
		destring ssi_*, replace
		
drop if stname==""
//replace cty_fips="" if cty_name=="UNKNOWN" //Cases assigned to state but not a specific county.
drop if cty_name == "UNKNOWN"
destring year, replace
destring cty_fips, replace

compress
cd $data
cd ssa_ssirecipients
save ssicases_2009_2018, replace

//Read in 2002 data from https://www.ssa.gov/policy/docs/statcomps/ssi_sc/2002/al.html
//Copied from PDF to Excel
cd $data
cd ssa_ssirecipients


foreach yr in 02 {
	foreach st in "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware" "Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" "Nevada" "New Hampshire" "New Jersey" "New Mexico" "New York" "North Carolina" "North Dakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania" "Rhode Island" "South Carolina" "South Dakota" "Tennessee" "Texas" "Utah" "Vermont" "Virginia" "Washington" "West Virginia" "Wisconsin" "Wyoming" {
		cd $data
		cd ssa_ssirecipients
		import excel using ssi_sc`yr'.xlsx, clear sheet("`st'")
		//clean data
		rename A cty_name
		rename B ssi_tot
		rename C ssi_aged
		rename D ssi_disabled
		rename E ssi_under18
		rename F ssi_18_64
		rename G ssi_above64
		rename H ssi_alsoOASDI
		rename I ssi_paymenttot
		drop if _n<=9 //To drop the header of each table
		foreach var of varlist ssi_* {
			cap tostring `var', replace
			replace `var' = "" if `var' == "b"
			replace `var' = "" if `var' == "a"
		}
		destring ssi_*, replace
		
		drop if cty_name=="Unknown"
		
		drop if cty_name=="."

		gen year = 20`yr'
		gen stname = "`st'"
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
	
		replace cty_name = regexr(cty_name," "," ") //The format of the space changed after 2002.
	
		if "`st'"=="Virginia" {
			replace cty_name="Albemarle" if cty_name=="Albermarle"
			replace cty_name="Alexandria City" if cty_name=="Alexandria"
			replace cty_name="Bristol City" if cty_name=="Bristol"
			replace cty_name="Buena Vista City" if cty_name=="Buena Vista"
			replace cty_name="Charles City" if cty_name=="Charles City County"
			replace cty_name="Charlottesville City" if cty_name=="Charlottesville"
			replace cty_name="Chesapeake City" if cty_name=="Chesapeake"
			replace cty_name="Colonial Heights City" if cty_name=="Colonial Heights"
			replace cty_name="Covington City" if cty_name=="Covington"
			replace cty_name="Danville City" if cty_name=="Danville"
			replace cty_name="Emporia City" if cty_name=="Emporia"
			replace cty_name="Falls Church City" if cty_name=="Falls Church"
			replace cty_name="Fredericksburg City" if cty_name=="Fredericksburg"
			replace cty_name="Galax City" if cty_name=="Galax"
			replace cty_name="Hampton City" if cty_name=="Hampton"
			replace cty_name="Harrisonburg City" if cty_name=="Harrisonburg"
			replace cty_name="Hopewell City" if cty_name=="Hopewell"
			replace cty_name="James City" if cty_name=="James City County"
			replace cty_name="Lexington City" if cty_name=="Lexington"
			replace cty_name="Lynchburg City" if cty_name=="Lynchburg"
			replace cty_name="Manassas Park City" if cty_name=="Manassas Park"
			replace cty_name="Manassas City" if cty_name=="Manassas"
			replace cty_name="Martinsville City" if cty_name=="Martinsville"
			replace cty_name="Newport News City" if cty_name=="Newport News"
			replace cty_name="Norfolk City" if cty_name=="Norfolk"
			replace cty_name="Norton City" if cty_name=="Norton"
			replace cty_name="Petersburg City" if cty_name=="Petersburg"
			replace cty_name="Poquoson City" if cty_name=="Poquoson"
			replace cty_name="Portsmouth City" if cty_name=="Portsmouth"
			replace cty_name="Radford City" if cty_name=="Radford"
			replace cty_name="Salem City" if cty_name=="Salem"
			replace cty_name="Staunton City" if cty_name=="Staunton"
			replace cty_name="Suffolk City" if cty_name=="Suffolk"
			replace cty_name="Virginia Beach City" if cty_name=="Virginia Beach"
			replace cty_name="Waynesboro City" if cty_name=="Waynesboro"
			replace cty_name="Williamsburg City" if cty_name=="Williamsburg"
			replace cty_name="Winchester City" if cty_name=="Winchester"
		}
		if "`st'"=="Texas" {
			replace cty_name="Comanche" if cty_name=="Comanchel"
			replace cty_name="DeWitt" if cty_name=="De Witt"
		}
		if "`st'"=="Colorado" {
			replace cty_name="Custer" if cty_name=="Custe"
		}
		if "`st'"=="New Mexico" {
			replace cty_name="DeBaca" if cty_name=="De Baca"
			replace cty_name="San Juan" if cty_name=="San Jaun"
		}
		if "`st'"=="Illinois" {
			replace cty_name="DeKalb" if cty_name=="De Kalb"
		}
		if "`st'"=="Tennessee" {
			replace cty_name="DeKalb" if cty_name=="De Kalb"
		}
		if "`st'"=="Florida" {
			replace cty_name="DeSoto" if cty_name=="De Soto"
		}
		if "`st'"=="Mississippi" {
			replace cty_name="DeSoto" if cty_name=="De Soto"
		}
		if "`st'"=="Indiana" {
			replace cty_name="De Kalb" if cty_name=="DeKalb"
			replace cty_name="La Porte" if cty_name=="LaPorte"
		}
		if "`st'"=="Louisiana" {
			replace cty_name="De Soto" if cty_name=="DeSoto"
		}
		if "`st'"=="Illinois" {
			replace cty_name="De Witt" if cty_name=="DeWitt"
			replace cty_name="La Salle" if cty_name=="LaSalle"
			replace cty_name="DuPage" if cty_name=="Du Page"
			replace cty_name="St. Clair" if cty_name=="St. Clair"
		}
		if "`st'"=="California" {
			replace cty_name="El Dorado" if cty_name=="Eldorado"
		}
		if "`st'"=="New Hampshire" {
			replace cty_name="Hillsborough" if cty_name=="Hillsboro"
		}
		if "`st'"=="Nebraska" {
			replace cty_name="Hitchcock" if cty_name=="Hitchock"
		}
		if "`st'"=="Alaska" {
			replace cty_name="Kenai Peninsula" if cty_name=="Kenai-Cook Inlet"
			replace cty_name="Prince of Wales-Outer Ketchikan" if cty_name=="Prince of Wales"
			replace cty_name="Prince of Wales-Outer Ketchikan" if cty_name=="Prince of Wales-    Outer Ketchican"
			replace cty_name="Prince of Wales-Outer Ketchikan" if cty_name=="Prince of Wales-Outer    Ketchikan"
			replace cty_name="Skagway-Hoonah-Angoon" if cty_name=="Skagway-Hoonah-"
			replace cty_name="Skagway-Hoonah-Angoon" if cty_name=="Skagway-Yakutat"
		}
		if "`st'"=="North Dakota" {
			replace cty_name="LaMoure" if cty_name=="La Moure"
			replace cty_name="Mountrail" if cty_name=="Mountrial"
		}
		if "`st'"=="Pennsylvania" {
			replace cty_name="Mc Kean" if cty_name=="McKean"
		}
		if "`st'"=="New York" {
			replace cty_name="Schenectady" if cty_name=="Schnectady"
		}
		if "`st'"=="Missouri" {
			replace cty_name="Ste. Genevieve" if cty_name=="Ste. Genevieve"
			replace cty_name="DeKalb" if cty_name=="De Kalb"
			
		}
		if "`st'"=="Louisiana" {
			replace cty_name="St. Bernard" if cty_name=="St. Bernard"
			replace cty_name="St. Charles" if cty_name=="St. Charles"
		}
		if "`st'"=="Alabama" {
			replace cty_name="St. Clair" if cty_name=="St. Clair"
		}
		
	//Some counties were merged into others over this time period. We will treat such counties as if the merger had already taken place.
		if "`st'"=="Virginia" {
			replace cty_name="Halifax" if cty_name=="South Boston City"
		}
		if "`st'"=="South Dakota" {
			replace cty_name="Jackson" if cty_name=="Washabaugh"
		}
		
		
		compress
		cd $data
		cd ssa_ssirecipients
		save ssicases_`st1'_20`yr', replace
	}
}


//Check that format in early years are the same
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
		rename A cty_name
		rename C ssi_tot
		rename D ssi_aged
		rename E ssi_disabled
		rename F ssi_under18
		rename G ssi_18_64
		rename H ssi_above64
		rename I ssi_alsoOASDI
		rename J ssi_paymenttot
		
		drop if _n<=5 //drop heading
		drop if ssi_tot == "" //drop footnotes
		drop B //drop empty column
		
		
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
		
	
			
		if "`st'" != "Nevada" replace cty_name = cty_name + " City" if city == 1 		//captures all but Carson City NV
		assert regexm(cty_name, "City City") == 0
		
		drop city cty
		
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
		
	//Various county names were changed or were recorded incorrectly. The following represent changes to county names in order to allow for a proper merge with the Commuting Zones Data used below.
		if "`st'"=="Virginia" {
			replace cty_name="Albemarle" if cty_name=="Albermarle"
			replace cty_name="Alexandria City" if cty_name=="Alexandria"
			replace cty_name="Bristol City" if cty_name=="Bristol"
			replace cty_name="Buena Vista City" if cty_name=="Buena Vista"
			replace cty_name="Charles City" if cty_name=="Charles City County"
			replace cty_name="Charlottesville City" if cty_name=="Charlottesville"
			replace cty_name="Chesapeake City" if cty_name=="Chesapeake"
			replace cty_name="Colonial Heights City" if cty_name=="Colonial Heights"
			replace cty_name="Covington City" if cty_name=="Covington"
			replace cty_name="Danville City" if cty_name=="Danville"
			replace cty_name="Emporia City" if cty_name=="Emporia"
			replace cty_name="Falls Church City" if cty_name=="Falls Church"
			replace cty_name="Fredericksburg City" if cty_name=="Fredericksburg"
			replace cty_name="Galax City" if cty_name=="Galax"
			replace cty_name="Hampton City" if cty_name=="Hampton"
			replace cty_name="Harrisonburg City" if cty_name=="Harrisonburg"
			replace cty_name="Hopewell City" if cty_name=="Hopewell"
			replace cty_name="James City" if cty_name=="James City County"
			replace cty_name="Lexington City" if cty_name=="Lexington"
			replace cty_name="Lynchburg City" if cty_name=="Lynchburg"
			replace cty_name="Manassas Park City" if cty_name=="Manassas Park"
			replace cty_name="Manassas City" if cty_name=="Manassas"
			replace cty_name="Martinsville City" if cty_name=="Martinsville"
			replace cty_name="Newport News City" if cty_name=="Newport News"
			replace cty_name="Norfolk City" if cty_name=="Norfolk"
			replace cty_name="Norton City" if cty_name=="Norton"
			replace cty_name="Petersburg City" if cty_name=="Petersburg"
			replace cty_name="Poquoson City" if cty_name=="Poquoson"
			replace cty_name="Portsmouth City" if cty_name=="Portsmouth"
			replace cty_name="Radford City" if cty_name=="Radford"
			replace cty_name="Salem City" if cty_name=="Salem"
			replace cty_name="Staunton City" if cty_name=="Staunton"
			replace cty_name="Suffolk City" if cty_name=="Suffolk"
			replace cty_name="Virginia Beach City" if cty_name=="Virginia Beach"
			replace cty_name="Waynesboro City" if cty_name=="Waynesboro"
			replace cty_name="Williamsburg City" if cty_name=="Williamsburg"
			replace cty_name="Winchester City" if cty_name=="Winchester"
			
		}
		if "`st'"=="Texas" {
			replace cty_name="Comanche" if cty_name=="Comanchel"
			replace cty_name="DeWitt" if cty_name=="De Witt"
		}
		if "`st'"=="Colorado" {
			replace cty_name="Custer" if cty_name=="Custe"
		}
		if "`st'"=="New Mexico" {
			replace cty_name="DeBaca" if cty_name=="De Baca"
			replace cty_name="San Juan" if cty_name=="San Jaun"
		}
		if "`st'"=="Illinois" {
			replace cty_name="DeKalb" if cty_name=="De Kalb"
		}
		if "`st'"=="Tennessee" {
			replace cty_name="DeKalb" if cty_name=="De Kalb"
		}
		if "`st'"=="Florida" {
			replace cty_name="DeSoto" if cty_name=="De Soto"
		}
		if "`st'"=="Mississippi" {
			replace cty_name="DeSoto" if cty_name=="De Soto"
			replace cty_name="DeSoto" if cty_name=="De Soto"
		}
		if "`st'"=="Indiana" {
			replace cty_name="De Kalb" if cty_name=="DeKalb"
			replace cty_name="La Porte" if cty_name=="LaPorte"
		}
		if "`st'"=="Louisiana" {
			replace cty_name="De Soto" if cty_name=="DeSoto"
		}
		if "`st'"=="Illinois" {
			replace cty_name="De Witt" if cty_name=="DeWitt"
			replace cty_name="La Salle" if cty_name=="LaSalle"
			replace cty_name="DuPage" if cty_name=="Du Page"
		}
		if "`st'"=="California" {
			replace cty_name="El Dorado" if cty_name=="Eldorado"
		}
		if "`st'"=="New Hampshire" {
			replace cty_name="Hillsborough" if cty_name=="Hillsboro"
		}
		if "`st'"=="Nebraska" {
			replace cty_name="Hitchcock" if cty_name=="Hitchock"
		}
		if "`st'"=="Alaska" {
			replace cty_name="Kenai Peninsula" if cty_name=="Kenai-Cook Inlet"
			replace cty_name="Prince of Wales-Outer Ketchikan" if cty_name=="Prince of Wales"
			replace cty_name="Prince of Wales-Outer Ketchikan" if cty_name=="Prince of Wales-Outer"
			replace cty_name="Prince of Wales-Outer Ketchikan" if cty_name=="Prince of Wales-"
			replace cty_name="Skagway-Hoonah-Angoon" if cty_name=="Skagway-Hoonah-"
		}
		if "`st'"=="North Dakota" {
			replace cty_name="LaMoure" if cty_name=="La Moure"
			replace cty_name="Mountrail" if cty_name=="Mountrial"
		}
		if "`st'"=="Pennsylvania" {
			replace cty_name="Mc Kean" if cty_name=="McKean"
		}
		if "`st'"=="New York" {
			replace cty_name="Schenectady" if cty_name=="Schnectady"
		}
		if "`st'"=="Missouri" {
			replace cty_name="Ste. Genevieve" if cty_name=="Ste. Genevieve"
			replace cty_name="St. Charles" if cty_name=="St. Charles"
		}
		if "`st'"=="Louisiana" {
			replace cty_name="St. Bernard" if cty_name=="St. Bernard"
			replace cty_name="St. Charles" if cty_name=="St. Charles"
		}
		if "`st'"=="Alabama" {
			replace cty_name="St. Clair" if cty_name=="St. Clair"
		}

		destring ssi_*, replace
		drop if cty_name=="Unknown"
		
		//add year, state 
		gen year = 20`yr'
		gen stname = "`st'"
		
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
		
	//South Boston City, VA and Washabaugh, SD were merged into Halifax, VA and Jackson, SD respectively over this time period. We will treat such counties as if the merge had already taken place.
		if "`st'"=="Virginia" {
			replace cty_name="Halifax" if cty_name=="South Boston City"
		}
		if "`st'"=="South Dakota" {
			replace cty_name="Jackson" if cty_name=="Washabaugh"
		}
		
		compress
		//saving before reading in the next state
		cd $data
		cd ssa_ssirecipients
		save ssicases_`st3'_20`yr', replace
		
	}
}


/*
2007 
We ascribe these to clerical error resulting in gaps in the original data. 
Missing counties are clumped together and are only missing in 2007. We loop through these states individually a second time using separate state specific files drawn from the same source, as the aforementioned gaps only exist in the general data for the entire United States. The state specific files for 2007 are whole and complete.
The associated files can be found here: https://www.ssa.gov/policy/docs/statcomps/ssi_sc/2007/index.html
- 13081 (Crisp, Georgia)
- 13083 (Dade, Georgia)
- 13085 (Dawson, Georgia)
- 13161 (Jeff Davis, Georgia)
- 13163 (Jefferson, Georgia)
- 13615 (Jenkins, Georgia)
- 13243 (Randolph, Georgia)
- 13245 (Richmond, Georgia)
- 13247 (Rockdale, Georgia)
- 21079 (Garrard, Kentucky)
- 21081 (Grant, Kentucky)
- 21083 (Graves, Kentucky)
- 21159 (Martin, Kentucky)
- 21161 (Mason, Kentucky)
- 21163 (Meade, Kentucky)
*/
foreach st in "Georgia" "Kentucky" {
		cd $data
		cd ssa_ssirecipients
		import excel using `st'07, clear sheet("Table 3")
		//clean data
		rename A cty_name
		rename C ssi_tot
		rename D ssi_aged
		rename E ssi_disabled
		rename F ssi_under18
		rename G ssi_18_64
		rename H ssi_above64
		rename I ssi_alsoOASDI
		rename J ssi_paymenttot

		drop if cty_name ==""

		drop if ssi_tot == "" //drop footnotes
		drop B //drop empty column

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
		
		destring ssi_*, replace
		drop if cty_name=="Unknown"
		
		//add year, state 
		gen year = 2007
		gen stname = "`st'"
		
		compress
		//saving before reading in the next state
		cd $data
		cd ssa_ssirecipients
		save ssicases_`st'_2007, replace	
		
}

//Writing in Washington D.C. — which is not included in these data as its own sheet.
//Note: Washington D.C. data for 2002-2008 and 2010 does not include ssi_paymenttot
cd $data
cd ssa_ssirecipients
import excel using ssi_sc02.xlsx, clear sheet("Sheet1")
drop if _n<=15 //drop heading
rename A cty_name
rename B ssi_tot
rename C ssi_aged
rename D ssi_disabled
rename E ssi_under18
rename F ssi_18_64
rename G ssi_above64
rename H ssi_alsoOASDI
drop if cty_name != "District of Columbia"
gen year = 2002
gen stname = "District of Columbia"
replace cty_name = "DC" if stname == "District of Columbia"

destring ssi_*, replace	
compress
cd $data
cd ssa_ssirecipients
save ssicases_District_of_Columbia_2002, replace

foreach yr in 03 04 05 06 07 08 10 {
	cd $data
	cd ssa_ssirecipients
	import excel using ssi_sc`yr'.xlsx, clear sheet("Table 1")
	rename A cty_name
	rename D ssi_tot
	rename E ssi_aged
	rename F ssi_disabled
	rename G ssi_under18
	rename H ssi_18_64
	rename I ssi_above64
	rename J ssi_alsoOASDI
		
	drop if _n<=4 //drop heading
	drop if cty_name != "District of Columbia" //drop footnotes
	drop B C //drop empty columns
	gen year = 20`yr'
	gen stname = "District of Columbia"
	replace cty_name = "DC" if stname == "District of Columbia"
	
	destring ssi_*, replace
	
	compress
	cd $data
	cd ssa_ssirecipients
	save ssicases_District_of_Columbia_20`yr', replace
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
		append using ssicases_`st'_20`yr'
	}
}
	
drop if cty_name == ""	

//Some counties have multiple records for a single year.
collapse (sum) ssi_tot ssi_aged ssi_disabled ssi_under18 ssi_18_64 ssi_above64 ssi_alsoOASDI ssi_paymenttot, by (cty_name year stname)

//Get state and county codes
replace stname = upper(stname)
rename cty_name cty_name_lc
gen cty_name=upper(cty_name_lc)
cd $data
merge m:1 stname using fips_states

drop if stname=="AMERICAN SAMOA"
drop if stname=="GUAM"
drop if stname=="PUERTO RICO"
drop if stname=="VIRGIN ISLANDS"
//_m == 1, none
//_m == 2, states not in panel (ex. Puerto Rico)
drop _m
rename st_fips stfips

//merge to the county code
cd $data
merge m:1 cty_name stfips using cz_counties_plusbroomfield, keepusing(ctyfips cz2000)

replace ctyfips = 11001 if cty_name == "DC"

rename ctyfips cty_fips
rename stfips st_fips
drop if cty_name==""
drop if stname==""
drop _m

cd $data
cd ssa_ssirecipients
save ssicases_2002_2008, replace

//append to the 2009-2018 data
append using ssicases_2009_2018

replace stname = upper(stname)

drop st_fips
drop stateabbreviation

bys cty_fips: egen temp= max(cz2000)
replace cz2000 = temp if cz2000 == .

drop temp

drop if cty_fips==.

replace cty_fips = 51005 if cty_fips == 51560 // Virginia Clifton Forge City was absorbed into Alleghany County
replace cty_fips = 46102 if cty_fips == 46113 // South Dakota Shannon County was renamed and its code changed
replace cty_fips = 51019 if cty_fips == 51515 // Virginia Bedford City was absorbed into Bedford County
replace cty_name = "ALLEGHANY" if cty_name == "CLIFTON FORGE CITY"
replace cty_name = "BEDFORD" if cty_name == "BEDFORD CITY"
replace cty_name = "BEDFORD" if cty_name == "BEDFORD B"
replace cty_name = "OGLALA LAKOTA" if cty_name == "SHANNON"
replace cty_name = "POQUOSON CITY" if cty_name == "POQUOSON"


replace cty_fips = 11001 if cty_fips == 11000 // Washington DC is coded differently depending on the dataset. We standardize it to 11001

collapse (sum) ssi_tot ssi_aged ssi_disabled ssi_under18 ssi_18_64 ssi_above64 ssi_alsoOASDI ssi_paymenttot, by (cty_name year stname cz2000 cty_fips) //Some counties have multiple observations in the same year. We will sum the case count. 

cd $data
save ssicases_2002_2018, replace








/************************************
QWI Write-In

Start date: Oct 23rd, 2020
Prepared by Riley Wilson
			TJ Barden

*************************************/

/*
(1) Read in the data for each state.
(2) Keep observations for all industries and each age*sex group
(3) Collapse to get annual mean for each county by year by age*sex group
(4) Reshape, to get one observation per county and year
(5) Append all of the years together
*/

//cd $data\qwi\sex_age
cd $data/qwi/sex_age
clear
set obs 1
gen drop = 1
save qwi_age_all, replace

//insheet using /Users/t.j.barden/Box/ssi_statesupplement/data/qwi/sex_age/qwi_wy_sa_f_gc_ns_oslp_u.csv, names clear

//local files : dir "${data}\qwi\sex_age" files "*.csv" //Wilson
local files : dir "${data}/qwi/sex_age" files "*.csv" //Barden
foreach file in `files' {
	//cd ${data}\qwi\sex_age
	cd ${data}/qwi/sex_age
	insheet using `file', names clear
	drop periodicity seasonadj ownercode race ethnicity education firmage firmsize
	
	gen male = sex == 1
	replace male = 2 if sex == 0
	
	rename geography ctyfips
	
	drop if ind_level=="S"
	
	collapse (mean) emptotal, by (ctyfips sex year agegrp)
	
	gen gender_age_group = .
	replace gender_age_group = 0 if sex == 2 & agegrp == "A00"
	replace gender_age_group = 1 if sex == 2 & agegrp == "A01"
	replace gender_age_group = 2 if sex == 2 & agegrp == "A02"
	replace gender_age_group = 3 if sex == 2 & agegrp == "A03"
	replace gender_age_group = 4 if sex == 2 & agegrp == "A04"
	replace gender_age_group = 5 if sex == 2 & agegrp == "A05"
	replace gender_age_group = 6 if sex == 2 & agegrp == "A06"
	replace gender_age_group = 7 if sex == 2 & agegrp == "A07"
	replace gender_age_group = 8 if sex == 2 & agegrp == "A08"
	replace gender_age_group = 9 if sex == 1 & agegrp == "A01"
	replace gender_age_group = 10 if sex == 1 & agegrp == "A02"
	replace gender_age_group = 11 if sex == 1 & agegrp == "A03"
	replace gender_age_group = 12 if sex == 1 & agegrp == "A04"
	replace gender_age_group = 13 if sex == 1 & agegrp == "A05"
	replace gender_age_group = 14 if sex == 1 & agegrp == "A06"
	replace gender_age_group = 15 if sex == 1 & agegrp == "A07"
	replace gender_age_group = 16 if sex == 1 & agegrp == "A08"
	replace gender_age_group = 17 if sex == 1 & agegrp == "A00"
	
	replace gender_age_group = 18 if sex == 0 & agegrp == "A00"
	replace gender_age_group = 19 if sex == 0 & agegrp == "A01"
	replace gender_age_group = 20 if sex == 0 & agegrp == "A02"
	replace gender_age_group = 21 if sex == 0 & agegrp == "A03"
	replace gender_age_group = 22 if sex == 0 & agegrp == "A04"
	replace gender_age_group = 23 if sex == 0 & agegrp == "A05"
	replace gender_age_group = 24 if sex == 0 & agegrp == "A06"
	replace gender_age_group = 25 if sex == 0 & agegrp == "A07"
	replace gender_age_group = 26 if sex == 0 & agegrp == "A08"
	
	drop sex agegrp

	reshape wide emptotal, i(ctyfips year) j(gender_age_group)
	
	rename emptotal0 emp_female_allages
	rename emptotal1 emp_female_14_18
	rename emptotal2 emp_female_19_21
	rename emptotal3 emp_female_22_24
	rename emptotal4 emp_female_25_34
	rename emptotal5 emp_female_35_44
	rename emptotal6 emp_female_45_54
	rename emptotal7 emp_female_55_64
	rename emptotal8 emp_female_65_99
	rename emptotal9 emp_male_14_18
	rename emptotal10 emp_male_19_21
	rename emptotal11 emp_male_22_24
	rename emptotal12 emp_male_25_34
	rename emptotal13 emp_male_35_44
	rename emptotal14 emp_male_45_54
	rename emptotal15 emp_male_55_64
	rename emptotal16 emp_male_65_99
	rename emptotal17 emp_male_allages
	
	rename emptotal18 emp_total_allages
	rename emptotal19 emp_total_14_18
	rename emptotal20 emp_total_19_21
	rename emptotal21 emp_total_22_24
	rename emptotal22 emp_total_25_34
	rename emptotal23 emp_total_35_44
	rename emptotal24 emp_total_45_54
	rename emptotal25 emp_total_55_64
	rename emptotal26 emp_total_65_99
	
	
	cd ${data}/qwi/sex_age
	//cd ${data}\qwi\sex_age
	append using qwi_age_all
	save qwi_age_all, replace
	
}

drop if drop==1
drop drop
cd ${data}\qwi\sex_age
save qwi_age_all, replace

cd $data\qwi\sex_education
clear
set obs 1
gen drop = 1
save qwi_education_all, replace

local files : dir "${data}\qwi\sex_education" files "*.csv"
foreach file in `files' {
	cd ${data}\qwi\sex_education
	insheet using `file', names clear
	drop periodicity seasonadj ownercode race agegrp ethnicity firmage firmsize
	
	rename geography ctyfips
	
	drop if ind_level=="S"
	
	collapse (mean) emptotal, by (ctyfips sex education year)
	
	gen gender_education = .
	replace gender_education = 0 if sex == 2 & education=="E0"
	replace gender_education = 1 if sex == 2 & education=="E1"
	replace gender_education = 2 if sex == 2 & education=="E2"
	replace gender_education = 3 if sex == 2 & education=="E3"
	replace gender_education = 4 if sex == 2 & education=="E4"
	
	
	replace gender_education = 9 if sex == 1 & education=="E0"
	replace gender_education = 5 if sex == 1 & education=="E1"
	replace gender_education = 6 if sex == 1 & education=="E2"
	replace gender_education = 7 if sex == 1 & education=="E3"
	replace gender_education = 8 if sex == 1 & education=="E4"

	
	replace gender_education = 10 if sex == 0 & education=="E0"
	replace gender_education = 11 if sex == 0 & education=="E1"
	replace gender_education = 12 if sex == 0 & education=="E2"
	replace gender_education = 13 if sex == 0 & education=="E3"
	replace gender_education = 14 if sex == 0 & education=="E4"
	
	replace gender_education = 15 if sex == 2 & education=="E5"
	replace gender_education = 16 if sex == 1 & education=="E5"
	replace gender_education = 17 if sex == 0 & education=="E5"
	
	drop sex education
	reshape wide emptotal, i(ctyfips year) j(gender_education)
	
	rename emptotal0 emp_female_all_education
	rename emptotal1 emp_female_no_high_school
	rename emptotal2 emp_female_high_school
	rename emptotal3 emp_female_some_college
	rename emptotal4 emp_female_college
	rename emptotal5 emp_male_no_high_school
	rename emptotal6 emp_male_high_school
	rename emptotal7 emp_male_some_college
	rename emptotal8 emp_male_college
	rename emptotal9 emp_male_all_education
	rename emptotal10 emp_total_all_education
	rename emptotal11 emp_total_no_high_school
	rename emptotal12 emp_total_high_school
	rename emptotal13 emp_total_some_college
	rename emptotal14 emp_total_college
	rename emptotal15 emp_female_under25
	rename emptotal16 emp_male_under25
	rename emptotal17 emp_total_under25
	
	
	cd ${data}\qwi\sex_education
	append using qwi_education_all
	save qwi_education_all, replace
	
}

drop if drop==1
drop drop
cd ${data}\qwi\sex_education
save qwi_education_all, replace







/************************
SEER Population Data

Start Date November 23rd, 2020
Prepared by Riley Wilson
			TJ Barden
			
This file will write in SEER data detailing county level population by year. 
************************/


/************************
SEER Population Data
************************/

cd $data

use SEER_pop_all_ages.dta, clear

drop if year < 2002

drop st stfips registry race hispanic

rename county ctyfips

destring ctyfips, replace


//The following changes are to bring this data set into alignment with the previous alterations we've had to make previously.
replace ctyfips = 08001 if ctyfips == 08911 //Adams County CO which was labelled differently pre 2001 when Broomfield was created
replace ctyfips = 08013 if ctyfips == 08912 //Boulder County CO which was labelled differently pre 2001 when Broomfield was created
replace ctyfips = 08059 if ctyfips == 08913 //Jefferson County CO which was labelled differently pre 2001 when Broomfield was created
replace ctyfips = 08123 if ctyfips == 08914 //Weld County CO which was labelled differently pre 2001 when Broomfield was created
replace ctyfips = 51515 if ctyfips == 051917 //Bedford City and Bedford County VA were combined
replace ctyfips = 51515 if ctyfips == 051019 //Bedford City and Bedford County VA were combined
replace ctyfips = 46102 if ctyfips == 46113 //Shannon County SD was remaned and recoded as Oglala Lakota County

gen pop_female = pop if sex == 2
gen pop_male = pop if sex == 1

gen pop_14_18 = pop if age<=18 & age>=14
gen pop_19_21 = pop if age>=19 & age<=21
gen pop_22_24 = pop if age>=22 & age<=24
gen pop_25_34 = pop if age>=25 & age<=34
gen pop_35_44 = pop if age>=35 & age<=44
gen pop_45_54 = pop if age>=45 & age<=54
gen pop_55_64 = pop if age>=55 & age<=64
gen pop_65_99 = pop if age>=65
gen pop_over25 = pop if age > 24

gen pop_female_14_18 = pop if age<=18 & age>=14 & sex == 2
gen pop_female_19_21 = pop if age>=19 & age<=21 & sex == 2
gen pop_female_22_24 = pop if age>=22 & age<=24 & sex == 2
gen pop_female_25_34 = pop if age>=25 & age<=34 & sex == 2
gen pop_female_35_44 = pop if age>=35 & age<=44 & sex == 2
gen pop_female_45_54 = pop if age>=45 & age<=54 & sex == 2
gen pop_female_55_64 = pop if age>=55 & age<=64 & sex == 2
gen pop_female_65_99 = pop if age>=65 & sex == 2
gen pop_female_over25 = pop if age > 24 & sex == 2

gen pop_male_14_18 = pop if age<=18 & age>=14 & sex == 1
gen pop_male_19_21 = pop if age>=19 & age<=21 & sex == 1
gen pop_male_22_24 = pop if age>=22 & age<=24 & sex == 1
gen pop_male_25_34 = pop if age>=25 & age<=34 & sex == 1
gen pop_male_35_44 = pop if age>=35 & age<=44 & sex == 1
gen pop_male_45_54 = pop if age>=45 & age<=54 & sex == 1
gen pop_male_55_64 = pop if age>=55 & age<=64 & sex == 1
gen pop_male_65_99 = pop if age>=65 & sex == 1
gen pop_male_over25 = pop if age > 24 & sex == 1


collapse (sum) pop*, by(ctyfips year)
rename pop totalpop


compress
cd $data
save seer_pop02_16, replace







/************************************
Education-Population Write-In

Start date: July 21, 2021
Prepared by Riley Wilson
			TJ Barden

*************************************/


cd $data/census_educshares
insheet using ACSST5Y2010.S1501_data_with_overlays_2021-06-25T104005.csv, names clear



foreach v in s1501_c01_001e s1501_c01_001m s1501_c01_002e s1501_c01_002m s1501_c01_003e s1501_c01_003m s1501_c01_004e s1501_c01_004m s1501_c01_005e s1501_c01_005m s1501_c01_006e s1501_c01_006m s1501_c01_007e s1501_c01_007m s1501_c01_008e s1501_c01_008m s1501_c01_009e s1501_c01_009m s1501_c01_010e s1501_c01_010m s1501_c01_011e s1501_c01_011m s1501_c01_012e s1501_c01_012m s1501_c01_013e s1501_c01_013m s1501_c01_014e s1501_c01_014m s1501_c01_015e s1501_c01_015m s1501_c01_016e s1501_c01_016m s1501_c01_017e s1501_c01_017m s1501_c01_018e s1501_c01_018m s1501_c01_019e s1501_c01_019m s1501_c01_020e s1501_c01_020m s1501_c01_021e s1501_c01_021m s1501_c01_022e s1501_c01_022m s1501_c01_023e s1501_c01_023m s1501_c01_024e s1501_c01_024m s1501_c01_025e s1501_c01_025m s1501_c01_026e s1501_c01_026m s1501_c01_027e s1501_c01_027m s1501_c01_028e s1501_c01_028m s1501_c01_029e s1501_c01_029m s1501_c01_030e s1501_c01_030m s1501_c01_031e s1501_c01_031m s1501_c01_032e s1501_c01_032m s1501_c01_033e s1501_c01_033m s1501_c01_034e s1501_c01_034m s1501_c01_035e s1501_c01_035m s1501_c01_036e s1501_c01_036m s1501_c01_037e s1501_c01_037m s1501_c01_038e s1501_c01_038m s1501_c02_001e s1501_c02_001m s1501_c02_002e s1501_c02_002m s1501_c02_003e s1501_c02_003m s1501_c02_004e s1501_c02_004m s1501_c02_005e s1501_c02_005m s1501_c02_006e s1501_c02_006m s1501_c02_007e s1501_c02_007m s1501_c02_008e s1501_c02_008m s1501_c02_009e s1501_c02_009m s1501_c02_010e s1501_c02_010m s1501_c02_011e s1501_c02_011m s1501_c02_012e s1501_c02_012m s1501_c02_013e s1501_c02_013m s1501_c02_014e s1501_c02_014m s1501_c02_015e s1501_c02_015m s1501_c02_016e s1501_c02_016m s1501_c02_017e s1501_c02_017m s1501_c02_018e s1501_c02_018m s1501_c02_019e s1501_c02_019m s1501_c02_020e s1501_c02_020m s1501_c02_021e s1501_c02_021m s1501_c02_022e s1501_c02_022m s1501_c02_023e s1501_c02_023m s1501_c02_024e s1501_c02_024m s1501_c02_025e s1501_c02_025m s1501_c02_026e s1501_c02_026m s1501_c02_027e s1501_c02_027m s1501_c02_028e s1501_c02_028m s1501_c02_029e s1501_c02_029m s1501_c02_030e s1501_c02_030m s1501_c02_031e s1501_c02_031m s1501_c02_032e s1501_c02_032m s1501_c02_033e s1501_c02_033m s1501_c02_034e s1501_c02_034m s1501_c02_035e s1501_c02_035m s1501_c02_036e s1501_c02_036m s1501_c02_037e s1501_c02_037m s1501_c02_038e s1501_c02_038m s1501_c03_001e s1501_c03_001m s1501_c03_002e s1501_c03_002m s1501_c03_003e s1501_c03_003m s1501_c03_004e s1501_c03_004m s1501_c03_005e s1501_c03_005m s1501_c03_006e s1501_c03_006m s1501_c03_007e s1501_c03_007m s1501_c03_008e s1501_c03_008m s1501_c03_009e s1501_c03_009m s1501_c03_010e s1501_c03_010m s1501_c03_011e s1501_c03_011m s1501_c03_012e s1501_c03_012m s1501_c03_013e s1501_c03_013m s1501_c03_014e s1501_c03_014m s1501_c03_015e s1501_c03_015m s1501_c03_016e s1501_c03_016m s1501_c03_017e s1501_c03_017m s1501_c03_018e s1501_c03_018m s1501_c03_019e s1501_c03_019m s1501_c03_020e s1501_c03_020m s1501_c03_021e s1501_c03_021m s1501_c03_022e s1501_c03_022m s1501_c03_023e s1501_c03_023m s1501_c03_024e s1501_c03_024m s1501_c03_025e s1501_c03_025m s1501_c03_026e s1501_c03_026m s1501_c03_027e s1501_c03_027m s1501_c03_028e s1501_c03_028m s1501_c03_029e s1501_c03_029m s1501_c03_030e s1501_c03_030m s1501_c03_031e s1501_c03_031m s1501_c03_032e s1501_c03_032m s1501_c03_033e s1501_c03_033m s1501_c03_034e s1501_c03_034m s1501_c03_035e s1501_c03_035m s1501_c03_036e s1501_c03_036m s1501_c03_037e s1501_c03_037m s1501_c03_038e s1501_c03_038m {       
	 local class = strpos("`v'", "m")
	 local key = substr("`v'", -4, 3)
	 display `key'
	 
	 if `class' > 0 {
	 	drop `v'
	 }
	 capture {
	 	if `key' > 27 {
			drop `v'
	 }
	 capture {
	 	if `key' == 14 | `key' == 15 {
			drop `v'
		}
	 }
	 } 
	 
}

gen cty_fips = substr(geo_id, -5, .)
order cty_fips
drop geo_id
destring cty_fips, replace
drop if cty_fips > 57000
sort cty_fips
destring s*, replace force

foreach v in s1501_c01_001e s1501_c01_002e s1501_c01_003e s1501_c01_004e s1501_c01_005e s1501_c01_006e s1501_c01_007e s1501_c01_008e s1501_c01_009e s1501_c01_010e s1501_c01_011e s1501_c01_012e s1501_c01_013e s1501_c01_016e s1501_c01_017e s1501_c01_018e s1501_c01_019e s1501_c01_020e s1501_c01_021e s1501_c01_022e s1501_c01_023e s1501_c01_024e s1501_c01_025e s1501_c01_026e s1501_c01_027e s1501_c02_001e s1501_c02_002e s1501_c02_003e s1501_c02_004e s1501_c02_005e s1501_c02_006e s1501_c02_007e s1501_c02_008e s1501_c02_009e s1501_c02_010e s1501_c02_011e s1501_c02_012e s1501_c02_013e s1501_c02_016e s1501_c02_017e s1501_c02_018e s1501_c02_019e s1501_c02_020e s1501_c02_021e s1501_c02_022e s1501_c02_023e s1501_c02_024e s1501_c02_025e s1501_c02_026e s1501_c02_027e s1501_c03_001e s1501_c03_002e s1501_c03_003e s1501_c03_004e s1501_c03_005e s1501_c03_006e s1501_c03_007e s1501_c03_008e s1501_c03_009e s1501_c03_010e s1501_c03_011e s1501_c03_012e s1501_c03_013e s1501_c03_016e s1501_c03_017e s1501_c03_018e s1501_c03_019e s1501_c03_020e s1501_c03_021e s1501_c03_022e s1501_c03_023e s1501_c03_024e s1501_c03_025e s1501_c03_026e s1501_c03_027e {
	local gender = substr("`v'", -6, 1)
	local age = substr("`v'", -3, 2)

	//Most of these variables are represented as percentage breakdowns of population values - we will convert these percentages to real numbers.
	//Total
	if (`gender' == 1) {
		//Pop 18-24
		if ((`age' >= 2) & (`age' <= 5)) {
		replace `v' = (`v'/100) * s1501_c01_001e
		}
		//Pop Over 25
		if ((`age' >= 7) & (`age' <= 13)) {
		replace `v' = (`v'/100) * s1501_c01_006e
		}
		//Pop 25-34
		if ((`age' >= 17) & (`age' <= 18)) {
		replace `v' = (`v'/100) * s1501_c01_016e
		}
		//Pop 35-44
		if ((`age' >= 20) & (`age' <= 21)) {
		replace `v' = (`v'/100) * s1501_c01_019e
		}
		//Pop 45-64
		if ((`age' >= 23) & (`age' <= 24)) {
		replace `v' = (`v'/100) * s1501_c01_022e
		}
		//Pop Over 65
		if ((`age' >= 26) & (`age' <= 27)) {
		replace `v' = (`v'/100) * s1501_c01_025e
		}
	}
	
	//Male
	if (`gender' == 2) {
		//Pop 18-24
		if ((`age' >= 2) & (`age' <= 5)) {
		replace `v' = (`v'/100) * s1501_c02_001e
		}
		//Pop Over 25
		if ((`age' >= 7) & (`age' <= 13)) {
		replace `v' = (`v'/100) * s1501_c02_006e
		}
		//Pop 25-34
		if ((`age' >= 17) & (`age' <= 18)) {
		replace `v' = (`v'/100) * s1501_c02_016e
		}
		//Pop 35-44
		if ((`age' >= 20) & (`age' <= 21)) {
		replace `v' = (`v'/100) * s1501_c02_019e
		}
		//Pop 45-64
		if ((`age' >= 23) & (`age' <= 24)) {
		replace `v' = (`v'/100) * s1501_c02_022e
		}
		//Pop Over 65
		if ((`age' >= 26) & (`age' <= 27)) {
		replace `v' = (`v'/100) * s1501_c02_025e
		}
	}
	
	//Female
	if (`gender' == 3) {
		//Pop 18-24
		if ((`age' >= 2) & (`age' <= 5)) {
		replace `v' = (`v'/100) * s1501_c03_001e
		}
		//Pop Over 25
		if ((`age' >= 7) & (`age' <= 13)) {
		replace `v' = (`v'/100) * s1501_c03_006e
		}
		//Pop 25-34
		if ((`age' >= 17) & (`age' <= 18)) {
		replace `v' = (`v'/100) * s1501_c03_016e
		}
		//Pop 35-44
		if ((`age' >= 20) & (`age' <= 21)) {
		replace `v' = (`v'/100) * s1501_c03_019e
		}
		//Pop 45-64
		if ((`age' >= 23) & (`age' <= 24)) {
		replace `v' = (`v'/100) * s1501_c03_022e
		}
		//Pop Over 65
		if ((`age' >= 26) & (`age' <= 27)) {
		replace `v' = (`v'/100) * s1501_c03_025e
		}
	}
}
	*/
foreach v in s1501_c01_001e s1501_c01_002e s1501_c01_003e s1501_c01_004e s1501_c01_005e s1501_c01_006e s1501_c01_007e s1501_c01_008e s1501_c01_009e s1501_c01_010e s1501_c01_011e s1501_c01_012e s1501_c01_013e s1501_c01_016e s1501_c01_017e s1501_c01_018e s1501_c01_019e s1501_c01_020e s1501_c01_021e s1501_c01_022e s1501_c01_023e s1501_c01_024e s1501_c01_025e s1501_c01_026e s1501_c01_027e s1501_c02_001e s1501_c02_002e s1501_c02_003e s1501_c02_004e s1501_c02_005e s1501_c02_006e s1501_c02_007e s1501_c02_008e s1501_c02_009e s1501_c02_010e s1501_c02_011e s1501_c02_012e s1501_c02_013e s1501_c02_016e s1501_c02_017e s1501_c02_018e s1501_c02_019e s1501_c02_020e s1501_c02_021e s1501_c02_022e s1501_c02_023e s1501_c02_024e s1501_c02_025e s1501_c02_026e s1501_c02_027e s1501_c03_001e s1501_c03_002e s1501_c03_003e s1501_c03_004e s1501_c03_005e s1501_c03_006e s1501_c03_007e s1501_c03_008e s1501_c03_009e s1501_c03_010e s1501_c03_011e s1501_c03_012e s1501_c03_013e s1501_c03_016e s1501_c03_017e s1501_c03_018e s1501_c03_019e s1501_c03_020e s1501_c03_021e s1501_c03_022e s1501_c03_023e s1501_c03_024e s1501_c03_025e s1501_c03_026e s1501_c03_027e {
	local gender = substr("`v'", -6, 1)
	local age = substr("`v'", -3, 2)
	
	if (`gender' == 1) {
		rename `v' total_`age'
	}
	if (`gender' == 2) {
		rename `v' male_`age'
	}
	if (`gender' == 3) {
		rename `v' female_`age'
	}
	
	foreach c in pop_18_24 no_high_school_18_24 high_school_18_24 some_college_18_24 college_18_24 pop_over25 no_ninth_over25 some_high_school_over25 high_school_over25 some_college_over25 associates_over25 college_over25 gradschool_over25 pop_25_34 high_school_25_34 college_25_34 pop_35_44 high_school_35_44 college_35_44 pop_45_64 high_school_45_64 college_45_64 pop_65_99 high_school_65_99 college_65_99  {
	
	capture {
		rename total_`age' total_`c'
	}
	capture {
		rename female_`age' female_`c'
	}
	capture {
		rename male_`age' male_`c'
	}
	}
}


/**FIX ME
replace cty_fips = 46102 if cty_fips == 46113
replace cty_fips = 51019 if cty_fips == 51515
*/

cd $data/census_educshares
save educ_shares, replace
