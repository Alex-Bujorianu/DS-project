#R Script to preprocess the datasets

library(readxl)
library(dplyr)

dataset_110 <- read_excel("Datasets/time_series_test_110_preprocess_en.xlsx")
dataset_110_copy <- dataset_110
dataset_375 <- read_excel("Datasets/time_series_375_preprocess_en.xlsx")
dataset_375_copy <- dataset_375

#--------------
# First dataset
#-------------

#Rename the inconvenient columns
dataset_110 <- rename(dataset_110, lymphocytes = `(%)lymphocyte`)
dataset_110 <- rename(dataset_110, Lactate_dehydrogenase = `Lactate dehydrogenase`)
dataset_110 <- rename(dataset_110, C_protein = `Hypersensitive c-reactive protein`)

#Start by replacing NAs with patient ID
ID = 0
for (i in 1:length(dataset_110$PATIENT_ID)) {
  if (is.na(dataset_110$PATIENT_ID[i])) {
    dataset_110$PATIENT_ID[i] <- ID
  }
  else if (! is.na(dataset_110$PATIENT_ID[i])) {
    ID = ID + 1
  }
}

#Summarise patients by mean of the 3 biomarkers. Ignore missing data.
summary_110 <- dataset_110 %>%
  group_by(PATIENT_ID) %>%
  summarise(lymphocytes = mean(lymphocytes, na.rm = TRUE), 
            Lactate_dehydrogenase = mean(Lactate_dehydrogenase, na.rm = TRUE),
            C_protein = mean (C_protein, na.rm = TRUE)
  )

#--------------
# Second dataset
#--------------
ID = 0
for (i in 1:length(dataset_375$PATIENT_ID)) {
  if (is.na(dataset_375$PATIENT_ID[i])) {
    dataset_375$PATIENT_ID[i] <- ID
  }
  else if (! is.na(dataset_375$PATIENT_ID[i])) {
    ID = ID + 1
  }
}

summary_375 <- dataset_375 %>%
  group_by(PATIENT_ID) %>%
  summarise_all(mean, na.rm = TRUE)

#-----
# Imputations and removals
#-----

#Remove variables that have more than 6% missing values from the summary  
summary_375 <- summary_375 %>% select_if(colMeans(is.na(summary_375)) < 0.06)

#Remove patients with no data
for (i in 1:length(summary_375$PATIENT_ID)) {
  if (is.na(sum(summary_375[i, 8:ncol(summary_375)]))) {
    summary_375 <- summary_375[-c(i),] 
  }
}

#Mean imputation for columns with <6% missing values.
for(i in 8:ncol(summary_375)) {
  summary_375[ , i][is.na(summary_375[ , i])] <- mean(summary_375[ , i], na.rm = TRUE)
}


