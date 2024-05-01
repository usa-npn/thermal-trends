# fit_spatiotemporal_bam <- function(data) {
#   mgcv::bam(
#     doy ~ te(y, x, year_scaled, d = c(2, 1), bs = c("sos", "cs")),
#     data = data,
#     method = "REML"
#   )
# }

fit_bam <- function(data) {
  mgcv::bam(
    doy ~ ti(y, x, bs = "sos", d = 2, k = 25) +
      ti(year_scaled, bs = "cs", k = 30) +
      ti(y, x, year_scaled, d = c(2,1), bs = c("sos", "cs"), k = c(25, 30)),
    data = data,
    method = "REML"
  )
}

