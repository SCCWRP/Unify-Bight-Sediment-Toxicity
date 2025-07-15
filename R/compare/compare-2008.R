yr = 2008

unify_data = readr::read_rds("data/unified.rds") |>
  dplyr::filter(surveyyear == yr)

published_data = readr::read_csv("data-raw/DataPortalDownloads/ToxData-2008/B08CEToxicitySummaryResults_CE.csv")

unify = unify_data |> dplyr::mutate(
  concentration = NA_real_,
)

published = published_data |>
  dplyr::mutate(
    coefficientvariance = NA_real_,
    control_mean = NA_real_,
    fieldreplicate = NA_integer_,
    matrix = NA_character_,
    pvalue = NA_real_
  ) |>
  dplyr::rename(
    adjusted_control_mean = PctControl,
    comments = Comment,
    dilution = Dilution,
    endpoint = EPCode,
    lab = LabCode,
    mean = Mean,
    n = N,
    qacode = QACode,
    sampletypecode = SampleType,
    sigeffect = SigEffect,
    species = Species,
    stationid = StationID,
    stddev = StdDev,
    toxbatch = QABatch,
    units = Units
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

readr::write_rds(compare, "data/compare-2008.rds")
openxlsx::write.xlsx(compare, "data-compare/compare-2008.xlsx")
