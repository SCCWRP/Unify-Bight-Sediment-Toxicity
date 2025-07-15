yr = 2018

output_columns = readr::read_rds("data/output_columns.rds")

unify_data = readr::read_rds("data/unified.rds") |>
  dplyr::filter(surveyyear == yr)

published_data = readxl::read_excel("data-raw/DataPortalDownloads/ToxData-2018/Bight_18_Sediment_Toxicity_Summary_Results_9058230620704627381.xlsx") |>
  dplyr::rename(
    adjusted_control_mean = pctcontrol,
  )

published = published_data |> dplyr::mutate(
    control_mean = NA_real_
  )



common_cols = dplyr::intersect(names(unify_data), names(published))

unify = unify_data |> dplyr::select(all_of(common_cols))
published = published |> dplyr::select(all_of(common_cols))

joined = dplyr::full_join(published, unify, by=dplyr::join_by(stationid, lab, toxbatch, species, sampletypecode, fieldreplicate), suffix = c(".pub", ".uni"))
joining = joined |> dplyr::select(!ends_with(".pub") & !ends_with(".uni"))
non_joining = dplyr::bind_cols(joined |> dplyr::select(ends_with(".pub")), joined |> dplyr::select(ends_with(".uni")))

source("R/compare/compare-util.R")
non_joining = non_joining |> compare()

non_joining = non_joining |> dplyr::select(order(names(non_joining)))

compare = dplyr::bind_cols(joining, non_joining)
compare = compare |>
  dplyr::mutate(surveyyear = yr) |>
  dplyr::relocate(surveyyear, .before = 1)

readr::write_rds(compare, "data/compare-2018.rds")
openxlsx::write.xlsx(compare, "data-compare/compare-2018.xlsx")
