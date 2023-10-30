# Explore SOC data --------------------------------------------------------

# Start with spectral data ------------------------------------------------

data_raw_train %>%
  correlate() %>% # performs pearson
  focus(soc_perc_log1p) %>% # highlight the outcome
  arrange(desc(abs(soc_perc_log1p)))# not strong relationship between any specific nm

# Check geodata -----------------------------------------------------------

data_raw_train_geo %>%
  left_join(data_raw_train %>% select(sample_id, soc_perc_log1p),
            by = c("sample_id")) %>% # includes geodata
  correlate() %>%
  focus(soc_perc_log1p)  %>%
  arrange(desc(abs(soc_perc_log1p))) # not strong relationship between any variable

# plot nm -----------------------------------------------------------------
# see the data
data_raw_train %>%
  head(10) %>%
  pivot_longer(cols = -c(sample_id, soc_perc_log1p)) %>%
  ggplot(aes(x = name, y = value, group = sample_id)) +
  geom_line()

# Selection of nm using MLR -----------------------------------------------

# MLR selection: https://www.frontiersin.org/articles/10.3389/frans.2022.897605/full
# Savitzky-Golay filtering and SNV
# https://cran.r-project.org/web/packages/prospectr/vignettes/prospectr.html

sg_train <-
  savitzkyGolay(
    data_raw_train %>% select(-sample_id, -soc_perc_log1p),
    p = 3,
    w = 11,
    m = 0
  ) %>%
  standardNormalVariate()

sg_test <-
  savitzkyGolay(
    data_raw_test %>% select(-sample_id),
    p = 3,
    w = 11,
    m = 0
  )  %>%
  standardNormalVariate()


# Prepare data for MLR ----------------------------------------------------

data_step <- prepare_data(data_raw_train %>%
                            select(soc_perc_log1p), sg_train, na = FALSE)

selected_nm <-
  data_step %>%
  reduce_matrix(minpv = 0.01) %>%
  fast_forward(crit = bic, maxf = 70) %>%
  multi_backward(crit = mbic) %>%
  stepwise()

selected_nm_cols <- dput(selected_nm$model) # set of nm selected

# plot selected nm --------------------------------------------------------

as_tibble(sg_train)  %>%
  bind_cols(data_raw_train %>%
              select(sample_id, soc_perc_log1p)) %>%
  head(10) %>%
  pivot_longer(cols = -c(sample_id, soc_perc_log1p)) %>%
  ggplot(aes(x = name, y = value, group = sample_id)) +
  geom_line() +
  geom_vline(xintercept = selected_nm_cols)

# Create new datasets containing both spectra and geodata -----------------

training_data <- as_tibble(sg_train)  %>%
  bind_cols(data_raw_train %>% select(sample_id, soc_perc_log1p)) %>%
  select(all_of(selected_nm_cols) |
           starts_with("soc") |
           starts_with("sample")) %>%
  left_join(data_raw_train_geo, by = join_by(sample_id))

testing_data <- as_tibble(sg_test)  %>%
  bind_cols(sample_submit %>% select(sample_id)) %>%
  select(all_of(selected_nm_cols) |
           starts_with("soc") |
           starts_with("sample")) %>%
  left_join(data_raw_test_geo, by = join_by(sample_id))


# keep dataset with all variables for PLS ---------------------------------

training_data_all_vars <- as_tibble(sg_train)  %>%
  bind_cols(data_raw_train %>%
              select(sample_id, soc_perc_log1p)) %>%
  left_join(data_raw_train_geo, by = join_by(sample_id))

testing_data_all_vars <- as_tibble(sg_test)  %>%
  bind_cols(sample_submit %>%
              select(sample_id)) %>%
  left_join(data_raw_test_geo, by = join_by(sample_id))

