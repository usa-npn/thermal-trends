library(microbenchmark)
microbenchmark(list = list(
  REML = {mgcv::bam(
    DOY ~ 
      ti(x, y, bs = "cr", d = 2, k = 25) +                                # <1>
      ti(year_scaled, bs = "cr", k = 10) +                                # <2>
      ti(x, y, year_scaled, d = c(2,1), bs = "cr", k = c(25, 10)),        # <3>
    data = gdd_df,
    method = "REML"
  )},
  fREML = {mgcv::bam(
    DOY ~ 
      ti(x, y, bs = "cr", d = 2, k = 25) +                                # <1>
      ti(year_scaled, bs = "cr", k = 10) +                                # <2>
      ti(x, y, year_scaled, d = c(2,1), bs = "cr", k = c(25, 10)),        # <3>
    data = gdd_df,
    method = "fREML"
  )},
  fREML_discrete = {mgcv::bam(
    DOY ~ 
      ti(x, y, bs = "cr", d = 2, k = 25) +                                # <1>
      ti(year_scaled, bs = "cr", k = 10) +                                # <2>
      ti(x, y, year_scaled, d = c(2,1), bs = "cr", k = c(25, 10)),        # <3>
    data = gdd_df,
    method = "fREML",
    discrete = TRUE
  )},
  fREML_discrete_2threads = {mgcv::bam(
    DOY ~ 
      ti(x, y, bs = "cr", d = 2, k = 25) +                                # <1>
      ti(year_scaled, bs = "cr", k = 10) +                                # <2>
      ti(x, y, year_scaled, d = c(2,1), bs = "cr", k = c(25, 10)),        # <3>
    data = gdd_df,
    method = "fREML",
    discrete = TRUE,
    nthreads = 2
  )}
), times = 5)
