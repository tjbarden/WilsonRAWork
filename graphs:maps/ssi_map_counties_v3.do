/************************************
SSI Map Creator

Start date: June 3, 2021
Prepared by Riley Wilson
			TJ Barden

*************************************/

//global data "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
//global output "C:\Users\rwilson9\Box\Research\ssi_statesupplement\output"
global data "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/data"
global output "/Users/t.j.barden/Library/CloudStorage/Box-Box/ssi_statesupplement/output"
//global data "C:\Users\tjbarden\Box\ssi_statesupplement\data"
//global output "C:\Users\tjbarden\Box\ssi_statesupplement\output"


cd $data
cd shapefiles

use countydb, clear
rename id _ID
destring GEOID, gen(cty_fips)
cd $data
merge 1:m cty_fips using master_inflation_virginia_02_16
sort year cty_fips
drop if _m == 1 //Territories
drop if (cty_fips < 3000 & cty_fips > 2000) //Alaska
drop if (cty_fips < 16000 & cty_fips > 15000) //Hawaii
drop _m

gen ssi_tot_capita = ssi_tot/totalpop
order ssi_tot year _ID cty_fips st_name ssi_tot_capita


foreach year in 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 { 
cd $data
cd shapefiles
spmap ssi_tot_capita using countycoord_fixed if year == 2002, id(_ID) ///
		clmethod(custom) osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin) clnumber(10) clbreaks(0, 0.025, 0.05, 0.075, 0.1, 0.125, 0.15, 0.175, 0.2, 0.25)  fcolor(Blues2) legend(pos(4) title("Total SSI Recipients - `year'", size(small)) size(*1.2)  subtitle("By County", size(vsmall)) label(2 "0% - 0.25%") label(3 "0.25% - 0.5%") label(4 "0.5% - 0.75%") label(5 "7.5% - 1%") label(6 "1% - 1.25%") label(7 "1.25% - 1.5%") label(8 "1.5% - 1.75%") labe(9 "1.75% - 2%") label(10 "2% - 2.5%"))
cd $output/ssi_tot_maps
graph export ssi_tot_capita_counties_virginia_`year'.png, replace
}

