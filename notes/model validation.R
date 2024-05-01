library(targets)
library(mgcv)
library(gratia)
library(tictoc)
library(bbmle)

tar_load(gam_df)
tar_load(st_gam)

tic()
m2 <- mgcv::bam(
  doy ~ ti(y, x, bs = "sos", d = 2, k = 30) +
    ti(year_scaled, bs = "cs", k = 25) +
    ti(y, x, year_scaled, d = c(2,1), bs = c("sos", "cs"), k = c(30, 25)),
  data = gam_df,
  method = "REML"
)
toc()

AICctab(st_gam, m2)

k.check(m2)
draw(m2)


