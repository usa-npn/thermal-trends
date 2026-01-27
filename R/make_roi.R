make_roi <- function() {
  maps::map(database = "state", regions = c(
    "Connecticut",
    "Delaware",
    "Illinois",
    "Indiana",
    "Iowa",
    "Maine",
    "Maryland",
    "Massachusetts",
    "Michigan",
    "Minnesota",
    "Missouri",
    "New Hampshire",
    "New Jersey",
    "New York",
    "Ohio",
    "Pennsylvania",
    "Rhode Island",
    "Vermont",
    "West Virginia",
    "Wisconsin",
    "Kentucky",
    "Virginia"
  ), plot = FALSE, fill = TRUE) |> 
    sf::st_as_sf() |> 
    sf::st_combine() |> 
    terra::vect()
}

# sf version of above.  Don't want to edit the above function to depend on this
# one, because it'll invalidate the whole pipeline potentially.
make_roi_sf <- function() {
  maps::map(
    database = "state",
    regions = c(
      "Connecticut",
      "Delaware",
      "Illinois",
      "Indiana",
      "Iowa",
      "Maine",
      "Maryland",
      "Massachusetts",
      "Michigan",
      "Minnesota",
      "Missouri",
      "New Hampshire",
      "New Jersey",
      "New York",
      "Ohio",
      "Pennsylvania",
      "Rhode Island",
      "Vermont",
      "West Virginia",
      "Wisconsin",
      "Kentucky",
      "Virginia"
    ),
    plot = FALSE,
    fill = TRUE
  ) |>
    sf::st_as_sf()
}