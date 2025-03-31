calc_linear_slopes <- function(stack) {
  #being extra safe here and not assuming every year is represented
  year <- as.integer(names(stack))
  #scale
  year_scaled <- year - min(year, na.rm = TRUE)
  slopes <- terra::app(stack, \(x) {
    if (sum(is.finite(x)) < 10) {
      #don't bother if there's fewer than 10 non-NA years
      NA
    } else {
      m = lm(x ~ year_scaled)
      coef(m)[2]
    }
  })
  names(slopes) <- "slope"
  #return
  slopes
}


calc_doy_summary <- function(stack) {
  #being extra safe here and not assuming every year is represented
  year <- as.integer(names(stack))
  #scale
  year_scaled <- year - min(year, na.rm = TRUE)
  terra::app(stack, \(x) {
    #if there's not enough values to calculate slope, don't
    if (sum(is.finite(x)) < 2) {
      slope <- NA
    } else {
      slope <- coef(lm(x ~ year_scaled))[2]
    }
    # and only do the rest of the stats if there is at least 1 non-NA value

    if (sum(is.finite(x)) == 0) {
      out <- c(
        min = NA,
        max = NA,
        mean = NA,
        sd = NA,
        count = NA,
        slope = NA
      )
    } else {
      out <- c(
        min = min(x, na.rm = TRUE),
        max = max(x, na.rm = TRUE),
        mean = mean(x, na.rm = TRUE),
        sd = sd(x, na.rm = TRUE),
        count = sum(!is.na(x)),
        slope = slope
      )
    }
    out
  })
}
