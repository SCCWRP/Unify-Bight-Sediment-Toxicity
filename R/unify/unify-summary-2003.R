# Installing from local to pick up unmerged changes
devtools::load_all('../SQOUnified-git/')

#####
# Year: 2003
#####
# Script to preprocess, process, and post-process Bight Tox 2003 data

results <- readr::read_csv('data-raw/DataPortalDownloads/ToxData-2003/tblToxicityResults.txt') |>
  dplyr::rename_with(tolower)

stations <- readr::read_csv('data-raw/DataPortalDownloads/ToxData-2003/tblStations.txt') |>
  dplyr::rename_with(tolower)

batch <- readr::read_csv('data-raw/DataPortalDownloads/ToxData-2003/tblToxicityBatchInformation.txt') |>
  dplyr::rename_with(tolower)

names(stations) = tolower(names(stations))

results <- results |>
  dplyr::rename_with(tolower) |>
  dplyr::rename(
    toxbatch = qabatch,
    sampletypecode = sampletype,
    result = value,
    units = valueunits
  ) |> dplyr::mutate(
    sampletypecode = dplyr::case_match(
      sampletypecode,
      c("RESULT", "Result") ~ "Grab",
      .default = sampletypecode
    ),
    dilution = ifelse("dilution" %in% pick(everything()), as.numeric(dilution), -88),
    dilution = case_when(
      dilution < 0 ~ NA,
      .default = dilution
    )
  )

#####
# Table lookups
#####

# luList34_ToxictySpecies/TestType
lu_species <- dplyr::tibble(
  SpeciesCode = c("EE", "SP"),
  SpeciesName = c("Eohaustorius estuarius", "Strongylocentrotus purpuratus")
)

# Create the tibble for luList28_Units
lu_units <- tibble(
  UnitsCode = c(
    "C", "CFU/100ml", "CM", "Days", "FT", "G", "Hours", "KG", "KTS", "M",
    "M/S", "MG/KG", "MG/L", "MM", "MPN/100ml", "PDT", "PERCENT", "PST",
    "UG/KG", "UG/L", "pH", "NR"
  ),
  Units = c(
    "Degrees Centigrade", "Colony Forming Units", "Centimeters", "The number of days",
    "Feet", "grams", "The number of hours", "Kilograms", "Knots", "Meters",
    "Meters per second", "Milligrams per kilogram", "Milligrams per liter",
    "Millimeters", "Most Probable Number", "Pacifc Daylight savings time",
    "Percent", "Pacific Standard Time", "Micrograms per kilogram",
    "micrograms per liter", "Log of hydrogen ion\nconcentration", "Not Recorded"
  )
)

# Create the tibble for luList01_AgencyCodes
lu_lab <- tibble(
  LabCode = c(
    "AATI", "ABC", "AL", "CDFG", "CINMS", "CLAEMD", "CLB", "CRG", "CSD",
    "OCSD", "ENVIR", "EW", "HTB", "IDEXX", "JPL", "LACDHS", "LACET",
    "LACRWQCB", "LACSD", "LADWP", "LMU", "MBC", "MEC", "MMS", "OCCK",
    "OCEHD", "OCPFRD", "OCPHL", "OS", "OX", "POLA", "POLB", "SARWQCB",
    "SBCK", "SCCWRP", "SCMI", "SDBK", "SDCDEH", "SDRWQCB", "SEJPA",
    "SF", "SMBK", "SMBRP", "SOCWA", "SV", "SWRCB", "UCI", "UCSB", "USGS", "VRG"
  ),
  Lab = c(
    "Advanced Analytical Technology Incorporated",
    "Aquatic Bioassay and Consulting Laboratories",
    "Associated Laboratories",
    "California Department of Fish and Game",
    "Channel Islands National Marine Sanctuary (CINMS)",
    "City of Los Angeles Environmental Monitoring Division (CLAEMD)",
    "City of Long Beach",
    "CRG Labs",
    "City of San Diego",
    "Orange County Sanitation Districts (OCSD)",
    "Enviromatrix Analytical",
    "Encina Waste Water Authority",
    "Heal the Bay",
    "IDEXX Laboratories",
    "Jet Propulsion Laboratory",
    "Los Angeles County Dept. of Health Services",
    "LA County Environ Tox Lab",
    "Los Angeles County Regional Water Quality Control Board",
    "Los Angeles County Sanitation Districts (LACSD)",
    "Los Angeles Department of Water and Power (LADWP)",
    "Loyola Marymount University",
    "Marine Biological Consulting",
    "Marine Environmental Consulting Analytical Systems Inc.",
    "Minerals Management Service",
    "Orange County Coast Keeper",
    "Orange County Environmental Health Division",
    "Orange County Public Facilities and Resources (OCPFRD)",
    "Orange County Public Health Laboratory",
    "City of Oceanside",
    "City of Oxnard",
    "Port of Los Angeles",
    "Port of Long Beach",
    "Santa Ana Regional Water Quality Control Board",
    "Santa Barbara Channelkeeper",
    "Southern California Coastal Water Research Project(SCCWRP)",
    "Southern California Marine Institute(SCMI)",
    "San Diego Baykeeper",
    "San Diego County Dept. of Environmental Health",
    "San Diego Regional Water Quality Control Board (SDRWQCB)",
    "San Elijo Joint Powers Authority*",
    "Surfrider Foundation",
    "Santa Monica Baykeeper",
    "Santa Monica Bay Restoration Project",
    "Southern Orange County Water Authority",
    "Sea Ventures",
    "State Water Resources Control Board (SWRCB)",
    "University of California at Irvine",
    "University of California, Santa Barbara",
    "United States Geological Survey",
    "Vantuna Research Group"
  )
)

# Create the tibble for luList37_ToxicityEndPoints
lu_endpoints <- tibble(
  EPCode = c("B[a]Peq", "DV", "EC50", "FP", "IC50", "RL", "SP"),
  EndPoint = c(
    "Benzo [a] Pyrene equivalents",
    "Percent Normal Pluteus Stage",
    "median effective concentration",
    "Fertilized Percent",
    "median inhibitory concentration",
    "relative luminescence",
    "survival percent"
  )
)

lu_matrix = dplyr::tibble(
  Code = c("BS", "RT", "OL"),
  Matrix = c("Whole Sediment", "Reference Toxicant", "Overlaying Water")
)

results <- results |>
  dplyr::rename(
    species = `species/testtype`,
    lab = labcode,
  ) |>
  dplyr::mutate(
    species = with(lu_species, SpeciesName[match(species, SpeciesCode)]),
    lab = with(lu_lab, Lab[match(lab, LabCode)]),
    sampledepthunits = with(lu_units, Units[match(sampledepthunits, UnitsCode)]),
    concentrationunits = with(lu_units, Units[match(concentrationunits, UnitsCode)]),
    units = with(lu_units, Units[match(units, UnitsCode)]),
    endpoint = with(lu_endpoints, EndPoint[match(endpoint, EPCode)]),
  ) |>
  dplyr::full_join(stations, by = dplyr::join_by(stationid)) |>
  dplyr::full_join(batch, by = dplyr::join_by(toxbatch == qabatch, species)) |>
  dplyr::mutate(
    matrix = with(lu_matrix, Matrix[match(matrix, Code)])
  )

summary <- dplyr::tibble(surveyyear = 2003) |> dplyr::cross_join(SQOUnified::tox.summary(results))

readr::write_rds(summary, "data/unify-summary-2003.rds")
