library(dplyr)
library(sf)
library(targets)
library(tidyr)
library(terra)
library(purrr)
tar_load(roi)
tar_load(gdd_doy_1950)
tar_load(gdd_doy_2500)
tar_load(gdd_doy_1250)
locs <- tribble(~ city, ~lon, ~lat,
  "Grand Rapids, MN", 47.237222, -93.530278,
  "Bergland, MI", 46.592222, -89.573333
) 

locs_sf <- locs |> st_as_sf(coords = c("lat", "lon"), crs = 4326)
stack_1250 <- rast(gdd_doy_1250)
stack_1950 <- rast(gdd_doy_1950)
stack_2500 <- rast(gdd_doy_2500)
names(stack_1250) <- map_chr(gdd_doy_1250, names)
names(stack_1950) <- map_chr(gdd_doy_1950, names)
names(stack_2500) <- map_chr(gdd_doy_2500, names)

point_1250 <- terra::extract(stack_1250, locs_sf)
point_1950 <- terra::extract(stack_1950, locs_sf)
point_2500 <- terra::extract(stack_2500, locs_sf)


data <- bind_rows(
    bind_cols(locs, point_1250) |>
    mutate(threshold = 1250, .after = city),
  bind_cols(locs, point_1950) |>
    mutate(threshold = 1950, .after = city),
  bind_cols(locs, point_2500) |>
    mutate(threshold = 2500, .after = city)
) |>
  select(-ID) |>
  pivot_longer(
    c(-city, -lon, -lat, -threshold),
    names_to = "year",
    values_to = "DOY",
    names_transform = as.integer
  )


readr::write_csv(data, "point_data_nathan.csv")

tar_load(slope_differences)

terra::extract(slope_differences, locs_sf)
