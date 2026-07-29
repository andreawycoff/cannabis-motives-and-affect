/* Standardizing momentary predictors to read pseudo-standardized betas.
 * Adapted from "dataprep and analysis code 20240703.sas" (this repo):
 * the library/dataset load is replaced by the inlined sample in
 * autoexec.sas (dataset cannabis_data). The change scores, person-mean
 * centering, and the PROC STANDARD (mean=0 std=1) requested for the R&R
 * are the author's, unchanged.
 */

/* sort so LAG/FIRST. see moments in order within each person-day */
proc sort data=cannabis_data out=data; by id studyday; run;

/*create change scores for momentary affect before dropping non-use moments*/
data data; set data; by id studyday;
lag_pa = lag(pa); if first.studyday then lag_pa = .;
lag_na = lag(na); if first.studyday then lag_na = .;
run;
data data; set data; by id studyday;
dpa = pa-lag_pa;
dna = na-lag_na;
run;

/*drop moments with no cannabis use*/
data data; set data;
if mjyn = 0 then delete;
if mjyn = . then delete;
run;

/*aggregate to person means and person-center the momentary motives*/
proc sort data=data; by id; run;
proc means data=data noprint; by id;
var enhance cope;
output out=personmeans mean=/autoname; run;
data personmeans; set personmeans; drop _type_ _freq_; run;

data data; merge data personmeans; by id;
enh_personc=enhance-enhance_mean;
cop_personc=cope-cope_mean;
run;

/*for r&r, standardize all momentary variables to get pseudo betas to report in table*/
proc standard data=data mean=0 std=1 out=data_standardized_m; var dpa dna lag_pa lag_na enh_personc cop_personc
alcyn with_ppl studyday weekend hour_after_wake; run;
proc means data=data_standardized_m; var dpa dna lag_pa lag_na enh_personc cop_personc
alcyn with_ppl studyday weekend hour_after_wake; run;
