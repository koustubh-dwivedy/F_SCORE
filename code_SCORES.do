clear
cd C:\Users\TradingLab15\Desktop\Piotroski\data_2014_15


import excel using "2014_NUM_SHARES.xlsx", firstrow clear
save NUM_SHARES_2014, replace

import excel using "2015_NUM_SHARES.xlsx", firstrow clear
save NUM_SHARES_2015, replace




import excel using "2015_SHARE_PRICE_MARCH.xlsx", firstrow clear
save SHARE_PRICE_2015_MARCH, replace

import excel using "2016_SHARE_PRICE_MARCH.xlsx", firstrow clear
save SHARE_PRICE_2016_MARCH, replace



import excel using "2015_SHARE_PRICE_JUNE.xlsx", firstrow clear
save SHARE_PRICE_2015_JUNE, replace

import excel using "2016_SHARE_PRICE_JUNE.xlsx", firstrow clear
save SHARE_PRICE_2016_JUNE, replace



import excel using "2014_ALL.xlsx", firstrow clear

drop sa_finance1_year Year Month
keep if sa_months == 12
drop sa_months
rename sa_finance1_cocode cocode
rename sa_company_name company_name
rename sa_sales se_sales_2014
rename sa_tot_inc_net_of_pe sa_tot_inc_net_of_pe_2014
rename sa_net_sales sa_net_sales_2014
rename sa_cost_of_goods_sold sa_cost_of_goods_sold_2014
rename sa_long_term_borrowings sa_long_term_borrowings_2014
rename sa_total_assets sa_total_assets_2014
rename sa_avg_total_assets_net_of_reval avg_total_assets_net_of_reval_4
rename sa_current_ratio sa_current_ratio_2014
rename sa_cf_net_frm_op_activity sa_cf_net_frm_op_activity_2014

save ALL_2014, replace



import excel using "2015_ALL.xlsx", firstrow clear

drop sa_finance1_year Year Month
keep if sa_months == 12
drop sa_months
rename sa_finance1_cocode cocode
rename sa_company_name company_name
rename sa_sales se_sales_2015
rename sa_tot_inc_net_of_pe sa_tot_inc_net_of_pe_2015
rename sa_net_sales sa_net_sales_2015
rename sa_cost_of_goods_sold sa_cost_of_goods_sold_2015
rename sa_long_term_borrowings sa_long_term_borrowings_2015
rename sa_total_assets sa_total_assets_2015
rename sa_avg_total_assets_net_of_reval avg_total_assets_net_of_reval_5
rename sa_current_ratio sa_current_ratio_2015
rename sa_cf_net_frm_op_activity sa_cf_net_frm_op_activity_2015


save ALL_2015, replace

clear

use ALL_2014

* Problem in data point of Mahindra in ALL_2015. Deleted the December's value

merge 1:1 cocode using ALL_2015
keep if _merge == 3
drop _merge

rename cocode co_code



/*
merge 1:1 co_code using 2014_PB
keep if _merge == 3
drop _merge
*/


merge 1:1 co_code using 2015_PB, force
keep if _merge == 3
drop _merge

merge 1:1 co_code using NUM_SHARES_2014, force
keep if _merge == 3
drop _merge

merge 1:1 co_code using NUM_SHARES_2015, force
keep if _merge == 3
drop _merge



/*
merge 1:1 co_code using SHARE_PRICE_2015_MARCH, force
keep if _merge == 3
drop _merge

merge 1:1 co_code using SHARE_PRICE_2016_MARCH, force
keep if _merge == 3
drop _merge
*/

merge 1:1 co_code using SHARE_PRICE_2015_JUNE, force
keep if _merge == 3
drop _merge

merge 1:1 co_code using SHARE_PRICE_2016_JUNE, force
keep if _merge == 3
drop _merge





save ALL_2014_2015, replace


gen F_ROA = ( sa_tot_inc_net_of_pe_2015/ sa_total_assets_2014 ) >= 0
gen F_delta_ROA = ( (sa_tot_inc_net_of_pe_2015/ sa_total_assets_2014) - (sa_tot_inc_net_of_pe_2014/ (2*avg_total_assets_net_of_reval_4 - sa_total_assets_2014)) ) >= 0
gen F_CFO = ( sa_cf_net_frm_op_activity_2015/sa_total_assets_2014 ) >= 0
gen F_ACCRUAL = ( (sa_tot_inc_net_of_pe_2015 - sa_cf_net_frm_op_activity_2015)/ sa_total_assets_2014 ) < 0
gen F_delta_MARGIN = (((sa_net_sales_2015 - sa_cost_of_goods_sold_2015)/ sa_net_sales_2015) - ((sa_net_sales_2014 - sa_cost_of_goods_sold_2014)/ sa_net_sales_2014)) >= 0
gen F_delta_TURN = ((sa_net_sales_2015/avg_total_assets_net_of_reval_5) - (sa_net_sales_2014/avg_total_assets_net_of_reval_4)) >= 0
gen F_delta_LEVER = ((sa_long_term_borrowings_2015/avg_total_assets_net_of_reval_5) - (sa_long_term_borrowings_2014/avg_total_assets_net_of_reval_4)) < 0
gen F_delta_LIQUID = (sa_current_ratio_2015 - sa_current_ratio_2014) >= 0
gen EQ_OFFER = (shares_outstanding_2015 - shares_outstanding_2014) <= 0

gen F_SCORE = F_ROA + F_delta_ROA + F_CFO + F_ACCRUAL + F_delta_MARGIN + F_delta_TURN + F_delta_LEVER + F_delta_LIQUID + EQ_OFFER


gen RETURN = (closing_price_adj_2016 - closing_price_adj_2015)/closing_price_adj_2015
sort F_SCORE

save FINAL_RESULT_2015, replace

xtile q = bm_2015, nq(100)
keep if q >= 50
recode F_SCORE (0/2 = 1 LOW) (3/6 = 2 MED) (7/9 = 3 HIGH), gen(CLASS)
*recode F_SCORE (0/3 = 1 LOW) (4/5 = 2 MED) (6/9 = 3 HIGH), gen(CLASS)
tabstat RETURN, by(F_SCORE) stat(n mean p25 p50 p75 sd)
tabstat RETURN, by(CLASS) stat(n mean p25 p50 p75 sd)

keep if bm_2015 >= 1

tabstat RETURN, by(CLASS) stat(n mean p25 p50 p75 sd)

*clear