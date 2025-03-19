# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(here)
library(qs2)

# Set target options:
tar_option_set(
  packages = c("tidyverse", "janitor", "readxl"), # Packages that your targets need for their tasks.
  format = "qs", # Optionally set the default storage format. qs is fast.
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  tar_target(
    name = pred_file,
    command = here("data", "adult predators 2016-2024.xlsx"),
    format = "file" # Tracks changes in file on HD
  ),
  tar_target(
    name = pred_data,
    command = get_pred_summary_data(pred_file)
  ),
  tar_target(
    name = snorkel_files,
    command = here("data", "snorkel_indexes", list.files(here("data", "snorkel_indexes"))),
    format = "file"
  ),
  tar_target(
    name = snorkel_data,
    command = get_snorkel_data(snorkel_files)
  )
)