count_gdd_reached <- function(stack, roi) {
  roi <- terra::project(roi, stack)
  app(stack, \(x) sum(!is.na(x))) |> mask(roi)
}