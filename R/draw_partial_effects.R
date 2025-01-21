#draw model partial effects plot
# library(gratia)
# library(targets)
# library(colorspace)
# library(ggplot2)
# library(tidyterra)
# library(terra)
# tar_load(gam_50000_50)
# tar_load(roi)


#' Draw partial effects plots
#'
#' @param gam a gam target
#' @param roi the roi target
#'
#' @return path
#' @export
#'
#' @examples
draw_partial_effects <- function(gam, roi) {
  if (!inherits(gam, "gam")) { #if target doesn't exist...
    return(NULL)
  }
  roi <- project(roi, crs("ESRI:102010"))
  gam_name <- deparse(substitute(gam))

  smooth_est <- 
    gratia::smooth_estimates(gam, dist = 0.1, n_3d = 6, unconditional = TRUE, overall_uncertainty = TRUE)
  
  ti_xy_rast <- 
    smooth_est |> 
    dplyr::filter(.smooth == "ti(x,y)") |> 
    dplyr::select(x, y, .estimate) |> 
    tibble::as_tibble() |> 
    terra::rast()
  
  crs(ti_xy_rast) <- "ESRI:102010"
  
  ti_xy_rast <- crop(ti_xy_rast, roi, mask = TRUE)
  
  p_ti_xy <- 
    ggplot2::ggplot() +
    tidyterra::geom_spatraster(data = ti_xy_rast) +
    tidyterra::geom_spatvector(data = roi, fill = "NA") +
    colorspace::scale_fill_continuous_diverging(rev = TRUE, na.value = "transparent") +
    ggplot2::labs(fill = "Partial Effect", title = "ti(x,y)")
  
  ti_yr <- smooth_est |> 
    dplyr::filter(.smooth == "ti(year_scaled)")
  
  p_ti_yr <-
    ggplot2::ggplot(ti_yr, ggplot2::aes(x = year_scaled, y = .estimate, ymin = .estimate - .se, ymax = .estimate + .se)) +
    ggplot2::geom_line() +
    ggplot2::geom_ribbon(alpha = 0.3) +
    ggplot2::labs(y = "Partial Effect", title = "ti(year_scaled)")
  
  ti_xyyr_rast <-
    smooth_est |> 
    dplyr::filter(.smooth %in% c("ti(x,y,year_scaled)", "ti(year_scaled,x,y)")) |> 
    dplyr::select(x, y, year_scaled, .estimate) |> 
    dplyr::mutate(year_scaled = as.character(year_scaled)) |> 
    as.data.frame() |> 
    terra::rast(type = "xylz")
  
  crs(ti_xyyr_rast) <- "ESRI:102010"
  
  ti_xyyr_rast <- crop(ti_xyyr_rast, roi, mask = TRUE)
  
  p_ti_xyyr <- 
    ggplot2::ggplot() +
    tidyterra::geom_spatraster(data = ti_xyyr_rast) +
    ggplot2::facet_wrap(~lyr) +
    colorspace::scale_fill_continuous_diverging(rev = TRUE, na.value = "transparent")  +
    ggplot2::labs(title = "ti(x,y,year_scaled)", fill = "Partial Effect")
  
  library(patchwork)
  
  p <- (p_ti_xy | p_ti_yr) / p_ti_xyyr & ggplot2::theme_minimal() 
  
  p <- p + patchwork::plot_annotation(title = gam_name)
  
  ggsave(
    filename = paste0("partial_effects_", gam_name, ".png"),
    plot = p, 
    path = "output/gams/",
    width = 12, 
    height = 10, 
    bg = "white"
  )
  
}