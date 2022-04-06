/****************************
Identify points on state borders to calculate minimum distance to the border
****************************/

/////////////////////////
//cd "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data\shapefiles"
global data "/Users/t.j.barden/Box/ssi_statesupplement/data"
global output "/Users/t.j.barden/Box/ssi_statesupplement/output"


cd $data/shapefiles

use statecoord, clear
duplicates drop

bys _X _Y: gen N = _N

egen group = group(_X _Y)

merge m:1 _ID using statedb

destring STATEFP, gen(stfips)

keep if N > 1 //these are points that show up for at least two counties

keep group _ID _X _Y stfips 

bys group: egen minst = min(stfips)
bys group: egen maxst = max(stfips)

gen stborder = minst ~= maxst

keep if stborder == 1 //these are points that lie on state border

drop if _X == . | _Y == . //there are 56 of these, on for each area

keep _X _Y stfips
duplicates drop

bys _X _Y (stfips): gen n = _n
reshape wide stfips, i(_X _Y) j(n)

//cd "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
cd $data/county_centroids
compress 
save stateborder_point_latlon, replace //this file has all of the points on a state border with the corresponding states that are on that border

//there are 60 points where at least 3 states touch. These are all corners of some sort. 
//There is one place where 4 states touch. We are interested in the shared borders
//Which aren't really defined for a single point. For this reason we will drop the points 
//shared by 3 or more states and focus on the two state borders

drop if stfips3 ~= .
drop stfips3 stfips4

egen border_id = group(stfips*)
sort border_id
reshape long stfips, i(_X _Y border_id) j(num)


//cd "C:\Users\rwilson9\Box\Research\ssi_statesupplement\data"
compress 



save stateborder_eachstborder_latlon, replace //With this file, you can limit the sample to a specific state,
//merge on county pop centroids for every county in that state to every point, construct the distance (geodist) 
//and then keep the shortest distance for each border_id linking this back to the previous file using _X _Y
//you can identify which state border pair it belongs to.


