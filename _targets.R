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
library(qs) #for format = "qs"

# Detect whether you're on HPC & not with an Open On Demand session (which cannot submit SLURM jobs).
slurm_host <- Sys.getenv("SLURM_SUBMIT_HOST")
hpc <- grepl("hpc\\.arizona\\.edu", slurm_host) & !grepl("ood", slurm_host)

controller_hpc_light <- 
  crew.cluster::crew_controller_slurm(
    name = "hpc_light",
    workers = 5, 
    # make workers semi-persistent: 
    tasks_max = 40, # shut down SLURM job after completing 40 targets
    seconds_idle = 300, # or when idle for some time
    garbage_collection = TRUE, # run garbage collection between tasks
    launch_max = 5L, # number of unproductive launched workers until error
    slurm_partition = "standard",
    slurm_time_minutes = 60, #wall time for each worker
    slurm_log_output = "logs/crew_log_%A.out",
    slurm_log_error = "logs/crew_log_%A.err",
    slurm_memory_gigabytes_per_cpu = 5,
    slurm_cpus_per_task = 3, #use 3 cpus per worker
    script_lines = c(
      "#SBATCH --account theresam",
      #use optimized openBLAS for linear algebra
      "export LD_PRELOAD=/opt/ohpc/pub/libs/gnu8/openblas/0.3.7/lib/libopenblas.so",
      "module load gdal/3.8.5 R/4.4 eigen/3.4.0"
    )
  )
controller_hpc_heavy <- 
  crew.cluster::crew_controller_slurm(
    name = "hpc_heavy",
    workers = 3, 
    seconds_idle = 1000,
    tasks_max = 20,
    garbage_collection = TRUE,
    launch_max = 5L,
    slurm_partition = "standard",
    slurm_time_minutes = 360, #wall time for each worker
    slurm_log_output = "logs/crew_log_%A.out",
    slurm_log_error = "logs/crew_log_%A.err",
    slurm_memory_gigabytes_per_cpu = 5,
    slurm_cpus_per_task = 6, 
    script_lines = c(
      "#SBATCH --account theresam",
      "export LD_PRELOAD=/opt/ohpc/pub/libs/gnu8/openblas/0.3.7/lib/libopenblas.so",
      "module load gdal/3.8.5 R/4.4 eigen/3.4.0"
    )
  )

controller_local <-
  crew::crew_controller_local(
    name = "local",
    workers = 3, 
    seconds_idle = 60,
    options_local = crew::crew_options_local(
      log_directory = "logs/"
    )
  )

if (isTRUE(hpc)) { #when on HPC, do ALL the thresholds
  threshold <- seq(50, 2500, by = 50)
} else { # only do select thresholds
  threshold <- c(50, 1250, 2500)
}

# Set target options:
tar_option_set(
  trust_timestamps = TRUE, #just check last modified date when deciding whether to re-run
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
    "car",
    "httr2",
    "readr",
    "sf",
    "maps",
    "tidyr",
    "dplyr",
    "broom",
    "forcats",
    "mgcv"
  ), 
  controller = crew::crew_controller_group(
    controller_hpc_heavy, controller_hpc_light, controller_local
  ),
  resources = tar_resources(
    crew = tar_resources_crew(controller = ifelse(isTRUE(hpc), "hpc_light", "local"))
  ),
  #assume workers have access to the _targets/ data store
  storage = "worker",
  retrieval = "worker",
  #allows use of `tar_workspace()` to load dependencies of an errored target for interactive debugging.
  workspace_on_error = TRUE 
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()


main <- tar_plan(
  years = 1981:2023,
  tar_target(
    name = prism_tmean,
    command = get_prism_tmean(years),
    pattern = map(years),
    deployment = "main", #prevent downloads from running in parallel
    format = "file", 
    description = "download PRISM data"
  ),
  tar_terra_vect(
    roi,
    make_roi(),
    deployment = "main",
    description = "vector for North East"
  ),
  tar_map( # for each threshold...
    values = list(threshold = threshold),
    tar_terra_rast(
      gdd_doy,
      calc_gdd_doy(rast_dir = prism_tmean, roi = roi, gdd_threshold = threshold),
      pattern = map(prism_tmean),
      iteration = "list",
      description = "calc DOY to reach threshold GDD"
    ),
    
    # This converts the output of the dynamic branching to be SpatRasters with
    # multiple layers instead of lists of SpatRasters. Would love to not have to
    # have this target, but there is no way to customize how iteration works.
    tar_terra_rast(
      gdd_doy_stack,
      terra::rast(unname(gdd_doy))
    ),
    tar_terra_rast(
      normals_summary,
      summarize_normals(gdd_doy_stack),
      deployment = "main"
    ),
    tar_target(
      normals_mean_gtiff,
      write_tiff(normals_summary[["mean"]],
                 filename = paste0("normals_mean_", threshold, ".tiff")),
      format = "file"
    ),
    tar_target(
      normals_sd_gtiff,
      write_tiff(normals_summary[["sd"]], 
                 filename = paste0("normals_sd_", threshold, ".tiff")),
      format = "file"
    ),
    tar_target(
      normals_mean_plot,
      plot_normals_mean(normals_summary, threshold, height = 7, width = 7),
      format = "file"
    ),
    tar_target(
      normals_sd_plot,
      plot_normals_sd(normals_summary, threshold, height = 7, width = 7),
      format = "file"
    )
  ),
)


gams <- tar_plan(
  #prep data
  tar_target(
    gam_df_50gdd,
    make_gam_df(gdd_doy_stack_50, res = 25000),
    format = "qs"
  ),
  tar_target(
    gam_df_1250gdd,
    make_gam_df(gdd_doy_stack_1250, res = 25000),
    format = "qs"
  ),
  tar_target(
    gam_df_2500gdd,
    make_gam_df(gdd_doy_stack_2500, res = 25000),
    format = "qs"
  ),
  #fit gams
  tar_target(
    gam_50gdd,
    fit_bam(gam_df_50gdd, k_spatial = 1000),
    format = "qs",
    resources = tar_resources(
      crew = tar_resources_crew(controller = ifelse(isTRUE(hpc), "hpc_heavy", "local"))
    )
  ),
  tar_target(
    gam_1250gdd,
    fit_bam(gam_df_1250gdd, k_spatial = 1000),
    format = "qs",
    resources = tar_resources(
      crew = tar_resources_crew(controller = ifelse(isTRUE(hpc), "hpc_heavy", "local"))
    )
  ),
  tar_target(
    gam_2500gdd,
    fit_bam(gam_df_2500gdd, k_spatial = 1000),
    format = "qs",
    resources = tar_resources(
      crew = tar_resources_crew(controller = ifelse(isTRUE(hpc), "hpc_heavy", "local"))
    )
  ),
  tar_file(
    smooths_50gdd,
    draw_smooth_estimates(gam_50gdd, roi)
  ),
  tar_file(
    smooths_1250gdd,
    draw_smooth_estimates(gam_1250gdd, roi)
  ),
  tar_file(
    smooths_2500gdd,
    draw_smooth_estimates(gam_2500gdd, roi)
  ),
  tar_target(
    k_check_50gdd,
    check_k(gam_50gdd),
    packages = c("mgcv", "dplyr")
  ),
  tar_target(
    k_check_1250gdd,
    check_k(gam_1250gdd),
    packages = c("mgcv", "dplyr")
  ),
  tar_target(
    k_check_2500gdd,
    check_k(gam_2500gdd),
    packages = c("mgcv", "dplyr")
  ),
  tar_target(
    k_check_df,
    bind_rows(!!!rlang::syms(c(
      "k_check_50gdd", "k_check_1250gdd", "k_check_2500gdd"
    ))),
    tidy_eval = TRUE,
    description = "Collect results from k_check targets"
  ),
  tar_file(
    k_check_df_csv,
    tar_write_csv(k_check_df, "output/gams/k_check.csv")
  ),
  tar_target(
    slope_newdata,
    #doesn't matter which dataset since all that is used is x,y, and year_scaled
    #using very coarse newdata regardless of resolution of original data.
    make_slope_newdata(gdd_doy_stack_50, res_m = 25000) |> 
      dplyr::group_by(group) |> 
      targets::tar_group(),
    #grouped by about 1000 pixels per group
    iteration = "group",
    format = "qs"
  ),
  tar_target(
    cities_sf,
    make_cities_sf(),
    description = "Example cities for plotting fitted trends"
  ),
  tar_map(
    values = list(gam = rlang::syms(c("gam_50gdd", "gam_1250gdd", "gam_2500gdd"))),
    tar_target(
      slopes,
      calc_avg_slopes(gam, slope_newdata),
      packages = c("marginaleffects", "mgcv"),
      resources = tar_resources(
        crew = tar_resources_crew(controller = ifelse(isTRUE(hpc), "hpc_heavy", "local"))
      ),
      pattern = map(slope_newdata),
      format = "qs"
    ),
    tar_target(
      slope_range,
      range(slopes$estimate),
      resources = tar_resources(
        crew = tar_resources_crew(controller = ifelse(isTRUE(hpc), "hpc_heavy", "local"))
      ),
      pattern = map(slopes),
      format = "qs"
    ),
    tar_target(
      city_plot,
      plot_city_trend(gam, cities_sf),
      description = "timeseries plot for example cities for each gam"
    )
  ),
  tar_target(
    slope_range,
    range(slope_range_gam_50gdd, slope_range_gam_1250gdd, slope_range_gam_2500gdd),
    description = "range across all thresholds for colorbar"
  ),
  tar_map(
    values = list(
      slopes = rlang::syms(c(
        "slopes_gam_50gdd", "slopes_gam_1250gdd", "slopes_gam_2500gdd"
      )),
      city_plot = rlang::syms(c(
        "city_plot_gam_50gdd", "city_plot_gam_1250gdd", "city_plot_gam_2500gdd"
      ))
    ),
    tar_file(
      slopes_plot,
      plot_avg_slopes(slopes, slope_range, roi, cities_sf, city_plot),
      packages = c("ggpattern", "ggplot2", "terra", "tidyterra", "patchwork"),
      resources = tar_resources(
        crew = tar_resources_crew(controller = ifelse(isTRUE(hpc), "hpc_heavy", "local"))
      )
    )
  )
)


tar_plan(
  main,
  gams
)
