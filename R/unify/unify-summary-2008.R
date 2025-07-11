devtools::load_all('../SQOUnified-git/')

results = read.csv('data-raw/DataPortalDownloads/ToxData-2008/B08CEToxicityResults_CE.csv')
stations = read.csv('data-raw/DataPortalDownloads/ToxData-2008/B08CEToxicityStations_CE.csv')
batch = read.csv('data-raw/DataPortalDownloads/ToxData-2008/B08CEToxicityBatchInformation_CE.csv')

agency_lookup <- dplyr::tibble(
  code = c(
    "AES", "ABC", "CSUCI", "CINMS", "CUPC", "CLB", "CLAEMD", "OC", "OX", "CSD",
    "VT", "CRG", "EW", "GC", "GTCN", "HI", "UABC", "JPL", "LACDBH", "LACDHS", "LACRWQCB",
    "LACSD", "LADWP", "LMU", "MBC", "MCB", "MMS", "NPS", "NES", "NRG", "OCEHD",
    "OCPFRD", "OCSD", "POLA", "POSD", "RC", "SDCDEH", "SDRWQCB", "SEJPA",
    "SARWQCB", "SBHCS", "SMBRC", "SMBRP", "SV", "SCCWRP", "SCWRP", "SOCWA",
    "SWRCB", "TENERR", "USFWS", "USGS", "UCLA", "UCSB", "VRG", "WS", "NE", "NWAS"
  ),
  fullname = c(
    "AES Corporation", "Aquatic Bioassay and Consulting Laboratories",
    "California State University at Channel Islands",
    "Channel Islands National Marine Sanctuary", "Chevron USA Products Company",
    "City of Long Beach", "City of Los Angeles Environmental Monitoring Division",
    "City of Oceanside", "City of Oxnard", "City of San Diego", "City of Ventura",
    "CRG Labs", "Encina Waste Water Authority", "Granite Canyon Marine Pollution Studies Lab", "Granite Canyon Marine Pollution Studies Lab",
    "Houston Industries Inc.", "Instituto de Investigacione, Oceanologicas",
    "Jet Propulsion Laboratory", "Los Angeles County Department of Beaches and Harbors",
    "Los Angeles County Dept. of Health Services", "Los Angeles County Regional Water Quality Control Board",
    "Los Angeles County Sanitation Districts", "Los Angeles Department of Water and Power",
    "Loyola Marymount University", "Marine Biological Consulting",
    "Marine Corps Base - Camp Pendleton", "Minerals Management Service",
    "National Park Service", "NES Energy Inc.", "NRG Energy Inc.",
    "Orange County Environmental Health Division", "Orange County Public Facilities and Resources",
    "Orange County Sanitation Districts", "Port of Los Angeles", "Port of San Diego",
    "Reliant Corporation", "San Diego County Department of Environmental Health",
    "San Diego Regional Water Quality Control Board", "San Elijo Joint Powers Authority*",
    "Santa Ana Regional Water Quality Control Board", "Santa Barbara Health Care Services",
    "Santa Monica Bay Restoration Commission", "Santa Monica Bay Restoration Project",
    "Sea Ventures", "Southern California Coastal Water Research Project",
    "Southern California Wetland Recovery Project", "Southern Orange County Water Authority",
    "State Water Resources Control Board", "Tijuana Estuary National Estuarine Research Reserve",
    "United States Fish and Wildlife Service", "United States Geological Survey",
    "University of California at Los Angeles", "University of California, Santa Barbara",
    "Vantuna Research Group", "Weston Solutions", "Nautilus Environmental",
    "Northwest Aquatic Sciences"
  )
)

matrix_lookup = dplyr::tibble(
  code = c("BS", "SWI"),
  name = c("Whole Sediment", "Sediment Water Interface")
)

results = results |>
  dplyr::rename_with(tolower) |>
  dplyr::rename(
    toxbatch = qabatch,
    sampletypecode = sampletype,
    result = value,
    endpoint_method = endpoint
  ) |>
  dplyr::mutate(
    sampletypecode = dplyr::case_match(
      sampletypecode,
      c("RESULT", "Result") ~ "Grab",
      .default = sampletypecode
    ),
    species = dplyr::case_match(
      tolower(species),
      "ee" ~ "Eohaustorius estuarius",
      "mg" ~ "Mytilus galloprovincialis",
      .default = species
    ),
    lab = with(agency_lookup, fullname[match(labcode, code)]),
    matrix = with(matrix_lookup, name[match(matrix, code)]),
    units = "percent",
    dilution = ifelse("dilution" %in% pick(everything()), as.numeric(dilution), -88),
    dilution = case_when(
      dilution < 0 ~ NA,
      .default = dilution
    )
  )



summary <- dplyr::tibble(surveyyear = 2008) |> dplyr::cross_join(SQOUnified::tox.summary(results))

readr::write_rds(summary, "data/unify-summary-2008.rds")
