comparison.combined <- readr::read_rds("~/Workspace/bight-toxicity-unification/data/comparison-combined.rds")

## Check p-values not matching sigdiff

pval.sig = comparison.combined |>
  dplyr::select(surveyyear, stationid, toxbatch, species.pub, species.uni,
                dplyr::starts_with("P Val"), dplyr::starts_with("sigdiff"))
pval.sig |> dplyr::count(dplyr::across(dplyr::starts_with("sigdiff")))

# Rows where pval indicates significant effect, but sigeffect marked as NSC
pval.sig |> dplyr::filter(`P Value.uni` <= 0.05, sigdiff.pub != "SC")

# Rows where pval indicates no significant effect, but sigeffect marked as SC
pval.sig |> dplyr::filter(`P Value.uni` > 0.05, sigdiff.pub != "NSC")


## Check p-values where count of CNEG rows doesn't match count of Result rows for given toxbatch

comparison.combined |> dplyr::group_by(toxbatch, species.uni, sampletypecode.)
