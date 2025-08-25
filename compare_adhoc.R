comparison.combined = readr::read_rds("data/comparison-combined.rds")

# Get an important subset of the comparison columns
compare = comparison.combined |> dplyr::select(surveyyear, stationid, toxbatch,
    dplyr::starts_with("species"),
    dplyr::starts_with("fieldreplicate"),
    dplyr::starts_with("sampletypecode"),
    dplyr::starts_with("qacode"),
    dplyr::starts_with("n."),
    dplyr::starts_with("mean"),
    dplyr::starts_with("control_mean"),
    dplyr::starts_with("pvalue"),
    dplyr::starts_with("sigeffect"),
    dplyr::starts_with("sqocategory"),
    -mean.zpdiff
  ) |> 
  # Round the means and pvalues
  dplyr::mutate(
    mean.pub = round(mean.pub) |> dplyr::coalesce(-88),
    mean.uni = round(mean.uni) |> dplyr::coalesce(-88),
    mean.zcomp = (mean.pub < 0 & mean.uni < 0) | mean.pub == mean.uni,
    control_mean.pub = round(control_mean.pub) |> dplyr::coalesce(-88),
    control_mean.uni = round(control_mean.uni) |> dplyr::coalesce(-88),
    control_mean.zcomp = control_mean.pub == control_mean.uni,
    pvalue.pub = round(pvalue.pub, digits=3) |> dplyr::coalesce(-88),
    pvalue.uni = round(pvalue.uni, digits=3) |> dplyr::coalesce(-88),
    pvalue.zcomp = pvalue.pub == pvalue.uni,
    # Check the SQO Category comparison
    sqocategory.zcomp = dplyr::coalesce(sqocategory.pub, "X") == dplyr::coalesce(sqocategory.uni, "X")
  ) |>
  # Only select rows where at least the means, sigeffects, or sqocategories are different
  dplyr::filter(
    (!dplyr::coalesce(mean.zcomp, FALSE) | !dplyr::coalesce(sigeffect.zcomp, FALSE) | !dplyr::coalesce(sqocategory.zcomp, FALSE))
    # Only get the Results and Controls rows
    & (sampletypecode.uni %in% c("Grab", "CNEG")
    & sampletypecode.pub %in% c("Grab", "RESULT", "Result", "CNEG"))
  )

compare |> openxlsx::write.xlsx("compare-subselect-2.xlsx")

# Find the rows where the means are different
problems = compare |> dplyr::filter(!mean.zcomp)
View(problems)

# Get the corresponding tox batches
problem.toxbatch = problems |>
  dplyr::select(toxbatch) |>
  unlist() |>
  as.character()

# Read in the results data and calculate the means based on that

results.13 = readxl::read_excel("data-raw/DataPortalDownloads/ToxData-2013/Bight_2013_Regional_Survey_Toxicity_Results_-692175966774049861.xlsx")
problem.results.13 = results.13 |> dplyr::filter(ToxBatch %in% problem.toxbatch)
problem.means.13 = problem.results.13 |> dplyr::group_by(StationID, ToxBatch, Species, SampleTypeCode, QACode) |> dplyr::summarize(
  mean.calc = mean(Result)
)
problem.means.13

results.23 = readr::read_csv("data-raw/from-bight2023-db/bight23results.csv")
results.23 |> dplyr::count(qacode)
results.23 |> dplyr::filter(qacode == "C") |> dplyr::filter(toxbatch == "NIWC-2023-MG2") |> dplyr::select(stationid, labrep, result, comments)
summary.23.published = readr::read_csv("data-raw/from-bight2023-db/bight23summary.csv")
summary.23.published |> dplyr::filter(toxbatch == "NIWC-2023-MG2", stationid == "B23-12709") |> dplyr::select(stationid, mean, qacode, comments)

# Read in 2018 results data
results.18 = readr::read_csv("data-raw/DataPortalDownloads/ToxData-2018/Bight_18_Sediment_Toxicity_Results.csv")
# Count up the frequencies of the various QA codes
results.18 |> dplyr::count(qacode)
# How many have QA code "C"
results.18 |> dplyr::filter(qacode == "C") 

qacodes.18.C = results.18 |> dplyr::filter(qacode == "C") |> dplyr::select(stationid, toxbatch) |> unique()
qacodes.18.C |> dplyr::inner_join(results.18, by = dplyr::join_by(stationid, toxbatch)) |> dplyr::arrange(stationid, toxbatch, qacode) |> View()
summary.18.published = readxl::read_excel("data-raw/DataPortalDownloads/ToxData-2018/Bight_18_Sediment_Toxicity_Summary_Results_9058230620704627381.xlsx")
summary.18.published |> dplyr::count(qacode)
qacodes.18.C |> dplyr::inner_join(summary.18.published)
toxbatches.18.C = results.18 |> dplyr::filter(qacode == "C") |> dplyr::select(toxbatch) |> unique()
toxbatches.18.C |> dplyr::inner_join(results.18) |> dplyr::filter(sampletypecode == "CNEG")


### Specific comparisons
devtools::load_all("../SQOUnified-git/")

renamer.sqounified = function(s.tibble) {
  s.tibble |> dplyr::rename(
    pctcontrol = `Control Adjusted Mean`,
    pvalue = `P Value`,
    mean = Mean,
    stddev = `Standard Deviation`,
    sqocategory = `Category`,
    sigeffect = sigdiff,
    coefficientvariance = `Coefficient of Variance`
  )
}

# 2018 summary where qacode=="O"
s = summary.18.published |> dplyr::filter(qacode=="O")
r = summary.18.published |> dplyr::filter(qacode=="O") |> dplyr::select(stationid, toxbatch, species) |> unique() |> dplyr::inner_join(results.18)
# QA code for this summary row should be "A, O" because the results include results with qa code "A" (4 A's, 1 O)
# Correction
c = tox.summary(r) |> renamer.sqounified()
# Correction: prepend "O" with "A, " (It appears the "O" result was used in calculation of mean)
r = r |> dplyr::mutate(
  qacode = case_match(
    qacode,
    "O" ~ "A, O",
    .default = qacode
  )
)
c = tox.summary(r) |> renamer.sqounified()
s.corrections = s |> dplyr::inner_join(c, by=dplyr::join_by(stationid, toxbatch, species), suffix = c(".p", ".u"))


# Further correction needed for 2018 Results: The rows here with qacode "C" and without "X" should be prepended with "A, "
summary.18.published |> dplyr::count(qacode)
s = summary.18.published |> dplyr::filter(qacode=="C")
r = summary.18.published |> dplyr::filter(qacode=="C") |> dplyr::select(stationid, toxbatch) |> unique() |> dplyr::inner_join(results.18)
r = r |> dplyr::mutate(
  qacode = case_match(
    qacode,
    "C" ~ "A, C",
    .default = qacode
  )
)
c = tox.summary(r) |> renamer.sqounified()
s = s |> dplyr::right_join(c, by=dplyr::join_by(stationid, toxbatch, species), suffix = c(".p", ".u"))
s.corrections = s.corrections |> dplyr::bind_rows(s)

# 2018 summary where qacode=="E,X"
summary.18.published |> dplyr::count(qacode)
s = summary.18.published |> dplyr::filter(qacode=="E,X")

# No matching results:
s |> dplyr::select(stationid, toxbatch, species) |> unique() |> dplyr::inner_join(results.18)

# Try just matching on stationid
s = s |> dplyr::select(stationid) |> unique() |> dplyr::inner_join(results.18)
r = r |> dplyr::mutate(
  qacode = case_match(
    qacode,
    "E" ~ "A, E",
    .default = qacode
  )
)
# These stationid-toxbatch pairs in the 2018 published summary don't have corresponding rows in the 2018 results..?
c = tox.summary(r) |> renamer.sqounified()
s = s |> dplyr::inner_join(c, by=dplyr::join_by(stationid, toxbatch, species), suffix = c(".p", ".u"))
s.corrections = s.corrections |> dplyr::bind_rows(s)

joining = s.corrections |> dplyr::select(!dplyr::ends_with(".p") & !dplyr::ends_with(".u"))
non.joining = s.corrections |> dplyr::select(dplyr::ends_with(".p") | dplyr::ends_with(".u"))
non.joining = non.joining |> dplyr::select(sort(names(non.joining)))
