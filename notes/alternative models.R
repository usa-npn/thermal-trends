# Exploring spatial GAMs and geographically-weighted regression as alternatives to pixel-wise regression with FDR correction of p-values.
library(targets)
tar_load_globals()
library(mgcv)
library(gratia)
library(bbmle)
tar_load(gdd_doy_stack_50)

doy_df <- gdd_doy_stack_50[[1:5]] |> #just use 5 years for testing
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
    data = doy_df |> mutate(year = year - min(year)),
    method = "REML"
  )
summary(m1)
draw(m1, parametric = TRUE, rug = FALSE)
#ok, yeah, that makes more sense I think?

#use SOS basis for lat/lon data
m2 <- 
  gam(
    doy ~ year_scaled + s(x, y, bs = "sos"),
    data = doy_df |> mutate(year = year - min(year)),
    method = "REML"
  )
AICtab(m1, m2)
#big improvement!

#is it worth including an interaction term?
m3 <- 
  gam(
    doy ~ year_scaled + s(x,y, bs = "sos") + s(x, y, by = year_scaled, bs = "sos"),
    data = doy_df |> mutate(year = year - min(year)),
    method = "REML"
  )
summary(m3)
AICtab(m1, m2, m3)

#yes!
summary(m3)
#parameteric term of year goes away (no overall trend over time?)
#or maybe I did the interaction wrong?

m4 <- 
  gam(
    doy ~ year_scaled + s(x,y) + ti(x, y, year_scaled),
    data = doy_df |> mutate(year = year - min(year)),
    method = "REML"
  )

AICtab(m1,m2,m3,m4)

summary(m4)
draw(m4, parametric = TRUE, rug = FALSE)
