library(tidyverse)
library(units)
meta <- read_csv("tar_meta_hpc.csv")

meta |> 
  filter(str_starts(name, "gam_"), !str_detect(name, "df")) |> 
  select(name, bytes, seconds) |> 
  separate(name, into = c("trash", "resolution", "df")) |> 
  select(-trash) |> 
  mutate(
    resolution_km = set_units(as.numeric(resolution), "m") |> set_units("km") |> as.numeric(),
    size_mb = set_units(bytes, "bytes") |> set_units("megabytes") |> as.numeric()
  ) |> 
  ggplot(aes(x = resolution_km, y = seconds, color = factor(df))) +
  geom_line() +
  scale_x_reverse()
           