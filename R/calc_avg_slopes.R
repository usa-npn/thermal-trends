# library(targets)
# library(mgcv)
# gam <- tar_read(gam_50000_50)
# newdata <- tar_read(slope_newdata)
# # draw avg slopes
# library(marginaleffects)

#' @param gam a mgcv gam or bam model
#' @param newdata a dataframe with columns matching the predictors in the gam
calc_avg_slopes <- function(gam, newdata = NULL) {
  slopes <-
    marginaleffects::avg_slopes(
      gam,
      newdata = newdata,
      variables = "year_scaled",
      type = "response",
      by = c("y", "x"),
      # p_adjust = "BY", #will do p adjustment manually
      hypothesis = 0,
      df = insight::get_df(gam, type = "model"), #TODO: not 100% sure if this is appropriate
      eps = NULL, # Default is 0.0001 * 43 = 0.0043 years.
      discrete = TRUE #speeds up computation
    )
  #return as tibble
  as_tibble(slopes)
}
