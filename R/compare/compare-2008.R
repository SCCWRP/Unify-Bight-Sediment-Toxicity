unify_data = readr::read_rds("data/unified.rds") |>
  dplyr::filter(surveyyear == 2008)

published_data = readr::read_csv("data-raw/DataPortalDownloads/ToxData-2008/B08CEToxicitySummaryResults_CE.csv")

sort(names(unify_data))
sort(names(published_data))

published = published_data |>
  dplyr::mutate(
    coefficientvariance = NA_real_,
    control_mean = NA_real_,
    diluiton = NA_real_,
    fieldreplicate = NA_character_,
    matrix = NA_character_) |>
  dplyr::rename(
    adjusted_control_mean = PctControl,
    endpoint = EPCode,
    lab = LabCode,
    mean = Mean,
    n = N,
    sampletypecode = SampleType,
    sigeffect = SigEffect,
    species = Species,
    stationid = StationID,
    stddev = StdDev,
    toxbatch = QABatch,
    units = Units
  )

common_cols = dplyr::intersect(names(unify_data), names(published))

unify = unify_data |> select(all_of(common_cols))
published = published |> select(all_of(common_cols))

joined = dplyr::full_join(published, unify, by=dplyr::join_by(stationid, lab, toxbatch, species, sampletypecode), suffix = c(".pub", ".uni"))
joining = joined |> dplyr::select(!ends_with(".pub") & !ends_with(".uni"))
non_joining = dplyr::bind_cols(joined |> dplyr::select(ends_with(".pub")), joined |> dplyr::select(ends_with(".uni")))

source("R/compare/compare-util.R")
non_joining = non_joining |> compare()

non_joining = non_joining |> dplyr::select(all_of(order(names(non_joining))))

compare = dplyr::bind_cols(joining, non_joining)

readr::write_rds(compare, "data/compare-2013.rds")
readr::write_rds(missing_in_pub, "data/compare-pub_missing-2013.rds")
openxlsx::write.xlsx(compare, "data-compare/compare-2013.xlsx")
openxlsx::write.xlsx(missing_in_pub, "data-compare/compare-pub_missing-2013.xlsx")