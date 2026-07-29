/* Person-mean aggregation for two-level centering.
 * Adapted from "dataprep and analysis code 20240703.sas" (this repo):
 * the library/dataset load is replaced by the inlined sample in
 * autoexec.sas (dataset cannabis_data). The BY-group PROC MEANS with
 * OUTPUT ... MEAN=/AUTONAME and the drop of the automatic _TYPE_/_FREQ_
 * columns are the author's, unchanged.
 */

/*drop moments with no cannabis use*/
data data; set cannabis_data;
if mjyn = 0 then delete;
if mjyn = . then delete;
run;

/*TWO-LEVEL CENTERING*/
/*aggregate to person means*/
proc sort data=data; by id; run;
proc means data=data noprint; by id;
var enhance cope pa na cm_depressed cm_problems;
output out=personmeans mean=/autoname; run;
data personmeans; set personmeans; drop _type_ _freq_; run;

/* show the resulting person-level means dataset */
proc print data=personmeans; run;

/*aggregate to sample means*/
proc means data=personmeans noprint; output out=samplemeans mean= /autoname; run;
data samplemeans; set samplemeans; dumb=1; drop _type_ _freq_ id_mean; run;
proc print data=samplemeans; run;
