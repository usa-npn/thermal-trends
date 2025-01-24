#' Plot mean/min/max DOY to reach a GDD threshold
#' 
#' @param raster raster containing a single layer with mean/min/max DOY for a particular threshold.
#' @param range length 2 numeric vector; used to manually set limits for scale_fill.
#' @examples 
#'   plot_mean_doy(gdd_doy_mean_650)
#' 
plot_summary_doy <- function(raster, range = NULL) {
  raster_name <- deparse(substitute(raster))
  threshold <- stringr::str_extract(raster_name, "\\d+")
  p <- ggplot2::ggplot() +
    tidyterra::geom_spatraster(data = raster) +
    ggplot2::scale_fill_viridis_c(
      option = "A", #magma
      direction = -1, #reversed so earlier DOY is "hotter"
      end = 0.85, #don't use as much of the yellow end because it's hard to see
      na.value = "transparent",
      limits = range
    ) +
    ggplot2::labs(
      fill = "DOY"
    ) +
    # coord_sf(crs = "ESRI:102010") +
    ggplot2::theme_minimal()
  # return:
  p
  # ggplot2::ggsave(
  #   filename = paste0(raster_name, ".png"),
  #   plot = p, 
  #   path = "output/gams/",
  #   bg = "white",
  #   width = 7,
  #   height = 5
  # )
}

plot_summary_combined <- function(min, mean, max, range) {
  p_min <- plot_summary_doy(min, range = range)
  p_mean <- plot_summary_doy(mean, range = range)
  p_max <- plot_summary_doy(max, range = range)
  
  #extract threshold
  threshold <- stringr::str_extract(deparse(substitute(mean)), "\\d+")
  p <- 
    (p_min +  labs(subtitle = "minimum")) +
    (p_mean + labs(subtitle = "mean")) +
    (p_max +  labs(subtitle = "maximum")) +
    patchwork::plot_layout(guides = "collect", axes = "collect") +
    patchwork::plot_annotation(title = glue::glue("DOY to reach {threshold} GDD"))

  ggplot2::ggsave(
    filename = glue::glue("min_mean_max_{threshold}.png"),
    plot = p, 
    path = "output/gams/",
    width = 10,
    height = 3
  )

}


plot_sd_doy <- function(raster, range = NULL) {
  raster_name <- deparse(substitute(raster))
  threshold <- stringr::str_extract(raster_name, "\\d+")
  p <- ggplot2::ggplot() +
    tidyterra::geom_spatraster(data = raster) +
    ggplot2::scale_fill_viridis_c(na.value = "transparent") +
    ggplot2::labs(
      title = glue::glue("Standard deviation in DOY that {threshold} GDD is reached"),
      fill = "±days",
      x = "",
      y = ""
    ) +
    # coord_sf(crs = "ESRI:102010") +
    ggplot2::theme_minimal()

  ggplot2::ggsave(
    filename = glue::glue("sd_{threshold}.png"),
    plot = p, 
    path = "output/gams/",
    bg = "white",
    width = 7,
    height = 5
  )
}

