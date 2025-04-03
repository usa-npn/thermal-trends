library(targets)
library(terra)
library(tidyterra)
library(dplyr)
library(tidyr)
library(ggplot2)
# library(exactextractr)
tar_load(c(
  stack_2500,
  doy_summary_2500
))

#require 10 years of DOYs
doy_slopes <- mask(
  doy_summary_2500[["slope"]],
  doy_summary_2500[["count"]] >= 10,
  maskvalue = FALSE
)
top_12 <- doy_slopes |>
  as_tibble(xy = TRUE, cells = TRUE, na.rm = TRUE) |>
  mutate(cell = as.factor(cell)) |>
  arrange(desc(abs(slope))) |>
  slice_head(n = 12)

obs <- stack_2500 |>
  terra::extract(top_12 |> select(x, y), cells = TRUE) |>
  select(-ID) |>
  pivot_longer(
    -cell,
    names_to = "year",
    values_to = "DOY"
  ) |>
  mutate(
    cell = as.factor(cell),
    year = as.integer(year),
    year_scaled = year - 1981
  ) |>
  filter(!is.na(DOY))

lm_line <- obs |>
  group_by(cell) |>
  group_nest() |>
  mutate(
    lm = purrr::map(data, \(x) lm(DOY ~ year_scaled, data = x))
  ) |>
  mutate(
    intercept = purrr::map_dbl(lm, \(x) coef(x)[1]),
    slope = purrr::map_dbl(lm, \(x) coef(x)[2])
  ) |>
  select(-lm, -data)


ggplot(obs, aes(x = year_scaled, y = DOY)) +
  facet_wrap(vars(cell), labeller = label_both) +
  geom_point(size = 3) +
  geom_abline(aes(intercept = intercept, slope = slope), data = lm_line) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  theme_bw()

#these don't look like terrible fits to me.  I think these are actually extremes
