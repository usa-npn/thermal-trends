make_slope_newdata <- function(rast, res_m) {
  rast |> 
    project(crs("ESRI:102010"), res = res_m, method = "near") |> 
    as.data.frame(xy = TRUE, na.rm = TRUE) |> 
    tidyr::pivot_longer(c(-x,-y), names_to = "year", values_to = "DOY") |> 
    dplyr::mutate(year = as.numeric(year)) |> 
    dplyr::mutate(year_scaled = year - min(year, na.rm = TRUE)) |> 
    select(x, y, year_scaled)
}
