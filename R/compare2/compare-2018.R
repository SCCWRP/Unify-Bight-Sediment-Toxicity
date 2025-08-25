
pub = readxl::read_excel("data-raw/DataPortalDownloads/ToxData-2018/Bight_18_Sediment_Toxicity_Summary_Results_9058230620704627381.xlsx") |>
  dplyr::rename(
    fieldrep = fieldreplicate,
    `P Value` = pvalue,
    Mean = mean,
    `Control Adjusted Mean` = pctcontrol,
    `Standard Deviation` = stddev,
    `Coefficient of Variance` = coefficientvariance,
    sigdiff = sigeffect,
    Category = sqocategory
  )

uni = readr::read_rds("data/unify-summary-2018.rds")

joined = dplyr::full_join(pub, uni, by=dplyr::join_by(stationid, toxbatch), suffix = c(".pub", ".uni"))

joined = joined |>
  dplyr::select(all_of(order(names(joined)))) |>
  dplyr::mutate(
    surveyyear = 2018,
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

print("Writing data/compare-2018.rds")
readr::write_rds(joined, "data/compare-2018.rds")

print("Writing data-compare/compare-2018.xlsx")
openxlsx::write.xlsx(joined, "data-compare/compare-2018.xlsx")
