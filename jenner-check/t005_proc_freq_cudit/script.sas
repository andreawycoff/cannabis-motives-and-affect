/* Distribution of the cannabis use disorder screen (CUDIT-R).
 * Adapted from "dataprep and analysis code 20240703.sas" (this repo):
 * the PROC IMPORT of the baseline CSV is replaced by the inlined sample
 * in autoexec.sas (dataset baseline). The BY-id PROC MEANS to a
 * per-person value and the PROC FREQ over cudit are the author's.
 */

/* one cudit value per person */
proc sort data=baseline; by id; run;
proc means data=baseline noprint; by id; var cudit; output out = cuditmean mean=; run;

/* how the CUDIT-R screen is distributed across people */
proc means data=cuditmean; var cudit; run;
proc freq data=cuditmean; tables cudit; run;
