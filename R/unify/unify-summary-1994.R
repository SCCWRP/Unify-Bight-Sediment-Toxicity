# Installing from local to pick up unmerged changes
devtools::load_all('../SQOUnified-git/')

#####
# Year: 1994
#####
# Prepare 1994 results data
## This data was downloaded from the data portal

lookup_species = dplyr::tibble(
  SpeciesCode = c("AB", "SP"),
  SpeciesName = c("Ampelisca abdita", "Strongylocentrotus purpuratus")
)

lookup_phase = dplyr::tibble( # Is this similar to matrix, Sediment Water Interface and Whole Sediment?
  PhaseCode = c("WP", "SP"), # "Water Phase", "Sediment Phase"?
  PhaseName = c("Sediment Water Interface", "Whole Sediment")
)

lookup_agency = dplyr::tibble(
  AgencyCode = c("SC", "NG"), # Guess for NG: SAIC is in Narragansett, RI. Also, Toxicity assessment report only mentions SCCWRP and SAIC under Lab in Appendix 5.
  AgencyName = c("Southern California Coastal Water Research Project", "Science Applications International Corp.")
)

lookup_endpoint = dplyr::tibble(
  EndpointCode = c("NN", NA), # Guess for NN: Normal Development Normalized? NAs correspond to Survival?
  EndpointName = c("NormalDev", "Survival")
)

DATA = readr::read_csv('data-raw/DataPortalDownloads/ToxData-1994/TOX_DATA.TXT') |>
  dplyr::tibble() |>
  dplyr::rename_with(tolower)

all_stations = tibble(stationid = substr(unique(sort(DATA$log.number)), 6, 9))
control_stations = tibble(stationid = substr(unique(sort(DATA$controlcode)), 6, 9))

results = DATA |>
  dplyr::mutate(
    result = 100 * value / `start count`,
    units = "Percent"
  ) |>
  dplyr::rename(
    lab = `lab code`,
    labrep = `lab rep`,
    toxbatch = `qa batch`,
    qacode = `qa code`,
    matrix = phase
  ) |>
  dplyr::mutate(
    lab = with(lookup_agency, AgencyName[match(lab, AgencyCode)]),
    stationid = substr(`log number`, 6, 9),
    species = with(lookup_species, SpeciesName[match(species, SpeciesCode)]),
    matrix = with(lookup_phase, PhaseName[match(matrix, PhaseCode)]),
    endpoint = with(lookup_endpoint, EndpointName[match(endpoint, EndpointCode)]),
    sampletypecode = case_when(
      stationid %in% control_stations$stationid ~ "CNEG",
      TRUE ~ "Grab"
    )
  )

summary <- dplyr::tibble(surveyyear = 1994) |> dplyr::cross_join(SQOUnified::tox.summary(results))

readr::write_rds(summary, "data/unify-summary-1994.rds")
