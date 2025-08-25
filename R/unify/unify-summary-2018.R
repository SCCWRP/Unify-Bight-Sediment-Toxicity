# Installing from local to pick up unmerged changes
devtools::load_all('../SQOUnified-git/')

#####
# Year: 2018
#####
# Prepare 2018 results data
## This data was downloaded from the data portal
results <- readr::read_csv('data-raw/DataPortalDownloads/ToxData-2018/Bight_18_Sediment_Toxicity_Results.csv', show_col_types = FALSE) |>
  dplyr::tibble() |>
  dplyr::rename_with(tolower) |>
  dplyr::mutate(
    sampletypecode = case_match(
      sampletypecode,
      "Grab" ~ "Result",
      .default = sampletypecode
    ),
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

summary = tibble(surveyyear = 2018) |> dplyr::cross_join(SQOUnified::tox.summary(results, results.sampletypes = "Result", include.controls = T))

readr::write_rds(summary, "data/unify-summary-2018.rds")
