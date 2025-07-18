
output_columns = names(readr::read_csv("data-raw/from-bight2023-db/tbl_toxsumaryresultspublish_unifiedread.csv"))
readr::write_rds(output_columns, "data/output_columns.rds")

years = c("1994", "1998", "2003", "2008", "2013", "2018", "2023")

for (y in years) {
  print(paste("Processing year", y))
  callr::rscript(paste0("R/compare/compare-", y, ".R"))
}

print("Unifying comparisons...")
callr::rscript("R/compare/unify-comparisons.R")
