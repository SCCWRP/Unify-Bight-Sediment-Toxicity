# Installing from local to pick up unmerged changes
devtools::load_all('../SQOUnified-git/')

#####
# Year: 2023
#####
# Prepare 2023 results data
## This data was downloaded from the data portal
results <- readr::read_csv('data-raw/from-bight2023-db/bight23results.csv', show_col_types = FALSE) |>
  dplyr::mutate(
    sampletypecode = case_match(
      sampletypecode,
      "Grab" ~ "Result",
      .default = sampletypecode
    ),
    units = "Percent",
      treatment = case_match(
        treatment,
        "None" ~ NA_character_,
        .default = treatment
      ),
    dilution = ifelse("dilution" %in% pick(everything()), as.numeric(dilution), -88),
    dilution = case_when(
      dilution < 0 ~ NA,
      .default = dilution
    )
  )

summary = tibble(surveyyear = 2023) |> dplyr::cross_join(SQOUnified::tox.summary(results, results.sampletypes = "Result", include.controls = T))

readr::write_rds(summary, "data/unify-summary-2023.rds")
