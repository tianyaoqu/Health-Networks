/*

  Title:    Chronic illness and Bridging
  Purpose:  Network data cleaning and analysis 
  Author:   Tianyao Qu
  Date:     11/20/2020

*/

* ----------- Part 0: Setting -------------
clear all
set more off
set matsize 5000
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

* -------Part 1: wave 2 social network data cleaning---
use $working_data/wave3_network, clear
use $working_data/wave2_network, clear
use $working_data/wave1_network, clear

** only keep confidants in roster 1
sort ID SECTION
tab SECTION
keep if SECTION==1

*network size
egen nwsize = total(SECTION==1), by(ID)
gen pairs = (nwsize*(nwsize-1))/2   // total possible # unconnected alter pairs

* -------Part 2: different types of bridging-----*
**********************************************************
**** Bridging Potential: Prescence/abscence of ties ****
**********************************************************
**1. absence of ties, unconnected pairs (0=0; 1/8=1 : not connected = not interact at all in a year)
sum TALKFREQ1- TALKFREQ5
recode TALKFREQ1-TALKFREQ5 (0=1) (1/8=0), gen(nt1 nt2 nt3 nt4 nt5) 
egen nt_w2 = rowtotal(nt1 nt2 nt3 nt4 nt5), missing    //how many unconnected pairs that each alter has

*bridging capacity/total unconnected alter paris of each ego
egen cunconn=sum(nt), by(ID)   
replace cunconn=cunconn/2         //because ties go either ways, divided by 2

recode cunconn (1/max=1), gen(dunconn) //bridging potential dummy variable: as long as ego has 1 unconnected pairs

//bridging needs at least 2 alters
replace cunconn_w=. if nwsize==1
replace dunconn_w=. if nwsize==1

**poorly connnected pairs**
sum TALKFREQ1- TALKFREQ5

**2. less than once a year ---  (**eventually used** --> 0/1=0; 2/8=1 : 
**   not connected = not interact at all/less than once in a year)
recode TALKFREQ1-TALKFREQ5 (0/1=1) (2/8=0), gen(nt11 nt12 nt13 nt14 nt15) 
egen nt01 = rowtotal(nt11 nt12 nt13 nt14 nt15), missing //how many unconnected pairs that each alter has
egen cunconn01=sum(nt01), by(ID)   
replace cunconn01=cunconn01/2      

recode cunconn01 (1/max=1), gen(dunconn01) 

replace cunconn01=. if nwsize==1
replace dunconn01=. if nwsize==1

//3. once a year --- 0/1/2=0
recode TALKFREQ1-TALKFREQ5 (0/2=1) (3/8=0), gen(nt21 nt22 nt23 nt24 nt25) 
egen nt012 = rowtotal(nt21 nt22 nt23 nt24 nt25), missing
egen cunconn012=sum(nt012), by(ID)   
replace cunconn012=cunconn012/2      

recode cunconn012 (1/max=1), gen(dunconn012) 
replace cunconn012 =. if nwsize==1
replace dunconn012 =. if nwsize==1

**********************************************************
**** Network Density ****
**********************************************************
// present ties divided by g(g-1)/2 for non-directed network (5*4/2=10)
**1. recode = 1 if interact at least once in a year (1/8=1; 0=0)
recode TALKFREQ1-TALKFREQ5 (0=0) (1/8=1), gen(yt1 yt2 yt3 yt4 yt5)
egen yt = rowtotal(yt1 yt2 yt3 yt4 yt5), missing
gen nwden=yt/10

**********************************************************
**** Isolated Alters ****
**********************************************************
*isolated alters as long as anyline in yt_w is 0, meaning there is isolate in ego's network
egen isoal = anymatch(yt_w), value(0)
egen cisoal=total(isoal), by(ID) 
recode cisoal (1/max=1), gen(disoal)

replace cisoal =. if nwsize==1
replace disoal =. if nwsize==1

**2. poorly connected isolated alters (eventually used)
// recode = 1 if interact at least once in a year (1/8=1; 0=0)
recode TALKFREQ1-TALKFREQ5 (0/1=0) (2/8=1), gen(yt11 yt12 yt13 yt14 yt15)
egen yt01 = rowtotal(yt11 yt12 yt13 yt14 yt15), missing

*isolated alters as long as anyline in yt_w is 0, meaning there is isolate in ego's network
egen isoal01 = anymatch(yt01), value(0)
egen cisoal01=total(isoal01), by(ID) 
recode cisoal01 (1/max=1), gen(disoal01)

replace cisoal01 =. if nwsize==1
replace disoal01 =. if nwsize==1


**********************************************************
**** network efficiency (Burt 1992 Structural holes)  ****
**********************************************************
sum yt1 yt2 yt3 yt4 yt5
tab yt,m

gen eachredun = yt/nwsize

egen ttlredun= sum(eachredun), by(ID)
gen effsize=nwsize - ttlredun
gen effici = effsize/nwsize

//recode R  = missing if name <2 alters, because network efficiency needs at least 2 alters
replace effsize=. if nwsize==1
replace effici=. if nwsize==1
replace ttlredun=. if nwsize==1













