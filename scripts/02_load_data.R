
# Load data from kaggle ---------------------------------------------------

data_raw_test <-
  read_csv("ss4gg-hackathon-nir-neospectra/test.csv")

data_raw_train <-
  read_csv("ss4gg-hackathon-nir-neospectra/train.csv")

data_raw_test_geo <-
  read_csv("ss4gg-hackathon-nir-neospectra/test_geocovariates.csv")

data_raw_train_geo <-
  read_csv("ss4gg-hackathon-nir-neospectra/train_geocovariates.csv")

sample_submit <-
  read_csv("ss4gg-hackathon-nir-neospectra/sample_submission.csv")

# Glimpse data ------------------------------------------------------------

glimpse(data_raw_test) #rows 772, cols 602
glimpse(data_raw_test_geo) #rows 772, cols 220
glimpse(data_raw_train) # rows 1,202, cols 603 (soc_perc_log1p included)
glimpse(data_raw_train_geo)# rows 1,202, cols 202 (soc_perc_log1p not included)




