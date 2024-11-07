library(targets)
library(dplyr)
library(tibble)
library(tidyr)
library(ggplot2)
library(stringr)

tar_load(city_slopes_df)
city_slopes_df

city_slopes_df |> 
  separate_wider_delim(gam, names = c("trash", "threshold"), delim = "_") |> 
  select(-trash) |> 
  mutate(threshold = as.numeric(str_extract(threshold, "\\d+"))) |> 
  ggplot(aes(x = threshold, y = estimate, color = city)) +
  geom_point() +
  geom_line() +
  labs(
    x = "GDD Threshold",
    y = "Trend (DOY/yr)",
    caption = "Trend is measured as the average of instantaneous slopes from the fitted model for each year"
  )
  
