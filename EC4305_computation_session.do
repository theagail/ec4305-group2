*set up the directory on your pc or mac
/*global dir1="/Users/bianxiaochen/Downloads/EC4305"
*/
global dir1 "`c(pwd)'" 

cd "$dir1"

*import data
import delimited ResaleflatpricesbasedonregistrationdatefromJan2017onwards.csv

*check missing data 
misstable summarize
describe
codebook

*Feature Engineering 
gen year = real(substr(month, 1, 4))

format year %9.0g

gen remaining_lease_years = real(substr(remaining_lease,1,2))

encode(storey_range), gen(storey_range_num)

encode(town), gen(town_num)

gen price = resale_price/1000

gen average_storey = storey_range_num * 3 - 1


*** Merge dataset
drop if year == 2025
merge m:1 year using cpi_yearly

** Generate inflation-adjusted price
gen real_price = price * 0.01 * cpi

codebook


****Summary statistics  
*data description: mean, variance, max and mean
sum real_price floor_area_sqm remaining_lease_years average_storey


*pairwise correlation, covariance estimates etc)
pwcorr real_price floor_area_sqm remaining_lease_years average_storey

*covariance Matrix 
correlate real_price floor_area_sqm remaining_lease_years average_storey, covariance
matrix C = r(C)    // stores covariance matrix in C

*correlation matrix 
correlate real_price floor_area_sqm remaining_lease_years average_storey
matrix R = r(C)

* Excluding sq metre, remaining_lease_years is found to have the largest covariance with resale price, while average storey has the highest correlation 


***Regression 
reg real_price remaining_lease_years i.town_num i.year
reg real_price floor_area_sqm i.town_num i.year
reg real_price average_storey i.town_num i.year





