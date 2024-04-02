library(targets)
tar_load_globals()
library(grid)

tar_load(doy_trend_50)

#playing with ideas for how to represent non-significant areas of map

#fake non-significant areas
test <- doy_trend_50 < 2 & doy_trend_50 > -2

test_polygons <- as.polygons(test)
test_poly_true <- test_polygons[values(test_polygons)==1]


#"grey out" non-significant areas with a transparent layer
ggplot() +
  geom_spatraster(data = doy_trend_50) +
  geom_spatvector(data = test_poly_true, alpha = 0.5, fill = "white", color = NA) +
  scale_fill_continuous_diverging(na.value = "transparent") +
  theme_minimal()


#Make non-significant areas NAs
test2 <- doy_trend_50
test2[test2 < 2 & test2 > -2] <- NA

ggplot() +
  geom_spatraster(data = test2) +
  scale_fill_continuous_diverging(na.value = "grey") +
  theme_minimal()
#not as good because you can only have one na value and transparent looks weird\

# add layer of hatching
library(ggpattern)
library(sf)

sf::st_as_sf(test_poly_true) |> 
  as_tibble()

ggplot() +
  geom_spatraster(data = doy_trend_50) +
  geom_sf_pattern(
    data = st_as_sf(test_poly_true),
    pattern = "crosshatch",
    pattern_fill = "grey30",
    pattern_aspect_ratio = 1,
    fill = NA,
    colour = NA,
    pattern_alpha = 0.5, #maybe not necessary
    pattern_size = 0.05,
    pattern_spacing = 0.01,
    pattern_res = 200
  ) +
  scale_fill_continuous_diverging(na.value = "transparent") +
  theme_minimal()



# Getting the actual p-values ---------------------------------------------

tar_load(gdd_doy_stack_50)
library(car)

years <- as.numeric(names(gdd_doy_stack_50))
getTrend <- function(x) {
  if (any(is.na(x))) {
    c(slope = NA, p.val = NA)
  } else {
    m = lm(x ~ years)
    c(slope = m$coefficients[2], p.val = Anova(m)$`Pr(>F)`[1])
  }
}

slope_rast <- app(gdd_doy_stack_50, getTrend)
#adjust for false discovery rate
p_adj <- app(slope_rast[[2]], p.adjust, method = "fdr")

#no values are significant after FDR correction
plot(p_adj <= 0.05)

non_sig <- as.polygons(p_adj < 0.05) |> filter(lyr.1 == 0)  |> mutate(lyr.1 = as.factor(lyr.1))

ggplot() +
  geom_spatraster(data = slope_rast, aes(fill = slope.years)) +
  geom_sf_pattern(
    data = st_as_sf(non_sig),
    aes(pattern_fill = ""), #TODO trick to get legend to show up, but there's a new way to do this in ggplot2 I think
    pattern = "crosshatch",
    fill = NA,
    colour = NA,
    pattern_alpha = 0.5, #maybe not necessary
    pattern_size = 0.05, #make lines smaller
    pattern_spacing = 0.01, #make lines closer together
    pattern_res = 200, #make lines less pixelated
  ) +
  scale_pattern_fill_manual("p > 0.05", values = c("grey30")) +
  scale_fill_continuous_diverging(na.value = "transparent", rev = TRUE) +
  labs(fill = "∆DOY") +
  theme_minimal() 
