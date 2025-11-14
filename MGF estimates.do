//MGF 
clear all
// Load in bitcoin_gld.dta
use "bitcoin_gld.dta", clear

//turn date into numerical value 
// gen daily_date = date(date, "YMD") // Replace "MDY" with your actual date format (e.g., "DMY", "YMD")
sort daily_date
tsset week


// Keep only non-missing 
keep if !missing(return_btc)
keep if !missing(return_gld)

//////// MGF for BTC /////////////
 
//Prepare results container
tempfile mgf_tmp
postfile pf double t double mgf using "`mgf_tmp'", replace

// Grid settings
local from = -1
local to   = 1
local step = 0.1
local nsteps = ceil((`to' - `from')/`step')

// Loop over t values
forvalues i = 0/`nsteps' {
    * compute numeric t
    local t = `= `from' + `i'*`step''

    * compute v = t * return_btc, use log-sum-exp for stability
    quietly {
        gen double v = `t' * return_btc
        su v, meanonly
        local vmax = r(max)
        gen double exps = exp(v - `vmax') 
        su exps, meanonly
        local mean_shift = r(mean)
        * if underflow, set missing; otherwise recover logmgf and mgf
        if (`mean_shift' <= 0) {
            local mgfval = .
        }
        else {
            local logmgf = ln(`mean_shift') + `vmax'
            local mgfval = exp(`logmgf')
        }
        * drop temp vars so next iter starts clean
        drop v exps
    }

    * post result
    post pf (`t') (`mgfval')
}

// finish posting and load results
postclose pf
use "`mgf_tmp'", clear
sort t

// show results
list, noobs clean

twoway (line mgf t, sort lwidth(medium)), ///
    title("Empirical MGF of BTC Returns") xtitle("t") ytitle("M̂(t)")

///////////////////////////////


/////// MGF for GOLD ///////

clear
use "bitcoin_gld.dta", clear
sort daily_date
tsset week

keep if !missing(return_btc, return_gld)

// Prepare results container
tempfile mgf_gld
postfile pf_gld double t double mgf using "`mgf_gld'", replace

// Grid settings
local from = -1
local to   = 1
local step = 0.1
local nsteps = ceil((`to' - `from')/`step')

forvalues i = 0/`nsteps' {

    local t = `= `from' + `i'*`step''

    quietly {
        gen double v = `t' * return_gld
        su v, meanonly
        local vmax = r(max)

        gen double exps = exp(v - `vmax')
        su exps, meanonly
        local mean_shift = r(mean)

        if (`mean_shift' <= 0) local mgfval = .
        else local mgfval = exp( ln(`mean_shift') + `vmax' )

        drop v exps
    }

    post pf_gld (`t') (`mgfval')
}

postclose pf_gld
use "`mgf_gld'", clear
sort t

twoway (line mgf t, sort lwidth(medium)), ///
    title("Empirical MGF of Gold Returns") xtitle("t") ytitle("M̂(t)")








