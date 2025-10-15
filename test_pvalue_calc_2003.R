# Installing from local to pick up unmerged changes
devtools::load_all('../SQOUnified-git/')

results_2023 = readr::read_csv("data-raw/from-bight2023-db/bight23results.csv")
counts_cneg = results_2023 |>
  dplyr::filter(sampletypecode == "CNEG") |>
  dplyr::group_by(stationid, toxbatch, sampletypecode) |> dplyr::count()
counts_result = results_2023 |>
  dplyr::filter(sampletypecode == "Grab") |>
  dplyr::group_by(stationid, toxbatch, sampletypecode) |> dplyr::count()
counts = dplyr::inner_join(counts_result, counts_cneg, by = dplyr::join_by(toxbatch), suffix = c(".res", ".con"))
counts |> dplyr::filter(n.res < n.con)


# Results data produced by ~/Workspace/bight-toxicity-unification/R/unify/unify-summary-2003.R
results_2003 = readr::read_rds("test_pvalue_calc_2003.rds")
counts_cneg = results_2003 |>
  dplyr::filter(sampletypecode == "CNEG") |>
  dplyr::group_by(stationid, toxbatch, sampletypecode) |> dplyr::count()
counts_result = results_2003 |>
  dplyr::filter(sampletypecode == "Result") |>
  dplyr::group_by(stationid, toxbatch, sampletypecode) |> dplyr::count()
counts = dplyr::inner_join(counts_result, counts_cneg, by = dplyr::join_by(toxbatch), suffix = c(".res", ".con"))
counts |> dplyr::filter(n.res < n.con)

# Get station data of interest
results_station_4076 = results_2003 |> dplyr::filter(
  toxbatch == "Batch 3",
  stationid == 4076 | sampletypecode == 'CNEG'
)

# How I think the SQOUnigfied package is calculating PValues
results = results_station_4076 |>
  dplyr::filter(sampletypecode == "Result")
control = results_station_4076 |>
  dplyr::filter(sampletypecode == "CNEG")

results_for_summary = results |> full_join(
  control,
    by = c("toxbatch", "species", "labrep", "lab"),
    suffix = c("", "_control")
  )
t.test(x = results_for_summary$result, y = results_for_summary$result_control, mu = 0, var.equal = F, alternative = "two.sided")$p.value / 2

# Actual Summary produced
summary_4076 = SQOUnified::tox.summary(results_station_4076)
summary_4076$`P Value`
