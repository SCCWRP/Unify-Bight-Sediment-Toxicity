make_path = function(year) { paste0("data/compare-", year, ".rds") }

years = c("2003", "2008", "2013", "2018", "2023")

datasets = list()
for (y in years) {
  datasets[[y]] = readr::read_rds(make_path(y))
}

preprocessed = dplyr::bind_rows(datasets)
postprocessed = preprocessed

readr::write_rds(postprocessed, "data/comparison-combined.rds")
openxlsx::write.xlsx(postprocessed, "data-compare/comparison-combined.xlsx")
