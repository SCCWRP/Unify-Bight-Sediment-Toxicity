# Installing from local to pick up unmerged changes
devtools::load_all('../SQOUnified-git/')

#####
# Year: 2018
#####
# Prepare 2018 results data
## This data was downloaded from the data portal
results <- readr::read_csv('data-raw/from-bight2023-db/bight23results.csv') |>
  dplyr::mutate(
    units = "Percent"
  )

summary = tibble(surveyyear = 2023) |> dplyr::cross_join(SQOUnified::tox.summary(results))

readr::write_rds(summary, "data/unify-summary-2023.rds")
