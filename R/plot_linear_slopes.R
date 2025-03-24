# library(ggplot2)
# library(tidyterra)
# library(targets)
# library(colorspace)
# tar_load(starts_with("linear_slopes"))
# tar_load(linear_slope_limits)
# tar_load(roi)

# dots <- rlang::dots_list(linear_slopes_50, linear_slopes_650, linear_slopes_1250, linear_slopes_1950, linear_slopes_2500, .named = TRUE)

#' @param ... linear_slopes_{threshold} targets
#' @param limits the limits used for the fill scale.  Use `NA` for the lower, 
#'   upper, or both limits to use the range of the data.  Specify as numeric to 
#'   override.
#' @param use_percentile_lims ignore any input for `limits` and instead use 
#'   limits that capture 95% of the DOY values.
plot_linear_slopes <- function(..., roi, limits = c(NA, NA), use_percentile_lims = TRUE) {
  dots <- rlang::dots_list(..., .named = TRUE)
  thresholds <- stringr::str_extract(names(dots), "\\d+")
  stack <- terra::rast(dots)
  names(stack) <- thresholds
  range <- range(terra::values(stack), na.rm = TRUE)
  limits <- dplyr::coalesce(limits, range)

  if(use_percentile_lims) {
    #what if we want to use (global) 95%ile for limits?
    limits <- stack |> terra::values() |> quantile(probs = c(0.025, 0.975), na.rm = TRUE)
    # TODO:
    # hmm, this emphasizes the negative slopes more than positive because negative
    # slopes are more common over all thresholds.  Maybe better to do this on a 
    # per-threshold basis and then stitch together with patchwork instead
  }

  p <- ggplot() +
    facet_wrap(vars(lyr)) +
    geom_spatvector(data = roi, fill = "white") +
    geom_spatraster(data = stack) +
    scale_fill_continuous_diverging(
      na.value = "transparent", 
      rev = TRUE, 
      limits = limits,
      oob = scales::oob_squish,
      breaks = breaks_limits(
        n = 5,
        min = !is.na(limits[1]),
        max = !is.na(limits[2]),
        tol = 0.15
      )
    ) +
    labs(
      fill = "Linear slope (DOY/yr)"
    ) +
    # coord_sf(crs = "ESRI:102010") +
    theme_minimal()
  # p

  ggplot2::ggsave(
    filename = "linear_slopes.png",
    plot = p,
    path = "output/linear-slopes/",
    bg = "white",
    width = 9,
    height = 4.5
  )
}

# plot_linear_slopes(linear_slopes_50, c(NA, NA))
# plot_linear_slopes(linear_slopes_650, linear_slope_limits)
# plot_linear_slopes(linear_slopes_1250, linear_slope_limits)
# plot_linear_slopes(linear_slopes_1950, linear_slope_limits)
# plot_linear_slopes(linear_slopes_2500, linear_slope_limits)


# #global range
# plot_linear_slopes(linear_slopes_1950, linear_slope_limits)
# #range for just this threshold
# plot_linear_slopes(linear_slopes_1950, c(NA, NA))
# #arbitrary narrower range
# plot_linear_slopes(linear_slopes_1950, c(-0.5, 0.5))