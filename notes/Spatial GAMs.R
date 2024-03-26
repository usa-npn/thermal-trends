# Exploring spatial GAMs and geographically-weighted regression as alternatives to pixel-wise regression with FDR correction of p-values.
library(targets)
tar_load_globals()
library(mgcv)
library(gratia)
library(bbmle)
tar_load(gdd_doy_stack_50)
library(tidyverse)

doy_df <-
  #downsample spatially and temporally for testing
  aggregate(gdd_doy_stack_50, fact = 8)[[c(1:5)]] |> 
  as_tibble(xy = TRUE, na.rm = TRUE) |>
  pivot_longer(
    c(-x,-y),
    names_to = "year",
    values_to = "doy",
    names_transform = list(year = as.numeric)
  )

doy_df

#basic model with trend over year and smoother for lat/lon
m <- gam(doy ~ year + s(x,y), data = doy_df, method = "REML")
summary(m)
gratia::draw(m,parametric = TRUE, rug = FALSE)

#uhh, partial effect should be in units of DOY, right?  Not good that it's 3850-ish
# do I need to rescale year?
doy_df <- doy_df |> mutate(year_scaled = year - min(year))
m1 <-
  gam(
    doy ~ year_scaled + s(x, y),
    data = doy_df,
    method = "REML"
  )
summary(m1)
draw(m1, parametric = TRUE, rug = FALSE)
#ok, yeah, that makes more sense I think?

#include interaction as tensor product with simple construction
m2 <- gam(
  doy ~ te(x, y, year_scaled),
  data = doy_df,
  method = "REML"
)
AICtab(m1, m2)
draw(m2, rug = FALSE)

#more complicated things are possible like using a 2d thin plate spline for lat and long and a cubic regression spline for year.
m3 <- gam(
  doy ~ te(x, y, year_scaled, d = c(2, 1), bs = c("tp", "cs")),
  data = doy_df,
  method = "REML"
)
AICtab(m1, m2, m3)
draw(m3, rug = FALSE)

#we can also separate out main effects with ti()
m4 <- gam(
  doy ~ s(x, y) + #geography main effect
    s(year_scaled, bs = "cs", k = 4) + #year main effect
    ti(x, y, year_scaled, d = c(2, 1), bs = c("tp", "cs"), k = c(NULL, 4)), #geography-year interaction
  data = doy_df,
  method = "REML"
)
AICtab(m1, m2, m3, m4)
summary(m4)
draw(m4, rug = FALSE)

#would need to figure out appropriate smoothers, number of knots, etc. and interpretation is difficult, but very informative

#If the effects of lat and lon are on different scales, might be better to use `te()`
m5 <- gam(
  doy ~ te(x, y) + #geography main effect
    s(year_scaled, bs = "cs", k = 4) + #year main effect
    ti(x, y, year_scaled, d = c(2, 1), bs = c("tp", "cs"), k = c(NULL, 4)), #geography-year interaction
  data = doy_df,
  method = "REML"
)
AICtab(m1, m2, m3, m4, m5)
summary(m5)
draw(m5, rug = FALSE)

#m3 is best by AIC