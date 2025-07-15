yr = 2003

# -------------------------------------------------------------------------


unify_data = readr::read_rds("data/unified.rds") |>
  dplyr::filter(surveyyear == yr)

published_data = readr::read_csv("data-raw/DataPortalDownloads/ToxData-2003/tblToxicitySummaryResults.txt")

output_columns = readr::read_rds("data/output_columns.rds")

# dplyr::setdiff(output_columns, names(unify_data))
# dplyr::setdiff(output_columns, names(published_data))
# names(published_data)

unify = unify_data

published = published_data |>
  dplyr::rename_with(tolower)

# sort(dplyr::setdiff(output_columns, names(published)))
# sort(names(published))

published = published |>
  dplyr::mutate(
    coefficientvariance = NA_real_,
    fieldreplicate = NA_integer_,
    matrix = NA_character_,
    pvalue = NA_real_,
    treatment = NA_character_
  ) |>
  dplyr::rename(
    comments = comment,
    endpoint = epcode,
    lab = labcode,
    sampletypecode = sampletype,
    species = speciescode,
    toxbatch = qabatch
  )

common_cols = dplyr::intersect(names(unify_data), names(published))

unify = unify_data |> dplyr::select(all_of(common_cols))
published = published |> dplyr::select(all_of(common_cols))

joined = dplyr::full_join(published, unify, by=dplyr::join_by(stationid, toxbatch), suffix = c(".pub", ".uni"))
joining = joined |> dplyr::select(!ends_with(".pub") & !ends_with(".uni"))
non_joining = dplyr::bind_cols(joined |> dplyr::select(ends_with(".pub")), joined |> dplyr::select(ends_with(".uni")))

source("R/compare/compare-util.R")
non_joining = non_joining |> compare()

non_joining = non_joining |> dplyr::select(all_of(order(names(non_joining))))

compare = dplyr::bind_cols(joining, non_joining)
compare = compare |>
  dplyr::mutate(surveyyear = yr) |>
  dplyr::relocate(surveyyear, .before = 1)

readr::write_rds(compare, "data/compare-2003.rds")
openxlsx::write.xlsx(compare, "data-compare/compare-2003.xlsx")
