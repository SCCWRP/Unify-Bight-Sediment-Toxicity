
pub = readxl::read_excel("data-raw/DataPortalDownloads/ToxData-2013/Bight_13_Toxicity_Summary_Results2_-2502133100839271899.xlsx") |>
  dplyr::rename(
    Category = sqocategory,
    `Control Adjusted Mean` = pctcontrol,
    Mean = mean,
    sigdiff = sigeffect,
    `Standard Deviation` = stddev,
  )

uni = readr::read_rds("data/unify-summary-2013.rds")

joined = dplyr::full_join(pub, uni, by=dplyr::join_by(stationid, toxbatch), suffix = c(".pub", ".uni"))

joined = joined |>
  dplyr::select(all_of(order(names(joined)))) |>
  dplyr::mutate(
    surveyyear = 2013,
    Category.zcomp = Category.pub == Category.uni,
    Category.zcomp = dplyr::coalesce(Category.zcomp, FALSE)
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

print("Writing data/compare-2013.rds")
readr::write_rds(joined, "data/compare-2013.rds")

print("Writing data-compare/compare-2013.xlsx")
openxlsx::write.xlsx(joined, "data-compare/compare-2013.xlsx")