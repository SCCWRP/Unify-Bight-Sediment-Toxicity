# Installing from local to pick up unmerged changes
devtools::load_all('../SQOUnified-git/')

make_path = function(year) { paste0("data/unify-summary-", year, ".rds") }

years = c("1994", "1998", "2003", "2008", "2013", "2018", "2023")

datasets = list()
for (y in years) {
  datasets[[y]] = readr::read_rds(make_path(y))
}

unified = dplyr::bind_rows(datasets) |>
  dplyr::mutate(objectid = dplyr::row_number()) |>
  dplyr::relocate(objectid, .before = surveyyear)

readr::write_rds(unified, "data/unified.rds")
