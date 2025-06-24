summarize_summary <- function(doy_summary) {
  # Figure out threshold from target name

  target_name <- deparse(substitute(doy_summary))
  threshold <- stringr::str_extract(target_name, "\\d+$")

  doy_summary |>
    as_tibble(na.rm = TRUE) |>
    summarize(
      doy_min = min(min),
      doy_mean = mean(mean),
      doy_max = max(max),
      doy_sd_min = min(sd),
      doy_sd_mean = mean(sd),
      doy_sd_max = max(sd),
      slope_min = min(slope),
      slop_mean = mean(slope),
      slope_max = max(slope)
    ) |>
    mutate(threshold = threshold, .before = doy_min)
}
