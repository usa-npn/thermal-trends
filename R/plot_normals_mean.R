plot_normals_mean <- function(normals_summary, threshold, out_dir = "output/figs", ext = "png", ...) {
  fs::dir_create(out_dir)
  has_inf <- any(is.infinite(values(normals_summary)))
  p <-
    ggplot() +
    geom_spatraster(data = normals_summary, aes(fill = mean)) +
    scale_fill_viridis_c(
      na.value = "transparent", option = "B",
      direction = -1, #earlier DOY = hotter color
      end = 0.9, #don't use the lightest yellow—hard to see on white background
      oob = scales::oob_squish_infinite,
      breaks = breaks_limits(
        n = 7,
        min = FALSE,
        max = has_inf,
        tol = 0.15
      ),
      labels = \(x) names(x)
    ) +
    labs(title = glue::glue("DOY to reach > {threshold} GDD"),
         subtitle = "Mean of 1991-2020", fill = "DOY") +
    theme_minimal()
  
  if (isTRUE(has_inf)) {
    p <- p + labs(caption= glue::glue(
      "Note: Pixels that never reach {threshold} GDD in *all* years are lumped in with the maximum DOY color."
      ))
  }
  
  filename <- glue::glue("normals_mean_{threshold}.{ext}")
  ggsave(filename = filename, path = out_dir, plot = p, bg="white", ...)
}
