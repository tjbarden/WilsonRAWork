
cd $data
use judge_monthly_panel, clear

merge m:1 judge_id using judges_racegender, keepusing(prob_* pct*)
drop _m

gen probwhite50 = pctwhite >=50 
gen probblack50 = pctblack >=50
gen probhispanic50 = pcthispanic >=50
for X in any white black hispanic: replace probX50 = . if pctX == .

gen surnamemiss = 0
replace surnamemiss = 1 if probwhite50 == 0 & probblack50 == 0 & probhispanic50 == 0
replace surnamemiss = 1 if probwhite50 == . & probblack50 == . & probhispanic50 == .

rename m_jawardrate m_jallowrate

replace hearingofficename = upper(hearingofficename)
gen nhc = regexm(hearingofficename,"NHC$") == 1
cd $data
save judge_monthly_panel_wrace, replace

cd $output
cap file close sumstat
file open sumstat using table_sumstat.tex, write replace
file write sumstat "\begin{tabular}{lccccc}" _n
file write sumstat "\toprule" _n
file write sumstat "\toprule" _n
file write sumstat "& & \multicolumn{3}{c}{Event Study Analysis Sample} \\" _n
file write sumstat "\cmidrule{3-5}" _n
file write sumstat "& Full Sample & Full Sample & Before Retirement & After Retirement & Retirees \\" _n
file write sumstat "& (1) & (2) & (3) & (4) & (5) \\" _n
file write sumstat "\midrule" _n
file write sumstat "\\" _n

local vars = "m_dispositions m_decisions m_awards m_ffavorable m_jallowrate prob_fem50 pctwhite pctblack pcthispanic surnamemiss year"
local varlabs = `" "Dispositions" "Decisions" "Awards" "Fully Favorable" "Allowance Rate" "Female First Name" "Prob. White Surname" "Prob. Black Surname" "Prob. Hispanic Surname" "Race Surname Missing" "Observation Year" "'
local n : word count `vars'

forval i = 1/`n' {
	local var : word `i' of `vars'
	local varlab : word `i' of `varlabs'
	
	cd $data
	use judge_monthly_panel_wrace, clear
	reg `var' if nhc == 0
	cd $output
	file write sumstat "`varlab' & " %7.2f (_b[_cons]) 
	cd $data
	use  retire_judgepanel_6pre9post, clear
	reg `var' if balancepanel16 == 1 & nhc == 0 
	cd $output
	file write sumstat "&" %7.2f (_b[_cons])
	reg `var' if balancepanel16 == 1 & period_t<0 & nhc == 0
	cd $output
	file write sumstat "&" %7.2f (_b[_cons]) 
	reg `var' if balancepanel16 == 1 & period_t>=0 & nhc == 0
	cd $output
	file write sumstat "&" %7.2f (_b[_cons])
	reg `var' if (judge_id == r_judge_id1 | judge_id == r_judge_id2 | judge_id == r_judge_id3) & period_t<0 & nhc == 0
	file write sumstat "&" %7.2f (_b[_cons])
	file write sumstat "\\" _n
}
file write sumstat "\\" _n
cd $data
use judge_monthly_panel_wrace, clear
reg m_dispositions if nhc == 0
cd $output
file write sumstat "Monthly Observations & " %12.0fc (e(N))
cd $data
use  retire_judgepanel_6pre9post, clear
reg m_dispositions if balancepanel16 == 1 & nhc == 0
cd $output
file write sumstat "&" %12.0fc (e(N))
reg m_dispositions if balancepanel16 == 1 & period_t<0 & nhc == 0
cd $output
file write sumstat "&"%12.0fc (e(N)) 
reg m_dispositions if balancepanel16 == 1 & period_t>=0 & nhc == 0
cd $output
file write sumstat "&" %12.0fc (e(N))
reg m_dispositions if (judge_id == r_judge_id1 | judge_id == r_judge_id2 | judge_id == r_judge_id3) & period_t<0 & nhc == 0
cd $output
file write sumstat "&" %12.0fc (e(N))
file write sumstat "\\" _n
file write sumstat "\bottomrule" _n
file write sumstat "\bottomrule" _n
file write sumstat "\end{tabular}"
file close sumstat


////////////////////////
//SAMPLE REGRESSION TABLE
//////////////////////////

cd $data
use acs2012_2017_microdatamoves, clear

gen stfips_1 = migplac1 if migrate1 >1 //for movers
replace stfips_1 = stfips if migrate1 <=1 //for non-movers

gen migpuma_1 = migpuma1 if migrate1 >1 //for movers
replace migpuma_1 = migpuma2010 if migrate1 <=1 //for non-movers

gen orig_notbstate = orig_bstate == 0
replace orig_notbstate = . if orig_bstate == .

gen move_samemigpuma = migrate1d == 23
gen move_crossmigpuma = migrate1d == 24

egen st_puma_1 = group(stfips_1 migpuma_1)
egen st_puma = group(statefip migpuma2010_1)
//commute measures
gen commuter = pwstate2 ~= 0
gen commute_outstate = pwstate2 ~= statefip
replace commute_outstate = . if pwstate2 == 0


foreach outcome in move_any {
		reghdfe `outcome' orig_bstate [pw = perwt], absorb(i.st_puma_1#i.year) vce(cluster st_puma_1)
		matrix b_`outcome' = e(b)
		matrix V_`outcome' = e(V)
		scalar edf_r`outcome' = e(df_r)
		scalar n_`outcome' = e(N)
		qui sum `outcome' if e(sample) == 1  & orig_bstate == 0
		scalar dmean_`outcome' = r(mean)
		
		reghdfe `outcome' orig_bstate female blacknh asiannh othernh hisp nevmar div_sepwidow child_1 child_2 child_3 lshs somcoll coll advcoll [pw = perwt], absorb(i.st_puma_1#i.year age occ2010) vce(cluster st_puma_1)
		matrix b_c`outcome' = e(b)
		matrix V_c`outcome' = e(V)
		scalar edf_rc`outcome' = e(df_r)
		scalar n_c`outcome' = e(N)
		qui sum `outcome' if e(sample) == 1  & orig_bstate == 0
		scalar dmean_c`outcome' = r(mean)
}		

foreach outcome in move_outstate move_crossmigpuma {
		reghdfe `outcome' orig_bstate if move_any == 1 [pw = perwt], absorb(i.st_puma_1#i.year) vce(cluster st_puma_1)
		matrix b_`outcome' = e(b)
		matrix V_`outcome' = e(V)
		scalar edf_r`outcome' = e(df_r)
		scalar n_`outcome' = e(N)
		qui sum `outcome' if e(sample) == 1  & orig_bstate == 0
		scalar dmean_`outcome' = r(mean)
		
		reghdfe `outcome' orig_bstate female blacknh asiannh othernh hisp nevmar div_sepwidow child_1 child_2 child_3 lshs somcoll coll advcoll if move_any == 1 [pw = perwt], absorb(i.st_puma_1#i.year age occ2010) vce(cluster st_puma_1)
		matrix b_c`outcome' = e(b)
		matrix V_c`outcome' = e(V)
		scalar edf_rc`outcome' = e(df_r)
		scalar n_c`outcome' = e(N)
		qui sum `outcome' if e(sample) == 1  & orig_bstate == 0
		scalar dmean_c`outcome' = r(mean)
}

foreach outcome in commute_outstate {
		reghdfe `outcome' curr_bstate if commuter == 1 [pw = perwt], absorb(i.st_puma#i.year) vce(cluster st_puma)
		matrix b_`outcome' = e(b)
		matrix V_`outcome' = e(V)
		scalar edf_r`outcome' = e(df_r)
		scalar n_`outcome' = e(N)
		qui sum `outcome' if e(sample) == 1  & curr_bstate == 0
		scalar dmean_`outcome' = r(mean)
		
		reghdfe `outcome' curr_bstate female blacknh asiannh othernh hisp nevmar div_sepwidow child_1 child_2 child_3 lshs somcoll coll advcoll if commuter == 1 [pw = perwt], absorb(i.st_puma#i.year age occ2010) vce(cluster st_puma)
		matrix b_c`outcome' = e(b)
		matrix V_c`outcome' = e(V)
		scalar edf_rc`outcome' = e(df_r)
		scalar n_c`outcome' = e(N)
		qui sum `outcome' if e(sample) == 1  & curr_bstate == 0
		scalar dmean_c`outcome' = r(mean)
}


cd $output
cap file close regout
file open regout using tab_acs_movecommuteoutstate_orig.tex, write replace
//Header
file write regout "\begin{tabular}{lcccccccc}" _n
file write regout "\toprule" _n
file write regout "\toprule" _n
file write regout "& & & \multicolumn{4}{c}{Among Movers} & \multicolumn{2}{c}{Among Commuters} \\" _n
file write regout "\cmidrule{4-7}" _n
file write regout "& \multicolumn{2}{c}{Move at All} & \multicolumn{2}{c}{Move Out of PUMA, Stay in State} & \multicolumn{2}{c}{Move Out of State} & \multicolumn{2}{c}{Commute Out of State} \\" _n
file write regout "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\" _n
file write regout "\midrule" _n
file write regout " \\" _n
//Table
file write regout "Originally in Birth State" 
foreach outcome in move_any cmove_any move_crossmigpuma cmove_crossmigpuma move_outstate cmove_outstate {
	file write regout "&" %7.3f (b_`outcome'[1,1])
	if 2*(ttail(`=scalar(edf_r`outcome')',abs(b_`outcome'[1,1]/(sqrt(V_`outcome'[1,1]))))) <.01 {
		file write regout "***"
	}
	if 2*(ttail(`=scalar(edf_r`outcome')',abs(b_`outcome'[1,1]/(sqrt(V_`outcome'[1,1]))))) >=.01 & 2*(ttail(`=scalar(edf_r`outcome')',abs(b_`outcome'[1,1]/(sqrt(V_`outcome'[1,1]))))) <.05{
		file write regout "**"
	}
	if 2*(ttail(`=scalar(edf_r`outcome')',abs(b_`outcome'[1,1]/(sqrt(V_`outcome'[1,1]))))) >=.05 & 2*(ttail(`=scalar(edf_r`outcome')',abs(b_`outcome'[1,1]/(sqrt(V_`outcome'[1,1]))))) <.10{
		file write regout "*"
	}
}
file write regout "\\" _n
foreach outcome in move_any cmove_any move_crossmigpuma cmove_crossmigpuma move_outstate cmove_outstate {
	file write regout "&" "(" %5.3f ( sqrt(V_`outcome'[1,1]) ) ")"
}
file write regout "\\" _n
file write regout "Currently in Birth State & & & & & & " 
foreach outcome in commute_outstate ccommute_outstate {
	file write regout "&" %7.3f (b_`outcome'[1,1])
	if 2*(ttail(`=scalar(edf_r`outcome')',abs(b_`outcome'[1,1]/(sqrt(V_`outcome'[1,1]))))) <.01 {
		file write regout "***"
	}
	if 2*(ttail(`=scalar(edf_r`outcome')',abs(b_`outcome'[1,1]/(sqrt(V_`outcome'[1,1]))))) >=.01 & 2*(ttail(`=scalar(edf_r`outcome')',abs(b_`outcome'[1,1]/(sqrt(V_`outcome'[1,1]))))) <.05{
		file write regout "**"
	}
	if 2*(ttail(`=scalar(edf_r`outcome')',abs(b_`outcome'[1,1]/(sqrt(V_`outcome'[1,1]))))) >=.05 & 2*(ttail(`=scalar(edf_r`outcome')',abs(b_`outcome'[1,1]/(sqrt(V_`outcome'[1,1]))))) <.10{
		file write regout "*"
	}
}
file write regout "\\" _n
file write regout "& & & & & &"
foreach outcome in commute_outstate ccommute_outstate {
	file write regout "&" "(" %5.3f ( sqrt(V_`outcome'[1,1]) ) ")"
}
file write regout "\\" _n

file write regout "\\" _n
//Statistics
file write regout "Demographic Controls & & X & & X & & X & & X \\" _n
file write regout "Dependent Mean, Not Birth State"
foreach outcome in move_any cmove_any move_crossmigpuma cmove_crossmigpuma move_outstate cmove_outstate commute_outstate ccommute_outstate {
	file write regout "&" %5.2f (`=scalar(dmean_`outcome')') 
}
file write regout "\\" _n
file write regout "Observations" 
foreach outcome in move_any cmove_any move_crossmigpuma cmove_crossmigpuma move_outstate cmove_outstate commute_outstate ccommute_outstate {
	file write regout "&" %12.0fc (`=scalar(n_`outcome')') 
}
file write regout "\\" _n
file write regout "\bottomrule" _n
file write regout "\bottomrule" _n
file write regout "\end{tabular}"
file close regout

