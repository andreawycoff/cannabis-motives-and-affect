/*set library*/
libname cannabis "C:\Users\amwt27\OneDrive - University of Missouri\Desktop\Research\_Cannabis momos"; run;

/*load data*/
data data; set cannabis.cannabis_motives_affect_dataset; run;

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
/*766 observations across 48 people, avg of ~16 cannabis use moments per person (across 14 days in study)*/

/*iccs-unconditional models predicting affect and motives to see how much variability is at each level*/
proc mixed data=data covtest noclprint method = ML;
class id studyday;
model pa=/solution ddfm = SATTERTHWAITE;
random intercept / sub=id type=vc;
random intercept / sub=studyday(id) type=vc; run;

proc mixed data=data covtest noclprint method = ML;
class id studyday;
model na=/solution ddfm = SATTERTHWAITE;
random intercept / sub=id type=vc;
random intercept / sub=studyday(id) type=vc; run;

proc mixed data=data covtest noclprint method = ML;
class id studyday;
model enhance=/solution ddfm = SATTERTHWAITE;
random intercept / sub=id type=vc;

random intercept / sub=studyday(id) type=vc; run;
proc mixed data=data covtest noclprint method = ML;
class id studyday;
model cope=/solution ddfm = SATTERTHWAITE;
random intercept / sub=id type=vc;
random intercept / sub=studyday(id) type=vc; run;

/*ICCs for day level are low: for affect, day-level ICCs are 12-13%, for motives they are 14-15%*/
/*go with 2-level model, moments within person*/

/*two-level unconditional models predicting affect and motives*/
proc mixed data=data covtest noclprint method = ML;
class id studyday;
model pa=/solution ddfm = SATTERTHWAITE;
random intercept / sub=id type=vc; run;

proc mixed data=data covtest noclprint method = ML;
class id studyday;
model na=/solution ddfm = SATTERTHWAITE;
random intercept / sub=id type=vc; run;

proc mixed data=data covtest noclprint method = ML;
class id studyday;
model enhance=/solution ddfm = SATTERTHWAITE;
random intercept / sub=id type=vc; run;

proc mixed data=data covtest noclprint method = ML;
class id studyday;
model cope=/solution ddfm = SATTERTHWAITE;
random intercept / sub=id type=vc; run;

/*these look better*/

/*prep data for 2-level analyses*/

/*TWO-LEVEL CENTERING*/
/*aggregate to person means*/
proc sort data=data; by id; run;
proc means data=data noprint; by id;
var enhance cope pa na cm_depressed cm_problems;
output out=personmeans mean=/autoname; run;
data personmeans; set personmeans; drop _type_ _freq_; run;

/*aggregate to sample means*/
proc means data=personmeans noprint; output out=samplemeans mean= /autoname; run;
data samplemeans; set samplemeans; dumb=1; drop _type_ _freq_ id_mean; run;

/*center*/
data data; merge data personmeans; by id;
enh_personc=enhance-enhance_mean;
cop_personc=cope-cope_mean;
cop_depanx_personc=cm_depressed-cm_depressed_mean;
cop_prob_personc=cm_problems-cm_problems_mean;
run;

data data; set data; dumb=1; run;
data data; merge data samplemeans; by dumb;
enh_samplec=enhance_mean-enhance_mean_mean;
cop_samplec=cope_mean-cope_mean_mean;
cop_depanx_samplec=cm_depressed_mean-cm_depressed_mean_mean;
cop_prob_samplec=cm_problems_mean-cm_problems_mean_mean;
run;

/*import baseline qualtrics*/
PROC IMPORT OUT= WORK.baseline 
            DATAFILE= "C:\Users\amwt27\OneDrive - University of Missouri\Desktop\Research\_Cannabis momos\baseline_data_toupload.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

/*merge baseline and data*/
proc sort data=baseline; by id; run;
data data; merge data baseline; by id; run;

/*delete people that we already excluded based on low compliance*/
data data; set data; if studyday=. then delete; run;

/*center cudit, age, and baseline enjoyment and coping motives*/
proc means data=data noprint; by id; var cudit age cmmq_enjoy cmmq_cope; output out=bperson mean=; run;
proc means data=bperson noprint; var cudit age cmmq_enjoy cmmq_cope; output out=bsample mean=/autoname; run;
data bsample; set bsample; dumb=1; drop _type_ _freq_; run;
data data; set data; dumb=1; run;
data data; merge data bsample; by dumb; run;

data data; set data;
cudit_c = cudit-cudit_mean;
age_c = age-age_mean;
cmmq_enjoy_c = cmmq_enjoy-cmmq_enjoy_mean;
cmmq_cope_c =cmmq_cope-cmmq_cope_mean;
run;

/*cuditr*/
proc means data=bperson; var cudit; run;
proc freq data=bperson; tables cudit; run;

/*person-level aggregate measure descriptive info (table 2)*/
proc means data=data noprint; by id; var pa na enhance cope cmmq_enjoy cmmq_cope cudit; output out = table2descs mean=; run;
proc corr data=table2descs; var pa na enhance cope cmmq_enjoy cmmq_cope cudit; run;

/*ema descriptive info for measures section*/
proc means data=data; var enhance cope pa na; run;


/*comment out these next 3 sections on standardizing variables when not trying to get pseudo betas*/

/*3/22/24-- for r&r, standardize all variables to get pseudo betas to report in table*/
proc standard data=data mean=0 std=1 out=data_standardized_m; var dpa dna lag_pa lag_na enh_personc cop_personc
alcyn with_ppl studyday weekend hour_after_wake; run;
proc means data=data_standardized_m; var dpa dna lag_pa lag_na enh_personc cop_personc
alcyn with_ppl studyday weekend hour_after_wake; run;

/*go to a person level dataset*/
proc means data=data noprint; by id; var enh_samplec cop_samplec cmmq_enjoy_c
cmmq_cope_c age_c gender_recode; output out = plevel mean=; run;
proc standard data=plevel mean=0 std=1 out=data_standardized_p; var enh_samplec cop_samplec cmmq_enjoy_c
cmmq_cope_c age_c gender_recode; run;
proc means data=data_standardized_p; var enh_samplec cop_samplec cmmq_enjoy_c cmmq_cope_c age_c gender_recode; run;

/*replace data with standardized vars so that we don't have to change dataset or variable names below*/
data data; set data_standardized_m; run;
/*add in person level standardized variables*/
data data; set data; drop enh_samplec cop_samplec cmmq_enjoy_c cmmq_cope_c age_c gender_recode; run;
data data; merge data data_standardized_p; by id; run;


/*create motive and affect files to read into mplus for omegas*/
/*enhancement*/
data mplus_enh; set data; drop studyday--mjyn cm_depressed--cmmq_cope_c; run;
data mplus_enh; set mplus_enh;
if cm_feeling = . then delete;
if cm_fun = . then delete;
if cm_pleasant = . then delete;
if cm_high = . then delete;
run;
PROC EXPORT DATA= WORK.MPLUS_ENH 
            OUTFILE= "C:\Users\amwt27\OneDrive - University of Missouri\Desktop\Research\_Cannabis momos\omegas\mplus_enh.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
/*remember to delete variable names before reading into mplus*/

/*coping*/
data mplus_cop; set data; drop studyday--cm_high excited--cmmq_cope_c; run;
data mplus_cop; set mplus_cop;
if cm_depressed = . then delete;
if cm_problems = . then delete;
run;
PROC EXPORT DATA= WORK.MPLUS_COP 
            OUTFILE= "C:\Users\amwt27\OneDrive - University of Missouri\Desktop\Research\_Cannabis momos\omegas\mplus_cop.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
/*remember to delete variable names before reading into mplus*/

/*PA*/
data mplus_pa; set data; drop studyday--cm_problems scornful--cmmq_cope_c; run;
data mplus_pa; set mplus_pa;
if excited = . then delete;
if active = . then delete;
if alert = . then delete;
if happy = . then delete;
if enthusiastic = . then delete;
run;
PROC EXPORT DATA= WORK.MPLUS_PA 
            OUTFILE= "C:\Users\amwt27\OneDrive - University of Missouri\Desktop\Research\_Cannabis momos\omegas\mplus_pa.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
/*remember to delete variable names before reading into mplus*/

/*NA*/
data mplus_na; set data; drop studyday--enthusiastic alcyn--cmmq_cope_c; run;
data mplus_na; set mplus_na;
if scornful = . then delete;
if downhearted = . then delete;
if alone = . then delete;
if angry = . then delete;
if shaky = . then delete;
if nervous = . then delete;
if blue = . then delete;
if jittery = . then delete;
if hostile = . then delete;
if sad = . then delete;
if loathing = . then delete;
if afraid = . then delete;
run;
PROC EXPORT DATA= WORK.MPLUS_NA 
            OUTFILE= "C:\Users\amwt27\OneDrive - University of Missouri\Desktop\Research\_Cannabis momos\omegas\mplus_na.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
/*remember to delete variable names before reading into mplus*/

/***/

/******descriptive results******/

/*number of cannabis use moments per person*/
proc means data=data noprint; by id; var mjyn; output out = cmomspp sum=; run;
proc means data=cmomspp; var mjyn; run;

proc means data=data noprint; by id; var cudit; output out = cuditmean mean=; run;
proc freq data=cuditmean; tables cudit; run;

/****/

/*model 1--enhancement and pa*/
proc mixed data=data noclprint covtest method=REML;
class id gender_recode(ref= /*"1"*/ "-0.930797009"); /*use ref="1" when going back to non standardized variables*/
model dpa = lag_pa
/*momentary*/ enh_personc cop_personc
/*person*/ enh_samplec cop_samplec
/*covariates*/ alcyn with_ppl studyday weekend hour_after_wake cmmq_enjoy_c cmmq_cope_c
				age_c gender_recode
/ s cl ddfm=sat corrb;
random intercept /*enh_personc*/ /*cop_personc*//subject=id type=vc;
ods output solutionf=fixed;
run;

/*model 2-- coping and na*/
proc mixed data=data noclprint covtest method=REML;
class id gender_recode(ref= /*"1"*/ "-0.930797009"); /*use ref="1" when going back to non standardized variables*/
model dna = lag_na
/*momentary*/ enh_personc cop_personc
/*person*/ enh_samplec cop_samplec
/*covariates*/ alcyn with_ppl studyday weekend hour_after_wake cmmq_enjoy_c cmmq_cope_c
				age_c gender_recode
/ s cl ddfm=sat corrb;
random intercept enh_personc /*cop_personc*//subject=id type=vc;
ods output solutionf=fixed;
run;

/****/


/*model coping items separately to see if results change, given low within person reliability of the coping aggregate*/

/*b/c it helps me when i feel depressed or nervous*/
proc mixed data=data noclprint covtest method=REML;
class id gender_recode(ref="1");
model dna = lag_na
/*momentary*/ enh_personc cop_depanx_personc
/*person*/ enh_samplec cop_depanx_samplec
/*covariates*/ alcyn with_ppl studyday weekend hour_after_wake cmmq_enjoy_c cmmq_cope_c
				age_c gender_recode
/ s cl ddfm=sat;
random intercept enh_personc /*cop_personc*//subject=id type=vc;
ods output solutionf=fixed;
run;

/*to forget about my problems*/
proc mixed data=data noclprint covtest method=REML;
class id gender_recode(ref="1");
model dna = lag_na
/*momentary*/ enh_personc cop_prob_personc
/*person*/ enh_samplec cop_prob_samplec
/*covariates*/ alcyn with_ppl studyday weekend hour_after_wake cmmq_enjoy_c cmmq_cope_c
				age_c gender_recode
/ s cl ddfm=sat;
random intercept enh_personc /*cop_personc*//subject=id type=vc;
ods output solutionf=fixed;
run;

/*robustness tests-- commenting out different sets of covariates to see if results change*/

/*first remove CMMQ baseline enhancement and coping motives*/
/*then remove the other motive (remove coping for enh model, remove enh for cop model)*/
/*next: social context*/
/*hour after wake*/
/*alcohol use*/
/*study day*/
/*weekend*/
/*age*/
/*gender*/

/*enhancement aggregate predicting change in pa*/
proc mixed data=data noclprint covtest method=REML;
class id gender_recode(ref="1");
model dpa = lag_pa
/*momentary*/ enh_personc /*cop_personc*/
/*person*/ enh_samplec /*cop_samplec*/
/*covariates*/ /*alcyn*/ /*with_ppl*/ /*studyday*/ /*weekend*/ /*hour_after_wake*/ /*cmmq_enjoy_c cmmq_cope_c*/
				/*age_c*/ /*gender_recode*/
/ s cl ddfm=sat corrb;
random intercept /*enh_personc*/ /*cop_personc*//subject=id type=vc;
ods output solutionf=fixed;
run;

/*coping aggregate predicting change in na*/
proc mixed data=data noclprint covtest method=REML;
class id gender_recode(ref="1");
model dna = lag_na
/*momentary*/ enh_personc cop_personc
/*person*/ enh_samplec cop_samplec
/*covariates*/ /*alcyn*/ /*with_ppl*/ /*studyday*/ /*weekend*/ /*hour_after_wake*/ /*cmmq_enjoy_c cmmq_cope_c*/
				/*age_c*/ /*gender_recode*/
/ s cl ddfm=sat corrb;
random intercept enh_personc /*cop_personc*//subject=id type=vc;
ods output solutionf=fixed;
run;


/*trying different covariance structures*/

/*enhancement and pa*/
proc mixed data=data noclprint covtest method=REML;
class id gender_recode(ref="1");
model dpa = lag_pa
/*momentary*/ enh_personc cop_personc
/*person*/ enh_samplec cop_samplec
/*covariates*/ alcyn with_ppl studyday weekend hour_after_wake cmmq_enjoy_c cmmq_cope_c
				age_c gender_recode
/ s cl ddfm=sat corrb;
random intercept /*enh_personc*/ /*cop_personc*//subject=id type=ar(1); /*also tried "type=un"*/
ods output solutionf=fixed;
run;

/*coping and na*/
proc mixed data=data noclprint covtest method=REML;
class id gender_recode(ref="1");
model dna = lag_na
/*momentary*/ enh_personc cop_personc
/*person*/ enh_samplec cop_samplec
/*covariates*/ alcyn with_ppl studyday weekend hour_after_wake cmmq_enjoy_c cmmq_cope_c
				age_c gender_recode
/ s cl ddfm=sat corrb;
random intercept enh_personc /*cop_personc*//subject=id type=ar(1); /*also tried "type=un"*/
ods output solutionf=fixed;
run;
