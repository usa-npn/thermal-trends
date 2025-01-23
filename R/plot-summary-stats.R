#' Plot mean DOY to reach a GDD threshold
#' 
#' @param raster raster containing a single layer with mean DOY for a particular threshold.
#' @param range length 2 numeric vector; used to manually set limits for scale_fill.
#' @examples 
#'   plot_mean_doy(gdd_doy_mean_650)
#' 
plot_mean_doy <- function(raster, range = NULL) {
  raster_name <- deparse(substitute(raster))
  threshold <- stringr::str_extract(raster_name, "\\d+")
  p <- ggplot2::ggplot() +
    tidyterra::geom_spatraster(data = raster) +
    ggplot2::scale_fill_viridis_c(na.value = "transparent", limits = range) +
    ggplot2::labs(
      title = glue::glue("Mean DOY that {threshold} GDD is reached"),
      fill = "mean DOY",
      x = "",
      y = ""
    ) +
    # coord_sf(crs = "ESRI:102010") +
    ggplot2::theme_minimal()
  
  ggplot2::ggsave(
    filename = paste0(raster_name, ".png"),
    plot = p, 
    path = "output/gams/",
    bg = "white",
    width = 7,
    height = 5
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
    filename = paste0(raster_name, ".png"),
    plot = p, 
    path = "output/gams/",
    bg = "white",
    width = 7,
    height = 5
  )
}

