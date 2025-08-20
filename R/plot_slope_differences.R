# library(targets)
# library(terra)
# library(tidyterra)
# library(ggplot2)
# library(purrr)
# library(colorspace)

# tar_load(c(
#   starts_with("doy_summary"),
#   roi
# ))

# dots <- rlang::dots_list(
#   doy_summary_50,
#   doy_summary_650,
#   doy_summary_350,
#   doy_summary_1250,
#   doy_summary_1950,
#   doy_summary_2500,
#   .named = TRUE
# )

#' Plot differences in slopes between thresholds
#'
#' Plots the differences in slopes between sucessive thresholds optionally
#' dividing by the difference in degree days between thresholds to put all maps
#' on the same scale.
#'
#' @param roi the `roi` target (shapefile of NE America)
#' @param ... the `doy_summary_*` targets; summay rasters for different
#'   thresholds each with at least a "slope" and "count" layer
#' @param correct_diff divide by difference between thresholds?  If `TRUE`, units
#'   will be days per year per ºF.  If `FALSE` (default), results will be in units of
#'   days per decade.
#' @param use_percentile_lims use the 0.005 and 0.995 quantiles of the data for
#'   the scale limits and squish values outside of those bounds to have the same
#'   colors as the limits.  Defaults to `TRUE`.
plot_slope_differences <- function(
  roi,
  ...,
  correct_diff = FALSE,
  use_percentile_lims = TRUE
) {
  dots <- rlang::dots_list(..., .named = TRUE)
  slopes_list <- dots |>
    purrr::map(\(x) {
      #at least 10 non-NA years for reliable slopes
      mask(x[["slope"]], x[["count"]] >= 10, maskvalue = FALSE)
    })

  thresholds <- names(slopes_list) |>
    stringr::str_extract("\\d+") |>
    as.numeric()
  #rename using thresholds
  names(slopes_list) <- thresholds

  #Order by list by threshold.
  slopes_list <- slopes_list[order(thresholds)]

  d_slopes <- map2(slopes_list, dplyr::lead(slopes_list), \(x_1, x_2) {
    if (!is.null(x_2)) {
      thr_1 <- x_1 |> varnames() |> stringr::str_extract("\\d+") |> as.numeric()
      thr_2 <- x_2 |> varnames() |> stringr::str_extract("\\d+") |> as.numeric()

      if (correct_diff) {
        (x_2 - x_1) / (thr_2 - thr_1)
      } else {
        (x_2 - x_1) * 10 #convert to days/decade
      }
    } else {
      NULL
    }
  }) |>
    set_names(paste(
      dplyr::lead(names(slopes_list)),
      "-",
      names(slopes_list)
    )) |>
    compact()

  # also add the max - min GDD
  if (correct_diff) {
    d_full_range <- list(
      (slopes_list[[length(slopes_list)]] - slopes_list[[1]]) /
        (max(thresholds) - min(thresholds))
    )
  } else {
    d_full_range <- list(
      (slopes_list[[length(slopes_list)]] - slopes_list[[1]]) * 10 #days/decade
    )
  }
  names(d_full_range) <- paste(max(thresholds), "-", min(thresholds))

  # add the last one and convert to raster
  d_slopes <- append(d_slopes, d_full_range)

  d_slopes <- rast(d_slopes)

  limits <- c(NA, NA)
  if (use_percentile_lims) {
    vals <- d_slopes |>
      terra::values()

    #original limits
    o_lims <- round(range(vals, na.rm = TRUE), 4)
    cli::cli_alert_info("original limits: {o_lims[1]}, {o_lims[2]}")

    limits <- vals |>
      quantile(probs = c(0.005, 0.995), na.rm = TRUE)
  }

  roi <- terra::project(roi, d_slopes)
  color_lab <- if (correct_diff) {
    "d yr<sup>-1</sup> ºF<sup>-1<sup>"
  } else {
    "days/decade"
  }
  p <- ggplot() +
    tidyterra::geom_spatvector(data = roi, fill = "white") +
    tidyterra::geom_spatraster(data = d_slopes) +
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
    labs(fill = color_lab) +
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
}
