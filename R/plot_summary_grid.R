# library(targets)
# library(ggplot2)
# library(patchwork)
# library(purrr)
# library(dplyr)

#combine all the targets and plot with facet_grid()

plot_summary_grid <- function(roi, ...) {
  
  # tar_load(c(starts_with("doy_mean"), starts_with("doy_min"), starts_with("doy_max")))
  # dots <- rlang::dots_list(doy_min_50, doy_mean_50, doy_max_50, doy_min_650, doy_mean_650, doy_max_650, .named = TRUE)
  dots <- rlang::dots_list(..., .named = TRUE)
  df <- purrr::imap(dots, function(raster, name) {
    tidyterra::as_tibble(raster, xy = TRUE, wide = FALSE, na.rm = TRUE) |> 
    #get threshold from target name
    dplyr::mutate(GDD = as.numeric(stringr::str_extract(name, "\\d+")))
  }) |> 
  purrr::list_rbind() |> 
    # re-order & rename factors
    dplyr::mutate(layer = factor(layer, levels = c("min", "mean", "max")))
  
  p <- ggplot(df) +
    # coord_sf(crs = terra::crs(dots[[1]])) + #assume same crs for all maps
    tidyterra::geom_spatvector(data = roi) +
    geom_raster(aes(x = x, y = y, fill = values)) +
    facet_grid(rows = vars(GDD), cols = vars(layer)) +
    ggplot2::scale_fill_viridis_c(
      option = "A", #magma
      direction = -1, #reversed so earlier DOY is "hotter"
      end = 0.85, #don't use as much of the yellow end because it's hard to see
      na.value = "transparent"
    ) +
    #n.breaks only works in current dev version of ggplot2: https://github.com/tidyverse/ggplot2/pull/5442
    scale_x_continuous(n.breaks = 5) + 
    scale_y_continuous(n.breaks = 5) +
    ggplot2::labs(
      fill = "DOY"
    ) +
    ggplot2::theme_minimal() +
    theme(axis.title = element_blank(), strip.background = element_rect(fill = "white"))
  
  ggsave(
    "summary_stats_plot.png",
    plot = p,
    path = "output/summary_stats",
    bg = "white"
  )
}