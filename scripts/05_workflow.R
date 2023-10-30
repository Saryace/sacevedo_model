
# Cross-validation --------------------------------------------------------

training_folds <- vfold_cv(training_data %>% 
                           select(-sample_id),
                           strata = soc_perc_log1p, repeats = 5)

training_folds_all_vars <- vfold_cv(training_data_all_vars %>% 
                             select(-sample_id),
                           strata = soc_perc_log1p, repeats = 5)

# Set engines -------------------------------------------------------------

cubist_spec <- 
  cubist_rules(committees = tune(), neighbors = tune()) %>% 
  set_engine("Cubist") 

# Setting workflow --------------------------------------------------------

using_recipe_basic <-
  workflow_set(
    preproc = list(selected_nm = recipe_basic),
    models = list(
      cubist = cubist_spec
    )
  ) 

using_recipe_pls <-
  workflow_set(
    preproc = list(selected_pls = recipe_pls),
    models = list(
      cubist = cubist_spec
    )
  ) 

# Grid control ------------------------------------------------------------

all_cores <- parallel::detectCores(logical = FALSE)

library(doFuture)
registerDoFuture()
cl <- makeCluster(all_cores)
plan(cluster, workers = cl)

grid_ctrl <-
  control_grid(
    save_pred = TRUE,
    parallel_over = "everything",
    save_workflow = TRUE
  )

grid_results <-
  using_recipe_basic %>%
  workflow_map(
    seed = 1234,
    resamples = training_folds,
    grid = 3,
    control = grid_ctrl,
    verbose = TRUE
  )

grid_results_all <-
  using_recipe_pls %>%
  workflow_map(
    seed = 1234,
    resamples = training_folds_all_vars,
    grid = 3,
    control = grid_ctrl,
    verbose = TRUE
  )





