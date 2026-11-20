# Harvard forest has predicted DOY for 2500GDD in 1981 > 365 with the survival
# regression which messes up the 6-panel figure.  What alternative city would
# work?

library(targets)
library(terra)
library(dplyr)

tar_load(stack_vrt_2500)
mass_roi <- maps::map(
  database = "state",
  regions = "Massachusetts",
  plot = FALSE,
  fill = TRUE
) |>
  sf::st_as_sf() |>
  sf::st_combine() |>
  terra::vect()


year <- as.integer(names(stack_vrt_2500))
# scale
year_scaled <- year - min(year, na.rm = TRUE)
n <- length(year)

# Create layers for censored DOY and censored indicator
event <- terra::ifel(is.na(stack_vrt_2500), 0, 1) |>
  terra::crop(mass_roi, mask = TRUE)
survdoy <- terra::ifel(is.na(stack_vrt_2500), 365, stack_vrt_2500) |>
  terra::crop(mass_roi, mask = TRUE)
# Stack layers
stack_surv_event <- c(survdoy, event) # layers 1:n = DOY; layers (n+1):2n = event

out <- terra::app(stack_surv_event, \(v) {
  time <- v[1:n]
  status <- v[(n + 1):(2 * n)]
  if (sum(status == 1, na.rm = TRUE) >= 10) {
    df <- tibble(time, status, year_scaled) |>
      filter(is.finite(time) & is.finite(status))

    fit <- try(
      survival::survreg(
        survival::Surv(time, status) ~ year_scaled,
        dist = "gaussian"
      )
    )
    if (!inherits(fit, "try-error")) {
      pred_1981 <- predict(fit, newdata = list(year_scaled = 0)) |> unname()
    } else {
      pred_1981 <- NA_real_
    }
  } else {
    pred_1981 <- NA_real_
  }
  c(pred_1981 = pred_1981)
})

plot(out <= 365)
