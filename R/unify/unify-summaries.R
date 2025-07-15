# Installing from local to pick up unmerged changes
devtools::load_all('../SQOUnified-git/')

make_path = function(year) { paste0("data/unify-summary-", year, ".rds") }

years = c("1994", "1998", "2003", "2008", "2013", "2018", "2023")

datasets = list()
for (y in years) {
  datasets[[y]] = readr::read_rds(make_path(y))
}

preprocessed = dplyr::bind_rows(datasets) %>% dplyr::select(-endpoint)

postprocessed <- preprocessed |>
  dplyr::rename(
    fieldreplicate = fieldrep,
    sigeffect = sigdiff
  ) |>
  dplyr::mutate(
    `Endpoint Method` = case_match(
      species,
      c("Ampelisca abdita", "Eohaustorius estuarius") ~ "10 day survival percent",
      c("Strongylocentrotus purpuratus", "Mytilus galloprovincialis") ~ "Percent normal-alive",
      "Neanthes arenaceodentata" ~ "Growth",
      .default = `Endpoint Method`
    ),
    units = case_match(
      `Endpoint Method`,
      "10 day survival percent" ~ "percentage",
      "Percent normal-alive" ~ "percentage",
      "Growth" ~ "milligrams dry weight per day",
      .default = units
    ),
    sigeffect = case_when(
      !sigeffect ~ "NSC",
      sigeffect ~ "SC"
    ),
    dilution = as.numeric(dilution),
    dilution = case_when(
      dilution < 0 ~ NA,
      .default = dilution
    )
  ) |>
  dplyr::rename(
    endpoint = `Endpoint Method`,
    mean = Mean,
    control_mean = pct_control,
    pctcontrol = `Control Adjusted Mean`,
    stddev = `Standard Deviation`,
    coefficientvariance = `Coefficient of Variance`,
    pvalue = `P Value`,
    sqocategory = `Category`
  )

postprocessed = postprocessed |>
  dplyr::mutate(objectid = dplyr::row_number()) |>
  dplyr::relocate(objectid, .before = surveyyear)

readr::write_rds(postprocessed, "data/unified.rds")
openxlsx::write.xlsx(postprocessed, "data-out/unified.xlsx")

