get_lm_slope <- function(gdd_stack) {
  years <- as.integer(names(gdd_stack))
  getTrend <- function(x) {
    if (is.na(x[1])) {
      NA
    } else {
      m = lm(x ~ years)
      m$coefficients[2]
    }
  }
  
  slope_rast <- app(gdd_stack, getTrend)
}