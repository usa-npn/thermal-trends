# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(geotargets)

# Set target options:
tar_option_set(
  # Packages that your targets need for their tasks.
  packages = c("prism", "fs", "terra", "stringr", "lubridate", "colorspace", "purrr",
               "ggplot2", "tidyterra", "glue", "car"),
  #
  # Pipelines that take a long time to run may benefit from
  # optional distributed computing. To use this capability
  # in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller that scales up to a maximum of two workers
  # which run as local R processes. Each worker launches when there is work
  # to do and exits if 60 seconds pass with no tasks to run.
  #
    controller = crew::crew_controller_local(workers = 3, seconds_idle = 60)
  #
  # Alternatively, if you want workers to run on a high-performance computing
  # cluster, select a controller from the {crew.cluster} package.
  # For the cloud, see plugin packages like {crew.aws.batch}.
  # The following example is a controller for Sun Grid Engine (SGE).
  # 
  #   controller = crew.cluster::crew_controller_sge(
  #     # Number of workers that the pipeline can scale up to:
  #     workers = 10,
  #     # It is recommended to set an idle time so workers can shut themselves
  #     # down if they are not running tasks.
  #     seconds_idle = 120,
  #     # Many clusters install R as an environment module, and you can load it
  #     # with the script_lines argument. To select a specific verison of R,
  #     # you may need to include a version string, e.g. "module load R/4.3.2".
  #     # Check with your system administrator if you are unsure.
  #     script_lines = "module load R"
  #   )
  #
  # Set other options as needed.
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
tar_plan(
  # years = seq(1981, 2023, by = 4),
  years = 1981:2023,
  tar_target(
    name = prism_tmean,
    command = get_prism_tmean(years),
    pattern = map(years),
    deployment = "main", #prevent downloads from running in parallel
    format = "file"
  ),
  tar_file(casc_ne_file, "data/Northeast_CASC.zip"),
  tar_terra_vect(casc_ne, read_casc_ne(casc_ne_file)),
  tar_map(
    values = list(threshold = c(50, 1000, 2500)),
    tar_terra_rast(
      gdd_doy,
      calc_gdd_doy(rast_dir = prism_tmean, casc_ne = casc_ne, gdd_threshold = threshold),
      pattern = map(prism_tmean),
      iteration = "list"
    ),
    #TODO: this is a workaround to get the output of the dynamic branching to be SpatRasters with multiple layers instead of lists of SpatRasters. Would love to not have to have this target.
    tar_terra_rast(
      gdd_doy_stack,
      terra::rast(unname(gdd_doy)),
      deployment = "main" #workaround for bug in geotargets: https://github.com/njtierney/geotargets/issues/52
    ),
    tar_target(
      doy_plot,
      plot_doy(gdd_doy_stack, gdd_threshold = threshold),
      format = "file"
    ),
    tar_terra_rast(
      doy_trend,
      get_lm_slope(gdd_doy_stack)
    ),
    tar_target(
      trend_plot,
      plot_slopes(doy_trend, gdd_threshold = threshold)
    ),
    tar_terra_rast(
      normals_summary,
      summarize_normals(gdd_doy_stack),
      deployment = "main"
    ),
    tar_target(
      normals_mean_plot,
      plot_normals_mean(normals_summary, threshold, height = 7, width = 7),
      format = "file"
    )
  ),
  
  # Reports
  tar_quarto(spatial_report, path = "docs/spatial-trends-report.qmd", working_directory = "docs"),
  tar_quarto(readme, path = "README.Qmd", cue = tar_cue("always"))
)
