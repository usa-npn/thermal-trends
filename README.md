

<!-- README.md is generated from README.Qmd. Please edit that file -->

# Estimating trends in phenology

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![DOI](https://zenodo.org/badge/889180921.svg)](https://doi.org/10.5281/zenodo.17087407)

<!-- badges: end -->

The goal of this project is to estimate spatial and temporal trends in
phenology in the Northeastern US using
[PRISM](https://prism.oregonstate.edu/) temperature data. This
analytical pipeline downloads daily data, calculates growing degree days
(GDD) for each day, and then finds the day of year (DOY) that certain
threshold GDD are reached for this region. It then uses DOY as a
response variable in pixel-wise linear regressions to explore
spatio-temporal trends.

## Reproducibility

This workflow requires a lot of computational power and disk space.
Currently it runs on a Jetstream2 instance with 16 cores and 60GB of ram
on a 500GB disk. Even then, the disk occasionally fills up and the temp
directory needs to be manually cleared out as intermediate tiff files
accumulate. I’ve used a `.Renviron` file to set the `TMPDIR` variable to
make sure `tmpdir()` is on a large enough attached volume rather than
the root disk, which for Jetstream2 is only 50GB.

This project was created with R version 4.4.2.

### `renv`

This project uses
[`renv`](https://rstudio.github.io/renv/articles/renv.html) for package
management. When opening this repo as an RStudio Project for the first
time, `renv` should automatically install itself and prompt you to run
`renv::restore()` to install all package dependencies. If you have any
issues with `renv::restore()`, you may want to ensure you are using the
same version of R (4.4.2)—[rig](https://github.com/r-lib/rig) is an
excellent tool for managing different R versions.

### `targets`

This project uses the [`targets`
package](https://docs.ropensci.org/targets/) for workflow management.
Run `targets::tar_make()` from the console to run the workflow and
reproduce all results. The graph below shows the workflow:

qs2 0.1.3

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    x2db1ec7a48f65a9b(["Outdated"]):::outdated
    xb6630624a7b3aa0f(["Dispatched"]):::dispatched
    xf1522833a4d242c5(["Up to date"]):::uptodate
    xd03d7c7dd2ddda2b(["Regular target"]):::none
    x6f7e04ea3427f824["Dynamic branches"]:::none
  end
  subgraph Graph
    direction LR
    xeb357bf500cb426f(["slope_differences"]):::outdated --> x1a57d81f9d478e5e(["by_state_slope_diff_summary"]):::outdated
    x4293cc4b2ce98353(["roi_sf"]):::uptodate --> x1a57d81f9d478e5e(["by_state_slope_diff_summary"]):::outdated
    xd36e999b706381d6(["doy_summary_650"]):::outdated --> x224b4ae6d4917e15(["by_state_summary"]):::outdated
    xd187396e35b9df6a(["doy_summary_2500"]):::outdated --> x224b4ae6d4917e15(["by_state_summary"]):::outdated
    xe7a2595a28ea2e04(["doy_summary_1250"]):::outdated --> x224b4ae6d4917e15(["by_state_summary"]):::outdated
    xc884cdd4fb17c69f(["doy_summary_1950"]):::outdated --> x224b4ae6d4917e15(["by_state_summary"]):::outdated
    xe3bc9075e32f80ca(["doy_summary_350"]):::outdated --> x224b4ae6d4917e15(["by_state_summary"]):::outdated
    xdc621d8734e6de6d(["doy_summary_50"]):::outdated --> x224b4ae6d4917e15(["by_state_summary"]):::outdated
    x4293cc4b2ce98353(["roi_sf"]):::uptodate --> x224b4ae6d4917e15(["by_state_summary"]):::outdated
    xdc621d8734e6de6d(["doy_summary_50"]):::outdated --> x11c2bf776c83b19c(["count_plot"]):::outdated
    xe7a2595a28ea2e04(["doy_summary_1250"]):::outdated --> x11c2bf776c83b19c(["count_plot"]):::outdated
    xd36e999b706381d6(["doy_summary_650"]):::outdated --> x11c2bf776c83b19c(["count_plot"]):::outdated
    xe3bc9075e32f80ca(["doy_summary_350"]):::outdated --> x11c2bf776c83b19c(["count_plot"]):::outdated
    xd187396e35b9df6a(["doy_summary_2500"]):::outdated --> x11c2bf776c83b19c(["count_plot"]):::outdated
    xc884cdd4fb17c69f(["doy_summary_1950"]):::outdated --> x11c2bf776c83b19c(["count_plot"]):::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x11c2bf776c83b19c(["count_plot"]):::outdated
    x3290bd5727894db5(["stack_1250"]):::outdated --> xe7a2595a28ea2e04(["doy_summary_1250"]):::outdated
    x8aa20a6b22429bc6(["stack_1950"]):::outdated --> xc884cdd4fb17c69f(["doy_summary_1950"]):::outdated
    x9bfde4bdb66389ab(["stack_2500"]):::outdated --> xd187396e35b9df6a(["doy_summary_2500"]):::outdated
    xc842f879425cacb9(["stack_350"]):::outdated --> xe3bc9075e32f80ca(["doy_summary_350"]):::outdated
    xff5a5197cb4eb936(["stack_50"]):::outdated --> xdc621d8734e6de6d(["doy_summary_50"]):::outdated
    x98420a84329bc56b(["stack_650"]):::outdated --> xd36e999b706381d6(["doy_summary_650"]):::outdated
    xb76c0bbea0c751b0["prism_tmax"]:::uptodate --> xc8e128aab3cd4a9e["gdd_doy_1250"]:::outdated
    xcaf68fce9acaa5b6["prism_tmin"]:::uptodate --> xc8e128aab3cd4a9e["gdd_doy_1250"]:::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> xc8e128aab3cd4a9e["gdd_doy_1250"]:::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x2fee061101c79ea2["gdd_doy_1950"]:::outdated
    xb76c0bbea0c751b0["prism_tmax"]:::uptodate --> x2fee061101c79ea2["gdd_doy_1950"]:::outdated
    xcaf68fce9acaa5b6["prism_tmin"]:::uptodate --> x2fee061101c79ea2["gdd_doy_1950"]:::outdated
    xcaf68fce9acaa5b6["prism_tmin"]:::uptodate --> x28c62ae9542e7849["gdd_doy_2500"]:::dispatched
    xb76c0bbea0c751b0["prism_tmax"]:::uptodate --> x28c62ae9542e7849["gdd_doy_2500"]:::dispatched
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x28c62ae9542e7849["gdd_doy_2500"]:::dispatched
    xcaf68fce9acaa5b6["prism_tmin"]:::uptodate --> x2d1ead242fc1f865["gdd_doy_350"]:::outdated
    xb76c0bbea0c751b0["prism_tmax"]:::uptodate --> x2d1ead242fc1f865["gdd_doy_350"]:::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x2d1ead242fc1f865["gdd_doy_350"]:::outdated
    xb76c0bbea0c751b0["prism_tmax"]:::uptodate --> x786a1a0a06ddc553["gdd_doy_50"]:::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x786a1a0a06ddc553["gdd_doy_50"]:::outdated
    xcaf68fce9acaa5b6["prism_tmin"]:::uptodate --> x786a1a0a06ddc553["gdd_doy_50"]:::outdated
    xb76c0bbea0c751b0["prism_tmax"]:::uptodate --> x6672cfab7f0558ba["gdd_doy_650"]:::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x6672cfab7f0558ba["gdd_doy_650"]:::outdated
    xcaf68fce9acaa5b6["prism_tmin"]:::uptodate --> x6672cfab7f0558ba["gdd_doy_650"]:::outdated
    xd187396e35b9df6a(["doy_summary_2500"]):::outdated --> x9a95e37bbec60034(["linear_slopes_plot"]):::outdated
    xc884cdd4fb17c69f(["doy_summary_1950"]):::outdated --> x9a95e37bbec60034(["linear_slopes_plot"]):::outdated
    xe3bc9075e32f80ca(["doy_summary_350"]):::outdated --> x9a95e37bbec60034(["linear_slopes_plot"]):::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x9a95e37bbec60034(["linear_slopes_plot"]):::outdated
    xe7a2595a28ea2e04(["doy_summary_1250"]):::outdated --> x9a95e37bbec60034(["linear_slopes_plot"]):::outdated
    xd36e999b706381d6(["doy_summary_650"]):::outdated --> x9a95e37bbec60034(["linear_slopes_plot"]):::outdated
    xdc621d8734e6de6d(["doy_summary_50"]):::outdated --> x9a95e37bbec60034(["linear_slopes_plot"]):::outdated
    x8aa20a6b22429bc6(["stack_1950"]):::outdated --> x41b128208ccec715(["poi_pred_doy"]):::outdated
    x98420a84329bc56b(["stack_650"]):::outdated --> x41b128208ccec715(["poi_pred_doy"]):::outdated
    x556077819df2ba0d(["poi"]):::uptodate --> x41b128208ccec715(["poi_pred_doy"]):::outdated
    xc842f879425cacb9(["stack_350"]):::outdated --> x41b128208ccec715(["poi_pred_doy"]):::outdated
    x9bfde4bdb66389ab(["stack_2500"]):::outdated --> x41b128208ccec715(["poi_pred_doy"]):::outdated
    xff5a5197cb4eb936(["stack_50"]):::outdated --> x41b128208ccec715(["poi_pred_doy"]):::outdated
    x3290bd5727894db5(["stack_1250"]):::outdated --> x41b128208ccec715(["poi_pred_doy"]):::outdated
    x41b128208ccec715(["poi_pred_doy"]):::outdated --> xbd115849bddb4a76(["poi_shifts_plot"]):::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> xbd115849bddb4a76(["poi_shifts_plot"]):::outdated
    xc303273133d8a2cf(["poi_stats_350"]):::outdated --> x7a722b64ce2ed1a1(["poi_stats"]):::outdated
    x87ab2591407fd72c(["poi_stats_650"]):::outdated --> x7a722b64ce2ed1a1(["poi_stats"]):::outdated
    xbdede1d17e2cddbb(["poi_stats_2500"]):::outdated --> x7a722b64ce2ed1a1(["poi_stats"]):::outdated
    x4a0f84ca502caa8d(["poi_stats_1950"]):::outdated --> x7a722b64ce2ed1a1(["poi_stats"]):::outdated
    x6fbb12a3bc31060f(["poi_stats_1250"]):::outdated --> x7a722b64ce2ed1a1(["poi_stats"]):::outdated
    x585c954b4e620bc6(["poi_stats_50"]):::outdated --> x7a722b64ce2ed1a1(["poi_stats"]):::outdated
    x556077819df2ba0d(["poi"]):::uptodate --> x6fbb12a3bc31060f(["poi_stats_1250"]):::outdated
    xe7a2595a28ea2e04(["doy_summary_1250"]):::outdated --> x6fbb12a3bc31060f(["poi_stats_1250"]):::outdated
    xc884cdd4fb17c69f(["doy_summary_1950"]):::outdated --> x4a0f84ca502caa8d(["poi_stats_1950"]):::outdated
    x556077819df2ba0d(["poi"]):::uptodate --> x4a0f84ca502caa8d(["poi_stats_1950"]):::outdated
    xd187396e35b9df6a(["doy_summary_2500"]):::outdated --> xbdede1d17e2cddbb(["poi_stats_2500"]):::outdated
    x556077819df2ba0d(["poi"]):::uptodate --> xbdede1d17e2cddbb(["poi_stats_2500"]):::outdated
    xe3bc9075e32f80ca(["doy_summary_350"]):::outdated --> xc303273133d8a2cf(["poi_stats_350"]):::outdated
    x556077819df2ba0d(["poi"]):::uptodate --> xc303273133d8a2cf(["poi_stats_350"]):::outdated
    xdc621d8734e6de6d(["doy_summary_50"]):::outdated --> x585c954b4e620bc6(["poi_stats_50"]):::outdated
    x556077819df2ba0d(["poi"]):::uptodate --> x585c954b4e620bc6(["poi_stats_50"]):::outdated
    x556077819df2ba0d(["poi"]):::uptodate --> x87ab2591407fd72c(["poi_stats_650"]):::outdated
    xd36e999b706381d6(["doy_summary_650"]):::outdated --> x87ab2591407fd72c(["poi_stats_650"]):::outdated
    xf9ac23fbc741da6f(["years"]):::uptodate --> xb76c0bbea0c751b0["prism_tmax"]:::uptodate
    xf9ac23fbc741da6f(["years"]):::uptodate --> xcaf68fce9acaa5b6["prism_tmin"]:::uptodate
    xe7a2595a28ea2e04(["doy_summary_1250"]):::outdated --> x1a7be1bbbb0646ca(["sd_plot"]):::outdated
    xd36e999b706381d6(["doy_summary_650"]):::outdated --> x1a7be1bbbb0646ca(["sd_plot"]):::outdated
    xd187396e35b9df6a(["doy_summary_2500"]):::outdated --> x1a7be1bbbb0646ca(["sd_plot"]):::outdated
    xc884cdd4fb17c69f(["doy_summary_1950"]):::outdated --> x1a7be1bbbb0646ca(["sd_plot"]):::outdated
    xdc621d8734e6de6d(["doy_summary_50"]):::outdated --> x1a7be1bbbb0646ca(["sd_plot"]):::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x1a7be1bbbb0646ca(["sd_plot"]):::outdated
    xe3bc9075e32f80ca(["doy_summary_350"]):::outdated --> x1a7be1bbbb0646ca(["sd_plot"]):::outdated
    xc884cdd4fb17c69f(["doy_summary_1950"]):::outdated --> xeb357bf500cb426f(["slope_differences"]):::outdated
    xd187396e35b9df6a(["doy_summary_2500"]):::outdated --> xeb357bf500cb426f(["slope_differences"]):::outdated
    xe7a2595a28ea2e04(["doy_summary_1250"]):::outdated --> xeb357bf500cb426f(["slope_differences"]):::outdated
    xd36e999b706381d6(["doy_summary_650"]):::outdated --> xeb357bf500cb426f(["slope_differences"]):::outdated
    xdc621d8734e6de6d(["doy_summary_50"]):::outdated --> xeb357bf500cb426f(["slope_differences"]):::outdated
    xe3bc9075e32f80ca(["doy_summary_350"]):::outdated --> xeb357bf500cb426f(["slope_differences"]):::outdated
    xeb357bf500cb426f(["slope_differences"]):::outdated --> x37fe5b550c0a1008(["slope_differences_plot"]):::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x37fe5b550c0a1008(["slope_differences_plot"]):::outdated
    xc8e128aab3cd4a9e["gdd_doy_1250"]:::outdated --> x3290bd5727894db5(["stack_1250"]):::outdated
    x2fee061101c79ea2["gdd_doy_1950"]:::outdated --> x8aa20a6b22429bc6(["stack_1950"]):::outdated
    x28c62ae9542e7849["gdd_doy_2500"]:::dispatched --> x9bfde4bdb66389ab(["stack_2500"]):::outdated
    x2d1ead242fc1f865["gdd_doy_350"]:::outdated --> xc842f879425cacb9(["stack_350"]):::outdated
    x786a1a0a06ddc553["gdd_doy_50"]:::outdated --> xff5a5197cb4eb936(["stack_50"]):::outdated
    x6672cfab7f0558ba["gdd_doy_650"]:::outdated --> x98420a84329bc56b(["stack_650"]):::outdated
    xd36e999b706381d6(["doy_summary_650"]):::outdated --> x000fd996de9c9b5d(["summary_plot"]):::outdated
    xd187396e35b9df6a(["doy_summary_2500"]):::outdated --> x000fd996de9c9b5d(["summary_plot"]):::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x000fd996de9c9b5d(["summary_plot"]):::outdated
    xc884cdd4fb17c69f(["doy_summary_1950"]):::outdated --> x000fd996de9c9b5d(["summary_plot"]):::outdated
    xe7a2595a28ea2e04(["doy_summary_1250"]):::outdated --> x000fd996de9c9b5d(["summary_plot"]):::outdated
    xdc621d8734e6de6d(["doy_summary_50"]):::outdated --> x000fd996de9c9b5d(["summary_plot"]):::outdated
    xe3bc9075e32f80ca(["doy_summary_350"]):::outdated --> x000fd996de9c9b5d(["summary_plot"]):::outdated
    x21512ad81bd47b85(["summary_summary_1250"]):::outdated --> xeb07a0ecc48d018b(["summary_summary"]):::outdated
    x22d1d76737e8c96c(["summary_summary_1950"]):::outdated --> xeb07a0ecc48d018b(["summary_summary"]):::outdated
    x98d5cb9b25df8fa2(["summary_summary_2500"]):::outdated --> xeb07a0ecc48d018b(["summary_summary"]):::outdated
    x482d008952893a57(["summary_summary_350"]):::outdated --> xeb07a0ecc48d018b(["summary_summary"]):::outdated
    xd673ca3454c59fd6(["summary_summary_50"]):::outdated --> xeb07a0ecc48d018b(["summary_summary"]):::outdated
    x8817687a9adb871f(["summary_summary_650"]):::outdated --> xeb07a0ecc48d018b(["summary_summary"]):::outdated
    xe7a2595a28ea2e04(["doy_summary_1250"]):::outdated --> x21512ad81bd47b85(["summary_summary_1250"]):::outdated
    xc884cdd4fb17c69f(["doy_summary_1950"]):::outdated --> x22d1d76737e8c96c(["summary_summary_1950"]):::outdated
    xd187396e35b9df6a(["doy_summary_2500"]):::outdated --> x98d5cb9b25df8fa2(["summary_summary_2500"]):::outdated
    xe3bc9075e32f80ca(["doy_summary_350"]):::outdated --> x482d008952893a57(["summary_summary_350"]):::outdated
    xdc621d8734e6de6d(["doy_summary_50"]):::outdated --> xd673ca3454c59fd6(["summary_summary_50"]):::outdated
    xd36e999b706381d6(["doy_summary_650"]):::outdated --> x8817687a9adb871f(["summary_summary_650"]):::outdated
    xc11069275cfeb620(["readme"]):::dispatched
  end
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef dispatched stroke:#000000,color:#000000,fill:#DC863B;
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
```

### PRISM API

In the process of writing this manuscript, the PRISM API changed ([new
API
documentation](https://prism.oregonstate.edu/documents/PRISM_downloads_web_service.pdf)).
The current `targets` pipeline won’t work with the new API, but we’ve
provided a function, `get_prism2()` that should be a drop-in replacement
wherever `get_prism()` is used. Anywhere `read_prism()` is used, the
`ext` argument will need to be set to `".tif"` as well. E.g. in
`calc_gdd_doy.R`, `prism_tmin <- read_prism(tmin_dir)` would need to be
changed to `prism_tmin <- read_prism(tmin_dir, ext = ".tif")`.

------------------------------------------------------------------------

Developed in collaboration with the University of Arizona [CCT Data
Science](https://datascience.cct.arizona.edu/) group.
