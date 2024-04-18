plot_slopes <- function(doy_trend, threshold, out_dir = "output/figs", ext = "png", ...) {
  p <- ggplot() +
    geom_spatraster(data = doy_trend, aes(fill = slope)) +
    #reverse direction so negative slopes (earlier DOY) are red and positive slopes are blue
    scale_fill_continuous_diverging(na.value = "transparent", rev = TRUE) +
    labs(title = glue::glue("Trend in DOY to reach > {threshold} GDD"),
         fill = "∆ DOY") +
    theme_minimal()
  filename <- glue::glue("slopes_{threshold}.{ext}")
  ggsave(filename = filename, path = out_dir, plot = p, ...)
}