
library(magrittr)

unify <- readr::read_rds("data/unified.rds") %>%
  dplyr::filter(surveyyear == 1994) %>%
  dplyr::mutate(pubstatus = "unpub") %>%
  dplyr::relocate(pubstatus, .before=1)

published <- readxl::read_xlsx("~/Workspace/bight-toxicity-unification/data-raw/DataPortalDownloads/ToxData-1994/bight tox 1994 summary.xlsx")

amphipod <- readr::read_csv("data-raw/DataPortalDownloads/ToxData-1994/summary/bight tox 1994 summary(amphipod AB).csv")
urchin <- readr::read_csv("data-raw/DataPortalDownloads/ToxData-1994/summary/bight tox 1994 summary(sea urchin SP).csv")

urchin %>% mutate(across(starts_with("%Control"), as.numeric)) %>% View()
urchin_control <- urchin %>% dplyr::select(stationid | starts_with("%Control")) %>% tidyr::pivot_longer(cols = !stationid, names_pattern = "%Control \\((\\d+)\\)", names_to="dilution", values_to = "pct_control")
urchin_mean <- urchin %>% dplyr::select(stationid | starts_with("%Normal")) %>% tidyr::pivot_longer(cols = !stationid, names_pattern = "%Normal \\((\\d+)\\)", names_to="dilution", values_to = "mean")
urchin_sd <- urchin %>% dplyr::select(stationid | starts_with("SD")) %>% tidyr::pivot_longer(cols = !stationid, names_pattern = "SD \\((\\d+)\\)", names_to="dilution", values_to = "sd")
urchin_sigdiff <- urchin %>%
  dplyr::select(stationid | starts_with("t test")) %>%
  tidyr::pivot_longer(
    cols = !stationid, names_pattern = "t test \\((\\d+)\\)", names_to="dilution", values_to = "sigdiff"
  ) %>%
  dplyr::mutate(
    sigdiff = case_match(
      sigdiff,
      NA ~ FALSE,
      "*" ~ TRUE,
      .default = NA
    )
  )

amphipod <- published %>%
  dplyr::rename(
    stationid = Station,
    lab = Lab,
    `Standard Deviation` = SD,
    pct_control = `%Control`,
    `P Value` = `t test`,
    qacode = `QA Code`
  ) %>%
  dplyr::mutate(
    stationid = stringr::str_pad(stationid, 4, side="left", pad="0"),
    p = dplyr::case_match(
      `P Value`,
      "*" ~ 0,
      .default = 1
    ),
    sigdiff = dplyr::case_match(
      `P Value`,
      "*" ~ "SC",
      .default = "NSC"
    ),
    species = "Ampelisca abdita"
  ) %>%
  dplyr::select(-`P Value`) %>%
  dplyr::mutate(pubstatus = "published") %>%
  dplyr::relocate(pubstatus, .before=1)

bound <- dplyr::bind_rows(unify, amphipod) %>% dplyr::arrange(stationid, species)
