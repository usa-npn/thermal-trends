plot_slopes <- function(doy_trend, gdd_threshold) {
  p <- ggplot() +
    geom_spatraster(data = doy_trend, aes(fill = slope)) +
    #reverse direction so negative slopes (earlier DOY) are red and positive slopes are blue
    scale_fill_continuous_diverging(na.value = "transparent", rev = TRUE) +
    labs(title = glue::glue("Trend in DOY to reach > {gdd_threshold} GDD"),
         fill = "∆ DOY") +
    theme_minimal()
  
  ggsave(filename = glue::glue("output/slopes_{gdd_threshold}.png"), plot = p)
}