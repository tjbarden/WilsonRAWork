
/*****************************
SSI State Supplements Analysis File

Start date: February 10, 2022
Prepared by Riley Wilson

******************************/
global data "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
global output "C:\Users\rwilson9\Box\Research\ssi_statesupplement\output"

/*****************************
County Pair Regression SSI on SSI rate
*****************************/
cd $data
use ssi_analysis_reshaped_woillinois, clear

gen have_supp = supplement_individual_2020 ~= 0
bys cty_fips: egen cty_eversupp = max(have_supp)
bys id: egen id_everanysupp = max(have_supp)

gen ssi_under18_rate = (ssi_under18/(totalpop-total_pop_18_24-total_pop_over25))*100
gen ssi_1864_rate = (ssi_18_64/(total_pop_18_24+total_pop_25_34+total_pop_35_44+total_pop_45_64))*100
gen ssi_over64_rate = (ssi_above64/(total_pop_65_99))*100
gen ssi_under65_rate = ((ssi_under18+ssi_18_64)/(totalpop-total_pop_65_99))*100

gen emp_rate = (emp_total_allages/totalpop)*100
gen emp_1864_rate = ((emp_total_19_21+emp_total_22_24+emp_total_25_34+emp_total_35_44+emp_total_45_54+emp_total_55_64)/(total_pop_18_24+total_pop_25_34+total_pop_35_44+total_pop_45_64))*100
gen emp_over64_rate = ((emp_total_65_99)/(total_pop_65_99))*100
//

reghdfe ssi_rate supplement_individual_2020 , absorb(year##id cty_fips) vce(cluster st_fips)
	matrix b_b = e(b)
	matrix V_b = e(V)
	scalar edf_rb = e(df_r)
	scalar n_b = e(N)
	qui reg ssi_rate if e(sample) == 1
	scalar dmean_b = _b[_cons]
	
reghdfe ssi_rate supplement_individual_2020 if id_everanysupp == 1, absorb(year##id cty_fips) vce(cluster st_fips)
	matrix b_s = e(b)
	matrix V_s = e(V)
	scalar edf_rs = e(df_r)
	scalar n_s = e(N)
	qui reg ssi_rate if e(sample) == 1
	scalar dmean_s = _b[_cons]
	
reghdfe ssi_rate supplement_individual_2020 [aw = totalpop], absorb(year##id cty_fips) vce(cluster st_fips)
	matrix b_wt = e(b)
	matrix V_wt = e(V)
	scalar edf_rwt = e(df_r)
	scalar n_wt = e(N)
	qui reg ssi_rate [pw = totalpop] if e(sample) == 1
	scalar dmean_wt = _b[_cons]
	

foreach outcome in ssi_under18_rate ssi_1864_rate ssi_over64_rate {
	reghdfe `outcome' supplement_individual_2020 , absorb(year##id cty_fips) vce(cluster st_fips)
	matrix b_`outcome' = e(b)
	matrix V_`outcome' = e(V)
	scalar edf_r`outcome' = e(df_r)
	scalar n_`outcome' = e(N)
	qui reg `outcome' if e(sample) == 1
	scalar dmean_`outcome' = _b[_cons]
}

cd $output
cap file close regout
file open regout using table_bpair_ssirates.tex, write replace
//Header
file write regout "\begin{tabular}{lcccccc}" _n
file write regout "\toprule" _n
file write regout "\toprule" _n
file write regout "& \multicolumn{3}{c}{SSI Recipient Rate} & \multicolumn{3}{c}{SSI Subgroup Rate} \\" _n
file write regout "\cmidrule{2-4}" _n
file write regout "& Baseline & Supplement$>$0 & Population Weighted & Under 18 & 18-64 & Over 64 \\" _n
file write regout "& (1) & (2) & (3) & (4) & (5)  & (6) \\" _n
file write regout "\midrule" _n
file write regout " \\" _n
//Table
file write regout "State Supplement (\\$100s)" 
foreach outcome in b s wt ssi_under18_rate ssi_1864_rate ssi_over64_rate   {
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
foreach outcome in b s wt ssi_under18_rate ssi_1864_rate ssi_over64_rate  {
	file write regout "&" "(" %5.3f ( sqrt(V_`outcome'[1,1]) ) ")"
}
file write regout "\\" _n
file write regout "\\" _n
//Statistics
file write regout "Dependent Mean" 
foreach outcome in b s wt ssi_under18_rate ssi_1864_rate ssi_over64_rate {
	file write regout "&" %6.2fc (`=scalar(dmean_`outcome')') 
}
file write regout "\\" _n
file write regout "Observations" 
foreach outcome in b s wt ssi_under18_rate ssi_1864_rate ssi_over64_rate {
	file write regout "&" %12.0fc (`=scalar(n_`outcome')') 
}  
file write regout "\\" _n
file write regout "\bottomrule" _n
file write regout "\bottomrule" _n
file write regout "\end{tabular}"
file close regout


//Employment
reghdfe emp_rate supplement_individual_2020 , absorb(year##id cty_fips) vce(cluster st_fips)
	matrix b_b = e(b)
	matrix V_b = e(V)
	scalar edf_rb = e(df_r)
	scalar n_b = e(N)
	qui reg ssi_rate if e(sample) == 1
	scalar dmean_b = _b[_cons]
	
reghdfe pe_total_high_school_ov25 supplement_individual_2020 , absorb(year##id cty_fips) vce(cluster st_fips)
	matrix b_b = e(b)
	matrix V_b = e(V)
	scalar edf_rb = e(df_r)
	scalar n_b = e(N)
	qui reg ssi_rate if e(sample) == 1
	scalar dmean_b = _b[_cons]
	
reghdfe emp_rate supplement_individual_2020 if id_everanysupp == 1, absorb(year##id cty_fips) vce(cluster st_fips)
	matrix b_s = e(b)
	matrix V_s = e(V)
	scalar edf_rs = e(df_r)
	scalar n_s = e(N)
	qui reg ssi_rate if e(sample) == 1
	scalar dmean_s = _b[_cons]
	
reghdfe emp_rate supplement_individual_2020 [aw = totalpop], absorb(year##id cty_fips) vce(cluster st_fips)
	matrix b_wt = e(b)
	matrix V_wt = e(V)
	scalar edf_rwt = e(df_r)
	scalar n_wt = e(N)
	qui reg ssi_rate [pw = totalpop] if e(sample) == 1
	scalar dmean_wt = _b[_cons]
	

foreach outcome in emp_1864_rate emp_over64_rate {
	reghdfe `outcome' supplement_individual_2020 , absorb(year##id cty_fips) vce(cluster st_fips)
	matrix b_`outcome' = e(b)
	matrix V_`outcome' = e(V)
	scalar edf_r`outcome' = e(df_r)
	scalar n_`outcome' = e(N)
	qui reg `outcome' if e(sample) == 1
	scalar dmean_`outcome' = _b[_cons]
}

cd $output
cap file close regout
file open regout using table_bpair_emprates.tex, write replace
//Header
file write regout "\begin{tabular}{lccccc}" _n
file write regout "\toprule" _n
file write regout "\toprule" _n
file write regout "& \multicolumn{3}{c}{Employment Rate} & \multicolumn{2}{c}{SSI Subgroup Rate} \\" _n
file write regout "\cmidrule{2-4}" _n
file write regout "& Baseline & Supplement$>$0 & Population Weighted & 18-64 & Over 64 \\" _n
file write regout "& (1) & (2) & (3) & (4) & (5)  \\" _n
file write regout "\midrule" _n
file write regout " \\" _n
//Table
file write regout "State Supplement (\\$100s)" 
foreach outcome in b s wt emp_1864_rate emp_over64_rate   {
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
foreach outcome in b s wt emp_1864_rate emp_over64_rate  {
	file write regout "&" "(" %5.3f ( sqrt(V_`outcome'[1,1]) ) ")"
}
file write regout "\\" _n
file write regout "\\" _n
//Statistics
file write regout "Dependent Mean" 
foreach outcome in b s wt emp_1864_rate emp_over64_rate {
	file write regout "&" %6.2fc (`=scalar(dmean_`outcome')') 
}
file write regout "\\" _n
file write regout "Observations" 
foreach outcome in b s wt emp_1864_rate emp_over64_rate {
	file write regout "&" %12.0fc (`=scalar(n_`outcome')') 
}  
file write regout "\\" _n
file write regout "\bottomrule" _n
file write regout "\bottomrule" _n
file write regout "\end{tabular}"
file close regout

//////
cd $data/county_centroids

use cty_border_distance_merged2010, clear
drop _m

//drop if abs(dif_individual_inf2020) < 35

/**************************************

Within 50 miles of the Border

****************************************/
drop if abs(distance) > 50
gen high = 1 if dif_individual_inf2020 > 0 
replace high = 0 if dif_individual_inf2020 < 0 
order high

drop if high == .
compress
collapse high, by(year st_fips cty_fips distance ssi_rate)
gen double id = (cty_fips * distance) + ((cty_fips + 3) * (distance + 3))
tempfile cty_info_temp
save `cty_info_temp', replace
collapse (min) distance, by(year st_fips cty_fips)
gen double id = (cty_fips * distance) + ((cty_fips + 3) * (distance + 3))

merge 1:1 st_fips year cty_fips id using `cty_info_temp'
drop if _m != 3
drop _m
replace distance = distance *-1 if high == 0


//Floor of One Mile
gen dist_bins = floor(distance)
gen numcty = 1
collapse (sum) numcty (mean) ssi_rate, by(dist_bins high)
///////////////////


//Line
twoway (scatter ssi_rate dist_bins if dist_bins<0, mcolor(bluishgray)) ///
	(scatter ssi_rate dist_bins if dist_bins>=0, mcolor(navy)) ///
	(lfit ssi_rate dist_bins [aw = numcty] if dist_bins<0, lcolor(black)) ///
	(lfit ssi_rate dist_bins [aw = numcty] if dist_bins>=0, lcolor(black))
cd $output/county_centroid_figures
graph export scatter_lfit_floor1_mindist.png, replace	

//Line w/ Confidence Intervals
twoway (scatter ssi_rate dist_bins if dist_bins<0, mcolor(bluishgray)) ///
	(scatter ssi_rate dist_bins if dist_bins>=0, mcolor(navy)) ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins<0, alcolor(gray) fcolor(none) ciplot(rline) alpattern(dash) range(-50 0) level(95))  ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins>=0, alcolor(gray) fcolor(none) ciplot(rline) alpattern(dash) range(50 0) level(95))
cd $output/county_centroid_figures
graph export scatter_lfitci_floor1_mindist.png, replace	

//Line w/ Confidence Intervals (Differing sized points)
twoway (scatter ssi_rate dist_bins [aw = numcty] if dist_bins<0, mcolor(bluishgray)) ///
	(scatter ssi_rate dist_bins [aw = numcty] if dist_bins>=0, mcolor(navy)) ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins<0, alcolor(gray) fcolor(none) ciplot(rline) alpattern(dash) range(-50 0) level(95))  ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins>=0, alcolor(gray) fcolor(none) ciplot(rline) alpattern(dash) range(50 0) level(95))
cd $output/county_centroid_figures
graph export scatter_wtlfitci_floor1_mindist.png, replace	

//LPoly (Differing sized points)
twoway (scatter ssi_rate dist_bins [aw = numcty] if dist_bins<0, mcolor(bluishgray)) ///
	(scatter ssi_rate dist_bins [aw = numcty]if dist_bins>=0, mcolor(navy)) ///
	(lpolyci ssi_rate dist_bins [aw = numcty] if dist_bins<0, bw(5) lcolor(black) alcolor(gray) fcolor(none) ciplot(rline) alpattern(dash) level(95)) ///
	(lpolyci ssi_rate dist_bins [aw = numcty] if dist_bins>=0, bw(5) lcolor(black) alcolor(gray) fcolor(none) ciplot(rline) alpattern(dash) level(95))
cd $output/county_centroid_figures
graph export scatter_lpoly_floor1_mindist.png, replace		



cd $data/county_centroids

use cty_border_distance_merged2010, clear
drop _m

//drop if abs(dif_individual_inf2020) < 35

/**************************************

Within 50 miles of the Border

****************************************/
drop if abs(distance) > 50
gen high = 1 if dif_individual_inf2020 > 0 
replace high = 0 if dif_individual_inf2020 < 0 
order high

drop if high == .
compress
collapse high, by(year st_fips cty_fips distance ssi_rate)
gen double id = (cty_fips * distance) + ((cty_fips + 3) * (distance + 3))
tempfile cty_info_temp
save `cty_info_temp', replace
collapse (min) distance, by(year st_fips cty_fips)
gen double id = (cty_fips * distance) + ((cty_fips + 3) * (distance + 3))

merge 1:1 st_fips year cty_fips id using `cty_info_temp'
drop if _m != 3
drop _m
replace distance = distance *-1 if high == 0

//Floor of Five Miles
gen dist_bins = 5 * floor(distance/5)
gen numcty = 1
collapse (sum) numcty (mean) ssi_rate, by(dist_bins high)
///////////////////

//Line
twoway (scatter ssi_rate dist_bins if dist_bins<0, mcolor(bluishgray)) ///
	(scatter ssi_rate dist_bins if dist_bins>=0, mcolor(navy)) ///
	(lfit ssi_rate dist_bins [aw = numcty] if dist_bins<0, lcolor(black)) ///
	(lfit ssi_rate dist_bins [aw = numcty] if dist_bins>=0, lcolor(black))
cd $output/county_centroid_figures
graph export scatter_lfit_floor5_mindist.png, replace	

//Line w/ Confidence Intervals
twoway (scatter ssi_rate dist_bins [aw = numcty] if dist_bins<0, mcolor(bluishgray)) ///
	(scatter ssi_rate dist_bins [aw = numcty] if dist_bins>=0, mcolor(navy)) ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins<0, lcolor(black) alcolor(gray) fcolor(none) ciplot(rline) alpattern(dash) range(-50 0) level(95)) ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins>=0, lcolor(black) alcolor(gray) fcolor(none) ciplot(rline) alpattern(dash) range(50 0) level(95))
cd $output/county_centroid_figures
graph export scatter_lfitci_floor5_mindist.png, replace	

//LPoly
twoway (scatter ssi_rate dist_bins [aw = numcty] if dist_bins<0, mcolor(bluishgray)) ///
	(scatter ssi_rate dist_bins [aw = numcty]if dist_bins>=0, mcolor(navy)) ///
	(lpolyci ssi_rate dist_bins [aw = numcty] if dist_bins<0, bw(10) lcolor(black))  ///
	(lpolyci ssi_rate dist_bins [aw = numcty] if dist_bins>=0, bw(10) lcolor(black)) 
cd $output/county_centroid_figures
graph export scatter_lpoly_floor5_mindist.png, replace

