#' Get means by state for min DOY, max DOY, mean DOY, sd DOY, and slope at all
#' thresholds
#' @param ... the SpatRaster targets of the form doy_summary_*
#' @param roi_sf the `roi_sf` target, a `sf` version of the SpatVector of NE
#'   states.
summarize_doy_state <- function(..., roi_sf) {
  # dots <- rlang::dots_list(
  #   doy_summary_50,
  #   doy_summary_350,
  #   doy_summary_650,
  #   doy_summary_1250,
  #   doy_summary_1950,
  #   doy_summary_2500,
  #   .named = TRUE
  # )

  dots <- rlang::dots_list(..., .named = TRUE)

  thresholds <- str_extract(names(dots), "\\d+$")

  names(dots) <- thresholds
  summary_list <- purrr::map(dots, function(threshold) {
    exactextractr::exact_extract(
      threshold,
      roi_sf,
      fun = "mean",
      append_cols = TRUE
    ) |>
      as_tibble()
  })

  states <- tibble(
    state = state.abb,
    state_name = state.name,
    ID = tolower(state.name)
  )
  state_summary <-
    summary_list |>
    purrr::list_rbind(names_to = "threshold") |>
    left_join(states, by = "ID") |>
    select(state, state_name, threshold, everything(), -ID, -mean.count) |>
    mutate(threshold = as.integer(threshold)) |>
    arrange(state, threshold)

  fs::dir_create('output', 'tables')
  readr::write_csv(
    state_summary,
    "output/tables/threshold_state_summary_stats.csv"
  )

  return("output/tables/threshold_state_summary_stats.csv")
}
