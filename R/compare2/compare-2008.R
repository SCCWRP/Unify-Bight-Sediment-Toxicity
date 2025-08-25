
pub = readr::read_csv("data-raw/DataPortalDownloads/ToxData-2008/B08CEToxicitySummaryResults_CE.csv", show_col_types = FALSE) |>
  dplyr::rename(
    `Control Adjusted Mean` = PctControl,
    endpoint = EPCode,
    lab = LabCode,
    n = N,
    qacode = QACode,
    sampletypecode = SampleType,
    species = Species,
    sigdiff = SigEffect,
    `Standard Deviation` = StdDev,
    stationid = StationID,
    toxbatch = QABatch
  ) |>
  dplyr::mutate(
    Category = NA_character_
  )

uni = readr::read_rds("data/unify-summary-2008.rds")

joined = dplyr::full_join(pub, uni, by=dplyr::join_by(stationid, toxbatch), suffix = c(".pub", ".uni"))

joined = joined |>
  dplyr::select(all_of(order(names(joined)))) |>
  dplyr::mutate(
    surveyyear = 2008,
    Category.zcomp = dplyr::coalesce(Category.uni == Category.pub, FALSE)
  ) |>
  dplyr::relocate(
    surveyyear,
    stationid,
    toxbatch,
    dplyr::starts_with("Category"),
    dplyr::starts_with("sampletypecode"),
    dplyr::starts_with("qacode"),
    dplyr::starts_with("P Val"),
    dplyr::starts_with("pvalue"),
    .before = 1)

print("Writing data/compare-2008.rds")
readr::write_rds(joined, "data/compare-2008.rds")

print("Writing data-compare/compare-2008.xlsx")
openxlsx::write.xlsx(joined, "data-compare/compare-2008.xlsx")
