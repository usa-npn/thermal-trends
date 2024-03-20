library(prism)
library(fs)
library(terra)
library(stringr)
library(lubridate)
library(colorspace)
library(purrr)

# Download tmean data -----------------------------------------------------
prism_set_dl_dir("prism", create = TRUE)

# start with a 2 years of daily data
# Structure downloads as "hive" with folders by year.  Makes tracking changes and reading in files easier
years <- 2022:2023
walk(years, \(year) {
  prism_set_dl_dir(path("prism", year), create = TRUE)
  get_prism_dailys(type = "tmean", minDate = make_date(year, 1, 1), maxDate = make_date(year, 12, 31))
})

# get_prism_dailys(type = "tmean", minDate = "2022-01-01", maxDate = "2023-12-31")

# Read in data ------------------------------------------------------------
paths_2022 <- dir_ls("prism/2022", glob = "*.bil", recurse = TRUE)
paths_2023 <- dir_ls("prism/2023", glob = "*.bil", recurse = TRUE)
#convert filenames to DOY to name layers later
doys_2022 <- paths_2022 |>
  fs::path_file() |>
  str_extract("\\d{8}") |>
  lubridate::ymd() |> 
  lubridate::yday()

doys_2023 <- paths_2023 |>
  fs::path_file() |>
  str_extract("\\d{8}") |>
  lubridate::ymd() |> 
  lubridate::yday()

#read in as raster stacks
prism_2022 <- rast(paths_2022)
prism_2023 <- rast(paths_2023)
names(prism_2022) <- doys_2022
names(prism_2023) <- doys_2023
units(prism_2022) <- units(prism_2023) <- "ºC"

#sort layers by DOY
prism_2022 <- subset(prism_2022, as.character(min(doys_2022):max(doys_2022)))
prism_2023 <- subset(prism_2023, as.character(min(doys_2023):max(doys_2023)))

# Calculate accumulated GDD -----------------------------------------------

# convert to degree days
# function for a single layer:
calc_dd <- function(tmean, base = 0) {
  if (base != 0) {
    dd <- tmean - base
  } else {
    dd <- tmean
  }
  dd[dd < 0] <- 0
  dd
}
# apply to every pixel in every layer:
gdd_2022 <- app(prism_2022, calc_dd)
gdd_2023 <- app(prism_2023, calc_dd)

# convert to accumulated dd
agdd_2022 <- cumsum(gdd_2022)
agdd_2023 <- cumsum(gdd_2023)

# DOY to reach a single threshold
threshold <- 200
gdd_doy_2022 <- which.lyr(agdd_2022 > threshold)
gdd_doy_2023 <- which.lyr(agdd_2023 > threshold)

gdd_stack <- c(gdd_doy_2022, gdd_doy_2023)
names(gdd_stack) <- c("2022", "2023")

writeRaster(gdd_stack,
            "~/Desktop/crimmins_doy_stack.gtiff", filetype = "GTiff")

#nicer plot:
library(ggplot2)
library(tidyterra)

ggplot() +
  geom_spatraster(data = gdd_stack) +
  scale_fill_viridis_c(na.value = "transparent", direction = -1) +
  facet_wrap(~lyr) +
  labs(
    title = glue::glue("Days to reach > {threshold} GDD"),
    fill = "DOY"
  ) 

# Assess trends ---------------------------------------------------------------------

#this is where `stars` might make things easier?

# Simple pixel-wise linear regression
time <- 2022:2023
getTrend <- function(x) {
  if (is.na(x[1])) {
    NA
  } else {
    m = lm(x ~ time)
    m$coefficients[2]
  }
}

doy_slopes <- app(gdd_stack, getTrend)

ggplot() +
  geom_spatraster(data = doy_slopes) +
  scale_fill_continuous_diverging(na.value = "transparent") +
  theme_minimal() +
  labs(title = "Change in DOY to reach 200 GDD",
       subtitle = "Data from 2022 and 2023 only",
       fill = "∆ DOY")
