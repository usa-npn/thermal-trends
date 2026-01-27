# Created by use_targets().
# Follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(geotargets)
library(crew)
library(qs2) # for format = "qs"

# currently this is running on a Jetstream 2 instance with 16 cores and 60GB of
# RAM with 5 parallel workers—you may need to adjust the number of workers to
# run on your system.
controller_js2 <-
  crew::crew_controller_local(
    name = "js2",
    workers = 5,
    seconds_idle = 60,
    options_local = crew::crew_options_local(
      log_directory = "logs/"
    )
  )

threshold <- c(
  # in ºF
  50,
  350,
  650,
  1250,
  1950,
  2500
)

# Set target options:
tar_option_set(
  # Only check last modified date when deciding whether to re-run
  trust_timestamps = TRUE,
  # Packages that your targets need for their tasks.
  packages = c(
    "fs",
    "terra",
    "stringr",
    "lubridate",
    "colorspace",
    "purrr",
    "ggplot2",
    "tidyterra",
    "glue",
    "httr2",
    "readr",
    "sf",
    "maps",
    "tidyr",
    "dplyr",
    "forcats"
  ),
  controller = controller_js2,
  # assume workers have access to the _targets/ data store
  storage = "worker",
  retrieval = "worker",
  memory = "auto",
  # allows use of `tar_workspace()` to load dependencies of an errored target
  # for interactive debugging.
  workspace_on_error = TRUE
)
geotargets::geotargets_option_set(
  gdal_vector_driver = "GeoJSON",
  gdal_raster_driver = "GTiff"
)
# `source()` the R scripts in the R/ folder with your custom functions:
targets::tar_source()

tarchetypes::tar_plan(
  years = 1981:2023,
  tar_target(
    name = prism_tmin,
    command = get_prism(years, "tmin"),
    pattern = map(years),
    deployment = "main",
    format = "file",
    description = "download PRISM tmin"
  ),
  tar_target(
    name = prism_tmax,
    command = get_prism(years, "tmax"),
    pattern = map(years),
    deployment = "main",
    format = "file",
    description = "download PRISM tmax"
  ),
  tar_target(
    roi_sf,
    make_roi_sf(),
    deployment = "main",
    description = "sf of NE states"
  ),
  tar_terra_vect(
    roi,
    make_roi(),
    deployment = "main",
    description = "SpatVector of NE states"
  ),
  tar_terra_vect(
    poi,
    make_poi(),
    deployment = "main",
    description = "points of interest"
  ),
  tar_map(
    # for each threshold...
    values = list(threshold = threshold),
    tar_terra_rast(
      gdd_doy,
      calc_gdd_be_doy(
        tmin_dir = prism_tmin, #ºC, but gets converted to ºF
        tmax_dir = prism_tmax, #ºC, but gets converted to ºF
        roi = roi,
        gdd_threshold = threshold, #ºF
        gdd_base = 50 #ºF
      ),
      pattern = map(prism_tmin, prism_tmax),
      description = "calc DOY to reach threshold GDD"
    ),
    # Combine list of SpatRasters into multi-layer SpatRaster
    # TODO: use tar_terra_vrt() here to save disk space?
    tar_terra_rast(
      stack,
      terra::rast(unname(gdd_doy))
    ),
    # summary statistics across years
    tar_terra_rast(
      doy_summary,
      calc_doy_summary(stack)
    ),
    # summarize across space
    tar_target(
      summary_summary,
      summarize_summary(doy_summary)
    ),
    # point statistics
    tar_target(
      poi_stats,
      extract_summary_poi(doy_summary, poi)
    )
  ), # end tar_map()
  tar_file(
    poi_stats,
    {
      dplyr::bind_rows(!!!rlang::syms(glue::glue("poi_stats_{threshold}"))) |>
        readr::write_csv("output/summary_stats/point_stats.csv")
      "output/summary_stats/point_stats.csv"
    }
  ),
  tar_target(
    poi_pred_doy,
    pred_poi_stats(poi, !!!rlang::syms(glue::glue("stack_{threshold}")))
  ),
  tar_file(
    poi_shifts_plot,
    plot_poi_shifts(poi_pred_doy, roi),
    packages = c("dplyr", "ggplot2", "cowplot", "terra", "tidyterra", "ggpubr")
  ),
  tar_target(
    summary_summary,
    dplyr::bind_rows(!!!rlang::syms(glue::glue("summary_summary_{threshold}")))
  ),
  tar_file(
    summary_plot,
    plot_summary_grid(
      roi = roi,
      !!!rlang::syms(glue::glue("doy_summary_{threshold}"))
    ),
    packages = c("ggplot2", "tidyterra", "stringr", "terra", "purrr")
  ),
  tar_file(
    sd_plot,
    plot_sd_doy(
      roi = roi,
      !!!rlang::syms(glue::glue("doy_summary_{threshold}"))
    ),
    packages = c("ggplot2", "tidyterra", "stringr", "terra", "purrr")
  ),
  tar_file(
    count_plot,
    plot_count_years(
      roi = roi,
      !!!rlang::syms(glue::glue("doy_summary_{threshold}"))
    ),
    packages = c("ggplot2", "tidyterra", "stringr", "terra", "purrr")
  ),
  tar_file(
    linear_slopes_plot,
    plot_linear_slopes(
      roi = roi,
      !!!rlang::syms(glue::glue("doy_summary_{threshold}"))
    ),
    packages = c(
      "ggplot2",
      "colorspace",
      "tidyterra",
      "terra",
      "purrr",
      "ggtext"
    )
  ),
  tar_file(
    by_state_summary,
    summarize_doy_state(
      !!!rlang::syms(glue::glue("doy_summary_{threshold}")),
      roi_sf = roi_sf
    )
  ),
  # TODO finish up this function to just get the data and pull plot code out to a separate function
  tar_terra_rast(
    slope_differences,
    make_slope_differences(
      !!!rlang::syms(glue::glue("doy_summary_{threshold}"))
    )
  ),
  tar_file(
    by_state_slope_diff_summary,
    summarize_slope_diffs_state(slope_differences, roi_sf)
  ),
  # Faceted by thresold comparison, single scale
  tar_file(
    slope_differences_plot,
    plot_slope_differences(
      roi = roi,
      slope_differences
    ),
    packages = c(
      "ggplot2",
      "colorspace",
      "tidyterra",
      "terra",
      "purrr",
      "ggtext"
    )
  ),
  tarchetypes::tar_quarto(readme, "README.Qmd")
)
