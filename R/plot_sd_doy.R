plot_sd_doy <- function(raster, roi, range = NULL) {
  raster_name <- deparse(substitute(raster))
  threshold <- stringr::str_extract(raster_name, "\\d+")
  p <- ggplot2::ggplot() +
    tidyterra::geom_spatvector(data = roi) +
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

