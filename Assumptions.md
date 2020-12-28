#This document is a record of our assumptions and decisions undertaken during modelling

##Preprocessing
In data sheet 375, some columns, like TNF-α, IL-2, IL-6 etc. are missing a lot of values. We had to come up with an appropriate solution. Here is our approach:
+ First we removed columns that were missing more than 40% of their values (in the summary). This dropped 10 variables. Our justification is that there is simply no way to trust a model with these parameters when they are missing so much data (which would have to be guessed with imputation). This is unfortunate, too, since some of these variables are important immune-system regulators and are likely to be important.
+ We considered mean imputation, but there are some big problems with it: firstly, it leads to underestimating standard errors (i.e. our p values are artificially low because we’re assuming guesses are real data). Secondly, it assumes that the mean is an unbiased estimate for the real data; this is true if missing values are missing at random. It may be the case, however, that some patients are missing values because they were in a critical condition and it was too difficult to perform the tests. We will discuss this in our report.
+ Multiple imputation is a possible solution but it’s very complicated—it requires running models on multiple datasets and combining them. Moreover, it still assumes MAR (Missing-at-Random) just like mean imputation.
+ Ultimately, we removed columns that were missing more than 6% of their values (which dropped us to 48 variables) and used mean imputation on the remaining dataset.
+ We had to remove patients with no data.
+ Regarding the MAR assumption: patient 189 had no data. She died in less than 24 hours.