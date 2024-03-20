plot_doy <- function(gdd_stack, gdd_threshold) {
  p <- ggplot() +
    geom_spatraster(data = gdd_stack) +
    scale_fill_viridis_c(na.value = "transparent", direction = -1) +
    facet_wrap(~lyr) +
    labs(
      title = glue::glue("Days to reach > {gdd_threshold} GDD"),
      fill = "DOY"
    ) +
    theme_minimal()

  ggsave(filename = glue::glue("output/doy_{gdd_threshold}.png"), plot = p)
}