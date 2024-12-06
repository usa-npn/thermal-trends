#' Calculate DOY a threshold GDD is reached
#'
#' @param rast_dir Path to directory containing PRISM mean temp data for a
#'   single year. Assumes folder name is just the year.
#' @param roi SpatVector object with boundaries of region of interest
#' @param gdd_threshold Threshold GDD
#' @param gdd_base Temperature base, in ºC, for calculating GDD
#'
#' @return SpatRaster
calc_gdd_doy <- function(rast_dir, roi, gdd_threshold, gdd_base = 0) {
  prism <- read_prism(rast_dir)
  
  #crop to roi
  roi <- terra::project(roi, prism)
  prism_roi <- terra::crop(prism, roi, mask = TRUE)
  
  # calculate degree days
  gdd <- terra::app(prism_roi, calc_gdd_simple, base = gdd_base)
  
  # convert to accumulated gdd
  agdd <- cumsum(gdd)
  
  # DOY to reach a single threshold
  gdd_doy <- terra::which.lyr(agdd > gdd_threshold)
  
  names(gdd_doy) <- 
    fs::path_file(rast_dir) #gets just the end folder name which should be the year
  
  #return:
  gdd_doy
}


read_prism <- function(rast_dir) {
  files <- fs::dir_ls(rast_dir, glob = "*.zip")
  
  #convert filenames to DOY to use for layer names
  doys <- files |>
    fs::path_file() |>
    stringr::str_extract("\\d{8}") |>
    lubridate::ymd() |> 
    lubridate::yday()
  
  #construct paths with /vsizip/ to read inside .zip files
  bils <- 
    files |> 
    fs::path_file() |>
    fs::path_ext_set(".bil")
  rast_paths <- paste0("/vsizip/", fs::path(files, bils))
  
  #read in multi-layer rasters
  prism <- terra::rast(here::here(rast_paths))
  names(prism) <- doys
  terra::units(prism) <- "ºC"
  #sort layers by DOY
  prism <- terra::subset(prism, as.character(min(doys):max(doys)))
  #return
  prism
}

#' Simple averaging method for GDD calculation
#' 
#' @param tmean Numeric vector; mean daily temp in ºC.
#' @param base Base temp in ºC.
calc_gdd_simple <- function(tmean, base = 0) {
  if (base != 0) {
    gdd <- tmean - base
  } else {
    gdd <- tmean
  }
  gdd[gdd < 0] <- 0
  gdd
}