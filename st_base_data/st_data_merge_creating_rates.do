/*****************************************
state Data Merge

Prepared by Riley Wilson
			Thomas Barden
Start Date: April 4th, 2022

******************************************/


//global data "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
//global output "C:\Users\rwilson9\Box\Research\ssi_statesupplement\output"

global data "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/data"
global output "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/output"


/************************
Merge of State SEER Population Data, QWI Data, 5-Year Educational Data, and SSI Recipients Data 
************************/

cd $data
use st_seer_pop02_16, clear

cd $data/qwi/sex_education
merge 1:1 year st_fips using st_qwi_education_all
drop _m

cd $data/qwi/sex_age
merge 1:1 year st_fips using st_qwi_age_all
drop _m
/*Data gaps due to lack of QWI data for some states in the early 2000s
Arizona (04): 2002-2003
Massachusettes (25): 2002-2009
Mississippi (28): 2002
New Hampshire (33): 2002
Washington D.C. (11001): 2002-2004
*/

drop if year < 2002
drop if year > 2016

cd $data
save st_seer_qwi_02_16, replace

cd $data
merge 1:1 year st_fips using st_ssicases_02_16
drop if year > 2016
drop _m

save st_seer_qwi_ssicases_02_16, replace

merge m:1 stname year using state_SSI_supplements_full
drop if year > 2016
rename stname st_name
drop _m

sort year
compress

cd $data
merge m:1 st_fips using st_educ_shares
drop _m

cd $data
save st_seer_qwi_ssicases_supplements_02_16, replace


/*
Adjusting Supplement Values for Inflation
*/

cd $data
use st_seer_qwi_ssicases_supplements_02_16, clear
merge m:1 year using pce_inflator2020
drop if year < 2002 | year > 2016
drop _m
gen supplement_individual_2020 = individual * pceindex2020
gen supplement_couple_2020 = couple * pceindex2020
gen supplement_indwsomeone_2020 = indwsomeone * pceindex2020
gen supplement_couplewsomeone_2020 = couplewsomeone * pceindex2020
gen supplement_individual_2012 = individual * pceindex2012
gen supplement_couple_2012 = couple * pceindex2012
gen supplement_indwsomeone_2012 = indwsomeone * pceindex2012
gen supplement_couplewsomeone_2012 = couplewsomeone * pceindex2012
sort year st_fips
order year st_fips st_name
save st_inflation_02_16, replace


/************************
Merge of Other Explanatory Variables

Start Date September 9th, 2021
Prepared by Riley Wilson
			TJ Barden
			
************************/


cd $data
use st_inflation_02_16, clear

merge 1:1 st_fips year using st_annualemp2000_2018
drop if year > 2016
drop if year < 2002
drop if (st_fips == 2) //Alaska
drop if (st_fips == 15) //Hawaii
drop if st_fips > 70000
tab _m
drop _m

merge m:1 st_fips using st_salestax2017
drop if st_name == "ALASKA" | st_name == "HAWAII"
tab _m
drop _m

merge m:1 st_fips using state_transferpolicy2017
drop if st_name == "ALASKA" | st_name == "HAWAII"
tab _m
drop _m

cd $data
save st_inflation_02_16, replace


/************************
Creating Rates

Start Date July 1st, 2021
Prepared by Riley Wilson
			TJ Barden
			
************************/

cd $data
use st_inflation_02_16, clear



gen ssi_rate = ssi_tot/totalpop
gen emp_rate_female = emp_female_allages/pop_female
gen emp_rate_male = emp_male_allages/pop_male


/*
foreach age in 14_18 19_21 22_24 25_34 35_44 45_54 55_64 65_99 {
	gen emp_rate_female_`age' = emp_female_`age'/pop_female_`age'
	gen emp_rate_male_`age' = emp_male_`age'/pop_male_`age'
}
*/
replace total_some_high_school_over25 = total_some_high_school_over25 + total_no_ninth_over25
rename total_some_high_school_over25 total_no_high_school_over25
replace total_some_college_over25 = total_some_college_over25 + total_associates_over25

replace female_some_high_school_over25 = female_some_high_school_over25 + female_no_ninth_over25
rename female_some_high_school_over25 female_no_high_school_over25
replace female_some_college_over25 = female_some_college_over25 + female_associates_over25

replace male_some_high_school_over25 = male_some_high_school_over25 + male_no_ninth_over25
rename male_some_high_school_over25 male_no_high_school_over25
replace male_some_college_over25 = male_some_college_over25 + male_associates_over25

foreach s in total female male {
	foreach ed in no_high_school high_school some_college college {
		gen r_`ed'_`s'_ov25 = (`s'_`ed'_over25)/(`s'_pop_over25)
		gen s_`ed'_`s'_ov25 = (r_`ed'_`s'_ov25) * (pop_over25)
		gen pe_`s'_`ed'_ov25 = (emp_`s'_`ed')/(s_`ed'_`s'_ov25)
	}
}
drop if st_fips > 60

cd $data
save st_r_inflation_02_16, replace

cd $data/st_data
save st_data_02_16, replace
