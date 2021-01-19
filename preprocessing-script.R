#R Script to preprocess the datasets

library(readxl)
library(dplyr)
library(tidyr)

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

# Alternative dataset with last value instead of mean
summary_375_last <- dataset_375 %>%
  pivot_longer(cols=-c(PATIENT_ID, RE_DATE, `Admission time`, `Discharge time`, gender, outcome, age),
               names_to="variables",
               values_to="value",
               values_drop_na = TRUE) %>%
  group_by(PATIENT_ID, variables) %>%
  mutate(n = row_number()) %>%
  dplyr::filter(n == max(n)) %>%
  select(-n, -RE_DATE) %>%
  ungroup() %>%
  pivot_wider(values_from = value, names_from = variables)

#-----
# Imputations and removals
#-----

#Remove variables that have more than 6% missing values from the summary  
#For some reason summary_375 is getting a lot more variables removed than summary_375_last
summary_375 <- summary_375 %>% select_if(colMeans(is.na(summary_375)) < 0.06)
summary_375_last <- summary_375_last %>% select_if(colMeans(is.na(summary_375_last)) < 0.06)
#summary_375_last %>% select_if(colMeans(is.na(summary_375_last)) < 0.06)

# missing_patients <- as_tibble(data.frame(matrix(nrow=0,ncol=length(colnames(summary_375)))))
# colnames(missing_patients) <- colnames(summary_375)
#Why not just make a copy of summary 375 with 0 rows?
missing_patients <- summary_375[0,]


#Remove patients with no data and add it to the other database
for (i in 1:nrow(summary_375)) {
  if (all(is.na(summary_375[i, 8:ncol(summary_375)]))) {
    missing_patients <- missing_patients %>% add_row(as_tibble(summary_375[i,])) #you have to assign; add_row is COW
    summary_375 <- summary_375[-c(i),]
  }
}

#which(is.na(missing_patients$))

#Mean imputation for columns with <6% missing values.
for(i in 8:ncol(summary_375)) {
  summary_375[is.na(summary_375[,i]), i] <- colMeans(summary_375[,i], na.rm = TRUE) #round does not work here
}
for(i in 7:ncol(summary_375_last)) {
  summary_375_last[is.na(summary_375_last[,i]), i] <- colMeans(summary_375_last[,i], na.rm = TRUE) #round does not work here
}

#Rounding
rounded <- summary_375 %>% mutate(across(8:48, round, 3)) #this is rounded correctly in the dataframe but not in the csv output
summary_375_last <- summary_375_last %>% mutate(across(7:58, round, 3))