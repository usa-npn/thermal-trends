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
  df <-
    purrr::imap(dots, function(raster, name) {
      raster |>
        tidyterra::select(count) |>
        tidyterra::as_tibble(raster, xy = TRUE, na.rm = TRUE) |>
        #get threshold from target name
        dplyr::mutate(GDD = as.numeric(stringr::str_extract(name, "\\d+")))
    }) |>
    purrr::list_rbind() |>
    rename(count = lyr.1) |>
    mutate(prop = count / max(count))

  p <- ggplot(df) +
    facet_wrap(vars(GDD), labeller = label_both) +
    tidyterra::geom_spatvector(data = roi) +
    geom_raster(aes(x = x, y = y, fill = count)) +
    # scale_fill_binned_sequential() +
    scale_fill_continuous_sequential() +
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
