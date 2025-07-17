yr = 2013

unify_data = readr::read_rds("data/unified.rds") |>
  dplyr::filter(surveyyear == yr)

published_data = readxl::read_excel("data-raw/DataPortalDownloads/ToxData-2013/Bight_13_Toxicity_Summary_Results2_-2502133100839271899.xlsx")

published = published_data |> dplyr::mutate(
    control_mean = NA_real_,
    dilution = NA_real_,
    fieldreplicate = NA_integer_,
    pvalue = NA_real_,
    coefficientvariance = NA_real_,
    treatment = NA,
    comments = comment,
    matrix = NA_character_
  )


common_cols = dplyr::intersect(names(unify_data), names(published))

unify = unify_data |> dplyr::select(all_of(common_cols))
published = published |> dplyr::select(all_of(common_cols))

joined = dplyr::full_join(published, unify, by=dplyr::join_by(stationid, toxbatch), suffix = c(".pub", ".uni"))
comparison_cols = dplyr::bind_cols(joined |> dplyr::select(ends_with(".pub")), joined |> dplyr::select(ends_with(".uni")))

source("R/compare/compare-util.R")
comparison_cols = comparison_cols |> compare()

comparison_cols = comparison_cols |> dplyr::select(all_of(order(names(comparison_cols))))

other_cols = joined |> dplyr::select(!ends_with(".pub") & !ends_with(".uni"))
compare = dplyr::bind_cols(other_cols, comparison_cols)

compare = compare |>
  dplyr::mutate(surveyyear = yr) |>
  dplyr::relocate(surveyyear, .before = 1)

readr::write_rds(compare, "data/compare-2013.rds")
openxlsx::write.xlsx(compare, "data-compare/compare-2013.xlsx")