#' Map standard deviation in DOY that GDD thresholds are reached
#'
#' @param roi the roi target (a `SpatVector` of the NE US)
#' @param ... `SpatRaster`s created by [calc_doy_summary()]
#'
plot_sd_doy <- function(roi, ...) {
  dots <- rlang::dots_list(..., .named = TRUE)
  df <- purrr::imap(dots, function(raster, name) {
    raster |>
      tidyterra::select("sd") |>
      tidyterra::as_tibble(xy = TRUE, na.rm = TRUE) |>
      #get threshold from target name
      dplyr::mutate(GDD = as.numeric(stringr::str_extract(name, "\\d+")))
  }) |>
    purrr::list_rbind()

  p <- ggplot(df) +
    facet_wrap(vars(GDD), labeller = label_both) +
    tidyterra::geom_spatvector(data = roi) +
    geom_raster(aes(x = x, y = y, fill = std)) +
    ggplot2::scale_fill_viridis_c(na.value = "transparent") +
    ggplot2::labs(
      # title = glue::glue("Standard deviation in DOY that {threshold} GDD is reached"),
      fill = "sd (±days)"
    ) +
    #n.breaks only works in current dev version of ggplot2: https://github.com/tidyverse/ggplot2/pull/5442
    scale_x_continuous(n.breaks = 5) +
    scale_y_continuous(n.breaks = 5) +
    # coord_sf(crs = "ESRI:102010") +
    ggplot2::theme_minimal() +
    theme(
      axis.title = element_blank(),
      strip.background = element_rect(fill = "white")
    )

  ggplot2::ggsave(
    filename = "stdev.png",
    plot = p,
    path = "output/summary_stats/",
    bg = "white",
    width = 9.5,
    height = 5
  )
}
