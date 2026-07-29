/* Momentary change scores from the cannabis motives & affect study.
 * Adapted from "dataprep and analysis code 20240703.sas" (this repo):
 * the libname/dataset load is replaced by the inlined sample in
 * autoexec.sas (dataset cannabis_data); the change-score logic below is
 * the author's, unchanged.
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

/* look at the momentary change scores that result */
proc means data=data n mean std min max;
var pa lag_pa dpa na lag_na dna;
run;
