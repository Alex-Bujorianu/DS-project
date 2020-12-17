#R Script to preprocess dataset 110 (three biomarkers)

library(readxl)
library(dplyr)

dataset_110 <- read_excel("Datasets/time_series_test_110_preprocess_en.xlsx")
dataset_110_copy <- dataset_110

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
dataset_summary <- dataset_110 %>%
  group_by(PATIENT_ID) %>%
  summarise(lymphocytes = mean(lymphocytes, na.rm = TRUE), 
            Lactate_dehydrogenase = mean(Lactate_dehydrogenase, na.rm = TRUE),
            C_protein = mean (C_protein, na.rm = TRUE)
  )
  
View(dataset_summary)