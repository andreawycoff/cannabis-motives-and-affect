/* cap input rows for the captured run */
options obs=100;

/* Baseline sample (excerpt of baseline_data_toupload.csv). */
data baseline;
  infile datalines dsd missover;
  input id age cmmq_enjoy cmmq_cope cudit;
datalines;
1001,40,15,10,7
1002,47,15,4,18
1003,31,11,7,12
1004,22,15,3,14
1006,39,10,9,16
1008,23,14,5,14
;
run;
