# library(targets)
# library(mgcv)
# gam <- tar_read(gam_50000_50)
# newdata <- tar_read(slope_newdata)
# # draw avg slopes
# library(marginaleffects)

#' @param gam a mgcv gam or bam model
#' @param newdata a dataframe with columns matching the predictors in the gam
#' @param stepsize passed to the `eps` argument of `avg_slopes()`, controls the
#'   'dx' in the slope calculations.  Default is 0.0001 * 43 = 0.0043 years,
#'   which is quite small and results in a very slow function.
calc_avg_slopes <- function(gam, newdata = NULL, stepsize = NULL) {
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
      eps = stepsize,
      discrete = TRUE #speeds up computation
    )
  #return as tibble
  as_tibble(slopes)
}
