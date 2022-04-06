/************************************
SSI Map Creator - State

Start date: June 21, 2021
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

use statedb, clear
destring GEOID, gen(st_fips)
cd $data
merge 1:m st_fips using master_inflation_02_16
sort year st_fips
drop if _m == 1 //Territories
drop _m
drop if (cty_fips < 3000 & cty_fips > 2000) //Alaska
drop if (cty_fips < 16000 & cty_fips > 15000) //Hawaii
collapse (mean) individual couple indwsomeone couplewsomeone supplement*, by(st_fips st_name year _ID)
order supplement*


foreach year in 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016  {
cd $data
cd shapefiles
spmap individual using statecoord if year == `year', id(_ID) ///
		clmethod(custom) clnumber(14) clbreaks(0, 0.1, 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300) ndf(gs6) fcolor(Blues2) legend(pos(4) title("`year' SSI Supplements", size(small)) size(*1.2)  subtitle("Individual (2020 Value)", size(small)) label(2 "No Supplement") label(3 "$0 - $25") label(4 "$25 - $50") label(5 "$50 - $75") label(6 "$75 - $100") label(7 "$100 - $125") label(8 "$125 - $150") label(9 "$150 - $175") label(10 "$175 - $200") label(11 "$200 - $225") label(12 "$225 - $250") label(13 "$250 - $275") label(14 "$275 - $300"))
cd $output/ssi_supplement_maps
graph export st_map_supplement_individual_`year'.png, replace

}
cd $data
cd shapefiles
spmap indwsomeone using statecoord if year == `year', id(_ID) ///
		clmethod(custom) clnumber(14) clbreaks(0, 0.1, 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300) ndf(gs6) fcolor(Blues2) legend(pos(4) title("`year' SSI Supplement ", size(small)) size(*1.2)  subtitle("Ind. w/ Someone (2020 Value)", size(small)) label(2 "No Supplement") label(3 "$0 - $25") label(4 "$25 - $50") label(5 "$50 - $75") label(6 "$75 - $100") label(7 "$100 - $125") label(8 "$125 - $150") label(9 "$150 - $175") label(10 "$175 - $200") label(11 "$200 - $225") label(12 "$225 - $250") label(13 "$250 - $275") label(14 "$275 - $300"))
cd $output/ssi_supplement_maps
graph export st_map_supplement_indwsomeone_`year'.png, replace



cd $data
cd shapefiles
spmap couple using statecoord if year == `year', id(_ID) ///
		clmethod(custom) clnumber(11) clbreaks(0, 0.1, 50, 100, 200, 300, 400, 500, 600, 700, 800) ndf(gs6) fcolor(Blues2) legend(pos(4) title("`year' SSI Supplements", size(small)) size(*1.2)  subtitle("Couple (2020 Value)", size(small)) label(2 "No Supplement") label(3 "$0 - $50") label(4 "$50 - $100") label(5 "$100 - $200") label(6 "$200 - $300") label(7 "$300 - $400") label(8 "$400 - $500") label(9 "$500 - $600") label(10 "$600 - $700") label(11 "$700 - $800"))
cd $output/ssi_supplement_maps
graph export st_map_supplement_couple_`year'.png, replace


cd $data
cd shapefiles
spmap couplewsomeone using statecoord if year == `year', id(_ID) ///
		clmethod(custom) clnumber(11) clbreaks(0, 0.1, 50, 100, 200, 300, 400, 500, 600, 700, 800) ndf(gs6) fcolor(Blues2) legend(pos(4) title("`year' SSI Supplements", size(small)) size(*1.2)  subtitle("Couple w/ Someone (2020 Value)", size(small)) label(2 "No Supplement") label(3 "$0 - $50") label(4 "$50 - $100") label(5 "$100 - $200") label(6 "$200 - $300") label(7 "$300 - $400") label(8 "$400 - $500") label(9 "$500 - $600") label(10 "$600 - $700") label(11 "$700 - $800"))
cd $output/ssi_supplement_maps
graph export st_map_supplement_couplewsomeone_`year'.png, replace

}


foreach year in 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016  {
cd $data
cd shapefiles
spmap supplement_individual_2020 using statecoord if year == `year', id(_ID) ///
		clmethod(custom) clnumber(14) clbreaks(0, 0.1, 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300) ndf(gs6) fcolor(Blues2) legend(pos(4) title("`year' SSI Supplements", size(small)) size(*1.2)  subtitle("Individual (2020 Value)", size(small)) label(2 "No Supplement") label(3 "$0 - $25") label(4 "$25 - $50") label(5 "$50 - $75") label(6 "$75 - $100") label(7 "$100 - $125") label(8 "$125 - $150") label(9 "$150 - $175") label(10 "$175 - $200") label(11 "$200 - $225") label(12 "$225 - $250") label(13 "$250 - $275") label(14 "$275 - $300"))
cd $output/ssi_supplement_maps
graph export st_map_supplement_individual_`year'_2020.png, replace


cd $data
cd shapefiles
spmap supplement_indwsomeone_2020 using statecoord if year == `year', id(_ID) ///
		clmethod(custom) clnumber(14) clbreaks(0, 0.1, 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300) ndf(gs6) fcolor(Blues2) legend(pos(4) title("`year' SSI Supplement ", size(small)) size(*1.2)  subtitle("Ind. w/ Someone (2020 Value)", size(small)) label(2 "No Supplement") label(3 "$0 - $25") label(4 "$25 - $50") label(5 "$50 - $75") label(6 "$75 - $100") label(7 "$100 - $125") label(8 "$125 - $150") label(9 "$150 - $175") label(10 "$175 - $200") label(11 "$200 - $225") label(12 "$225 - $250") label(13 "$250 - $275") label(14 "$275 - $300"))
cd $output/ssi_supplement_maps
graph export st_map_supplement_indwsomeone_`year'_2020.png, replace



cd $data
cd shapefiles
spmap supplement_couple_2020 using statecoord if year == `year', id(_ID) ///
		clmethod(custom) clnumber(11) clbreaks(0, 0.1, 50, 100, 200, 300, 400, 500, 600, 700, 800) ndf(gs6) fcolor(Blues2) legend(pos(4) title("`year' SSI Supplements", size(small)) size(*1.2)  subtitle("Couple (2020 Value)", size(small)) label(2 "No Supplement") label(3 "$0 - $50") label(4 "$50 - $100") label(5 "$100 - $200") label(6 "$200 - $300") label(7 "$300 - $400") label(8 "$400 - $500") label(9 "$500 - $600") label(10 "$600 - $700") label(11 "$700 - $800"))
cd $output/ssi_supplement_maps
graph export st_map_supplement_couple_`year'_2020.png, replace


cd $data
cd shapefiles
spmap supplement_couplewsomeone_2020 using statecoord if year == `year', id(_ID) ///
		clmethod(custom) clnumber(11) clbreaks(0, 0.1, 50, 100, 200, 300, 400, 500, 600, 700, 800) ndf(gs6) fcolor(Blues2) legend(pos(4) title("`year' SSI Supplements", size(small)) size(*1.2)  subtitle("Couple w/ Someone (2020 Value)", size(small)) label(2 "No Supplement") label(3 "$0 - $50") label(4 "$50 - $100") label(5 "$100 - $200") label(6 "$200 - $300") label(7 "$300 - $400") label(8 "$400 - $500") label(9 "$500 - $600") label(10 "$600 - $700") label(11 "$700 - $800"))
cd $output/ssi_supplement_maps
graph export st_map_supplement_couplewsomeone_`year'_2020.png, replace

}



/*
cd $data
cd shapefiles
spmap ssi_tot using countycoord_fixed if year == 2002, id(_ID) ///
		clmethod(quantile) clnumber(6) fcolor(Reds2)  legend(pos(4) title("Number of SSI Recipients", size(small)) size(*1.2)  subtitle("Move Out-of-State", size(small)) label(2 "Bottom 20%") label(3 "21-40%") label(4 "41-60%") label(5 "61-80%") label(6 "Top 20%"))


spmap ssi_tot using countycoord_fixed if year == 2002, id(_ID) ///
		clmethod(eqint) clnumber(11) fcolor(Reds2)  legend(pos(4) title("Number of SSI Recipients", size(small)) size(*1.2)  subtitle("Move Out-of-State", size(small)) label(2 "Bottom 10") label(3 "11-20") label(4 "21-30") label(5 "31-40") label(6 "41-50") label(7 "51-60") label(8 "61-70") label(9 "71-80") label(10 "81-90") label(11 "Top 10"))
		
cd $output
graph export shr_moveoutstate_bystate_map.png, replace


