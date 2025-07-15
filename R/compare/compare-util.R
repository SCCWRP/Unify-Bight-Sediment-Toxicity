float_eq = function (p, u) { 
  purrr::map2(p, u, function(pp, uu) {
    # Return FALSE if either of the published or unified data are NA
    if(is.na(pp) && is.na(uu)) return(FALSE)
    if(is.na(pp) && !is.na(uu) || !is.na(pp) && is.na(uu)) return(FALSE)
    if(pp == uu) return(TRUE)
    # Published and unified values are not equal
    # Assign 0 to preliminary value if divide by zero happens
    prelim = 100 * abs(pp-uu) / pp
    diff = ifelse(is.na(prelim), -1, prelim)
    # Return FALSE if the difference wasn't small enough
    ifelse(diff > 1 || diff < 0, FALSE, TRUE)
  }) |> as.logical()
}

pct_diff = function (p, u) { 
  purrr::map2(p, u, function(pp, uu) {
    # Return -1 if either of the published or unified data are NA
    if(is.na(pp) && is.na(uu)) return(-1)
    if(is.na(pp) && !is.na(uu) || !is.na(pp) && is.na(uu)) return(-1)
    if(pp == uu) return(0)
    prelim = 100 * abs(pp-uu) / pp
    # Return -1 if preliminary comparison was NA or NaN,
    #  likely due to division by 0.
    diff = ifelse(is.na(prelim), -1, prelim)
    return(round(diff, digits = 3))
  }) |> as.double()
}

bool_diff = function (p, u, both.na.equal = FALSE) {
  purrr::map2(p, u, function(pp, uu) {
    if(is.na(pp) && is.na(uu)) return(ifelse(both.na.equal, TRUE, FALSE))
    if(is.na(pp) && !is.na(uu) || !is.na(pp) && is.na(uu)) return(FALSE)
    return(pp == uu)
  }) |> as.logical()
}

compare = function(non_joining) {
  if ("dilution.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(dilution.zcomp = float_eq(dilution.pub, dilution.uni),
                                               dilution.zpdiff = pct_diff(dilution.pub, dilution.uni))
  if ("pvalue.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(pvalue.zcomp =  float_eq(pvalue.pub, pvalue.uni),
                                               pvalue.zpdiff = pct_diff(pvalue.pub, pvalue.uni))
  if ("mean.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(mean.zcomp = float_eq(mean.pub, mean.uni),
                                               mean.zpdiff = pct_diff(mean.pub, mean.uni))
  if ("control_mean.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(control_mean.zcomp = float_eq(control_mean.pub, control_mean.uni),
                                               control_mean.zpdiff = pct_diff(control_mean.pub, control_mean.uni))
  if ("adjusted_control_mean.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(adjusted_control_mean.zcomp = float_eq(adjusted_control_mean.pub, adjusted_control_mean.uni),
                                               adjusted_control_mean.zpdiff = pct_diff(adjusted_control_mean.pub, adjusted_control_mean.uni))
  if ("stddev.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(stddev.zcomp = float_eq(stddev.pub, stddev.uni),
                                               stddev.zpdiff = pct_diff(stddev.pub, stddev.uni))
  if ("coefficientvariance.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(coefficientvariance.zcomp = float_eq(coefficientvariance.pub, coefficientvariance.uni),
                                               coefficientvariance.zpdiff = pct_diff(coefficientvariance.pub, coefficientvariance.uni))
  if ("n.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(n.zcomp = float_eq(n.pub, n.uni),
                                               n.zpdiff = pct_diff(n.pub, n.uni))
  if ("units.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(units.zcomp = bool_diff(units.pub, units.uni))
  if ("qacode.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(qacode.zcomp = bool_diff(qacode.pub, qacode.uni))
  if ("treatment.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(treatment.zcomp = bool_diff(treatment.pub, treatment.uni))
  if ("comments.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(comments.zcomp = bool_diff(comments.pub, comments.uni, both.na.equal = TRUE))
  if ("matrix.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(matrix.zcomp = bool_diff(matrix.pub, matrix.uni))
  if ("sigeffect.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(sigeffect.zcomp = bool_diff(sigeffect.pub, sigeffect.uni))
  if ("endpoint.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(endpoint.zcomp = bool_diff(endpoint.pub, endpoint.uni))
  if ("sqocategory.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(sqocategory.zcomp = bool_diff(sqocategory.pub, sqocategory.uni, both.na.equal = TRUE))
  return(non_joining)
}
