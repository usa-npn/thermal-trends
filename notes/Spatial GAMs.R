# Exploring spatial GAMs and geographically-weighted regression as alternatives to pixel-wise regression with FDR correction of p-values.
library(targets)
tar_load_globals()
library(mgcv)
library(gratia)
library(bbmle)
tar_load(gdd_doy_stack_50)
library(tidyverse)

doy_df <-
  #downsample spatially for testing
  aggregate(gdd_doy_stack_50, fact = 8) |> 
  as_tibble(xy = TRUE, na.rm = TRUE) |>
  pivot_longer(
    c(-x,-y),
    names_to = "year",
    values_to = "doy",
    names_transform = list(year = as.numeric)
  )

doy_df

#basic model with trend over year and smoother for lat/lon
m <- gam(doy ~ year + s(y, x), data = doy_df, method = "REML")
summary(m)
appraise(m)
draw(m, parametric = TRUE)

#uhh, partial effect should be in units of DOY, right?  Not good that it's 3850-ish
# do I need to rescale year?
doy_df <- doy_df |> mutate(year_scaled = year - min(year))
m1 <-
  gam(
    doy ~ year_scaled + s(y, x),
    data = doy_df,
    method = "REML"
  )
summary(m1)
appraise(m1)
draw(m1, parametric = TRUE)
#ok, yeah, that makes more sense I think?

# Try spline on the sphere
m1a <- 
  gam(
    doy ~ year_scaled + s(y, x, bs = "sos"),
    data = doy_df,
    method = "REML"
  )
AICtab(m1, m1a)
appraise(m1a)
draw(m1a, parametric = TRUE)

#include interaction as tensor product with simple construction
m2 <- gam(
  doy ~ te(y, x, year_scaled),
  data = doy_df,
  method = "REML"
)
AICtab(m1a, m2)
summary(m2)
appraise(m2)
draw(m2) & coord_flip()

#more complicated things are possible like using a 2d thin plate spline for lat and long and a cubic regression spline for year.
m3 <- gam(
  doy ~ te(y, x, year_scaled, d = c(2, 1), bs = c("tp", "cs")),
  data = doy_df,
  method = "REML"
)
AICtab(m1a, m2, m3)
summary(m3)
appraise(m3)
draw(m3) & coord_flip()

#sos version
m3a <- gam(
  doy ~ te(y, x, year_scaled, d = c(2, 1), bs = c("sos", "cs")),
  data = doy_df,
  method = "REML"
)
AICtab(m1a, m2, m3, m3a)
summary(m3a)
draw(m3a) + coord_flip()

#we can also separate out main effects with ti()
m4 <- gam(
  doy ~ s(y, x) + #geography main effect
    s(year_scaled, bs = "cs", k = 4) + #year main effect
    ti(y, x, year_scaled, d = c(2, 1), bs = c("tp", "cs"), k = c(NULL, 4)), #geography-year interaction
  data = doy_df,
  method = "REML"
)
AICtab(m3a, m4)
summary(m4)
appraise(m4)
draw(m4)

#would need to figure out appropriate smoothers, number of knots, etc. and interpretation is difficult, but very informative

# sos version
m4a <- gam(
  doy ~ s(y, x, bs = "sos") + #geography main effect
    s(year_scaled, bs = "cs", k = 4) + #year main effect
    ti(y, x, year_scaled, d = c(2, 1), bs = c("sos", "cs"), k = c(NULL, 4)), #geography-year interaction
  data = doy_df,
  method = "REML"
)
AICtab(m3a, m4, m4a)
summary(m4a)
appraise(m4a)
draw(m4a)


#If the effects of lat and lon are on different scales, might be better to use `te()`
m5 <- gam(
  doy ~ te(y, x) + #geography main effect
    s(year_scaled, bs = "cs", k = 4) + #year main effect
    ti(y, x, year_scaled, d = c(2, 1), bs = c("tp", "cs"), k = c(NULL, 4)), #geography-year interaction
  data = doy_df,
  method = "REML"
)
AICtab(m3a, m4a, m5) #not better
summary(m5)
appraise(m5)
draw(m5, rug = FALSE)

# Here is my attempt to do an interaction between a linear year_scaled term and a spatial smoother
# https://stats.stackexchange.com/questions/465035/what-is-the-correct-mgcv-syntax-for-interacting-a-smooth-with-an-interaction-of
m6 <- gam(
  doy ~ s(y, x, bs = "sos") + #geography main effect
    year_scaled + #parametric year main effect
    ti(y, x, year_scaled, d = c(2, 1), bs = c("sos", "re")), #geography-year interaction with random slope for year???
  data = doy_df,
  method = "REML"
)
AICtab(m3a, m4a, m6)
summary(m6)
appraise(m6)
draw(m6, parametric = TRUE)
#m3a is best by AIC
#m4a is supposed to be same model as m3a, but paramaterized for easier interpretation of interactions
#m6 restricts year to linear and is a worse fit, but maybe easier interpretation of slopes??


# Slope esitmates ---------------------------------------------------------
# Perhaps it's just best to use the best fit model (m3a) and extract estimated slopes with ±95% CI
# Here I'm getting slope estimates for each pixel, I think?

library(marginaleffects)

m3a_slopes <- 
  marginaleffects::slopes(m3a, variables = "year_scaled", by = c("y", "x"), p_adjust = "fdr") |>
  as_tibble() 

m3a_slopes |> 
  ggplot(aes(x, y, fill = estimate)) +
  geom_tile() +
  scale_fill_continuous_diverging(rev = TRUE) +
  coord_sf(crs = crs(gdd_doy_stack_50))

#looks somewhat legit—similar to pixel-wise regression.  Some regions are reaching threshold about a day earlier per year, some about a day later per year.  Not really sure how this works though when year isn't linear. 

#TODO read more about slopes() and avg_slopes() with GAMs—what does it do?  over what range does it estimate dx/dy?
#TODO mask points where CI of slope overlaps 0.

#might be best to turn back into SpatRaster?

m3a_slopes_rast <- m3a_slopes |> 
  select(x, y, estimate, p.value) |> rast()

crs(m3a_slopes_rast) <- crs(gdd_doy_stack_50)

non_sig <- m3a_slopes_rast |> 
  mutate(non_sig = ifelse(p.value > 0.05, TRUE, NA)) |> 
  select(non_sig) |> 
  as.polygons() |> 
  # as.data.frame(xy = TRUE)
  st_as_sf()

library(ggpattern)

ggplot() +
  geom_spatraster(data = m3a_slopes_rast, aes(fill = estimate)) +
  scale_fill_continuous_diverging(na.value = "transparent", rev = TRUE) +
  geom_sf_pattern(
    data = non_sig,
    aes(pattern_fill = ""), #TODO trick to get legend to show up, but there's a new way to do this in ggplot2 I think
    pattern = "crosshatch",
    fill = NA,
    colour = NA,
    pattern_alpha = 0.5, #maybe not necessary
    pattern_size = 0.05, #make lines smaller
    pattern_spacing = 0.01, #make lines closer together
    pattern_res = 200, #make lines less pixelated
  ) +
  scale_pattern_fill_manual(values = c("grey30")) +
  labs(title = "Estimated change in DOY over time for 50 GDD threshold", 
       fill = "∆DOY/yr", pattern_fill = "p > 0.05") +
  coord_sf() +
  theme_minimal()
