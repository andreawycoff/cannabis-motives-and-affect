/* Unconditional (intercept-only) multilevel model for positive affect.
 * Adapted from "dataprep and analysis code 20240703.sas" (this repo):
 * the library/dataset load is replaced by the inlined sample in
 * autoexec.sas (dataset cannabis_data). The moment-drop and the
 * two-level PROC MIXED variance-components model are the author's.
 *
 * This is the "how much of the variability in momentary affect is
 * between people" step: a random person intercept, ML estimation,
 * Satterthwaite denominator df, with COVTEST on the variance estimates.
 */

/*drop moments with no cannabis use*/
data data; set cannabis_data;
if mjyn = 0 then delete;
if mjyn = . then delete;
run;

/*two-level unconditional model predicting positive affect*/
proc mixed data=data covtest noclprint method = ML;
class id studyday;
model pa=/solution ddfm = SATTERTHWAITE;
random intercept / sub=id type=vc; run;
