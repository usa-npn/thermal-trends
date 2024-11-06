# library(targets)
# library(marginaleffects)
# library(sf)
# library(dplyr)
# library(tidyr)
# library(purrr)
# source("R/calc_avg_slopes.R")
# tar_load(c(gam_50gdd,  gam_1250gdd, gam_2500gdd))
# tar_load(cities_sf)

calc_cities_slopes <- function(cities_sf, gam, stepsize = NULL) {
#create  newdata from cities
  newdata <- cities_sf |> 
    group_by(across(-geometry)) |>
    reframe(st_coordinates(geometry) |> as.data.frame()) |> 
    rename(x = X, y = Y) |> 
    expand_grid(year_scaled = 0:42) 
  
  calc_avg_slopes(gam, newdata = newdata, stepsize = stepsize) |> 
    tibble::add_column(gam = deparse(substitute(gam)), .before = "term")
}

# slope_50gdd <- calc_cities_slopes(cities_sf, gam_50gdd)

