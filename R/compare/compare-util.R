pct_diff = function (p, u) { 
  purrr::map2(p, u, function(pp, uu) {
    if(is.na(pp) && is.na(uu)) return(FALSE)
    if(is.na(pp) && !is.na(uu) || !is.na(pp) && is.na(uu)) return(FALSE)
    if(pp == uu) return(TRUE)
    pd = (pp-uu) / pp
    d = ifelse(is.na(pd), 0, pd)
    ifelse(d > 0.1, FALSE, TRUE)
  })
}
bool_diff = function (p, u, both.na.equal = FALSE) {
  purrr::map2(p, u, function(pp, uu) {
    if(is.na(pp) && is.na(uu)) return(ifelse(both.na.equal, TRUE, FALSE))
    if(is.na(pp) && !is.na(uu) || !is.na(pp) && is.na(uu)) return(FALSE)
    return(pp == uu)
  })
}

names(non_joining)

compare = function(non_joining) {
  if ("dilution.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(dilution.zcomp = pct_diff(dilution.pub, dilution.uni))
  if ("pvalue.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(pvalue.zcomp =  pct_diff(pvalue.pub, pvalue.uni))
  if ("mean.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(mean.zcomp = pct_diff(mean.pub, mean.uni))
  if ("control_mean.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(control_mean.zcomp = pct_diff(control_mean.pub, control_mean.uni))
  if ("adjusted_control_mean.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(adjusted_control_mean.zcomp = pct_diff(adjusted_control_mean.pub, adjusted_control_mean.uni))
  if ("stddev.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(stddev.zcomp = pct_diff(stddev.pub, stddev.uni))
  if ("coefficientvariance.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(coefficientvariance.zcomp = pct_diff(coefficientvariance.pub, coefficientvariance.uni))
  if ("n.pub" %in% names(non_joining))
    non_joining = non_joining |> dplyr::mutate(n.zcomp = pct_diff(n.pub, n.uni))
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
