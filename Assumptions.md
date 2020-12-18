#This document is a record of our assumptions and decisions undertaken during modelling

##Preprocessing
+ Data sheet 375: some columns, like TNF-α, IL-2, IL-6 etc. are missing a lot of values. We need to come up with an appropriate solution. Mean imputation may be acceptable in some cases, but definitely not all. I suggest using the select() function to remove variables based on a conditional, e.g. >50% of missing values. 
