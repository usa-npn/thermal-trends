# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(geotargets)
library(crew)
library(crew.cluster)

# Detect whether you're on HPC & not with an Open On Demand session (which cannot submit SLURM jobs) and set appropriate controller
slurm_host <- Sys.getenv("SLURM_SUBMIT_HOST")
hpc <- grepl("hpc\\.arizona\\.edu", slurm_host) & !grepl("ood", slurm_host)
# If on HPC, use SLURM jobs for parallel workers
if (isTRUE(hpc)) {
  controller <- crew.cluster::crew_controller_slurm(
    workers = 3, #TODO increase for production
    seconds_idle = 120, #time until workers are shut down after idle
    slurm_partition = "standard",
    slurm_time_minutes = 60, #wall time for each worker
    slurm_log_output = "logs/crew_log_%A.out",
    slurm_log_error = "logs/crew_log_%A.err",
    slurm_memory_gigabytes_per_cpu = 4,
    slurm_cpus_per_task = 1,
    script_lines = c(
      "#SBATCH --account theresam",
      "module load R",
      "module load gdal",
      "module load eigen"
      #add additional lines to the SLURM job script as necessary here
    )
  )
  #when on HPC, do ALL the thresholds
  # threshold <- seq(50, 2500, by = 50) #Uncomment to do them all
  threshold <- c(50, 100, 1000, 2500)
  
} else { # If local or on OOD session, use multiple R sessions for workers
  controller <- crew::crew_controller_local(workers = 3, seconds_idle = 60)
  
  threshold <- c(50, 1000, 2500)
}

# Set target options:
tar_option_set(
  # Packages that your targets need for their tasks.
  packages = c("prism", "fs", "terra", "stringr", "lubridate", "colorspace", "purrr",
               "ggplot2", "tidyterra", "glue", "car"),
  controller = controller
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
main <- tar_plan(
  years = seq(1981, 2023, by = 8),
  # years = 1981:2023,
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
    values = list(threshold = threshold),
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
)

reports <- tar_plan(
  # Reports
  tar_quarto(spatial_report, path = "docs/spatial-trends-report.qmd", working_directory = "docs"),
  tar_quarto(readme, path = "README.Rmd", cue = tar_cue("always"))
)

#if on HPC don't render quarto docs (no quarto or pandoc on HPC)
if (isTRUE(hpc)) {
  main
} else {
  list(main, reports)
}