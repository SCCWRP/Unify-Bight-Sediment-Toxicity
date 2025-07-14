# Installing from local to pick up unmerged changes
devtools::load_all('../SQOUnified-git/')

#####
# Year: 2018
#####
# Prepare 2018 results data
## This data was downloaded from the data portal

lookup_species = dplyr::tibble(
  SpeciesCode = c("EE"),
  SpeciesName = c("Eohaustorius estuarius")
)

lookup_agency = dplyr::tibble(
  AgencyCode = c("AB", "AM", "AW", "BC", "BH", "CC", "CE", "CH", "CI", "CM", "CP", "CS", "CV", "DC", "DW", "EH", "EW", "GC", "GS", "HS", "HY", "IP", "IX", "LA", "LB", "ME", "MI", "MX", "NV", "OC", "OS", "OX", "PF", "RA", "RB", "RD", "RP", "SA", "SB", "SC", "SD", "SE", "SF", "SH", "SR", "UA", "UB", "WI"),
  AgencyName = c("Aquatic Bioassay and Consulting", "Algalita Marine Research Foundation", "Aliso Water Management Authority", "Santa Barbara County Health Service", "Los Angeles County Dept. of Beaches & Harbors", "Center for Environmental Cooperation", "Southern California Edison", "Chevron USA Products Company", "Channel Islands National Marine Sanctuary", "Cabrillo Marine Aquarium", "Marine Corps Base - Camp Pendleton", "Columbia Analytical Services", "City of Ventura", "San Diego Regional Water Quality Control Board", "Los Angeles Department of Water and Power", "Orange County Environmental Health Division", "Encina Wastewater Authority", "Granite Canyon Marine Pollution Studies Lab", "Goleta Sanitation District", "Los Angeles County Dept. of Health Services", "City of Los Angeles Environmental Monitoring Division", "San Diego Interagency Water Quality Panel", "US EPA Region IX", "Los Angeles County Sanitation Districts", "City of Long Beach", "MEC Analytical Systems Inc.", "Southern California Marine Institute", "National Fisheries Institute of Mexico", "US Navy, Space & Naval Warfare Systems Center, San Diego", "Orange County Sanitation Districts", "City of Oceanside", "City of Oxnard", "Orange County Public Facilities and Resources", "Southeast Regional Reclamation Authority", "Los Angeles County Regional Water Quality Control Board", "US EPA Office of Research and Development", "Santa Monica Bay Restoration Project", "Santa Ana Regional Water Quality Control Board", "City of Santa Barbara", "Southern California Coastal Water Research Project", "City of San Diego", "San Elijo Joint Powers Authority", "Surfrider Foundation", "San Diego County Dept. of Environmental Health", "State Water Resources Control Board", "University Autonomous de Baja California", "University of California, Santa Barbara", "USC Wrigley Institute for Environmental Studies")
)

batch = readr::read_csv('data-raw/DataPortalDownloads/ToxData-1998/Batch.txt') |>
  dplyr::tibble() |>
  dplyr::rename_with(tolower)

results = readr::read_csv('data-raw/DataPortalDownloads/ToxData-1998/Results.txt') |>
  dplyr::tibble() |>
  dplyr::rename_with(tolower) |>
  dplyr::rename(
    lab = labcode,
    species = `species/testtype`,
    result = value,
    sampletypecode = sampletype
  ) |>
  dplyr::full_join(batch) |>
  dplyr::rename(
    toxbatch = qabatch
  ) |>
  dplyr::mutate(
    species = with(lookup_species, SpeciesName[match(species, SpeciesCode)]),
    sampletypecode = dplyr::case_match(
      sampletypecode,
      "Result" ~ "Grab",
      .default = sampletypecode
    ),
    lab = with(lookup_agency, AgencyName[match(lab, AgencyCode)]),
    matrix = dplyr::case_match(
      matrix,
      'BS' ~ "Whole Sediment",
      .default = matrix
    ),
    units = dplyr::case_match(
      units,
      "%" ~ "percentage",
      .default = units
  ))

summary <- dplyr::tibble(surveyyear = 1998) |> dplyr::cross_join(SQOUnified::tox.summary(results, include.controls = T))

readr::write_rds(summary, "data/unify-summary-1998.rds")
