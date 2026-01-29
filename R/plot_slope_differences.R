# library(targets)
# library(terra)
# library(tidyterra)
# library(ggplot2)
# library(purrr)
# library(colorspace)

# tar_load(c(
#   slope_differences
#   roi
# ))

#' Plot differences in slopes between thresholds
#'
#' Plots the differences in slopes between sucessive thresholds optionally
#' dividing by the difference in degree days between thresholds to put all maps
#' on the same scale.
#'
#' @param roi the `roi` target (shapefile of NE America)
#' @param slope_differences the `slope_differences` target
#' @param use_percentile_lims use the 0.005 and 0.995 quantiles of the data for
#'   the scale limits and squish values outside of those bounds to have the same
#'   colors as the limits.  Defaults to `TRUE`.
plot_slope_differences <- function(
  roi,
  slope_differences,
  use_percentile_lims = TRUE
) {
  limits <- c(NA, NA)
  if (use_percentile_lims) {
    vals <- slope_differences |>
      terra::values()

    #original limits
    o_lims <- round(range(vals, na.rm = TRUE), 4)
    cli::cli_alert_info("original limits: {o_lims[1]}, {o_lims[2]}")

    limits <- vals |>
      quantile(probs = c(0.005, 0.995), na.rm = TRUE)
  }

  roi <- terra::project(roi, slope_differences)

  p <- ggplot() +
    # use white for NA because this color palette has grey in the middle
    geom_spatvector(data = roi, fill = "white", color = NA) +
    geom_spatraster(data = slope_differences) +
    geom_spatvector(data = roi, fill = NA, color = "grey50") +
    facet_wrap(vars(lyr)) +
    colorspace::scale_fill_continuous_diverging(
      palette = "Purple-Green",
      rev = TRUE,
      na.value = "transparent",
      limits = limits,
      oob = scales::oob_squish,
      breaks = breaks_limits(
        n = 5,
        min = !is.na(limits[1]),
        max = !is.na(limits[2]),
        tol = 0.1,
        digits = 1,
        scientific = any(abs(limits) < 0.1)
      )
    ) +
    labs(fill = "days/decade") +
    #n.breaks only works in current dev version of ggplot2: https://github.com/tidyverse/ggplot2/pull/5442
    scale_x_continuous(n.breaks = 5) +
    scale_y_continuous(n.breaks = 5) +
    theme_minimal() +
    theme(
      strip.background = element_rect(fill = "white"),
      axis.title = element_blank(),
      legend.title = element_markdown()
    )

  # p

  ggplot2::ggsave(
    filename = "slopes-differences.png",
    plot = p,
    path = "output/linear-slopes/",
    bg = "white",
    width = 9.5,
    height = 5
  )

  out <- ggplot2::ggsave(
    filename = "slopes-differences.pdf",
    plot = p,
    device = cairo_pdf,
    path = "output/linear-slopes/",
    bg = "white",
    width = 9.5,
    height = 5
  )

  embedFonts(out)
  out
}
