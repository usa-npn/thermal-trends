#' Create a sf data frame for points of interest
#'
make_poi <- function() {
  tibble::tribble(
    ~label, ~lat, ~lon,
    "Harvard Forest", 42.531325, -72.189789,
    "Grand Rapids, MI", 42.963333, -85.667778,
    "Rhinelander, WI", 45.639444, -89.412222,
    "Mountain Lake Biological Station", 37.36, -80.533889,
    "Georgetown, DE", 38.69, -75.385556,
    "Kansas City, MO", 39.099722, -94.578333
  ) |>
    vect(geom = c("lon", "lat"))
}
