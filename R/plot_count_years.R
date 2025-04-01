# library(targets)
# library(terra)
# library(tidyterra)
# tar_load(starts_with("doy_count"))

#' Map the number of years each pixel reached a threshold GDD
#'
#' @param roi the roi target (a `SpatVector` of the NE US)
#' @param ... `SpatRaster`s produced by [calc_doy_summary()]
#'
plot_count_years <- function(roi, ...) {
  dots <- rlang::dots_list(..., .named = TRUE)
  thresholds <- stringr::str_extract(names(dots), "\\d+")
  stack <-
    purrr::map(dots, function(raster) {
      raster[["count"]]
    }) |>
    terra::rast()
  names(stack) <- thresholds

  p <- ggplot() +
    facet_wrap(vars(lyr)) +
    tidyterra::geom_spatvector(data = roi) +
    tidyterra::geom_spatraster(data = stack) +
    # scale_fill_binned_sequential() +
    scale_fill_continuous_sequential(
      na.value = "transparent"
    ) +
    labs(fill = "N years") +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      strip.background = element_rect(fill = "white")
    )

  ggplot2::ggsave(
    filename = "count.png",
    plot = p,
    path = "output/summary_stats/",
    bg = "white",
    width = 9.5,
    height = 5
  )
}
