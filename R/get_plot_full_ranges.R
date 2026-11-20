get_plot_full_ranges <- function(summary_rasters, slope_differences) {
  sd_range <- summary_rasters |>
    purrr::map(\(x) {
      x[["sd"]] |> values() |> range(na.rm = TRUE)
    }) |>
    purrr::list_c() |>
    range()
  slope_range <- summary_rasters |>
    purrr::map(\(x) {
      x[["slope"]] |> values() |> range(na.rm = TRUE)
    }) |>
    purrr::list_c() |>
    range()
  slope_differences_range <- slope_differences |>
    values() |>
    range(na.rm = TRUE)
  # return:
  list(
    sd = sd_range,
    slope = slope_range,
    slope_differences = slope_differences_range
  )
}
