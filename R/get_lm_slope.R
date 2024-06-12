#takes a stack of yearly DOY to get to GDD and returns raster with a layer of slopes and a layer of fdr adjusted p-values
get_lm_slope <- function(gdd_stack) {
  years <- as.integer(names(gdd_stack))
  getTrend <- function(x) {
    #only attempt to fit a line if there are at least 7 non-NA values
    #this seems not quite right.  NAs here are really infinity (or 365??) because it means that pixel never reached the GDD threshold in that year.
    # if (sum(!is.na(x)) < 7) {
    #could instead only fit slopes when all values are non NA with
    if(any(is.na(x))) {
      c(slope = NA, p.val = NA)
    } else {
      m = lm(x ~ years)
      c(slope = m$coefficients[2], p.val = car::Anova(m)$`Pr(>F)`[1])
    }
  }
  
  slope_rast <- app(gdd_stack, getTrend)
  slope_rast[[2]] <- app(slope_rast[[2]], p.adjust, method = "fdr")
  names(slope_rast) <- c("slope", "p.value")
  
  #return
  slope_rast
}