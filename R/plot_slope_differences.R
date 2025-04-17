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

plot_slope_differences <- function(roi, ..., use_percentile_lims = TRUE) {
  dots <- rlang::dots_list(..., .named = TRUE)
  slopes_list <- dots |>
    purrr::map(\(x) {
      mask(x[["slope"]], x[["count"]] >= 10, maskvalue = FALSE) #at least 10 non-NA years for reliable slopes
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

      (x_2 - x_1) / (thr_2 - thr_1)
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

  #also add the max - min GDD
  d_full_range <- list(
    (slopes_list[[length(slopes_list)]] - slopes_list[[1]]) /
      (max(thresholds) - min(thresholds))
  )
  names(d_full_range) <- paste(max(thresholds), "-", min(thresholds))

  #add the last one and convert to raster
  d_slopes <- append(d_slopes, d_full_range)

  d_slopes <- rast(d_slopes)

  limits <- c(NA, NA)
  if (use_percentile_lims) {
    limits <- d_slopes |>
      terra::values() |>
      quantile(probs = c(0.005, 0.995), na.rm = TRUE)
  }

  roi <- terra::project(roi, d_slopes)

  p <- ggplot() +
    geom_spatvector(data = roi) +
    geom_spatraster(data = d_slopes) +
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
        digits = 3,
        scientific = TRUE
      )
    ) +
    labs(
      fill = "DOY yr<sup>-1</sup> ºF<sup>-1<sup>"
    ) +
    #n.breaks only works in current dev version of ggplot2: https://github.com/tidyverse/ggplot2/pull/5442
    scale_x_continuous(n.breaks = 5) +
    scale_y_continuous(n.breaks = 5) +
    theme_minimal() +
    theme(
      strip.background = element_rect(fill = "white"),
      axis.title = element_blank(),
      legend.title = element_markdown()
    )

  ggplot2::ggsave(
    filename = "slopes-differences.png",
    plot = p,
    path = "output/linear-slopes/",
    bg = "white",
    width = 9.5,
    height = 5
  )
}
