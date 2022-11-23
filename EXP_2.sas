
/* File imports */
proc import datafile  =  '/home/u40932848/FAA1.xls'
 out  =  FAA1
 dbms  =  xls
 replace
 ;
run;
proc print data = FAA1;
run;

proc import datafile  =  '/home/u40932848/FAA2.xls'
 out  =  FAA2
 dbms  =  xls
 replace
 ;
run;
proc print data = FAA2;
run;


/*Combining data sets FAA1 FAA2*/
DATA COMBINED;
SET FAA2_revised FAA1;
run;
proc print data = combined; /* This is the actually merged data */
run;

/*Checking for missing values in the combined data*/
proc means data = COMBINED nmiss N;
run;


/*Univariate statistics for the combined data */
PROC SORT DATA=COMBINED;
BY aircraft;
RUN;

proc univariate data = COMBINED;
Title "Descriptive statistics for COMBINED data";
VAR NO_PASG SPEED_AIR SPEED_GROUND HEIGHT PITCH DISTANCE;
by aircraft;
run;
 
 
/* Identifying duplicate records*/
proc sort data = COMBINED dupout = COMBINED_NODUPS nodup;
by _all_;
run;

/* Outlier check */
PROC UNIVARIATE DATA = combined;
 VAR Duration Distance speed_air speed_ground height pitch;
 histogram Distance / normal;
 histogram Duration / normal;
 histogram speed_air / normal;
 histogram speed_ground / normal;
 histogram height / normal;
 histogram pitch / normal;
run; 

/* Box plots */
PROC SGPANEL DATA=COMBINED;
PANELBY AIRCRAFT;
  VBOX DISTANCE ;
run;
  
/*Checking for missing values in the combined data*/
proc means data = COMBINED nmiss N;
run;


/*Univariate statistics for the combined data */
PROC SORT DATA=COMBINED;
BY aircraft;
RUN;

proc univariate data = COMBINED;
Title "Descriptive statistics for COMBINED data";
VAR NO_PASG SPEED_AIR SPEED_GROUND HEIGHT PITCH DISTANCE;
by aircraft;
run;
 
/* Identifying duplicate records*/
proc sort data = COMBINED dupout = COMBINED_NODUPS nodup;
by _all_;
run;


/* Checking for abnormality of values based on the data specs */
DATA DURATION_TEST;
set COMBINED;
TITLE 'Is Duration less than 40 minutes?';
if DURATION <40;
run;
proc print data=DURATION_TEST;
where DURATION is not null;
run;

DATA SPEED_GRND_TEST;
set COMBINED;
TITLE 'Speed_ground not between 30 and 140 MPH';
if speed_ground < 30 or speed_ground>140;
run;
proc print data=SPEED_GRND_TEST;
where speed_ground is not null;
run;

DATA SPEED_AIR_TEST;
set COMBINED;
TITLE 'air_speed not between 30 and 140 MPH';
if speed_air<30 or speed_air>140;
run;
proc print data=SPEED_AIR_TEST;
where speed_air is not null;
run;

DATA HEIGHT_TEST;
set COMBINED;
TITLE 'Height is less than 6';
if height<6 ;
run;

DATA DISTANCE_TEST;
set COMBINED;
TITLE 'Distance is more than 6000';
if distance>6000;
run;
proc print data=distance_test;
where distance is not null;
run;

proc print data=HEIGHT_TEST;
where height is not null;
TITLE 'Height is less than 6';
run;


/* Panelled Scatter plot for numeric variables(except distance) vs distance */
/* To understand the relationship between distance and other factors grouped by aircraft */
proc sgscatter data= COMBINED;
   compare y=distance
          x=(speed_ground height pitch no_pasg)
          / group= aircraft;
run;

/*Two sample T test */
PROC TTEST DATA=combined;
CLASS aircraft;
VAR distance;
TITLE T-TEST FOR COMPARING THE MEANS OF Distance IN Boeing AND Airbus;
RUN;

/* Correlation analysis */
proc corr data= combined;
var Distance speed_ground height;
title Pairwise correlation coefficients;
run;


proc corr data=combined;
var speed_ground height pitch;
with distance;
title Correlaiton coefficients with Y;
run;

/* Regression Analysis */
proc reg data=COMBINED;
model DISTANCE = SPEED_GROUND HEIGHT PITCH / r;
output out=diagnostics r=residual;
title Regression analysis of the COMBINED Flights data set;
run;

/* Model rebuild */
DATA fixed;
SET COMBINED ;
speed_ground_cn =(speed_ground-80.2)**2; /*centered*/
speed_ground_sq=(speed_ground)**2;
RUN;

/* Fitting quadratic term */

proc REG data= FIXED;
   model DISTANCE =  SPEED_GROUND HEIGHT PITCH speed_ground_cn /PARTIAL STB TOL COLLIN VIF;
   plot R.*P.;
   output out=diagnostics r=residual;
run;

