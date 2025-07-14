unify_data = readr::read_rds("data/unified.rds") |>
  dplyr::filter(surveyyear == 2023)

published_data = readr::read_csv("data-raw/from-bight2023-db/bight23summary.csv")

sort(names(unify_data))
sort(names(published_data))

common_cols = dplyr::intersect(names(unify), names(published_data))

unify = unify_data |> dplyr::select(all_of(common_cols))
published = published_data |> dplyr::select(all_of(common_cols))

joined = dplyr::full_join(published, unify, by=dplyr::join_by(stationid, lab, toxbatch, species, sampletypecode, fieldreplicate), suffix = c(".pub", ".uni"))

joining = joined |> dplyr::select(!ends_with(".pub") & !ends_with(".uni"))
non_joining = dplyr::bind_cols(joined |> dplyr::select(ends_with(".pub")), joined |> dplyr::select(ends_with(".uni")))

source("R/compare/compare-util.R")
non_joining = non_joining |> compare()

non_joining = non_joining |> dplyr::select(order(names(non_joining)))

compare = dplyr::bind_cols(joining, non_joining)                                           

readr::write_rds(compare, "data/compare-2023.rds")
openxlsx::write.xlsx(compare, "data-compare/compare-2023.xlsx")
