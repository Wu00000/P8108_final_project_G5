*** P8110 Applied Regression II ***
*** Group #1 **********************
*** Midterm Project **************;

/* Study Introduction */

* Study Interest: 
  To determine the effect of parental depression on the risk of depression in 
  their offspring. We compare offspring with depressed index parents with 
  offspring with normal index parents on the age of onset of depression;
  
* Sample: 220 eligible children (125 cases + 95 controls);

* Collected variables:
	- ID
	- PARDEP: Parent Depression Status (0:never depressed/ 1:ever depressed)
	- DSMDEPHR: Child Depression Status (0:never depressed/ 1:ever depressed)
	- PTSEX: Child Sex (1:male/ 2:female)
	- PTAGE: Age of Child at Interview (Age in years)
	- BEDEPON: Age of onset of depression in offspring (Age in years/ -1:missing data)
	- DSMSUBHR: Substance abuse status of offspring (0:no abuse/ 1:abuse)
	- BESUBON: Age of onset of substance abuse in offspring (Age in years/ -1:missing data)
	- SESCLASS: Categorized social class of parent (1,2,3,4,5/higher scores imply lower SES)
	- MSPARENT: Parent Marital status (1: married/ 2:seperated/divoced)

***************************************************************************************************;
/* Hypothesis #1 */
* Offspring of a depressed parent are more likely to have pre-pubertal onset (<13 years of age) 
  depression than offspring of a non-depressed parent, 
  but equally likely to have an onset of adolescent/early adulthood depression, 
  given demographic and social characteristics.	
  
* Outcome
	- Censoring status: DSMDEPHR
	- Time to event/time to censored
				if DSMDEPHR = 0, use PTAGE
				if DSMDEPHR = 1, use BEDEPON;
	
* Exposure
  PARDEP: Parent Depression Status;
  
* Covarients
 - PTSEX
 - SESCLASS
 - MSPARENT;

***************************************************************************************************;
/* Hypothesis #2 */
* Is there evidence for the effect of prior depression in offspring, as well as the
  effect of parent’s depression status on the age of onset of substance abuse/dependence 
  in offspring, given demographic and social characteristics?

* Outcome: 
	- Censoring status: DSMSUBHR (0:no sub abuse/ 1:sub abuse)
	- Time to event/time to censored
				if DSMSUBHR = 0, use PTAGE
				if DSMSUBHR = 1, use BESUBON;
				;
* Exposure: 
			- prior: depression take place before substance abuse or not 
			- PARDEP: Parent Depression Status;
* Covarients: 
			- PTSEX
 			- SESCLASS
 			- MSPARENT;



***************************************************************************************************;
/*** Data Importing and Manipulation ***/
proc import out=mid
	datafile="/home/u60695811/2022 Fall/P8110/P8110_Midterm/MidtermProjectData.csv"
	dbms=csv replace;
	getnames=yes;
run;

* Create labels;
data mid;
	set mid;
	label PARDEP = "Parent_Depression_Status"
		  DSMDEPHR = "Child_Depression_Status"
		  PTSEX = "Child_Sex"
		  PTAGE = "Child_Age_Interview"
		  BEDEPON = "Child_Age_Dep_Onset"
		  DSMSUBHR = "Child_Substance_Status"
		  BESUBON = "Child_Age_Sub_Onset"
		  SESCLASS = "Parent_Social_Class"
		  MSPARENT = "Parent_Marital_Status";
run;

* Missing Data: Setting "-1" to "" in BEDEPON and BESUBON;
data mid;
	set mid;
	if BEDEPON = "-1" then BEDEPON = .;
	if BESUBON = "-1" then BESUBON = .;
run;


* Creating variables, "time", and "time2";
* The time-to-event/time-to-censored variable, time, for hypothesis #1;
* The time-to-event/time-to-censored variable, time2, for hypothesis #2;

data mid;
	set mid;
	if DSMDEPHR = 0 then time = PTAGE;
	else time = BEDEPON;
	
	if DSMSUBHR = 0 then time2 = PTAGE;
	else time2 = BESUBON;
	
run;

Proc print data=mid (obs=10) label; run;
Proc print data=mid label; run;



***************************************************************************************************;
/*** Descriptive Statistics ***/
* Note: Use PROC FREQ for categorical variables
		Use PROC UNIVARIATE or PROC MEANS for continuous variables;
proc freq data=mid;
	tables (PTSEX DSMDEPHR DSMSUBHR SESCLASS MSPARENT)*PARDEP
	/nocol norow nopercent;
	title "Descriptive Statistics - categorical variables";
run;

proc univariate data=mid;
	var PTAGE BEDEPON BESUBON;
	title "Descriptive Statistics - continuous variables";
run;



***************************************************************************************************;
/*** Lifetest Procedure ***/
proc lifetest data = mid method=KM alpha=0.05 conftype=loglog
		outsurv=survival_A stderr plots=survival(cl);
	time time*DSMDEPHR(0);
	title "Hypothesis#1: Overall KM Estimates";
run;


/* by parent depression status (0:never depressed/ 1:ever depressed)*/
proc lifetest data = mid method=KM alpha=0.05 conftype=loglog 
		outsurv=survival_A stderr plots=survival(cl);
	time time*DSMDEPHR(0);
	strata PARDEP/adjust=bon;
	title "Hypothesis#1: KM estimates by Parent_Dep_Status";
run;
* Finding:
	- children with parent never depressed have later Age_Dep_onset
	- children with parent never depressed have higher survival rate;



***************************************************************************************************;
/*** Hypothesis #1 PHREG Procedure ***/
	
/* Test PH assumption */
proc phreg data = mid;
	class PARDEP(ref="0") 
	      PTSEX(ref="1")
	      SESCLASS(ref="1") 
	      MSPARENT(ref="1")/param=ref;
	model time*DSMDEPHR(0) = PARDEP PTSEX SESCLASS MSPARENT/ ties=efron;
	assess PH / resample;
	title "Hypothesis #1: PH Assumption Check";
run;
* Finding: PH assumption for PARDEP is violated;	



/* Cox Model for H#1 */	
* PARDEP is multiplied with the time indicator, interaction;
proc phreg data=mid;
	class PARDEP(ref="0") 
	      PTSEX(ref="1")
	      SESCLASS(ref="1") 
	      MSPARENT(ref="1")/param=ref;
	model time*DSMDEPHR(0) = PARDEP PTSEX MSPARENT timeP
	/ risklimits covb ties=efron;
	timeP = PARDEP*(time>=13);
	strata SESCLASS;
	title "Hypothesis #1: Cox Model";
run;

* HR(PARDEP 1 vs 0, timeP = 0) = 1.195 95%CI (0.637, 2.241);
* HR(PARDEP 1 vs 0, timeP = 1) = 1.474
                                 95% CI: var(beta(PARDEP)) = 0.396
                                         var(beta(timeP)) = 0.489
                                         cov(beta(PARDEP),beta(timeP)) = -0.393
                                         var(beta(PARDEP)+beta(timeP)) = 0.396 + 0.489 + 2*(-0.393) = 0.099
                                         upper limit: e^((1.897-1.509)+1.96*sqrt(0.099)) = 2.733
                                         lower limit: e^((1.897-1.509)-1.96*sqrt(0.099)) = 0.795
                                 thus 95% CI (0.491, 4.426);



***************************************************************************************************;
/*** Hypothesis #2 PHREG Procedure ***/

/* Test PH assumption */
proc phreg data = mid;
	class PARDEP(ref="0") 
	      PTSEX(ref="1")
	      SESCLASS(ref="1") 
	      MSPARENT(ref="1")/param=ref;
	model time2*DSMSUBHR(0) = PARDEP PTSEX SESCLASS MSPARENT/ ties=efron;
	assess PH / resample;
	title "Hypothesis #2: PH Assumption Check";
run;
* Finding: PH assumption is not violated;	


/* Cox Model for H#2 */	
* prior referes to whether depression happened before sub abuse;
proc phreg data = mid;
    class PARDEP(ref="0") 
	      PTSEX(ref="1")
	      SESCLASS(ref="1") 
	      MSPARENT(ref="1")/param=ref;
	model time2*DSMSUBHR(0) = prior PARDEP PTSEX MSPARENT/ risklimits covb ties = efron;
	if time <= time2 then prior = 1; 
	else prior = 0;
	strata SESCLASS;
	title "Hypothesis #2: Cox Model";
run;
* Note: since SAS read the first data as reference group, prior = 1 is the 
  reference group
  
  HR(prior 0 vs 1) = 1.478 (95% CI: 0.527, 4.146)
  HR(PARDEP 1 vs 0) = 2.768 (95% CI: 0.822, 9.325);


