# library(targets)
# library(ggtext)
# # tar_load_globals()
# tar_load(starts_with("doy_summary_"))
# tar_load(roi)
# dots <- rlang::dots_list(
#   doy_summary_1250,
#   doy_summary_1950,
#   doy_summary_2500,
#   doy_summary_350,
#   doy_summary_50,
#   doy_summary_650,
#   .named = TRUE
# )
# use_percentile_lims = TRUE

plot_slope_differences2 <- function(
  roi,
  ...,
  # correct_diff = TRUE,
  use_percentile_lims = TRUE
) {
  dots <- rlang::dots_list(..., .named = TRUE)
  slopes_list <- dots |>
    purrr::map(\(x) {
      #at least 10 non-NA years for reliable slopes
      mask(x[["slope"]], x[["count"]] >= 10, maskvalue = FALSE)
    })

  thresholds <- names(slopes_list) |>
    stringr::str_extract("\\d+") |>
    as.numeric()
  #rename using thresholds
  names(slopes_list) <- thresholds

  #Order by list by threshold.
  slopes_list <- slopes_list[order(thresholds)]

  d_slopes <- map2(slopes_list, dplyr::lead(slopes_list), \(x_1, x_2) {
    if (!is.null(x_2)) {
      thr_1 <- x_1 |> varnames() |> stringr::str_extract("\\d+") |> as.numeric()
      thr_2 <- x_2 |> varnames() |> stringr::str_extract("\\d+") |> as.numeric()

      x_2 - x_1
    } else {
      NULL
    }
  }) |>
    set_names(paste(
      dplyr::lead(names(slopes_list)),
      "–",
      names(slopes_list)
    )) |>
    purrr::compact()

  # also add the max - min GDD
  d_full_range <- list(
    (slopes_list[[length(slopes_list)]] - slopes_list[[1]]) /
      (max(thresholds) - min(thresholds))
  )
  names(d_full_range) <- paste(max(thresholds), "–", min(thresholds))

  # add the last one
  d_slopes <- append(d_slopes, d_full_range)
  # d_slopes <- rast(d_slopes)

  p_list <- imap(d_slopes, \(d_slope, title) {
    # for each plot separately, figure out quantiles for limits

    limits <- c(NA, NA)
    if (use_percentile_lims) {
      limits <- d_slope |>
        terra::values() |>
        quantile(probs = c(0.005, 0.995), na.rm = TRUE)
    }

    ggplot() +
      tidyterra::geom_spatvector(data = roi) +
      tidyterra::geom_spatraster(data = d_slope) +
      # facet_wrap(vars(lyr)) +
      colorspace::scale_fill_continuous_diverging(
        palette = "Purple-Green",
        rev = TRUE,
        na.value = "transparent",
        limits = limits,
        oob = scales::oob_squish,
        breaks = breaks_limits(
          n = 4,
          min = !is.na(limits[1]),
          max = !is.na(limits[2]),
          tol = 0.1,
          digits = 5,
          scientific = any(abs(limits) < 0.1)
        )
      ) +
      labs(subtitle = title, fill = NA) +
      #n.breaks only works in current dev version of ggplot2: https://github.com/tidyverse/ggplot2/pull/5442
      scale_x_continuous(n.breaks = 5) +
      scale_y_continuous(n.breaks = 5) +
      coord_sf() +
      theme_minimal() +
      theme(
        strip.background = element_rect(fill = "white"),
        title = element_markdown(),
        axis.title = element_blank(),
        legend.title = element_markdown(),
        legend.key.width = unit(1, "lines"),
        legend.key.height = unit(1, "lines")
        # legend.position = "bottom",
        # legend.key.width = unit(0.1, "npc"),
        # legend.key.height = unit(0.015, "npc")
      )
  })

  # collecting axes doesn't work with coord_sf() I think.
  # https://github.com/thomasp85/patchwork/issues/366
  # p <- patchwork::wrap_plots(p_list, axes = "collect")
  # goign to have to do it "manually"

  #fmt: skip
  p <-
    (p_list[[1]] + theme(axis.text.x = element_blank())) +
    (p_list[[2]] + theme(axis.text.x = element_blank(), axis.text.y = element_blank())) +
    (p_list[[3]] + theme(axis.text.x = element_blank(), axis.text.y = element_blank())) +
    (p_list[[4]]) +
    (p_list[[5]] + theme(axis.text.y = element_blank())) +
    (p_list[[6]] + theme(axis.text.y = element_blank()))

  # p

  ggplot2::ggsave(
    filename = "slopes-differences2.png",
    plot = p,
    path = "output/linear-slopes/",
    bg = "white",
    width = 9.5,
    height = 5
  )
}
