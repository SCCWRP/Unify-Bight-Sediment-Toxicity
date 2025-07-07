library(dplyr)
library(readr)

# Installing from local to pick up unmerged changes
devtools::load_all('../SQOUnified-git/')

#####
# Year: 2018
#####
# Prepare 2018 results data
## This data was downloaded from the data portal
results <- read.csv('data-raw/DataPortalDownloads/ToxData-2018/Bight_18_Sediment_Toxicity_Results.csv') |>
  dplyr::tibble() |>
  dplyr::rename_with(tolower)

summary = tibble(surveyyear = 2018) |> dplyr::cross_join(SQOUnified::tox.summary(results))

saveRDS(summary, "data/unify-summary-2018.rds")
