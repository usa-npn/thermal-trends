extract_summary_poi <- function(doy_summary, poi) {
  # Figure out threshold from target name
  target_name <- deparse(substitute(doy_summary))
  threshold <- stringr::str_extract(target_name, "\\d+$")

  terra::extract(doy_summary, poi, bind = TRUE) |>
    as_tibble() |>
    mutate(threshold = threshold, .before = 1)
}
