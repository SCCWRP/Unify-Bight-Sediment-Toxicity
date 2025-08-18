yr = 2023

output_columns = readr::read_rds("data/output_columns.rds")

unify_data = readr::read_rds("data/unified.rds") |>
  dplyr::filter(surveyyear == yr)

published_data = readr::read_csv("data-raw/from-bight2023-db/bight23summary.csv", show_col_types = FALSE) |>
  dplyr::rename_with(tolower)
common_cols = dplyr::intersect(names(unify_data), names(published_data))

unify = unify_data |> dplyr::select(all_of(common_cols))
published = published_data |> dplyr::select(all_of(common_cols))


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

readr::write_rds(compare, "data/compare-2023.rds")
openxlsx::write.xlsx(compare, "data-compare/compare-2023.xlsx")
