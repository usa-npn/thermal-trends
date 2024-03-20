# Exploring spatial GAMs and geographically-weighted regression as alternatives to pixel-wise regression with FDR correction of p-values.
library(targets)
tar_load_globals()
library(mgcv)
library(gratia)
library(bbmle)
tar_load(gdd_doy_stack_200)

doy_df <- gdd_doy_stack_200[[1:5]] |> #just use 5 years for testing
  as_tibble(xy = TRUE, na.rm = TRUE) |>
  pivot_longer(
    c(-x,-y),
    names_to = "year",
    values_to = "doy",
    names_transform = list(year = as.numeric)
  )

doy_df


m <- gam(doy ~ year + s(x,y), data = doy_df, method = "REML")
summary(m)
gratia::draw(m, rug = FALSE)
m2 <- gam(doy ~ year + s(x, y, by = year), data = doy_df, method = "REML")
summary(m2)
gratia::draw(m2, rug = FALSE)

AIC(m, m2)
# interaction improves

# try gaussian process basis
m3 <- gam(doy ~ year + s(x, y, by = year, bs = "gp"), data = doy_df, method = "REML")

#try spline on sphere (for lat long coords)
m4 <- gam(doy ~ year + s(x, y, by = year, bs = "sos"), data = doy_df, method = "REML")

AICctab(m, m2, m3, m4)
#SOS wins!

# are you supposed to include both s(x,y) and s(x,y, by = year) to get both main effect of geography and interaction with year?
# I think mostly the interaction term is of interest—is DOY advancing faster in some locations than others? But to get this, might need to pull out the main effect of geography?

m5 <- gam(doy ~ year + s(x,y, bs = "sos") + s(x, y, by = year, bs = "sos"), data = doy_df, method = "REML")

AICctab(m4, m5)

#m4 is better, regardless
gratia::draw(m4, rug = FALSE, crs = crs(doy_trend_200))
#blagh, not working
plot(m4)
#hmm, not right because it's the whole sphere??

#probably need to predict over custom grid of values within the borders
#also, SOS smoother probably not necessary because its such a small region

AICtab(m3, m4)

#although ∆AIC is quite large!
