
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cales-thermal-calendars

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

<!-- badges: end -->

The goal of cales-thermal-calendars is to …

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

- The project is out-of-sync – use `renv::status()` for details. Loading
  required namespace: terra Warning message: package ‘geotargets’ was
  built under R version 4.3.3

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- x70a5fa6bea6f298d[""Pattern""]:::none
    x70a5fa6bea6f298d[""Pattern""]:::none --- xf0bce276fe2b9d3e>""Function""]:::none
  end
  subgraph Graph
    direction LR
    x143c225a85b6f8ef["gdd_doy_1000<br>1000"]:::uptodate --> x40c2e72d4bfe48c6(["gdd_doy_stack_1000<br>1000"]):::uptodate
    x03a837447b8e1f85(["gdd_doy_stack_2500<br>2500"]):::uptodate --> xf560c6147541e200(["doy_trend_2500<br>2500"]):::uptodate
    xbfe90ebeeb7a071e>"get_lm_slope"]:::uptodate --> xf560c6147541e200(["doy_trend_2500<br>2500"]):::uptodate
    x03a837447b8e1f85(["gdd_doy_stack_2500<br>2500"]):::uptodate --> x4571a9b7d2c4f70f(["doy_plot_2500<br>2500"]):::uptodate
    x13c8ccaa5d631ad7>"plot_doy"]:::uptodate --> x4571a9b7d2c4f70f(["doy_plot_2500<br>2500"]):::uptodate
    xb88b325298077171>"calc_gdd_doy"]:::uptodate --> x5d124cd085114def["gdd_doy_2500<br>2500"]:::uptodate
    xd097f7e15f521741(["ne_vect_file"]):::uptodate --> x5d124cd085114def["gdd_doy_2500<br>2500"]:::uptodate
    xe4ea051685a102ce["prism_tmean"]:::uptodate --> x5d124cd085114def["gdd_doy_2500<br>2500"]:::uptodate
    x5a7177ac72d59179(["doy_trend_1000<br>1000"]):::uptodate --> x56ad0a64704ce37e(["trend_plot_1000<br>1000"]):::uptodate
    x298e720a0d38fbab>"plot_slopes"]:::uptodate --> x56ad0a64704ce37e(["trend_plot_1000<br>1000"]):::uptodate
    x067ed113746ada91(["doy_trend_50<br>50"]):::uptodate --> xb10cda98be740603(["trend_plot_50<br>50"]):::uptodate
    x298e720a0d38fbab>"plot_slopes"]:::uptodate --> xb10cda98be740603(["trend_plot_50<br>50"]):::uptodate
    xef0f3bd95aeea8a1(["gdd_doy_stack_50<br>50"]):::uptodate --> xa4e7d2ec2b26ed98(["doy_plot_50<br>50"]):::uptodate
    x13c8ccaa5d631ad7>"plot_doy"]:::uptodate --> xa4e7d2ec2b26ed98(["doy_plot_50<br>50"]):::uptodate
    x40c2e72d4bfe48c6(["gdd_doy_stack_1000<br>1000"]):::uptodate --> x5a7177ac72d59179(["doy_trend_1000<br>1000"]):::uptodate
    xbfe90ebeeb7a071e>"get_lm_slope"]:::uptodate --> x5a7177ac72d59179(["doy_trend_1000<br>1000"]):::uptodate
    x40c2e72d4bfe48c6(["gdd_doy_stack_1000<br>1000"]):::uptodate --> x1198f75c36e06a6d(["doy_plot_1000<br>1000"]):::uptodate
    x13c8ccaa5d631ad7>"plot_doy"]:::uptodate --> x1198f75c36e06a6d(["doy_plot_1000<br>1000"]):::uptodate
    x5d124cd085114def["gdd_doy_2500<br>2500"]:::uptodate --> x03a837447b8e1f85(["gdd_doy_stack_2500<br>2500"]):::uptodate
    x4e641563f83bc893["gdd_doy_50<br>50"]:::uptodate --> xef0f3bd95aeea8a1(["gdd_doy_stack_50<br>50"]):::uptodate
    x067ed113746ada91(["doy_trend_50<br>50"]):::uptodate --> x9dd6eb88f0f020eb(["spatial_report"]):::uptodate
    xef0f3bd95aeea8a1(["gdd_doy_stack_50<br>50"]):::uptodate --> x9dd6eb88f0f020eb(["spatial_report"]):::uptodate
    x4796032f25dfd47a>"get_prism_tmean"]:::uptodate --> xe4ea051685a102ce["prism_tmean"]:::uptodate
    x25dbf37c6e783c25(["years"]):::uptodate --> xe4ea051685a102ce["prism_tmean"]:::uptodate
    xb88b325298077171>"calc_gdd_doy"]:::uptodate --> x143c225a85b6f8ef["gdd_doy_1000<br>1000"]:::uptodate
    xd097f7e15f521741(["ne_vect_file"]):::uptodate --> x143c225a85b6f8ef["gdd_doy_1000<br>1000"]:::uptodate
    xe4ea051685a102ce["prism_tmean"]:::uptodate --> x143c225a85b6f8ef["gdd_doy_1000<br>1000"]:::uptodate
    xef0f3bd95aeea8a1(["gdd_doy_stack_50<br>50"]):::uptodate --> x067ed113746ada91(["doy_trend_50<br>50"]):::uptodate
    xbfe90ebeeb7a071e>"get_lm_slope"]:::uptodate --> x067ed113746ada91(["doy_trend_50<br>50"]):::uptodate
    xf560c6147541e200(["doy_trend_2500<br>2500"]):::uptodate --> xb9525cb3d2f5752d(["trend_plot_2500<br>2500"]):::uptodate
    x298e720a0d38fbab>"plot_slopes"]:::uptodate --> xb9525cb3d2f5752d(["trend_plot_2500<br>2500"]):::uptodate
    xb88b325298077171>"calc_gdd_doy"]:::uptodate --> x4e641563f83bc893["gdd_doy_50<br>50"]:::uptodate
    xd097f7e15f521741(["ne_vect_file"]):::uptodate --> x4e641563f83bc893["gdd_doy_50<br>50"]:::uptodate
    xe4ea051685a102ce["prism_tmean"]:::uptodate --> x4e641563f83bc893["gdd_doy_50<br>50"]:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
```

------------------------------------------------------------------------

Developed in collaboration with [CCT Data
Science](https://datascience.cct.arizona.edu/).
