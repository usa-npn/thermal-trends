make_slope_newdata <- function(rast, res_m) {
  rast |> 
    project(crs("ESRI:102010"), res = res_m, method = "near") |> 
    as.data.frame(xy = TRUE, na.rm = TRUE, wide = FALSE, cell = TRUE) |> 
    rename(year = layer, DOY = values) |> 
    dplyr::mutate(year = as.numeric(year)) |> 
    dplyr::mutate(year_scaled = year - min(year, na.rm = TRUE)) |> 
    select(cell, x, y, year_scaled) |> 
    mutate(group = cut(cell, breaks = ceiling(max(cell)/750))) 
}
