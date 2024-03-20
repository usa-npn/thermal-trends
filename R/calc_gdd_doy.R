#' Calculate DOY to reach a theshold GDD
#'
#' @param rast_dir Path to directory containing PRISM mean temp data for a single year. Assumes folder name is just the year.
#' @param ne_vect_file Path to file defining boundaries of the Northeast US. Will be read by `terra::vect()` and used to crop the data.  
#' @param gdd_threshold Threshold GDD
#' @param gdd_base Temperature base, in ºC, for calculating GDD
#'
#' @return SpatRaster
calc_gdd_doy <- function(rast_dir, ne_vect_file, gdd_threshold, gdd_base = 0) {
  files <- dir_ls(rast_dir, glob = "*.bil", recurse = TRUE)
  #convert filenames to DOY to name layers later
  doys <- files |>
    fs::path_file() |>
    stringr::str_extract("\\d{8}") |>
    lubridate::ymd() |> 
    lubridate::yday()
  
  #read in as raster stacks
  prism <- terra::rast(files)
  names(prism) <- doys
  units(prism) <- "ºC"
  
  #sort layers by DOY
  prism <- subset(prism, as.character(min(doys):max(doys)))
  
  #crop to northeast
  ne <- terra::vect(ne_vect_file) |> project(prism)
  prism_ne <- crop(prism, ne, mask = TRUE)
  
  # convert to degree days
  # function for a single layer:
  calc_dd <- function(tmean, base = 0) {
    if (base != 0) {
      dd <- tmean - base
    } else {
      dd <- tmean
    }
    dd[dd < 0] <- 0
    dd
  }
  
  #apply to every layer
  gdd <- terra::app(prism_ne, calc_dd, base = gdd_base)
  
  # convert to accumulated dd
  agdd <- cumsum(gdd)
  
  # DOY to reach a single threshold
  gdd_doy <- which.lyr(agdd > gdd_threshold)
  
  names(gdd_doy) <- 
    fs::path_file(rast_dir) #gets just the end folder name which should be the year
  
  #return:
  gdd_doy
}