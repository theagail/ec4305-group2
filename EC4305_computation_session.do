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

gen resale_prices_in_thousands = resale_price/1000

gen average_storey = storey_range_num * 3 + 2

***Regression 
reg resale_prices_in_thousands remaining_lease_years i.town_num i.year
reg resale_prices_in_thousands floor_area_sqm i.town_num i.year
reg resale_prices_in_thousands average_storey i.town_num i.year


****Summary statistics  
*data description: mean, variance, max and mean
sum resale_prices_in_thousands floor_area_sqm remaining_lease_years average_storey


*pairwise correlation, covariance estimates etc)
pwcorr resale_prices_in_thousands floor_area_sqm remaining_lease_years average_storey

*covariance Matrix 
correlate resale_prices_in_thousands floor_area_sqm remaining_lease_years average_storey, covariance
matrix C = r(C)    // stores covariance matrix in C

*correlation matrix 
correlate resale_prices_in_thousands floor_area_sqm remaining_lease_years average_storey
matrix R = r(C)

* Excluding sq metre, remaining_lease_years is found to have the largest covariance with resale price, while average storey has the highest correlation 


