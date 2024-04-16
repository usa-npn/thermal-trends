

<!-- README.md is generated from README.Qmd. Please edit that file -->

# Estimating trends in phenology

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

<!-- badges: end -->

The goal of this project is to estimate spatial and temporal trends in
phenology in the Northeastern US using
[PRISM](https://prism.oregonstate.edu/) temperature data. This
analytical pipeline downloads daily data, calculates growing degree days
(GDD) for each day, and then finds the day of year (DOY) that certain
threshold GDD are reached for this region. Products will include rasters
of mean DOY for a variety of GDD thresholds over the normals period
(1991-2020), and rasters of estimated rates of change in DOY for these
thresholds.

<!--This is a collaboration between USA-NPN, USDA, the NY Phenology Project, and University of Arizona CCT Data Science.-->
<!--# I'm not 100% sure about this, so I'll leave commented out for now -->

Report of work in progress:
<https://usa-npn.github.io/cales-thermal-calendars/spatial-trends-report.html>

## Reproducibility

### `renv`

This project uses
[`renv`](https://rstudio.github.io/renv/articles/renv.html) for package
management. When opening this repo as an RStudio Project for the first
time, `renv` should automatically install itself and prompt you to run
`renv::restore()` to install all package dependencies.

### `targets`

This project uses the [`targets`
package](https://docs.ropensci.org/targets/) for workflow management.
Run `targets::tar_make()` from the console to run the workflow and
reproduce all results. The graph below shows the workflow:

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    xf1522833a4d242c5([""Up to date""]):::uptodate --- xd03d7c7dd2ddda2b([""Stem""]):::none
    xd03d7c7dd2ddda2b([""Stem""]):::none --- x6f7e04ea3427f824[""Pattern""]:::none
  end
  subgraph Graph
    direction LR
    xff529209e87def7b["gdd_doy_1000<br>1000"]:::uptodate --> x46cc5bc3b6c68c1a(["gdd_doy_stack_1000<br>1000"]):::uptodate
    x47d67438bee47c7b(["normals_summary_1000<br>1000"]):::uptodate --> xd1093b48fdaa3b26(["normals_mean_plot_1000<br>1000"]):::uptodate
    x21326ed6e10cd0d0(["gdd_doy_stack_2500<br>2500"]):::uptodate --> xfdc192d56cd8f9ef(["normals_summary_2500<br>2500"]):::uptodate
    x21326ed6e10cd0d0(["gdd_doy_stack_2500<br>2500"]):::uptodate --> xe29a7570fd64b783(["doy_trend_2500<br>2500"]):::uptodate
    x21326ed6e10cd0d0(["gdd_doy_stack_2500<br>2500"]):::uptodate --> x07c639dff4c1c0c9(["doy_plot_2500<br>2500"]):::uptodate
    x6976cced396df4c9(["casc_ne"]):::uptodate --> x28c62ae9542e7849["gdd_doy_2500<br>2500"]:::uptodate
    xf1e1014b1abe0030["prism_tmean"]:::uptodate --> x28c62ae9542e7849["gdd_doy_2500<br>2500"]:::uptodate
    xb106621904434716(["casc_ne_file"]):::uptodate --> x6976cced396df4c9(["casc_ne"]):::uptodate
    x05f2370eca178222(["doy_trend_1000<br>1000"]):::uptodate --> x31a3593b535e23c4(["trend_plot_1000<br>1000"]):::uptodate
    xd87e155a2058b73d(["normals_summary_50<br>50"]):::uptodate --> xd07aca72e6461b3b(["normals_sd_plot_50<br>50"]):::uptodate
    x08bdbd4f78dad638(["doy_trend_50<br>50"]):::uptodate --> x5a26c52d2d28f1dc(["trend_plot_50<br>50"]):::uptodate
    xd87e155a2058b73d(["normals_summary_50<br>50"]):::uptodate --> xb6b5b21811b62e8e(["normals_mean_plot_50<br>50"]):::uptodate
    x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::uptodate --> x233d6af147d6e9d1(["doy_plot_50<br>50"]):::uptodate
    x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::uptodate --> xd87e155a2058b73d(["normals_summary_50<br>50"]):::uptodate
    x46cc5bc3b6c68c1a(["gdd_doy_stack_1000<br>1000"]):::uptodate --> x47d67438bee47c7b(["normals_summary_1000<br>1000"]):::uptodate
    x46cc5bc3b6c68c1a(["gdd_doy_stack_1000<br>1000"]):::uptodate --> x05f2370eca178222(["doy_trend_1000<br>1000"]):::uptodate
    x46cc5bc3b6c68c1a(["gdd_doy_stack_1000<br>1000"]):::uptodate --> x2c8ecb326142bdff(["doy_plot_1000<br>1000"]):::uptodate
    xfdc192d56cd8f9ef(["normals_summary_2500<br>2500"]):::uptodate --> x387144ee5a388fce(["normals_sd_plot_2500<br>2500"]):::uptodate
    x28c62ae9542e7849["gdd_doy_2500<br>2500"]:::uptodate --> x21326ed6e10cd0d0(["gdd_doy_stack_2500<br>2500"]):::uptodate
    x786a1a0a06ddc553["gdd_doy_50<br>50"]:::uptodate --> x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::uptodate
    xfdc192d56cd8f9ef(["normals_summary_2500<br>2500"]):::uptodate --> xa1c9e5079d21856f(["normals_mean_plot_2500<br>2500"]):::uptodate
    xf9ac23fbc741da6f(["years"]):::uptodate --> xf1e1014b1abe0030["prism_tmean"]:::uptodate
    x6976cced396df4c9(["casc_ne"]):::uptodate --> xff529209e87def7b["gdd_doy_1000<br>1000"]:::uptodate
    xf1e1014b1abe0030["prism_tmean"]:::uptodate --> xff529209e87def7b["gdd_doy_1000<br>1000"]:::uptodate
    x47d67438bee47c7b(["normals_summary_1000<br>1000"]):::uptodate --> x042637b768dd479e(["normals_sd_plot_1000<br>1000"]):::uptodate
    x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::uptodate --> x08bdbd4f78dad638(["doy_trend_50<br>50"]):::uptodate
    xe29a7570fd64b783(["doy_trend_2500<br>2500"]):::uptodate --> x4a7371f634a1c6ee(["trend_plot_2500<br>2500"]):::uptodate
    x6976cced396df4c9(["casc_ne"]):::uptodate --> x786a1a0a06ddc553["gdd_doy_50<br>50"]:::uptodate
    xf1e1014b1abe0030["prism_tmean"]:::uptodate --> x786a1a0a06ddc553["gdd_doy_50<br>50"]:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
```

------------------------------------------------------------------------

Developed in collaboration with the University of Arizona [CCT Data
Science](https://datascience.cct.arizona.edu/) group.
