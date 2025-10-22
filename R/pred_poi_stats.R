pred_poi_stats <- function(poi, ...) {
  dots <- rlang::dots_list(..., .named = TRUE)

  poi_pred_doy <- purrr::map(dots, \(stack) {
    bind_cols(as_tibble(poi), terra::extract(stack, poi, ID = FALSE)) |>
      pivot_longer(
        -label,
        names_to = "year",
        values_to = "doy",
        names_transform = list(year = as.integer)
      ) |>
      group_by(label) |>
      # mutate(year_scaled = year - min(year, na.rm = TRUE)) |>
      nest() |>
      mutate(
        lm = purrr::map(data, \(x) {
          if (sum(is.finite(x$doy)) > 10) {
            lm(doy ~ year, data = x)
          } else {
            NA
          }
        })
      ) |>
      mutate(
        pred_1981 = map_dbl(lm, \(x) {
          if (inherits(x, "lm")) {
            predict(x, newdata = list(year = 1981))
          } else {
            NA_real_
          }
        }),
        pred_2023 = map_dbl(lm, \(x) {
          if (inherits(x, "lm")) {
            predict(x, newdata = list(year = 2023))
          } else {
            NA_real_
          }
        })
      ) |>
      dplyr::select(-data, -lm) |>
      ungroup()
  })

  out <- poi_pred_doy |>
    list_rbind(names_to = "stack") |>
    separate(stack, into = c("trash", "threshold")) |>
    select(-trash) |>
    mutate(threshold = as.integer(threshold))

  out
}
