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
    minutes = set_units(seconds, "seconds") |> set_units("minutes") |> as.numeric(),
    size_mb = set_units(bytes, "bytes") |> set_units("megabytes") |> as.numeric(),
    df = fct_inseq(df)
  ) |> 
  ggplot(aes(x = resolution_km, y = minutes, color = df)) +
  geom_line() +
  scale_x_reverse() +
  scale_color_viridis_d(option = "D", end = 0.8)
           
