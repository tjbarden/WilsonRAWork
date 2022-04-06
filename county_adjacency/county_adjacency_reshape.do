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


/*****************************************

Illinois on its Own

******************************************/

cd $data
use ssi_analysis_pre_reshape, clear


drop if st_fips1 == st_fips2
keep if st_fips1 == 17 | st_fips2 == 17

/*
gsort id year dif_individual_inf20201
order dif_individual_inf20201 dif_individual_inf20202
*/

bys id year: keep if _n == _N
order id year num cty_fips* cty_name1 st_name1 cty_name2 st_name2
foreach t in individual couple indwsomeone couplewsomeone {
        gen dif_`t'_inf20201 = supplement_`t'_20201 - supplement_`t'_20202
		gen dif_`t'_inf20202 = supplement_`t'_20202 - supplement_`t'_20201
}
gen dif_ssi_rate1 = ssi_rate1 - ssi_rate2
gen dif_ssi_rate2 = ssi_rate2 - ssi_rate1


reshape long cty_fips cty_name st_name totalpop pop_female pop_male pop_14_18 pop_19_21 pop_22_24 pop_25_34 pop_35_44 pop_45_54 pop_55_64 pop_65_99 pop_over25 pop_female_14_18 pop_female_19_21 pop_female_22_24 pop_female_25_34 pop_female_35_44 pop_female_45_54 pop_female_55_64 pop_female_65_99 pop_female_over25 pop_male_14_18 pop_male_19_21 pop_male_22_24 pop_male_25_34 pop_male_35_44 pop_male_45_54 pop_male_55_64 pop_male_65_99 pop_male_over25 emp_female_all_education emp_female_no_high_school emp_female_high_school emp_female_some_college emp_female_college emp_male_no_high_school emp_male_high_school emp_male_some_college emp_male_college emp_male_all_education emp_total_all_education emp_total_no_high_school emp_total_high_school emp_total_some_college emp_total_college emp_female_under25 emp_male_under25 emp_total_under25 emp_female_allages emp_female_14_18 emp_female_19_21 emp_female_22_24 emp_female_25_34 emp_female_35_44 emp_female_45_54 emp_female_55_64 emp_female_65_99 emp_male_14_18 emp_male_19_21 emp_male_22_24 emp_male_25_34 emp_male_35_44 emp_male_45_54 emp_male_55_64 emp_male_65_99 emp_male_allages emp_total_allages emp_total_14_18 emp_total_19_21 emp_total_22_24 emp_total_25_34 emp_total_35_44 emp_total_45_54 emp_total_55_64 emp_total_65_99 cz2000 ssi_tot ssi_aged ssi_disabled ssi_under18 ssi_18_64 ssi_above64 ssi_alsoOASDI ssi_paymenttot st_fips fips individual couple indwsomeone couplewsomeone name total_pop_18_24 total_no_high_school_18_24 total_high_school_18_24 total_some_college_18_24 total_college_18_24 total_pop_over25 total_no_ninth_over25 total_no_high_school_over25 total_high_school_over25 total_some_college_over25 total_associates_over25 total_college_over25 total_gradschool_over25 total_pop_25_34 total_high_school_25_34 total_college_25_34 total_pop_35_44 total_high_school_35_44 total_college_35_44 total_pop_45_64 total_high_school_45_64 total_college_45_64 total_pop_65_99 total_high_school_65_99 total_college_65_99 male_pop_18_24 male_no_high_school_18_24 male_high_school_18_24 male_some_college_18_24 male_college_18_24 male_pop_over25 male_no_ninth_over25 male_no_high_school_over25 male_high_school_over25 male_some_college_over25 male_associates_over25 male_college_over25 male_gradschool_over25 male_pop_25_34 male_high_school_25_34 male_college_25_34 male_pop_35_44 male_high_school_35_44 male_college_35_44 male_pop_45_64 male_high_school_45_64 male_college_45_64 male_pop_65_99 male_high_school_65_99 male_college_65_99 female_pop_18_24 female_no_high_school_18_24 female_high_school_18_24 female_some_college_18_24 female_college_18_24 female_pop_over25 female_no_ninth_over25 female_no_high_school_over25 female_high_school_over25 female_some_college_over25 female_associates_over25 female_college_over25 female_gradschool_over25 female_pop_25_34 female_high_school_25_34 female_college_25_34 female_pop_35_44 female_high_school_35_44 female_college_35_44 female_pop_45_64 female_high_school_45_64 female_college_45_64 female_pop_65_99 female_high_school_65_99 female_college_65_99 pceindex2012 pceindex2020 supplement_individual_2020 supplement_couple_2020 supplement_indwsomeone_2020 supplement_couplewsomeone_2020 supplement_individual_2012 supplement_couple_2012 supplement_indwsomeone_2012 supplement_couplewsomeone_2012 month urate unemp emp labforce st_staxrate ave_localstax stloc_staxrate stateabbreviation minwage2017 eitc2017 tanf_maxben2kid eitc_refundable medicaid_exp ssi_rate emp_rate_female emp_rate_male r_no_high_school_total_ov25 s_no_high_school_total_ov25 pe_total_no_high_school_ov25 r_high_school_total_ov25 s_high_school_total_ov25 pe_total_high_school_ov25 r_some_college_total_ov25 s_some_college_total_ov25 pe_total_some_college_ov25 r_college_total_ov25 s_college_total_ov25 pe_total_college_ov25 r_no_high_school_female_ov25 s_no_high_school_female_ov25 pe_female_no_high_school_ov25 r_high_school_female_ov25 s_high_school_female_ov25 pe_female_high_school_ov25 r_some_college_female_ov25 s_some_college_female_ov25 pe_female_some_college_ov25 r_college_female_ov25 s_college_female_ov25 pe_female_college_ov25 r_no_high_school_male_ov25 s_no_high_school_male_ov25 pe_male_no_high_school_ov25 r_high_school_male_ov25 s_high_school_male_ov25 pe_male_high_school_ov25 r_some_college_male_ov25 s_some_college_male_ov25 pe_male_some_college_ov25 r_college_male_ov25 s_college_male_ov25 pe_male_college_ov25 dif_individual_inf2020 dif_couple_inf2020 dif_indwsomeone_inf2020 dif_couplewsomeone_inf2020 dif_ssi_rate, i(id year) j(cty_num)



replace ssi_rate = ssi_rate * 100
foreach var in supplement_individual_2020 supplement_couple_2020 supplement_indwsomeone_2020 supplement_couplewsomeone_2020 {
	replace `var' = `var' / 100
}

gen high = . 
gen low = . 
cd $data
save ssi_analysis_reshaped_illinois, replace


/*****************************************

Without Illinois

******************************************/

cd $data
use ssi_analysis_pre_reshape, clear

drop if st_fips1 == st_fips2
drop if st_fips1 == 17
drop if st_fips2 == 17

/*
gsort id year dif_individual_inf20201
order dif_individual_inf20201 dif_individual_inf20202
*/

bys id year: keep if _n == _N
order id year num cty_fips* cty_name1 st_name1 cty_name2 st_name2
foreach t in individual couple indwsomeone couplewsomeone {
        gen dif_`t'_inf20201 = supplement_`t'_20201 - supplement_`t'_20202
		gen dif_`t'_inf20202 = supplement_`t'_20202 - supplement_`t'_20201
}
gen dif_ssi_rate1 = ssi_rate1 - ssi_rate2
gen dif_ssi_rate2 = ssi_rate2 - ssi_rate1


reshape long cty_fips cty_name st_name totalpop pop_female pop_male pop_14_18 pop_19_21 pop_22_24 pop_25_34 pop_35_44 pop_45_54 pop_55_64 pop_65_99 pop_over25 pop_female_14_18 pop_female_19_21 pop_female_22_24 pop_female_25_34 pop_female_35_44 pop_female_45_54 pop_female_55_64 pop_female_65_99 pop_female_over25 pop_male_14_18 pop_male_19_21 pop_male_22_24 pop_male_25_34 pop_male_35_44 pop_male_45_54 pop_male_55_64 pop_male_65_99 pop_male_over25 emp_female_all_education emp_female_no_high_school emp_female_high_school emp_female_some_college emp_female_college emp_male_no_high_school emp_male_high_school emp_male_some_college emp_male_college emp_male_all_education emp_total_all_education emp_total_no_high_school emp_total_high_school emp_total_some_college emp_total_college emp_female_under25 emp_male_under25 emp_total_under25 emp_female_allages emp_female_14_18 emp_female_19_21 emp_female_22_24 emp_female_25_34 emp_female_35_44 emp_female_45_54 emp_female_55_64 emp_female_65_99 emp_male_14_18 emp_male_19_21 emp_male_22_24 emp_male_25_34 emp_male_35_44 emp_male_45_54 emp_male_55_64 emp_male_65_99 emp_male_allages emp_total_allages emp_total_14_18 emp_total_19_21 emp_total_22_24 emp_total_25_34 emp_total_35_44 emp_total_45_54 emp_total_55_64 emp_total_65_99 cz2000 ssi_tot ssi_aged ssi_disabled ssi_under18 ssi_18_64 ssi_above64 ssi_alsoOASDI ssi_paymenttot st_fips fips individual couple indwsomeone couplewsomeone name total_pop_18_24 total_no_high_school_18_24 total_high_school_18_24 total_some_college_18_24 total_college_18_24 total_pop_over25 total_no_ninth_over25 total_no_high_school_over25 total_high_school_over25 total_some_college_over25 total_associates_over25 total_college_over25 total_gradschool_over25 total_pop_25_34 total_high_school_25_34 total_college_25_34 total_pop_35_44 total_high_school_35_44 total_college_35_44 total_pop_45_64 total_high_school_45_64 total_college_45_64 total_pop_65_99 total_high_school_65_99 total_college_65_99 male_pop_18_24 male_no_high_school_18_24 male_high_school_18_24 male_some_college_18_24 male_college_18_24 male_pop_over25 male_no_ninth_over25 male_no_high_school_over25 male_high_school_over25 male_some_college_over25 male_associates_over25 male_college_over25 male_gradschool_over25 male_pop_25_34 male_high_school_25_34 male_college_25_34 male_pop_35_44 male_high_school_35_44 male_college_35_44 male_pop_45_64 male_high_school_45_64 male_college_45_64 male_pop_65_99 male_high_school_65_99 male_college_65_99 female_pop_18_24 female_no_high_school_18_24 female_high_school_18_24 female_some_college_18_24 female_college_18_24 female_pop_over25 female_no_ninth_over25 female_no_high_school_over25 female_high_school_over25 female_some_college_over25 female_associates_over25 female_college_over25 female_gradschool_over25 female_pop_25_34 female_high_school_25_34 female_college_25_34 female_pop_35_44 female_high_school_35_44 female_college_35_44 female_pop_45_64 female_high_school_45_64 female_college_45_64 female_pop_65_99 female_high_school_65_99 female_college_65_99 pceindex2012 pceindex2020 supplement_individual_2020 supplement_couple_2020 supplement_indwsomeone_2020 supplement_couplewsomeone_2020 supplement_individual_2012 supplement_couple_2012 supplement_indwsomeone_2012 supplement_couplewsomeone_2012 month urate unemp emp labforce st_staxrate ave_localstax stloc_staxrate stateabbreviation minwage2017 eitc2017 tanf_maxben2kid eitc_refundable medicaid_exp ssi_rate emp_rate_female emp_rate_male r_no_high_school_total_ov25 s_no_high_school_total_ov25 pe_total_no_high_school_ov25 r_high_school_total_ov25 s_high_school_total_ov25 pe_total_high_school_ov25 r_some_college_total_ov25 s_some_college_total_ov25 pe_total_some_college_ov25 r_college_total_ov25 s_college_total_ov25 pe_total_college_ov25 r_no_high_school_female_ov25 s_no_high_school_female_ov25 pe_female_no_high_school_ov25 r_high_school_female_ov25 s_high_school_female_ov25 pe_female_high_school_ov25 r_some_college_female_ov25 s_some_college_female_ov25 pe_female_some_college_ov25 r_college_female_ov25 s_college_female_ov25 pe_female_college_ov25 r_no_high_school_male_ov25 s_no_high_school_male_ov25 pe_male_no_high_school_ov25 r_high_school_male_ov25 s_high_school_male_ov25 pe_male_high_school_ov25 r_some_college_male_ov25 s_some_college_male_ov25 pe_male_some_college_ov25 r_college_male_ov25 s_college_male_ov25 pe_male_college_ov25 dif_individual_inf2020 dif_couple_inf2020 dif_indwsomeone_inf2020 dif_couplewsomeone_inf2020 dif_ssi_rate, i(id year) j(cty_num)



replace ssi_rate = ssi_rate * 100
foreach var in supplement_individual_2020 supplement_couple_2020 supplement_indwsomeone_2020 supplement_couplewsomeone_2020 {
	replace `var' = `var' / 100
}
//drop if st_fips == 17
gen high = 1 if dif_individual_inf2020 > 0
replace high = 0 if dif_individual_inf2020 < 0
gen low = 1 if dif_individual_inf2020 < 0
replace low = 0 if dif_individual_inf2020 > 0

cd $data
save ssi_analysis_reshaped_woillinois, replace

/*****************************************

Append Illinois

******************************************/

append using ssi_analysis_reshaped_illinois

gen pop_18_64 = pop_19_21 + pop_22_24 + pop_25_34 + pop_35_44 + pop_45_54 + pop_55_64

gen emp_total_18_64 = emp_total_19_21 + emp_total_22_24 + emp_total_25_34 + emp_total_35_44 + emp_total_45_54 + emp_total_55_64

gen pe_total_14_18 = emp_total_14_18/pop_14_18
gen pe_total_65_99 = emp_total_65_99/pop_65_99
gen pe_total_18_64 = emp_total_18_64/pop_18_64



save ssi_analysis_reshaped, replace
