/*

  Title:    Chronic illness and Bridging
  Purpose:  Core data cleaning wave2-3 cognition
  Author:   Tianyao Qu
  Date:     11/20/2020

*/

* ----------- Part 0: Setting -------------
clear all
set more off
set matsize 4000
global seed 4553
graph set window fontface "Times New Roman"

// Set the memory and file directory
global root_files   "C:\Users\windy\Desktop\Chronic_project"
global raw_data     "$root_files/DATA/raw_data"
global working_data "$root_files/DATA/working_data"
global logfiles     "$root_files/DOCUMENT"
global dofiles      "$root_files/CODE"
global tables       "$root_files/OUTPUT/tables"
global figures      "$root_files/OUTPUT/figures"

cd "$root_files"


********************************************
*****************in wave 2******************
********************************************
use $working_data/wave2_coredata, clear

// Verify that the only effectively missing values are for moca_contour,
// moca_numbers, moca_hands, moca_trail2 and moca_word2
foreach var of varlist moca_month2 moca_date2 moca_rhino ///
    moca_5numbers moca_3numbers moca_subcat moca_sentcat moca_alike2 ///
    moca_face moca_velvet moca_church moca_daisy moca_red {
        assert inlist(`var',0,1,2,3,4,.a,.b)
}

foreach var of varlist moca_contour moca_numbers moca_hands moca_trail2 moca_word2 {
    ass inlist(`var',0,1,.c,.d,.f)
}

local items moca_month2 moca_date2 moca_rhino moca_contour moca_numbers moca_hands ///
    moca_trail2 moca_5numbers moca_3numbers moca_subcat moca_sentcat moca_word2 ///
    moca_alike2 moca_face moca_velvet moca_church moca_daisy moca_red

forv i = 1/18 {
    tempvar moca`i'
    loc scorevars `scorevars' `moca`i''
    
    loc item: word `i' of `items'
    if `i'==10 {
        recode `item' (.a=0) (.b=0), gen(`moca`i'')
    }
    else if `i'==13 {
        recode `item' (1/2=1) (3/4=0) (.a=0) (.b=0), gen(`moca`i'')
    }
    else {
        gen byte `moca`i'' = (`item'==1) if !inlist(`item',.f)
    }
}
 sum `moca1'-`moca18'


// Handle flags
// Score serial subtraction as 0 if paper & pencil used
replace `moca10' = 0 if moca_flag==1

// Score all 3 clock items as 0 if aid used in drawing clock
replace `moca4' = 0 if moca_flag==9
replace `moca5' = 0 if moca_flag==9
replace `moca6' = 0 if moca_flag==9

// Score fluency as 0 if clues used
replace `moca12' = 0 if moca_flag==10
forv i = 1/18 {
    loc item: word `i' of `items'
    loc var: word `i' of `scorevars'
    gen `item'_score = `var'
}
lab var moca_month2_score   "Month score"
lab var moca_date2_score    "Date score"
lab var moca_rhino_score    "Rhino score"
lab var moca_contour_score  "Clock score (contour)"
lab var moca_numbers_score  "Clock score (numbers)"
lab var moca_hands_score    "Clock score (hands)"
lab var moca_trail2_score   "Trails score"
lab var moca_5numbers_score "Forward digits score"
lab var moca_3numbers_score "Backward digits score"
lab var moca_subcat_score   "Serial 7s subtraction score"
lab var moca_sentcat_score  "Cat sentence score"
lab var moca_word2_score    "F words score"
lab var moca_alike2_score   "Watch/ruler comparison score"
lab var moca_face_score     "Delayed recall (face)"
lab var moca_velvet_score   "Delayed recall (velvet)"
lab var moca_church_score   "Delayed recall (church)"
lab var moca_daisy_score    "Delayed recall (daisy)"
lab var moca_red_score      "Delayed recall (red)"

// Fill in missing values with prediction based on other items
loc mvars `moca4' `moca5' `moca6' `moca7' `moca12'
loc covs: list scorevars - mvars
tempvar p
foreach var of local mvars {
    logistic `var' `covs'
    predict `p'
    replace `var' = (`p'>0.5) if mi(`var')
    drop `p'
}
egen moca_sa = rowtotal(`scorevars')
lab var moca_sa       "Total MoCA-SA score"
alpha moca_month2_score moca_date2_score moca_rhino_score moca_contour_score moca_numbers_score moca_hands_score moca_trail2_score moca_5numbers_score moca_3numbers_score moca_subcat_score moca_sentcat_score moca_word2_score moca_alike2_score moca_face_score moca_velvet_score moca_church_score moca_daisy_score moca_red_score     


********************************************
*****************in wave 3******************
********************************************
use $working_data/wave3_coredata, clear

*cognition
renvars MOCA_MONTH2- MOCA_FLAG, lower

// Verify that the only effectively missing values are for moca_contour,
// moca_numbers, moca_hands, moca_trail2 and moca_word2
foreach var of varlist moca_month2 moca_date2 moca_rhino ///
    moca_5numbers moca_3numbers moca_subcat moca_sentcat moca_alike2 ///
    moca_face moca_velvet moca_church moca_daisy moca_red {
        assert inlist(`var',0,1,2,3,4,.a,.b)
}

foreach var of varlist moca_contour moca_numbers moca_hands moca_trail2 moca_word2 {
    ass inlist(`var',0,1,.c,.d,.f)
}

local items moca_month2 moca_date2 moca_rhino moca_contour moca_numbers moca_hands ///
    moca_trail2 moca_5numbers moca_3numbers moca_subcat moca_sentcat moca_word2 ///
    moca_alike2 moca_face moca_velvet moca_church moca_daisy moca_red

forv i = 1/18 {
    tempvar moca`i'
    loc scorevars `scorevars' `moca`i''
    
    loc item: word `i' of `items'
    if `i'==10 {
        recode `item' (.a=0) (.b=0), gen(`moca`i'')
    }
    else if `i'==13 {
        recode `item' (1/2=1) (3/4=0) (.a=0) (.b=0), gen(`moca`i'')
    }
    else {
        gen byte `moca`i'' = (`item'==1) if !inlist(`item',.f)
    }
}
 sum `moca1'-`moca18'


// Handle flags
// Score serial subtraction as 0 if paper & pencil used
replace `moca10' = 0 if moca_flag==1

// Score all 3 clock items as 0 if aid used in drawing clock
replace `moca4' = 0 if moca_flag==9
replace `moca5' = 0 if moca_flag==9
replace `moca6' = 0 if moca_flag==9

// Score fluency as 0 if clues used
replace `moca12' = 0 if moca_flag==10
forv i = 1/18 {
    loc item: word `i' of `items'
    loc var: word `i' of `scorevars'
    gen `item'_score = `var'
}
lab var moca_month2_score   "Month score"
lab var moca_date2_score    "Date score"
lab var moca_rhino_score    "Rhino score"
lab var moca_contour_score  "Clock score (contour)"
lab var moca_numbers_score  "Clock score (numbers)"
lab var moca_hands_score    "Clock score (hands)"
lab var moca_trail2_score   "Trails score"
lab var moca_5numbers_score "Forward digits score"
lab var moca_3numbers_score "Backward digits score"
lab var moca_subcat_score   "Serial 7s subtraction score"
lab var moca_sentcat_score  "Cat sentence score"
lab var moca_word2_score    "F words score"
lab var moca_alike2_score   "Watch/ruler comparison score"
lab var moca_face_score     "Delayed recall (face)"
lab var moca_velvet_score   "Delayed recall (velvet)"
lab var moca_church_score   "Delayed recall (church)"
lab var moca_daisy_score    "Delayed recall (daisy)"
lab var moca_red_score      "Delayed recall (red)"

// Fill in missing values with prediction based on other items
loc mvars `moca4' `moca5' `moca6' `moca7' `moca12'
loc covs: list scorevars - mvars
tempvar p
foreach var of local mvars {
    logistic `var' `covs'
    predict `p'
    replace `var' = (`p'>0.5) if mi(`var')
    drop `p'
}
egen moca_sa = rowtotal(`scorevars')
lab var moca_sa       "Total MoCA-SA score"
alpha moca_month2_score moca_date2_score moca_rhino_score moca_contour_score moca_numbers_score moca_hands_score moca_trail2_score moca_5numbers_score moca_3numbers_score moca_subcat_score moca_sentcat_score moca_word2_score moca_alike2_score moca_face_score moca_velvet_score moca_church_score moca_daisy_score moca_red_score     

 












