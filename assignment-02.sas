/*********************************************************
Advanced Business Intelligence (MIS 6334): Assignment #02
**********************************************************/

/*Q1: Using the "survival" dataset as the input, write a SAS program to create the following new dataset
called "mis6334.s4": (this is identical to the right one on slide 19 of our customer retention lecture)

Solution:
*/


data mydata.s4;
set mydata.survival end = eof;
output;
if eof then do
year =year +1;
customers = 0;
output;
end;
run;
data mydata.s3;
set mydata.s4;
keep year customers lost;
retain HoldCustomers;
Lost = HoldCustomers - Customers;
HoldCustomers = Customers;
if year > 0;
run;
proc print data = mydata.s3;
run;


/*Q2. In class we analyzed the survival model using MLE by assuming that all customers have the same theta. However the fit turns out to be poor. In this question, you are requested to use PROC NLMIXED to 
conduct MLE using the shifted Beta-Geometric (sBG) model, where each customer's theta as a
random draw from a Beta distribution. Print the "Fit Statistics" table and the "Parameter Estimates"
table.
*/

proc NLMIXED data= mydata.s4;
parms a=0.5, b=0.5;
if customers >0 then 
ll = lost*log(beta(a+1, b+year-1)/beta(a,b));
else 
ll = lost*log(beta(a,b+year-1)/beta(a,b));
Model lost~general(ll);
run;

/*
Q3. Suppose you found out that the optimal parameters are alpha = 0.668 and Beta = 3.806. Using these parameters, write a SAS program for simulating the individual-level survival behavior of 1000
customers over a 12-year span. (Hint: use my code on slide 21, and modify it to fit the sBG model.)
*/

DATA simulated (drop=x);
CALL streaminit(123); 
    DO i=1 to 1000;	/* simulate 1000 customers */
      DO t=1 to 12;	/* t represent period */
      x=rand('BERNOULLI',rand('BETA',0.6681,3.8061));	/* here we use the               
                                                      theta we got */
      IF x=1 THEN leave;
      END;
      OUTPUT;
    END;
RUN;

PROC sql;  /* count how many customers leave in each period */
create table sumtable as
select t as period, count(i) as lost from simulated
group by t;
QUIT;
DATA sumtable2;
  set sumtable;
  retain remain 1000;
  remain = remain - lost;
RUN;
PROC sgplot data=sumtable2;
  scatter x = period y = remain;
  title "Survival Behaviour of Customers";
RUN;

/*
Q4. Aggregate the simulated data to show population-level survival result (just use my code on slide 22 -no need to include this part of code in your submission). Then, based on this data, calculate retention
rate for each period and save the result in a dataset. Print both your code and your resulting dataset.
Each row in the dataset should have properties: year, customers, retention_rate.
*/

DATA simulated (drop=x);
  CALL streaminit(123); 
  DO i=1 to 1000;	/* simulate 1000 customers */
      DO t=1 to 12;	/* t represent period */
      x=rand('BERNOULLI',rand('BETA',0.6681,3.8061));	/* here we use the                        
                                                       theta we got */
      IF x=1 THEN leave;
      END;
  OUTPUT;
  END;
RUN;

PROC sql;  /* count how many customers leave in each period */
create table sumtable as
 select t as year, count(i) as lost from simulated
 group by t;
QUIT;
DATA sumtable2;
  set sumtable;
  keep year customers retention_Rate;
  retain customers 1000; 
  remain = customers - lost;
  retention_rate = remain/customers ;
customers=remain;
output;
  
RUN;
proc print data = sumtable2;
title "Retention rate of customers";
run;

/*
Q5.
This question is on Macro and Simulation in SAS. For each of the following five distributions,
generate 1000 random samples: a) a normal distribution N(90,8), b) exponential with the parameter to
be 8, c) binomial with n=200 and p=0.2 , d) Poisson distribution with a parameter to be 8 and e) a
Gamma distribution G(3,8). Use PROC SGPLOT (see Sections 8.2 and 8.3 in our textbook on how to
use it) to plot a histogram for each generated random sample. Print the five histograms you got
(clearly title them), but do NOT print the datasets you generated. You are required to use a Macro
to simplify your coding -- in other words, instead of writing five separate codes (one for each
distribution), write one Macro and call it five times with appropriate parameters.
*/


%MACRO distcal(dist=);
data distval;
call streaminit(123);
if &dist='Binomial' then
do;
do i =1 to 1000;
x=rand('Binomial',0.2,200);
output;
end;
end;

else if &dist='Normal' then
do;
do i =1 to 1000;
x=rand('Normal',90,8);
output;
end;
end;

else if &dist='Poisson' then
do;
do i =1 to 1000;
x=rand('Poisson',8);
output;
end;
end;

else if &dist='Exponential' then
do;
do i =1 to 1000;
x=rand('Exponential')/8;
output;
end;
end;

else if &dist='Gamma' then
do;
do i =1 to 1000;
x=rand('Gamma',3,8);
output;
end;
end;
run;

proc sgplot data=distval;
histogram x;
title "&dist Distribution";
run;

%MEND distcal;
%distcal(dist='Binomial')
%distcal(dist='Exponential')
%distcal(dist='Normal')
%distcal(dist='Poisson')
%distcal(dist='Gamma')

/*
Q6.
From mathematics we know that a gamma distribution G(1,5), where the first parameter is 1, is
equivalent to an exponential distribution with parameter 1/5. Can you use data to show that indeed
they generate the same (or at least very similar) distribution of random numbers? Show your code and
your finding. (Hint: re-use your code from question 5, and see if you can show the histograms are
similar.)
*/

%MACRO distcal(dist=);
data distval;
call streaminit(123);

if &dist='Exponential' then
do;
do i =1 to 1000;
x=rand('Exponential')/5;
output;
end;
end;

else if &dist='Gamma' then
do;
do i =1 to 1000;
x=rand('Gamma',1,5);
output;
end;
end;
run;

proc sgplot data=distval;
histogram x;
title "&dist Distribution";
run;
%MEND distcal;
%distcal(dist='Exponential');
%distcal(dist='Gamma');
