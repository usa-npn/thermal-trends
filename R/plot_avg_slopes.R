# slopes_df
# tar_load(roi)
# library(tidyterra)
# library(ggpattern)

plot_avg_slopes <- function(slopes_df, roi, cities_sf, cities_plot) {
  
  #figure out threshold from target name
  slopes_df_name <- deparse(substitute(slopes_df))
  threshold <- str_extract(slopes_df_name, "\\d+")
  
  #p.adjust for FDR
  slopes_df <- slopes_df |> 
    mutate(p.value = p.adjust(p.value, method = "BY"))
  
  gam_pval_rast <- 
    rast(slopes_df |> select(x, y, p.value)) < 0.05
  
  non_sig <- 
    as.polygons(gam_pval_rast) |>
    filter(p.value == 0)  |>
    mutate(p.value = as.factor(p.value)) 
  crs(non_sig) <- "ESRI:102010"
  
  p <-
    ggplot(slopes_df) +
    geom_raster(aes(x = x, y = y, fill = estimate)) +
    geom_spatvector(data = roi, fill = NA, inherit.aes = FALSE) +
    geom_sf_pattern(
      data = st_as_sf(non_sig),
      aes(pattern_fill = ""), #TODO trick to get legend to show up, but there's a new way to do this in ggplot2 I think
      pattern = "crosshatch",
      fill = NA,
      colour = NA,
      pattern_alpha = 0.5, #maybe not necessary
      pattern_size = 0.05, #make lines smaller
      pattern_spacing = 0.01, #make lines closer together
      pattern_res = 200, #make lines less pixelated
    ) +
    geom_sf(data = cities_sf) +
    scale_pattern_fill_manual(values = c("grey30")) +
    scale_fill_continuous_diverging(na.value = "transparent", rev = TRUE) +
    labs(fill = "Avg. slope (DOY/yr)",
         pattern_fill = "p > 0.05",
         title = glue::glue("Trend in the DOY that {threshold} GDD is reached"),
         x = "",
         y = "") +
    coord_sf(crs = "ESRI:102010") +
    theme_minimal()
  
  #assemble plots with patchwork
  out <- free(p)/cities_plot +
    plot_layout(heights = c(1, 0.4)) + 
    plot_annotation(tag_levels ="A")
  
  filename <- paste0(slopes_df_name, ".png")
  ggsave(
    filename = filename,
    plot = out, 
    path = "output/gams/",
    bg = "white",
    width = 7,
    height = 7
  )
}
