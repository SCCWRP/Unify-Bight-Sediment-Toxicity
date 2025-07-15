
years = c("2008", "2013", "2018", "2023")

for (y in years) {
  print(paste("Processing year", y))
  callr::rscript(paste0("R/compare/compare-", y, ".R"))
}

print("Unifying comparisons...")
callr::rscript("R/compare/unify-comparisons.R")
