data final;
infile '/home/u59400603/P8108 Survival Analysis/Final.csv' delimiter=',' MISSOVER DSD;
input inst time status age sex ph_ecog ph_karno pat_karno meal_cal wt_loss;
run;

data final;
    set final;
    if _n_=1 then delete;
run;

* Survival experience between male and females;
proc lifetest data=final method=KM alpha=0.05 plots=survival(test);
time time*status(2);
strata sex;
title "Part 1: Kaplan-Meier estimates by gender";
run;
* Log-rank test statistic: 6.2289;
* P-value: 0.0126;
* Conclusion: We will reject the null hypothesis at a significance level of 0.05.
  There is a significant difference between two sex groups.
* Wilcoxon test statistic: 3.0413;
* P-value: 0.0812;
* Conclusion: because Wilcoxon test is more sensitive to detect
early points in time than the log-rank test, we fail reject the null hypothesis
at a significnce level of 0.05. There is no significant difference between two sex groups
(in earlier points in time).
* Likelihood Ratio test statstic: 5.6211;
* P-value: 0.0177;
* Conclusion: We will reject the null hypothesis at a significance level of 0.05.
  There is a significant difference between two sex groups;
  

proc univariate data=final;
var age;
run;

* Compare survival experience among multiple age groups;
proc lifetest data=final method=KM alpha=0.05 plots=survival(test);
time time*status(2);
strata age(60 70 80);
title "Part 2: Strata created by age";
run;
* Log-rank test statistic: 2.4897;
* P-value: 0.4772;
* Conclusion: We fail reject the null hypothesis at a significance level of 0.05.
  There is no significant difference between four age groups.
* Wilcoxon test statistic: 1.3868;
* P-value: 0.7086;
* Conclusion: We fail reject the null hypothesis
at a significnce level of 0.05. There is no significant difference between four age groups.
* Likelihood Ratio test statstic: 2.4924;
* P-value: 0.4767;
* Conclusion: We fail reject the null hypothesis at a significance level of 0.05.
  There is no significant difference between four age groups;



