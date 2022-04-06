/**************************************
Centroid to Border Distance Figures

Prepared by Riley Wilson
			Thomas Barden
Start Date: November 11th, 2021

****************************************/


//global data "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
//global output "C:\Users\rwilson9\Box\Research\ssi_statesupplement\output"
//global data "/Users/t.j.barden/Box/ssi_statesupplement/data"
//global output "/Users/t.j.barden/Box/ssi_statesupplement/output"

global data "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/data"
global output "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/output"


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
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins<0, lcolor(black) ciplot(rline) blpattern(dash) blcolor(gray) fcolor(ebg%10))  ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins>=0, lcolor(black) ciplot(rline) blpattern(dash) blcolor(gray) fcolor(ebg%10)), legend(order(1 "Lower Supplement" 2 "Higher Supplement")) subtitle("SSI Rates Along State Borders with Differing Supplemental Payments") xtitle("Distance to Border") ytitle("County SSI Rate") graphregion(color(white))
cd $output/county_centroid_figures
graph export n_scatter_lfitci_floor1_mindist.png, replace	

//Line w/ Confidence Intervals (Differing sized points)
twoway (scatter ssi_rate dist_bins [aw = numcty] if dist_bins<0, mcolor(bluishgray)) ///
	(scatter ssi_rate dist_bins [aw = numcty] if dist_bins>=0, mcolor(navy)) ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins<0, lcolor(black) fcolor(ebg%10))  ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins>=0, lcolor(black) fcolor(ebg%10))
cd $output/county_centroid_figures
graph export scatter_lfitci_floor1_mindist.png, replace	

//LPoly (Differing sized points)
twoway (scatter ssi_rate dist_bins [aw = numcty] if dist_bins<0, mcolor(bluishgray)) ///
	(scatter ssi_rate dist_bins [aw = numcty]if dist_bins>=0, mcolor(navy)) ///
	(lpoly ssi_rate dist_bins [aw = numcty] if dist_bins<0, bw(5) lcolor(black)) ///
	(lpoly ssi_rate dist_bins [aw = numcty] if dist_bins>=0, bw(5) lcolor(black)) ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins<0, lcolor(black) fcolor(ebg%10)) ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins>=0, lcolor(black) fcolor(ebg%10))
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
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins<0, lcolor(black) fcolor(ebg%10)) ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins>=0, lcolor(black) fcolor(ebg%10))
cd $output/county_centroid_figures
graph export scatter_lfitci_floor5_mindist.png, replace	

//LPoly
twoway (scatter ssi_rate dist_bins [aw = numcty] if dist_bins<0, mcolor(bluishgray)) ///
	(scatter ssi_rate dist_bins [aw = numcty]if dist_bins>=0, mcolor(navy)) ///
	(lpoly ssi_rate dist_bins [aw = numcty] if dist_bins<0, bw(5) lcolor(black)) ///
	(lpoly ssi_rate dist_bins [aw = numcty] if dist_bins>=0, bw(5) lcolor(black)) ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins<0, lcolor(black) fcolor(ebg%10)) ///
	(lfitci ssi_rate dist_bins [aw = numcty] if dist_bins>=0, lcolor(black) fcolor(ebg%10))
cd $output/county_centroid_figures
graph export scatter_lpoly_floor5_mindist.png, replace



/*
/*
twoway (scatter ssi_rate dist_bins, mcolor(navy)) ///
	(lfitci ssi_rate dist_bins if dist_bins<0, lcolor(black)) ///
	(lfitci ssi_rate dist_bins if dist_bins>=0, lcolor(black))
*/
//High & Low Lines
twoway (line ssi_rate dist_bins if high == 1) (line ssi_rate dist_bins if high == 0)
graph export lines_distbins1_test.png, replace




/**************************************

No Distance Restrictions

****************************************/
/*
drop if abs(distance) > 50
//twoway (scatter ssi_rate distance)
graph export dist_high_test.png, width(300) replace

gen dist_bins = round(distance, 1)
collapse (mean) ssi_rate, by(dist_bins high)
binscatter ssi_rate dist_bins, n(50)
graph export binscatter_bins50_test.png replace
twoway (line ssi_rate dist_bins if high == 1) (line ssi_rate dist_bins if high == 0)
graph export lines_distbins1_rounddown_test.png




//Floor of Two Miles
gen dist_bins = floor(distance)
order dist_bins
gen mod = mod(dist_bins, 2)
order mod
gen dist_bins2 = dist_bins + mod
collapse (mean) ssi_rate, by(dist_bins2 high)
///////////////////



//Round to One Mile
gen dist_bins = round(distance, 1)
collapse (mean) ssi_rate, by(dist_bins high)
///////////////////

//Round to Two Miles
gen dist_bins = round(distance, 2)
collapse (mean) ssi_rate, by(dist_bins high)
///////////////////

//Round to Five Miles
gen dist_bins = round(distance, 5)
collapse (mean) ssi_rate, by(dist_bins high)
///////////////////
