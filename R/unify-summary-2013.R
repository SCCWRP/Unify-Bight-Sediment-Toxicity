devtools::load_all("../SQOUnified-git/")

results <- readxl::read_excel('data-raw/DataPortalDownloads/ToxData-2013/Bight_2013_Regional_Survey_Toxicity_Results_-692175966774049861.xlsx')

results = results |>
  dplyr::rename_with(tolower) |>
  dplyr::rename(
    lab = agency
  ) |>
  dplyr::mutate(
    matrix = dplyr::case_match(
      matrix,
      "Bulk Sediment (whole sediment)" ~ "Whole Sediment",
      .default = matrix
    ),
    units = "Percent")

summary = dplyr::tibble(surveyyear = 2013) |> dplyr::cross_join(SQOUnified::tox.summary(results))

readr::write_rds(summary, "data/unify-summary-2013.rds")
