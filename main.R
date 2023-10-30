
# Load and install libraries ----------------------------------------------

source("scripts/01_libraries.R")

# Load data from kaggle ---------------------------------------------------

source("scripts/02_load_data.R")

# Data cleaning and test/train dataset ------------------------------------

# Selection of wavelenght by stepwise regresion

source("scripts/03_data_exploration.R")

# Create preprocessing ----------------------------------------------------

# Option 1: removal of near zero variance (nzv) and correlation > 0.7
# Option 2: removal of nzv, centering, scale and variable selection by PLS algorithm

source("scripts/04_create_recipe.R")

# Workflow of model development -------------------------------------------

source("scripts/05_workflow.R")

# Getting the best model --------------------------------------------------

source("scripts/06_best_model.R")



