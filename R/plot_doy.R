plot_doy <- function(gdd_stack, threshold, out_dir = "output/figs", ext = "png", ...) {
  fs::dir_create(out_dir)
  p <- ggplot() +
    geom_spatraster(data = gdd_stack) +
    scale_fill_viridis_c(
      na.value = "transparent", option = "B",
      direction = -1, #earlier DOY = hotter color
      end = 0.9 #don't use the lightest yellow—hard to see on white background
    ) +    facet_wrap(~lyr) +
    labs(
      title = glue::glue("Days to reach > {threshold} GDD"),
      fill = "DOY"
    ) +
    theme_minimal()
  filename <- glue::glue("doy_{threshold}.{ext}")
  ggsave(filename = filename, path = out_dir, plot = p, ...)
}