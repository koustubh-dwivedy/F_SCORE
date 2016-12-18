* Code for implementing Piotrosky's Algorithm in Indian Markets

* INPUTS TO THIS CODE: List of files containing Prowess code and BM ratio, File containing company codes of Nifty500
* In short, the pipeline should be Prowess -> Convert .dat.txt file to .xlsx -> Stata -> Result. No excel.

* What to do?

* Get a set of High BM companies
* BM is an attribute of a company
* Get all BM values of companies in the time range 2010-2015 (31st march each year)
* Calculate the 75th percentile of this entire set
* For each company (using it's prowess code): get it's average BM value over the years and attribute whether it's High or Low BM
* Save the Prowess company codes  for this high BM set


clear
cd C:\Users\TradingLab15\Desktop\Piotroski\new_data

* 500.xlsx contains the list of NIFTY 500 companies

import excel using "500.xlsx", firstrow clear
save 500, replace
clear

**********
import excel using "2010_PB.xlsx", firstrow clear
merge 1:1 co_code using 500
keep if _merge == 3
keep if nse_pb != "NA"
gen pb_2010 = real(nse_pb)
drop nse_pb
drop _merge
generate bm_2010 = 1/pb_2010
save 2010_PB, replace

import excel using "2011_PB.xlsx", firstrow clear
merge 1:1 co_code using 500
keep if _merge == 3
keep if nse_pb != "NA"
gen pb_2011 = real(nse_pb)
drop nse_pb
drop _merge
generate bm_2011 = 1/pb_2011
save 2011_PB, replace

import excel using "2012_PB.xlsx", firstrow clear
merge 1:1 co_code using 500
keep if _merge == 3
keep if nse_pb != "NA"
gen pb_2012 = real(nse_pb)
drop nse_pb
drop _merge
generate bm_2012 = 1/pb_2012
save 2012_PB, replace

import excel using "2013_PB.xlsx", firstrow clear
merge 1:1 co_code using 500
keep if _merge == 3
keep if nse_pb != "NA"
gen pb_2013 = real(nse_pb)
drop nse_pb
drop _merge
generate bm_2013 = 1/pb_2013
save 2013_PB, replace

import excel using "2014_PB.xlsx", firstrow clear
merge 1:1 co_code using 500
keep if _merge == 3
keep if nse_pb != "NA"
gen pb_2014 = real(nse_pb)
drop nse_pb
drop _merge
generate bm_2014 = 1/pb_2014
save 2014_PB, replace

import excel using "2015_PB.xlsx", firstrow clear
merge 1:1 co_code using 500
keep if _merge == 3
keep if nse_pb != "NA"
gen pb_2015 = real(nse_pb)
drop nse_pb
drop _merge
generate bm_2015 = 1/pb_2015
save 2015_PB, replace

clear
**********

use 2010_PB
merge 1:1 co_code using 2011_PB, force
keep if _merge == 3
drop _merge
merge 1:1 co_code using 2012_PB
keep if _merge == 3
drop _merge
merge 1:1 co_code using 2013_PB
keep if _merge == 3
drop _merge
merge 1:1 co_code using 2014_PB
keep if _merge == 3
drop _merge
merge 1:1 co_code using 2015_PB, force
keep if _merge == 3
drop _merge

save compiled_BM

