
# Create a recipe ---------------------------------------------------------

recipe_basic <- recipe(soc_perc_log1p ~ . ,
                       data = training_data %>%
                         select(-sample_id)) %>%
  step_nzv(all_numeric_predictors()) %>%
  step_corr(all_numeric_predictors(), threshold = .7)


recipe_pls <- recipe(soc_perc_log1p ~ . ,
                       data = training_data_all_vars %>%
                         select(-sample_id)) %>%
  step_nzv(all_numeric_predictors()) %>%
  step_center(all_numeric_predictors()) %>%
  step_scale(all_numeric_predictors()) %>% 
  step_pls(num_comp = 10, outcome = "soc_perc_log1p")

