# Installing from local to pick up unmerged changes
devtools::load_all('../SQOUnified-git/')

make_path = function(year) { paste0("data/unify-summary-", year, ".rds") }

years = c("1994", "1998", "2003", "2008", "2013", "2018", "2023")

datasets = list()
for (y in years) {
  datasets[[y]] = readr::read_rds(make_path(y))
}

preprocessed = dplyr::bind_rows(datasets) %>% dplyr::select(-endpoint)

postprocessed <- preprocessed |> dplyr::mutate(
  `Endpoint Method` = case_match(
    species,
    c("Ampelisca abdita", "Eohaustorius estuarius") ~ "Survival",
    c("Strongylocentrotus purpuratus", "Mytilus galloprovincialis") ~ "NormalDev",
    "Neanthes arenaceodentata" ~ "Growth",
    .default = `Endpoint Method`
  ),
  sigdiff = case_when(
    !sigdiff ~ "NSC",
    sigdiff ~ "SC"
  ),
  dilution = as.numeric(dilution),
  dilution = case_when(
    dilution < 0 ~ NA,
    .default = dilution
  )
)

postprocessed = postprocessed |>
  dplyr::mutate(objectid = dplyr::row_number()) |>
  dplyr::relocate(objectid, .before = surveyyear)

readr::write_rds(postprocessed, "data/unified.rds")
