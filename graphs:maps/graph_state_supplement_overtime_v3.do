/************************************
SSI Supplement Changes - Line Graph
Supplement Changes > $10 Only

Start date: July 13th, 2021
Prepared by Riley Wilson
			TJ Barden

*************************************/

//global data "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
//global output "C:\Users\rwilson9\Box\Research\ssi_statesupplement\output"
//global data "/Users/t.j.barden/Box/ssi_statesupplement/data"
//global output "/Users/t.j.barden/Box/ssi_statesupplement/output"
//global data "C:\Users\tjbarden\Box\ssi_statesupplement\data"
//global output "C:\Users\tjbarden\Box\ssi_statesupplement\output"

global data "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/data"
global output "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/output"

cd $data
use master_inflation_virginia_02_16, clear

drop if (cty_fips < 3000 & cty_fips > 2000) //Alaska
drop if (cty_fips < 16000 & cty_fips > 15000) //Hawaii

collapse (mean) supplement* individual couple indwsomeone couplewsomeone, by(st_fips st_name year)

order individual couple indwsomeone couplewsomeone
drop if individual == 0

	
	

twoway (line individual year if st_name == "CALIFORNIA", lpattern(solid) lcolor(navy*1.8) lwidth(*0.85)) /// 
(line individual year if st_name == "COLORADO", lpattern(solid) lcolor(red*1.8) lwidth(*0.85)) /// 
(line individual year if st_name == "CONNECTICUT", lpattern(solid) lcolor(green*1.8) lwidth(*0.85)) /// 
(line individual year if st_name == "IDAHO", lpattern(solid) lcolor(yellow*1.3) lwidth(*0.85)) /// 
(line individual year if st_name == "NEW HAMPSHIRE", lpattern(solid) lcolor(purple*1.8) lwidth(*0.85)) /// 
(line individual year if st_name == "OKLAHOMA", lpattern(solid) lcolor(orange*0.8) lwidth(*0.85)) /// 
(line individual year if st_name == "RHODE ISLAND", lpattern(solid) lcolor(navy*0.8) lwidth(*0.85)) /// 
(line individual year if st_name == "WASHINGTON", lpattern(solid) lcolor(red*0.8) lwidth(*0.85)) /// 
(line individual year if st_name == "WYOMING", lpattern(solid) lcolor(green*0.8) lwidth(*0.85)), legend(size(small) pos(6) rows(3) title("SSI State Supplements Over Time", size(small)) label(1 "California") label(2 "Colorado") label(3 "Connecticut") label(4 "Idaho") label(5 "New Hampshire") label( 6 "Oklahoma") label(7 "Rhode Island") label(8 "Washington") label(9 "Wyoming")) xlabel(2002(2)2016) ymlabel(##2)

cd $output/ssi_supplement_figures	
graph export states_supp_changes10+.png, width(2000) replace
	
/*	
foreach state in "CALIFORNIA" "COLORADO" "CONNECTICUT" "IDAHO" "NEW HAMPSHIRE" "OKLAHOMA" "RHODE ISLAND" "WASHINGTON" "WYOMING" {
		local linecmd "`linecmd' (line individual year if st_name == "`state'", lpattern(solid) lcolor(navy*1.8) lwidth(*0.5))"
	}
	
twoway `linecmd', legend(off) xlabel(2002(2)2016)

/*
foreach state in "ALABAMA" "ALASKA" "ARIZONA" "ARKANSAS" "CALIFORNIA" "COLORADO" "CONNECTICUT" "DELAWARE" "DISTRICT OF COLUMBIA" "FLORIDA" "GEORGIA" "HAWAII" "IDAHO" "ILLINOIS" "INDIANA" "IOWA" "KANSAS" "KENTUCKY" "LOUISIANA" "MAINE" "MARYLAND" "MASSACHUSETTS" "MICHIGAN" "MINNESOTA" "MISSISSIPPI" "MISSOURI" "MONTANA" "NEBRASKA" "NEVADA" "NEW HAMPSHIRE" "NEW JERSEY" "NEW MEXICO" "NEW YORK" "NORTH CAROLINA" "NORTH DAKOTA" "OHIO" "OKLAHOMA" "OREGON" "PENNSYLVANIA" "RHODE ISLAND" "SOUTH CAROLINA" "SOUTH DAKOTA" "TENNESSEE" "TEXAS" "UTAH" "VERMONT" "VIRGINIA" "WASHINGTON" "WEST VIRGINIA" "WISCONSIN" "WYOMING" {
		local linecmd "`linecmd' (line individual year if st_name == "`state'", lpattern(solid) lcolor(navy*1.8) lwidth(*0.5))"
	}
	
twoway `linecmd', legend(off) xlabel(2002(2)2016)
	

	
/*
foreach year in 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 {
cd $output
	for each st_name in "ALABAMA" "ALASKA" "ARIZONA" "ARKANSAS" "CALIFORNIA" "COLORADO" "CONNECTICUT" "DELAWARE" "DISTRICT OF COLUMBIA" "FLORIDA" "GEORGIA" "HAWAII" "IDAHO" "ILLINOIS" "INDIANA" "IOWA" "KANSAS" "KENTUCKY" "LOUISIANA" "MAINE" "MARYLAND" "MASSACHUSETTS" "MICHIGAN" "MINNESOTA" "MISSISSIPPI" "MISSOURI" "MONTANA" "NEBRASKA" "NEVADA" "NEW HAMPSHIRE" "NEW JERSEY" "NEW MEXICO" "NEW YORK" "NORTH CAROLINA" "NORTH DAKOTA" "OHIO" "OKLAHOMA" "OREGON" "PENNSYLVANIA" "RHODE ISLAND" "SOUTH CAROLINA" "SOUTH DAKOTA" "TENNESSEE" "TEXAS" "UTAH" "VERMONT" "VIRGINIA" "WASHINGTON" "WEST VIRGINIA" "WISCONSIN" "WYOMING" {
		twoway (line `var' year if year == `year', lpattern(solid) lcolor(navy*1.8) lwidth(*2)) ///
	(line p_child_month_share year if year == `year', lpattern(dash_dot_dot) lcolor(navy*1) lwidth(*2)) ///
	(line refund_interest_month_share year if year == `year', lpattern(dash) lcolor(navy*0.5) lwidth(*2)) ///
	, legend(order(1 "Payment Where Earned Income Credit Exceeds Liability for Tax" 2 "Payment Where Child Credit Exceeds Liability for Tax" 3 "Refunding Internal Revenue Collections, Interest") rows(3)) graphregion(color(white)) ///
	xtitle(Month) ytitle(Share of Annual Payments) ///
	ylabel(0(0.1)0.6) xlabel(1(1)12)

graph export three_var_`year'.png, width(1000)
	

twoway (line p_income_month_share month if year == `year', lcolor(navy*1.8) lwidth(*2)) ///
	, legend(order(1 "Payment Where Earned Income Credit Exceeds Liability for Tax") rows(1)) graphregion(color(white)) ///
	xtitle(Month) ytitle(Share of Annual EITC Refund Payments) ///
	ylabel(0(0.1)0.6) xlabel(1(1)12)

graph export EITC_`year'.png, width(1000)
	}
}
