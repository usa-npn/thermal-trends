# library(ggplot2)
# library(tidyterra)
# library(targets)
# library(cols4all)
# tar_load(starts_with("doy_summary"))
# tar_load(roi)

# dots <- rlang::dots_list(
#   doy_summary_50,
#   doy_summary_350,
#   doy_summary_650,
#   doy_summary_1250,
#   doy_summary_1950,
#   doy_summary_2500,
#   .named = TRUE
# )

#' Plot pixel-wise linear slopes
#'
#' Currently plots each threshold on it's own scale with the limits of the scale
#' encompasing 99% of the data points with more extreme values being lumped in
#' with the limits
#'
#' @param roi the roi target (a `SpatVector` of NE US)
#' @param ... doy_summary_{threshold} targets
#' @param use_percentile_lims use limits that capture 99% of the DOY values.
#'
plot_linear_slopes <- function(roi, ..., use_percentile_lims = TRUE) {
  dots <- rlang::dots_list(..., .named = TRUE)
  thresholds <- stringr::str_extract(names(dots), "\\d+")
  stack <-
    dots |>
    purrr::map(\(x) {
      mask(x[["slope"]], x[["count"]] >= 10, maskvalue = FALSE) #at least 10 non-NA years for reliable slopes
    }) |>
    terra::rast()
  names(stack) <- thresholds

  limits <- c(NA, NA)
  if (use_percentile_lims) {
    limits <- stack |>
      terra::values() |>
      quantile(probs = c(0.005, 0.995), na.rm = TRUE)
  }

  roi <- terra::project(roi, stack)
  p <-
    ggplot() +
    geom_spatvector(data = roi, fill = "white") +
    geom_spatraster(data = stack) +
    facet_wrap(vars(lyr)) +
    colorspace::scale_fill_continuous_diverging(
      palette = "Purple-Brown",
      rev = TRUE,
      na.value = "transparent",
      limits = limits,
      oob = scales::oob_squish,
      breaks = breaks_limits(
        n = 5,
        min = !is.na(limits[1]),
        max = !is.na(limits[2]),
        tol = 0.15
      )
    ) +
    #n.breaks only works in current dev version of ggplot2: https://github.com/tidyverse/ggplot2/pull/5442
    scale_x_continuous(n.breaks = 5) +
    scale_y_continuous(n.breaks = 5) +
    labs(
      fill = "Linear slope (DOY yr<sup>-1</sup>)"
    ) +
    # coord_sf(crs = "ESRI:102010") +
    theme_minimal() +
    theme(
      strip.background = element_rect(fill = "white"),
      axis.title = element_blank(),
      legend.title = element_markdown()
    )
  # p

  ggplot2::ggsave(
    filename = "linear_slopes.png",
    plot = p,
    path = "output/linear-slopes/",
    bg = "white",
    width = 9.5,
    height = 5
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
