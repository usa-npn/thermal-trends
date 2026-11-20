pred_poi_stats <- function(poi, ..., min_events = 10) {
  dots <- rlang::dots_list(..., .named = TRUE)

  poi_pred_doy <- purrr::map(dots, \(stack) {
    bind_cols(as_tibble(poi), terra::extract(stack, poi, ID = FALSE)) |>
      pivot_longer(
        -label,
        names_to = "year",
        values_to = "doy",
        names_transform = list(year = as.integer)
      ) |>
      # Set up for survival regression
      mutate(
        event = if_else(doy <= 365, true = TRUE, false = FALSE, missing = FALSE)
      ) |>
      mutate(doy = if_else(doy > 365 | is.na(doy), 365, doy)) |>
      mutate(year_scaled = year - 1981) |>
      group_by(label) |>
      nest() |>
      mutate(
        fit = purrr::map(data, \(x) {
          if (sum(x$event) > min_events) {
            survival::survreg(
              survival::Surv(doy, event) ~ year_scaled,
              dist = "gaussian",
              data = x
            )
          } else {
            NA
          }
        })
      ) |>
      mutate(
        pred_1981 = map_dbl(fit, \(x) {
          if (inherits(x, "survreg")) {
            predict(x, newdata = list(year_scaled = 1981 - 1981))
          } else {
            NA_real_
          }
        }),
        pred_2023 = map_dbl(fit, \(x) {
          if (inherits(x, "survreg")) {
            predict(x, newdata = list(year_scaled = 2023 - 1981))
          } else {
            NA_real_
          }
        })
      ) |>
      dplyr::select(-data, -fit) |>
      ungroup()
  })

  out <- poi_pred_doy |>
    list_rbind(names_to = "stack") |>
    mutate(
      threshold = stringr::str_split_i(stack, pattern = "_", i = -1) |>
        as.integer(),
      .keep = "unused"
    )

  out
}
