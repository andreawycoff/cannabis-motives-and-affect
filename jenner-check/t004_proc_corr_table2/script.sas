/* Person-level descriptive correlations (the paper's Table 2).
 * Adapted from "dataprep and analysis code 20240703.sas" (this repo):
 * the library load and PROC IMPORT of the baseline CSV are replaced by
 * the inlined samples in autoexec.sas (datasets cannabis_data and
 * baseline). The moment-drop, baseline merge, BY-id PROC MEANS to
 * person means, and the PROC CORR over those aggregates are the
 * author's, unchanged.
 */

/*drop moments with no cannabis use*/
data data; set cannabis_data;
if mjyn = 0 then delete;
if mjyn = . then delete;
run;

/*merge baseline and data*/
proc sort data=data; by id; run;
proc sort data=baseline; by id; run;
data data; merge data baseline; by id; run;

/*person-level aggregate measure descriptive info (table 2)*/
proc means data=data noprint; by id; var pa na enhance cope cmmq_enjoy cmmq_cope cudit; output out = table2descs mean=; run;
proc corr data=table2descs; var pa na enhance cope cmmq_enjoy cmmq_cope cudit; run;
