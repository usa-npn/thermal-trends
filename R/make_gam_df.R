#' Tidy data for modeling
#' 
#' Projects raster to use meters rather than lat-lon so dimensions are 
#' equidistant, and pivots to a "long" format with columns for year and DOY.  
#' Also aggregates data spatially.
#' @param a Spat Raster; the `gdd_stack` target
#' @param res target resoltion in meters
make_gam_df <- function(gdd_stack, res) {
  gdd_rast <- 
    project(gdd_stack, crs("ESRI:102010"), res = res)
  
  gdd_df <- 
    gdd_rast |> 
    as_tibble(xy = TRUE, na.rm = TRUE) |> 
    pivot_longer(c(-x, -y), names_to = "year", values_to = "DOY", names_transform = list(year = as.integer)) |>
    mutate(year_scaled = year - min(year)) |> 
  # Convert Inf values back to NA so they get dropped properly by bam()
    mutate(DOY = ifelse(is.infinite(DOY), NA_real_, DOY))
    
  gdd_df
}
