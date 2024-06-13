trend_rast2df <- function(raster) {
  gdd <- str_extract(deparse(substitute(raster)), "\\d+") |> as.numeric()
  raster |> 
    as_tibble(xy = TRUE, na.rm = TRUE) |> 
    tibble::add_column(gdd_threshold = gdd, .before = "x")
}