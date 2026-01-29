#' Map standard deviation in DOY that GDD thresholds are reached
#'
#' @param roi the roi target (a `SpatVector` of the NE US)
#' @param ... `SpatRaster`s created by [calc_doy_summary()]
#'
plot_sd_doy <- function(roi, ...) {
  dots <- rlang::dots_list(..., .named = TRUE)
  thresholds <- stringr::str_extract(names(dots), "\\d+")

  stack <- purrr::map(dots, function(raster) {
    raster[["sd"]]
  }) |>
    terra::rast()
  names(stack) <- thresholds

  p <- ggplot() +
    facet_wrap(vars(lyr)) +
    geom_spatvector(data = roi, fill = "grey95", color = NA) +
    tidyterra::geom_spatraster(data = stack) +
    geom_spatvector(data = roi, fill = NA, color = "grey50") +
    ggplot2::scale_fill_viridis_c(na.value = "transparent") +
    #n.breaks only works in current dev version of ggplot2: https://github.com/tidyverse/ggplot2/pull/5442
    scale_x_continuous(n.breaks = 5) +
    scale_y_continuous(n.breaks = 5) +
    ggplot2::labs(
      # title = glue::glue("Standard deviation in DOY that {threshold} GDD is reached"),
      fill = "sd (±days)"
    ) +
    # coord_sf(crs = "ESRI:102010") +
    ggplot2::theme_minimal() +
    theme(
      axis.title = element_blank(),
      strip.background = element_rect(fill = "white")
    )

  ggplot2::ggsave(
    filename = "stdev.png",
    plot = p,
    path = "output/summary_stats/",
    bg = "white",
    width = 9.5,
    height = 5
  )

  out <- ggplot2::ggsave(
    filename = "stdev.pdf",
    plot = p,
    device = cairo_pdf,
    path = "output/summary_stats/",
    bg = "white",
    width = 9.5,
    height = 5
  )

  embedFonts(out)
  out
}
