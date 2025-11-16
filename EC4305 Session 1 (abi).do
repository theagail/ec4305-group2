//turn date into numerical value 
use "bitcoin_gld.dta", clear
gen daily_date = date(date, "YMD") // Replace "MDY" with your actual date format (e.g., "DMY", "YMD")
sort daily_date
generate week = _n
tsset week

//find log differences 
gen lg_bitcoin = log(bitcoin)
gen lg_gld = log(gld)
gen return_btc = D.lg_bitcoin
gen return_gld = D.lg_gld
dfuller return_btc
dfuller return_gld //check stationarity --> returns are stationary 

sum _all
correlate return_btc return_gld, covariance 
matrix C = r(C)
correlate return_btc return_gld
matrix R = r(C)

//test for normality 
swilk return_btc return_gld //found that neither bitcoin or gold returns follows normal distribution 

histogram return_gld, frequency normal 
histogram return_btc, frequency normal 

//generate U using the empirical CDF 
sort week
sort return_btc
gen u_returnbtc = (_n - 0.5) / _N
// back to original order first before 2nd var
sort week
sort return_gld
gen u_returngld = (_n - 0.5) / _N
sort week


//Scatterplot of integral transformation (to check cdf shape)
scatter u_returnbtc return_btc, msymbol(o) mcolor(blue) title("Integral transformed data") ytitle("U = > F_X(X)") xtitle("Bitcoin")
scatter u_returngld return_gld, msymbol(o) mcolor(blue) title("Integral transformed data") ytitle("U = > F_X(X)") xtitle("Gold")
