#' Use survival regression to estimate slope and mean DOY to reach thresholds.
#'
#' @param stack a SpatRaster with one year per layer and values of DOY to reach
#'   threshold with `NA` for pixels that didn't reach the threshold in a
#'   particular year.
#' @param roi a SpatVector defining the ROI `stack` is already cropped to.
#' @param min_events a minimum number of years the threshold is reached in order
#'   to calculate a slope and mean.
calc_surv_summary <- function(stack, roi, min_events = 10) {
  # being extra safe here and not assuming every year is represented
  year <- as.integer(names(stack))
  # scale
  year_scaled <- year - min(year, na.rm = TRUE)
  n <- length(year)

  # Create layers for censored DOY and censored indicator
  event <- terra::ifel(is.na(stack), 0, 1) |> terra::mask(roi)
  survdoy <- terra::ifel(is.na(stack), 365, stack) |> terra::mask(roi)
  # Stack layers
  stack_surv_event <- c(survdoy, event) # layers 1:n = DOY; layers (n+1):2n = event

  terra::app(stack_surv_event, \(v) {
    time <- v[1:n]
    status <- v[(n + 1):(2 * n)]
    if (sum(status == 1, na.rm = TRUE) >= min_events) {
      ok <- is.finite(time) & is.finite(status)
      slope_fit <- tryCatch(
        survival::survreg(
          survival::Surv(time[ok], status[ok]) ~ year_scaled[ok],
          dist = "gaussian"
        ),
        error = function(e) NULL
      )
      slope <- unname(coef(slope_fit)[2]) %||% NA_real_
    } else {
      slope <- NA_real_
    }
    # and only do the rest of the stats if there is at least 1 non-NA value
    if (sum(status, na.rm = TRUE) == 0) {
      out <- c(
        min = NA,
        max = NA,
        mean = NA,
        sd = NA,
        count = NA,
        slope = slope
      )
    } else {
      out <- c(
        min = min(time[status == 1], na.rm = TRUE),
        max = max(time[status == 1], na.rm = TRUE),
        mean = mean(time[status == 1], na.rm = TRUE),
        sd = sd(time[status == 1], na.rm = TRUE),
        count = sum(status),
        slope = slope
      )
    }
    out
  })
}
