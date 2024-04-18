plot_normals_sd <- function(normals_summary, threshold, out_dir = "output/figs", ext = "png", ...) {
  fs::dir_create(out_dir)
  p <-
    ggplot() +
    geom_spatraster(data = normals_summary, aes(fill = sd)) +
    scale_fill_viridis_c(na.value = "transparent", option = "D") +
    labs(title = glue::glue("SD in DOY to reach > {threshold} GDD"),
         subtitle = "1991-2020", fill = "Days") +
    theme_minimal()
  
  filename <- glue::glue("normals_sd_{threshold}.{ext}")
  ggsave(filename = filename, path = out_dir, plot = p, ...)
}