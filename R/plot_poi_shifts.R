# Create draft figure for Thermal Calendars MS
# 17 Oct 2025

# library(dplyr)
# library(ggplot2)
# library(cowplot)
# library(terra)
# library(tidyterra)
# library(ggpubr)
# library(targets)
# tar_load(poi_pred_doy)
# tar_load(roi)

#' @author Erin Zylstra
#' @param poi_pred_doy the `poi_pred_doy` target, a tibble
#' @param roi the `roi` target, a SpatVector object
#' @param outpath path to directory to save figure
plot_poi_shifts <- function(poi_pred_doy, roi, outpath = "output/figs") {
  dat <-
    poi_pred_doy %>%
    rename(early = pred_1981, late = pred_2023)

  # Remove sites that didn't reach 2500 threshold and add state to label
  dat <- filter(
    dat,
    !label %in% c("Mountain Lake Biological Station", "Rhinelander, WI")
  ) %>%
    arrange(label, threshold) %>%
    mutate(
      label = ifelse(label == "Harvard Forest", "Harvard Forest, MA", label)
    )

  # Identify DOY range for each site and create short site name
  dat <- dat %>%
    group_by(label) %>%
    mutate(xmin = min(c(early, late)), xmax = max(c(early, late))) %>%
    ungroup() %>%
    data.frame() %>%
    mutate(
      label_short = case_when(
        label == "Georgetown, DE" ~ "Georgetown",
        label == "Grand Rapids, MI" ~ "GrandRapids",
        label == "Harvard Forest, MA" ~ "Harvard",
        .default = "KansasCity"
      )
    )

  # Extract site labels
  sites <- unique(dat$label)

  # Create data frame with information about each period between thresholds,
  # including the predicted difference in period durations between 1981 and 2023
  for (i in 1:length(sites)) {
    loc_dat <- filter(dat, label == sites[i])
    tmp_periods <- data.frame(
      label = sites[i],
      period = 1:5,
      early = loc_dat$early[2:6] - loc_dat$early[1:5],
      late = loc_dat$late[2:6] - loc_dat$late[1:5]
    ) %>%
      mutate(diff = late - early)
    if (i == 1) {
      dat_periods <- tmp_periods
    } else {
      dat_periods <- rbind(dat_periods, tmp_periods)
    }
  }

  # Create bins for changes in period durations:
  # <1 day change; 1-3 days; 3-5 days; 5-10 days; 10+ days
  dat_periods <- dat_periods %>%
    mutate(bins = cut(diff, breaks = c(-40, -10, -5, -3, -1, 1, 3, 5)))

  # Create balanced color ramp, but then remove two highest categories because
  # they didn't occur in our data
  colfunc <- colorRamp(c("#5aae61", "#f7f7f7", "#9970ab"))
  divcols <- colfunc(seq(0, 1, len = 9))
  divcols <- divcols[1:7, ]
  divcols <- rgb(divcols, maxColorValue = 255)
  divcolsdf <- data.frame(bins = levels(dat_periods$bins), col = divcols)
  cols <- rlang::set_names(divcolsdf$col, divcolsdf$bins)

  # Create figure for each location
  textsize <- 9

  for (i in 1:length(sites)) {
    dat1 <- dat %>%
      filter(label == sites[i])
    dat2 <- dat_periods %>%
      filter(label == sites[i])
    label_short <- dat1$label_short[1]

    # Top panel
    top <- ggplot(dat1) +
      geom_segment(
        aes(x = early, xend = late, y = threshold, yend = threshold),
        arrow = arrow(length = unit(0.15, "cm")),
        linewidth = 0.3
      ) +
      annotate(
        geom = "text",
        x = dat1$xmin[1],
        y = 2500,
        hjust = 0,
        vjust = 0,
        label = paste0(i, ": ", dat1$label[1]),
        size = (textsize) / .pt
      ) +
      scale_y_continuous(breaks = dat1$threshold) +
      scale_x_continuous(limits = c(dat1$xmin[1], dat1$xmax[2])) +
      labs(x = "Day of year", y = "GDD threshold") +
      theme(
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(color = "black"),
        text = element_text(size = textsize)
      )

    # Bottom panel
    polys <- data.frame(
      x = c(
        dat1$early[1],
        dat1$early[2],
        dat1$late[2],
        dat1$late[1],
        dat1$early[2],
        dat1$early[3],
        dat1$late[3],
        dat1$late[2],
        dat1$early[3],
        dat1$early[4],
        dat1$late[4],
        dat1$late[3],
        dat1$early[4],
        dat1$early[5],
        dat1$late[5],
        dat1$late[4],
        dat1$early[5],
        dat1$early[6],
        dat1$late[6],
        dat1$late[5]
      ),
      y = rep(c(2, 2, 1, 1), 5),
      period = rep(1:5, each = 4)
    ) %>%
      left_join(select(dat2, period, diff, bins), by = "period") %>%
      mutate(period = factor(period))
    poly_text <- polys %>%
      group_by(period) %>%
      summarize(x = mean(x)) %>%
      data.frame()

    bottom <- ggplot(dat1) +
      geom_polygon(
        data = polys,
        aes(x = x, y = y, group = period, fill = bins)
      ) +
      annotate(
        geom = "segment",
        x = dat1$xmin[1],
        xend = dat1$xmax[1],
        y = 1,
        yend = 1
      ) +
      annotate(
        geom = "segment",
        x = dat1$xmin[1],
        xend = dat1$xmax[1],
        y = 2,
        yend = 2
      ) +
      geom_segment(aes(x = early, xend = early, y = 2, yend = 2.1)) +
      geom_segment(aes(x = late, xend = late, y = 0.9, yend = 1)) +
      geom_segment(
        data = dat1,
        aes(x = early, xend = late, y = 2, yend = 1),
        color = "black",
        linewidth = 0.3
      ) +
      annotate(
        geom = "text",
        x = poly_text$x,
        y = 1.5,
        label = 1:5,
        size = (textsize - 1) / .pt
      ) +
      scale_fill_manual(values = cols) +
      scale_y_continuous(
        limits = c(0, 2.1),
        breaks = 1:2,
        labels = c("2023", "1981")
      ) +
      scale_x_continuous(limits = c(dat1$xmin[1], dat1$xmax[1])) +
      labs(y = "") +
      theme(
        legend.position = "none",
        axis.ticks = element_blank(),
        axis.text.x = element_blank(),
        axis.title.x = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        text = element_text(size = textsize)
      )

    # Merge top and bottom panels for each site
    combine <- cowplot::plot_grid(
      top,
      bottom,
      nrow = 2,
      rel_heights = c(3, 0.8),
      align = "v"
    )
    # Save with site name
    assign(paste0("p_", label_short), combine)
  }

  # Create separate plot to grab legend
  legendplot <- ggplot(dat1) +
    geom_polygon(
      data = polys,
      aes(x = x, y = y, group = period, fill = bins),
      show.legend = TRUE
    ) +
    annotate(
      geom = "segment",
      x = dat1$xmin[1],
      xend = dat1$xmax[1],
      y = 1,
      yend = 1
    ) +
    annotate(
      geom = "segment",
      x = dat1$xmin[1],
      xend = dat1$xmax[1],
      y = 5,
      yend = 5
    ) +
    geom_segment(aes(x = early, xend = early, y = 2, yend = 2.1)) +
    geom_segment(aes(x = late, xend = late, y = 0.9, yend = 1)) +
    geom_segment(
      data = dat1,
      aes(x = early, xend = late, y = 2, yend = 1),
      color = "gray"
    ) +
    annotate(
      geom = "text",
      x = poly_text$x,
      y = 1.5,
      label = 1:5,
      size = (textsize - 1) / .pt
    ) +
    scale_fill_manual(
      values = cols,
      labels = c(
        "3 to 5",
        "1 to 3",
        "-1 to 1",
        "-1 to -3",
        "-3 to -5",
        "-5 to -10",
        "< -10"
      ),
      drop = FALSE,
      name = "Change (days)",
      breaks = rev(names(cols))
    ) +
    labs(y = "") +
    theme(
      axis.ticks = element_blank(),
      axis.text.x = element_blank(),
      axis.title.x = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.background = element_blank(),
      text = element_text(size = textsize)
    )
  legend <- ggpubr::get_legend(legendplot)
  legend <- ggpubr::as_ggplot(legend)

  nestates <- roi
  locs <- data.frame(
    name = sites,
    num = 1:4,
    lon = c(-75.3855, -85.6700, -72.1755, -94.5783),
    lat = c(38.6901, 42.9638, 42.5388, 39.0997)
  )
  locsv <- vect(locs, geom = c("lon", "lat"), crs = "epsg:4326")

  sitemap <- ggplot(locsv) +
    geom_spatvector(data = nestates) +
    geom_spatvector(fill = "gray95") +
    geom_spatvector(data = locsv, color = "blue", size = 5) +
    geom_spatvector_text(data = locsv, aes(label = num), color = "white") +
    scale_y_continuous(breaks = c(40, 45)) +
    scale_x_continuous(breaks = c(-70, -80, -90)) +
    theme_bw() +
    theme(
      panel.border = element_blank(),
      axis.title = element_blank(),
      text = element_text(size = textsize)
    )

  # Merge map and legend
  bottomrow <- cowplot::plot_grid(
    sitemap,
    legend,
    nrow = 1,
    rel_widths = c(3, 1)
  )

  # Merge top 4 panels (one for each site)
  panels <- cowplot::plot_grid(
    p_Georgetown,
    p_GrandRapids,
    p_Harvard,
    p_KansasCity,
    nrow = 2,
    align = "hv"
  )

  # Merge everything together
  everything <- cowplot::plot_grid(
    panels,
    bottomrow,
    nrow = 2,
    rel_heights = c(2, 1)
  )

  # Save to file
  ggsave(
    filename = "shifts_6panel.png",
    path = outpath,
    plot = everything,
    width = 6.5,
    height = 9,
    units = "in",
    dpi = 600,
    bg = "white",
    create.dir = TRUE
  )
}
