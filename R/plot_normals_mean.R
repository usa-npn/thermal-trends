# library(targets)
# tar_load_globals()
# tar_load(normals_summary_50)
# threshold <- 50

plot_normals_mean <- function(normals_summary, threshold, path = "output/", ext = "png", ...) {
  p <-
    ggplot() +
    geom_spatraster(data = normals_summary, aes(fill = mean)) +
    scale_fill_viridis_c(
      na.value = "transparent", option = "B",
      direction = -1, #earlier DOY = hotter color
      end = 0.9 #don't use the lightest yellow—hard to see on white background
    ) +
    labs(title = glue::glue("DOY to reach > {threshold} GDD"),
         subtitle = "Mean of 1991-2020", fill = "DOY") +
    theme_minimal()
  
  filename <- glue::glue("normals_mean_{threshold}.{ext}")
  ggsave(filename = filename, path = path, plot = p, ...)
}