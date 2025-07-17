yr = 2018

output_columns = readr::read_rds("data/output_columns.rds")

unify_data = readr::read_rds("data/unified.rds") |>
  dplyr::filter(surveyyear == yr)

published_data = readxl::read_excel("data-raw/DataPortalDownloads/ToxData-2018/Bight_18_Sediment_Toxicity_Summary_Results_9058230620704627381.xlsx")

published = published_data |> dplyr::mutate(
    control_mean = NA_real_
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

readr::write_rds(compare, "data/compare-2018.rds")
openxlsx::write.xlsx(compare, "data-compare/compare-2018.xlsx")
