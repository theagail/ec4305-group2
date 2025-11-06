*set up the directory on your pc or mac
global dir1="/Users/bianxiaochen/Downloads/EC4305"
/*for Windowns:
global dir1="C:\Users\xiaochen\Downloads\EC4305"
*/
cd "$dir1"

*import data
use "$dir1/auoto.dta",clear
*Windows: 
*use "$dir1\auoto.dta",clear
import excel from "$dir\"

*Distribution and Dependence Analysis
sysuse auto,clear


****Summary statistics  
*data description: mean, variance, max and mean
sum _all

sum _all,details

codebook make

fre rep78

*pairwise correlation, covariance estimates etc)
pwcorr mpg rep78 price, sig
correlate mpg rep78 price, covariance
matrix C = r(C)    // stores covariance matrix in C
correlate mpg rep78 price
matrix R = r(C)

****Distribution test (for marginal distributions) e.g., normality test
*e.g. whether mileage and trunk space follows a normal distribution

swilk mpg trunk
*significance level 5%: p-value less than 5%-->less than 5% reject the null(normal), i.e. strong evidence that the distribution is NOT normal.P-value >5%, not enough evidence to reject the null: could be a normal distribution

****Plot of univariate empirical distributions
histogram mpg, frequency normal
histogram trunk, frequency normal

****Scatter plot of the integral transformed data
*Step 1: generate U using X. If we know the distribution of the RV, X, we could use the CFP of X directly. 
*For instance, we know from above that trunk follows a normal distribution
sum trunk
gen u_trunk = normal((trunk - `r(mean)')/`r(sd)')
/* alternatively, 
gen mean_trunk=13.75676
gen st_trunk=4.277404
replace u_trunk = normal((trunk - mean_trunk)/sd_trunk)
*/

/*If the distribution of the RV is unknown then we can generate U using the empirical CDF, e.g. mpg

sort mpg
gen u_mpg = (_n - 0.5) / _N

*/

*Step 2: Plot U vs X — visualize how the integral transform behaves.
scatter u_trunk trunk, msymbol(o) mcolor(blue) ///
    title("Integral-transformed data: U vs X") ///
    ytitle("U = F_X(X)") xtitle("Trunk Space")
	
	
*Copula estimation results (MLE with parametric, semiparametric, or nonparametric margins and copula), including AIC, BIC, and likelihood values
****BIC and AIC
sysuse auto,clear
capture program drop mylogit
program define mylogit
          args lnf Xb
          quietly replace `lnf' = -ln(1+exp(-`Xb')) if $ML_y1==1
          quietly replace `lnf' = -`Xb' - ln(1+exp(-`Xb')) if $ML_y1==0
end
ml model lf mylogit (foreign=mpg weight)
ml maximize
estat ic

ml model lf mylogit (foreign=mpg weight rep78)
ml maximize
estat ic

reg foreign mpg weight rep78
estat ic
predict mpgp if e(sample) 
corr mpg mpgp if e(sample)
di r(rho)^2


logit foreign mpg weight rep78
estat ic

*!!!!!!!!logi


use http://www.stata-press.com/data/r13/sysdsn1,clear

reg insure age male nonwhite  i.site
estat ic
mlogit insure age male nonwhite
estat ic
mlogit insure age male nonwhite i.site
estat ic

