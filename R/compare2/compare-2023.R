
pub = readr::read_csv("data-raw/from-bight2023-db/bight23summary.csv", show_col_types = FALSE) |>
  dplyr::rename(
    fieldrep = fieldreplicate,
    `Control Adjusted Mean` = adjusted_control_mean,
    `Standard Deviation` = stddev,
    `Coefficient of Variance` = coefficientvariance,
    `P Value` = pvalue,
    Mean = mean,
    sigdiff = sigeffect,
    Category = sqocategory
  )

uni = readr::read_rds("data/unify-summary-2023.rds")

joined = dplyr::full_join(pub, uni, by=dplyr::join_by(stationid, toxbatch), suffix = c(".pub", ".uni"))

joined = joined |>
  dplyr::select(all_of(order(names(joined)))) |>
  dplyr::mutate(
    surveyyear = 2023,
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

print("Writing data/compare-2023.rds")
readr::write_rds(joined, "data/compare-2023.rds")

print("Writing data-compare/compare-2023.xlsx")
openxlsx::write.xlsx(joined, "data-compare/compare-2023.xlsx")
