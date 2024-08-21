#some example cities
make_cities_sf <- function() {
    tribble(
      ~city, ~x, ~y,
      #city, #lon, #lat,
      "Columbus, OH", -83.000556, 39.962222,
      "Luverne, MN",  -96.214722, 43.655833
    ) |>
    st_as_sf(coords = c("x", "y"), crs = "WGS84") |>
    #transform to meters to match GAM data
    st_transform(crs = "ESRI:102010") 
}