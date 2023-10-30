# Model fitting time ------------------------------------------------------

# selected_nm_cubist (16m 3.8s)
# selected_pls_cubist (2h 43m 24.4s)

# SOC dataset -------------------------------------------------------------

# Get best results --------------------------------------------------------

grid_results %>%
  rank_results() %>%
  filter(.metric == "rmse") %>%
  select(model, .config, rmse = mean, rank)

rank_results(grid_results, select_best = TRUE) #ranking

grid_results_all %>%
  rank_results() %>%
  filter(.metric == "rmse") %>%
  select(model, .config, rmse = mean, rank)

rank_results(grid_results_all, select_best = TRUE) #ranking

best_results <-
  grid_results %>%
  extract_workflow_set_result("selected_nm_cubist") %>%
  select_best(metric = "rmse")

best_results_all <-
  grid_results_all %>%
  extract_workflow_set_result("selected_pls_cubist") %>%
  select_best(metric = "rmse")

# Recreate partition for workflow -----------------------------------------

all_data <- bind_rows(training_data,
                      testing_data %>% left_join(sample_submit,
                                                 by = join_by(sample_id)))

prop <-
  nrow(training_data) / (nrow(training_data) + nrow(testing_data))

split <- initial_time_split(all_data, prop = prop)


# All data for pls selection ----------------------------------------------

all_data_all_vars <- bind_rows(
  training_data_all_vars,
  testing_data_all_vars %>% left_join(sample_submit, by = join_by(sample_id))
)

prop_all_vars <-
  nrow(training_data_all_vars) / (nrow(training_data_all_vars) + nrow(testing_data_all_vars))

split_all_vars <-
  initial_time_split(all_data_all_vars, prop = prop_all_vars)


# test results ------------------------------------------------------------

test_results <-
  grid_results %>%
  extract_workflow("selected_nm_cubist") %>%
  finalize_workflow(best_results) %>%
  last_fit(split = split)

test_results_all <-
  grid_results_all %>%
  extract_workflow("selected_pls_cubist") %>%
  finalize_workflow(best_results_all) %>%
  last_fit(split = split_all_vars)


# collect metrics ---------------------------------------------------------

collect_metrics(test_results) # best model

collect_metrics(test_results_all)

# Plot testing dataset ----------------------------------------------------

test_results %>%
  collect_predictions() %>%
  ggplot(aes(x = soc_perc_log1p, y = .pred)) +
  geom_abline(color = "gray50", lty = 2) +
  geom_point(alpha = 0.5) +
  coord_obs_pred() +
  labs(x = "observed", y = "predicted")

test_results_all %>%
  collect_predictions() %>%
  ggplot(aes(x = soc_perc_log1p, y = .pred)) +
  geom_abline(color = "gray50", lty = 2) +
  geom_point(alpha = 0.5) +
  coord_obs_pred() +
  labs(x = "observed", y = "predicted")

# Saving results ----------------------------------------------------------

test_results %>% # using cubist approach
  collect_predictions() %>%
  bind_cols(sample_submit %>% dplyr::select(sample_id)) %>%
  dplyr::select(sample_id, soc_perc_log1p = .pred) %>% 
  write_csv("results/sample_submition.csv")
