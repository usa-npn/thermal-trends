plot_normals_sd <- function(normals_summary, threshold, path = "output/", ext = "png", ...) {
  p <-
    ggplot() +
    geom_spatraster(data = normals_summary, aes(fill = sd)) +
    scale_fill_viridis_c(na.value = "transparent", option = "D") +
    labs(title = glue::glue("SD in DOY to reach > {threshold} GDD"),
         subtitle = "1991-2020", fill = "Days") +
    theme_minimal()
  
  filename <- glue::glue("normals_sd_{threshold}.{ext}")
  ggsave(filename = filename, path = path, plot = p, ...)
}