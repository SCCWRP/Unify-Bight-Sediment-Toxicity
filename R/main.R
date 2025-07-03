library(callr)

years = c("1994", "1998", "2003", "2008", "2013", "2018", "2023")

for (y in years) {
  print(paste("Processing year", y))
  callr::rscript(paste0("R/unify-summary-", y, ".R"))
}

callr::rscript("R/unify-summaries.R")
