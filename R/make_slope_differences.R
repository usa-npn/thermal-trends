# library(targets)
# library(terra)
# tar_load(c(
#   starts_with("doy_summary"),
#   roi
# ))

# dots <- rlang::dots_list(
#   doy_summary_50,
#   doy_summary_650,
#   doy_summary_350,
#   doy_summary_1250,
#   doy_summary_1950,
#   doy_summary_2500,
#   .named = TRUE
# )

make_slope_differences <- function(...) {
  dots <- rlang::dots_list(..., .named = TRUE)
  slopes_list <- dots |>
    purrr::map(\(x) {
      #at least 10 non-NA years for reliable slopes
      terra::mask(x[["slope"]], x[["count"]] >= 10, maskvalue = FALSE)
    })

  thresholds <- names(slopes_list) |>
    stringr::str_extract("\\d+") |>
    as.numeric()
  #rename using thresholds
  names(slopes_list) <- thresholds

  #Order by list by threshold.
  slopes_list <- slopes_list[order(thresholds)]

  d_slopes <- purrr::map2(slopes_list, dplyr::lead(slopes_list), \(x_1, x_2) {
    if (!is.null(x_2)) {
      thr_1 <- x_1 |> varnames() |> stringr::str_extract("\\d+") |> as.numeric()
      thr_2 <- x_2 |> varnames() |> stringr::str_extract("\\d+") |> as.numeric()
      (x_2 - x_1) * 10 #convert to days/decade
    } else {
      NULL
    }
  }) |>
    purrr::set_names(paste(
      dplyr::lead(names(slopes_list)),
      "-",
      names(slopes_list)
    )) |>
    purrr::compact()

  # also add the max - min GDD
  d_full_range <- list(
    (slopes_list[[length(slopes_list)]] - slopes_list[[1]]) * 10 #days/decade
  )

  names(d_full_range) <- paste(max(thresholds), "-", min(thresholds))

  # add the last one and convert to raster
  d_slopes <- append(d_slopes, d_full_range)
  names <- names(d_slopes)
  d_slopes <- rast(d_slopes)
  names(d_slopes) <- names

  # return:
  d_slopes
}

# tar_load(poi)

# summary_summary
# library(tidyterra)
# dplyr::bind_cols(
#   poi |> as.data.frame(),
#   extract(d_slopes, poi) |> select(-ID)
# )

# stack <- purrr::map(dots, \(rast) {
#   rast["slope"]
# }) |>
#   rast()
# names(stack) <- thresholds
# stack

# #TODO use poi_stats for this once it is done running
# point_slopes <- dplyr::bind_cols(
#   poi |> as.data.frame(),

#   extract(stack, poi) |> select(-ID)
# ) |>
#   pivot_longer(
#     -label,
#     names_to = "threshold",
#     values_to = "slope",
#     names_transform = list(threshold = as.numeric)
#   )

# library(ggplot2)
# library(colorspace)
# library(patchwork)

# #show slopes as arrows
# p1 <- point_slopes |>
#   filter(label == "Grand Rapids, MI") |>
#   ggplot(aes(x = threshold, y = 0, yend = slope)) +
#   # facet_wrap(vars(label), ncol = 1,scales = "free_y") +
#   geom_hline(aes(yintercept = 0), color = "grey") +
#   geom_segment(
#     aes(color = slope < 0),
#     arrow = arrow(length = unit(0.1, "inches"))
#   ) +
#   scale_x_continuous(breaks = thresholds) +
#   # scale_y_reverse() +
#   theme_bw() +
#   theme(panel.grid = element_blank()) +
#   labs(y = "Trend (days/yr)")

# #show contractions and expansions as bars
# point_dslopes <- dplyr::bind_cols(
#   poi |> as.data.frame(),
#   terra::extract(d_slopes[[1:(nlyr(d_slopes) - 1)]], poi) |> select(-ID)
# ) |>
#   pivot_longer(
#     -label,
#     names_to = "threshold_comparison",
#     values_to = "slope_difference"
#   ) |>
#   tidyr::separate(
#     threshold_comparison,
#     into = c("threshold_end", "threshold_start"),
#     sep = " - "
#   ) |>
#   mutate(across(starts_with("threshold_"), as.numeric))

# p2 <- point_dslopes |>
#   filter(label == "Grand Rapids, MI") |>
#   ggplot() +
#   geom_segment(
#     aes(
#       y = 0,
#       x = threshold_start,
#       xend = threshold_end,
#       color = slope_difference
#     ),
#     linewidth = 5
#   ) +
#   # facet_wrap(vars(label), ncol = 1) +
#   scale_x_continuous("threshold", breaks = thresholds) +
#   colorspace::scale_color_continuous_diverging(
#     palette = "Purple-Green",
#     rev = TRUE,
#     na.value = "transparent"
#   ) +
#   theme_bw() +
#   theme(
#     panel.grid = element_blank(),
#     axis.text.y = element_blank(),
#     axis.ticks.y = element_blank(),
#     axis.title.y = element_blank()
#   )

# p2 /
#   p1 +
#   plot_layout(heights = c(0.2, 1), axes = "collect", guides = "collect") +
#   plot_annotation(title = "Grand Rapids, MI")
