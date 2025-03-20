calc_linear_slopes <- function(stack) {
  #being extra safe here and not assuming every year is represented
  time <- as.integer(names(stack))
  #scale
  time <- time - min(time)
  terra::app(stack, \(x) {
      if (sum(!is.na(x)) < 3) { #if there's fewer than 3 non-NA years
        NA
      } else {
        m = lm(x ~ time)
        m$coefficients[2]
      }
  })
}
