# library(targets)
# library(marginaleffects)
# library(sf)
# library(dplyr)
# library(tidyr)
# library(purrr)
# source("R/calc_avg_slopes.R")
# tar_load(c(gam_50gdd,  gam_1250gdd, gam_2500gdd))
# tar_load(cities_sf)

calc_city_slopes <- function(cities_sf, gam) {
  gam_name <- deparse(substitute(gam))
  #create  newdata from cities
  cities_df <-
    cities_sf |> 
    group_by(across(-geometry)) |>
    reframe(st_coordinates(geometry) |> as.data.frame()) |> 
    rename(x = X, y = Y) 
  newdata <- 
    cities_df |> 
    expand_grid(year_scaled = 0:42) 
  
  slopes <- calc_avg_slopes(gam, newdata = newdata) |> 
    tibble::add_column(gam = gam_name, .before = "term")
  
  #join to city names
  full_join(cities_df, slopes)
}

# slope_50gdd <- calc_cities_slopes(cities_sf, gam_50gdd)

