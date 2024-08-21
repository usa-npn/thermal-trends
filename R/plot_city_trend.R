# library(targets)
# library(tidyverse)
# library(sf)
# library(broom)
# 
# gam <- tar_read(gam_50gdd)
# gam_df <- tar_read(gam_df_50gdd)

plot_city_trend <- function(gam, cities_sf) {
  gam_df <- model.frame(gam) |> mutate(year = year_scaled + 1981)
  
  gam_sf <- gam_df |> 
    filter(year == dplyr::first(year)) |>
    select(x,y) |> 
    st_as_sf(coords = c("x", "y"), crs = "ESRI:102010")
  
  #what pixels are nearest these cities in the original data?
  
  newdata <-
    #find existing data points nearest to chosen cities
    #this doesn't work
    # st_join(gam_sf, cities_sf, join = st_nearest_feature) |>
    st_join(gam_sf, cities_sf, join = st_is_within_distance, dist = 28000) |> filter(!is.na(city)) |> 
    #convert to normal data frame
    group_by(across(-geometry)) |>
    reframe(st_coordinates(geometry) |>
              as.data.frame()) |> 
    rename(x = X, y = Y) |> 
    #add year_scaled
    expand_grid(year_scaled = 0:42)
  
  
  aug <- augment(gam, newdata = newdata)
  left_join(aug, gam_df) |> 
    ggplot(aes(x = year)) +
    facet_wrap(vars(forcats::fct_rev(city))) +
    geom_point(aes(y = DOY)) +
    geom_line(aes(y = .fitted)) +
    geom_ribbon(aes(ymin = .fitted -.se.fit, ymax = .fitted + .se.fit), color = NA, alpha = 0.4) 
  
}