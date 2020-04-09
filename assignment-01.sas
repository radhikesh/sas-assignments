/*********************************************************
Advanced Business Intelligence (MIS 6334): Assignment #01
**********************************************************/

/* Q1. Write a SAS program to read the 'testing' dataset, then view the contents (PROC CONTENTS) and
print the first 10 observations. (Whenever I say "print" in homework assignments, that means I expect
you to include the printed results in your submission.)
*/

/* Reading the sas file*/
PROC IMPORT DATAFILE='E:\Fall 15\abi\assignments\Catalog.xls' DBMS=xls OUT=Catalog Replace;
SHEET="Testing";
GETNAMES=Yes;
RUN;

/* Using Proc Contents */
PROC CONTENTS data= Catalog;
title "Using PROC CONTENTS";
run;

/* Printing first 10 observations */
PROC PRINT data = Catalog (firstobs=1 obs=10);
TITLE "First 10 Observations";
Run;


/* Q2. Create a new variable to convert "money" into a binary variable that takes only 0 or 1 as values.
Name the new variable "prospect" which indicates if the customer is potentially a heavy buyer (>$20).
Let the value be 1 if the customer orders more than $20 and 0 otherwise. (Note: use 'if ' for this
question).
Ans: /*creating a library to permanently store the data*/
libname mydata 'E:\Fall 15\abi\assignments';
data mydata.catalog;


DATA mydata.Catalog_Prospect;
SET mydata.Catalog;
IF (Money =< 20) THEN Prospect = 0; 
IF (Money > 20)THEN Prospect = 1;
Proc Print data = mydata.catalog_prospect; 
RUN;

/*Q3. Use 'where' to achieve the same as the previous question. Feel free to use multiple data steps if you
can't get it done in one data step.
*/

data mydata.not_heavy_buyer;
set mydata.catalog;
Prospect = 0;
Where MOney < 20;
run;
data mydata.heavy_buyer;
set mydata.catalog;
Prospect = 1;
Where MOney > 20;
Run;

data mydata.allbuyers;
set mydata.not_heavy_buyer mydata.heavy_buyer;
proc print data = mydata.allbuyers;
Title "using where condition";
run;

/*Q4: For the heavy buyers, compute the total number of orders placed within the past 24 months (i.e.,
NGIF). Try RETAIN and SUM. */

data mydata.TotalOrders;
set mydata.heavy_buyer;
Retain totalNGIF;
totalNGIF = sum(NGIF , totalNGIF);
proc print data = mydata.TotalOrders;
run;
/*
The total number of orders for the last 24 months where order is heavy.
is 310.
*/


/*Q5: For each RFA1 level (i.e., frequency of orders), compute the average order amount per customer
(total RAMN / total number of customers at this level). Use an Array to store the value for each level
of RFA1.
*/

DATA mydata.avarageOAPC0;
set mydata.catalog;
proc sort DATA = mydata.avarageOAPC0;
by RFA1;
DATA mydata.avarageOAPC2;
SET mydata.avarageOAPC0;
by RFA1;
ARRAY avarage (3) total_RAMN total_NO_of_Customer AVGOAPC;
IF first.RFA1 then avarage(2)=0 and avarage(1) = 0;
avarage(2) +1;
avarage(1) + RAMN;
avarage(3) = avarage(1)/avarage(2);
IF last.RFA1 then output;
RUN;
DATA mydata.avarageAPC;
SET mydata.avarageOAPC2;
keep RFA1 total_RAMN total_NO_of_Customer AVGOAPC;
RUN;
PROC PRINT DATA=mydata.avarageAPC;
TITLE " Average by frequency of order";
RUN;


/*Q6: Create a permanent new dataset that satisfy all following requirements:
a. keeping only the observations with more or equal to 2 orders in the last 24 months (NGIF),
b. sorted by NGIF and money,
c. and keeping only four variables: UserID, NGIF, money and order.
Print out the first 10 observations of this dataset.
*/

data  mydata.ques6;
set mydata.catalog;
IF NGIF >= 2;
run;
PROC SORT DATA = mydata.ques6;
BY NGIF Money;
run;

proc print data = mydata.ques6(firstobs=1 obs=10);
VAR CustomerID NGIF Money Order;
Title "First 10 Observations";
run;


/*Q7.  Run PROC MEANS over the dataset created in the previous step and report the results.*/

Proc Means data = Mydata.Ques6;
Run;


/*Q8: Generate one-way and two-way tables using PROC FREQ. Feel free to use any variables you are
interested */

Proc freq data=mydata.catalog;
tables NGIF NGIF*order;
run;
