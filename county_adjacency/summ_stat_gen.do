/**************************************
Stat Table

Prepared by Riley Wilson
			Thomas Barden
Start Date: November 20th, 2021

****************************************/

/////Create another column for everything including no difference pairs



//global data "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
//global output "C:\Users\rwilson9\Box\Research\ssi_statesupplement\output"
//global data "/Users/t.j.barden/Box/ssi_statesupplement/data"
//global output "/Users/t.j.barden/Box/ssi_statesupplement/output"

global data "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/data"
global output "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/output"

cd $data

use ssi_analysis_reshaped, clear

drop if st_name == "ILLINOIS"
gen r_ssi_aged = ssi_aged/ssi_tot
gen r_ssi_disabled = ssi_disabled/ssi_tot
gen r_pop_over25 = pop_over25/totalpop
gen r_pop_female = pop_female/totalpop
gen r_college_over25 = total_college_over25/total_pop_over25
gen r_no_high_school_over25 = total_no_high_school_over25/total_pop_over25




cd $output
cap file close sumstat
file open sumstat using table_sumstat.tex, write replace
file write sumstat "\begin{tabular}{lcccc}" _n
file write sumstat "\toprule" _n
file write sumstat "\toprule" _n
file write sumstat "& & \multicolumn{3}{c}{Adjacent Counties SSI Characteristics Summary} \\" _n
file write sumstat "\cmidrule{3-5}" _n
file write sumstat "Variable & Full Sample & High Supplement States & Low Supplement States & Cty-Year Pairs\\" _n
file write sumstat "& (1) & (2) & (3) & (4)\\" _n
file write sumstat "\midrule" _n
file write sumstat "\\" _n

local vars = "totalpop ssi_tot labforce urate ssi_rate r_ssi_aged r_ssi_disabled r_pop_over25 r_college_total_ov25 r_high_school_total_ov25 r_no_high_school_total_ov25 r_college_female_ov25 r_high_school_female_ov25 r_no_high_school_female_ov25 r_college_male_ov25 r_high_school_male_ov25 r_no_high_school_male_ov25 pe_total_no_high_school_ov25 pe_female_no_high_school_ov25 pe_male_no_high_school_ov25 pe_total_high_school_ov25 pe_female_high_school_ov25 pe_male_high_school_ov25 pe_total_college_ov25 pe_female_college_ov25 pe_male_college_ov25"
local var_labs = `" "Population" "Total SSI Recipients" "Labor Force" "Unemployment Rate" "SSI Rate" "\% SSI Aged" "\% SSI Disabled" "\% Pop. Over 25" "\% w/ College Degree" "\% w/ HS Diploma " "\% w/o HS Diploma " "\% Female w/ College Degree""\% Female w/ HS Diploma" "\% Female w/o HS Diploma" "\% Male w/ College Degree" "\% Male w/ HS Diploma" "\% Male w/o HS Diploma" "Emp Rate w/o HS Diploma" "Emp Rate w/o HS Diploma (Female)" "Emp Rate w/o HS Diploma (Male)""Emp Rate w/ HS Diploma" "Emp Rate w/ HS Diploma (Female)" "Emp Rate w/ HS Diploma (Male)""Emp Rate w/ College Degree" "Emp Rate w/ College Degree (Female)" "Emp Rate w/ College Degree (Male)""'
local num: word count `vars'

forval i = 1/`num' {
	local var : word `i' of `vars'
	local varlab : word `i' of `var_labs'
	file write sumstat "`varlab'"
	reg `var' if high !=.
	file write sumstat " & " %7.2f (_b[_cons])
	reg `var' high low if high !=., nocons
	file write sumstat " & " %7.2f (_b[high]) "& " %7.2f (_b[low])
	reghdfe `var' high if high !=., absorb(year#id) vce(cluster st_fips)
	file write sumstat " & " %7.2f (_b[high]) 
	test high = 0
	local p = r(p)
		if `p'<.01 {
			file write sumstat "***"
		}
		if `p' >=.01 & `p'<.05 {
			file write sumstat "**"
		}
		if `p' >=.05 & `p'<.1 {
			file write sumstat "*"
		}
	/*file write sumstat "&" %7.2f (_b[_cons]) 
	reg `var' if balancepanel16 == 1 & period_t>=0 & nhc == 0
	cd $output
	file write sumstat "&" %7.2f (_b[_cons])
	reg `var' if (judge_id == r_judge_id1 | judge_id == r_judge_id2 | judge_id == r_judge_id3) & period_t<0 & nhc == 0
	file write sumstat "&" %7.2f (_b[_cons])
	*/
	file write sumstat "\\" _n
}

file write sumstat "\\" _n
file write sumstat "\bottomrule" _n
file write sumstat "\bottomrule" _n
file write sumstat "\end{tabular}"
file close sumstat
