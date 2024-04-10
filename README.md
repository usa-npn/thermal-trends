

<!-- README.md is generated from README.Qmd. Please edit that file -->

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

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- xa8565c104d8f0705([""Dispatched""]):::dispatched
    xa8565c104d8f0705([""Dispatched""]):::dispatched --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- x70a5fa6bea6f298d[""Pattern""]:::none
    x70a5fa6bea6f298d[""Pattern""]:::none --- xf0bce276fe2b9d3e>""Function""]:::none
  end
  subgraph Graph
    direction LR
    x143c225a85b6f8ef["gdd_doy_1000<br>1000"]:::uptodate --> x40c2e72d4bfe48c6(["gdd_doy_stack_1000<br>1000"]):::uptodate
    x8b570043a37c4f3f(["normals_summary_1000<br>1000"]):::uptodate --> x39dc65dec856c05d(["normals_mean_plot_1000<br>1000"]):::uptodate
    xa917b7eaa4a3ab69>"plot_normals_mean"]:::uptodate --> x39dc65dec856c05d(["normals_mean_plot_1000<br>1000"]):::uptodate
    x03a837447b8e1f85(["gdd_doy_stack_2500<br>2500"]):::uptodate --> x45979941e033c65c(["normals_summary_2500<br>2500"]):::uptodate
    x5057cf71ad61ffba>"summarize_normals"]:::uptodate --> x45979941e033c65c(["normals_summary_2500<br>2500"]):::uptodate
    x03a837447b8e1f85(["gdd_doy_stack_2500<br>2500"]):::uptodate --> xf560c6147541e200(["doy_trend_2500<br>2500"]):::uptodate
    xbfe90ebeeb7a071e>"get_lm_slope"]:::uptodate --> xf560c6147541e200(["doy_trend_2500<br>2500"]):::uptodate
    x03a837447b8e1f85(["gdd_doy_stack_2500<br>2500"]):::uptodate --> x4571a9b7d2c4f70f(["doy_plot_2500<br>2500"]):::uptodate
    x13c8ccaa5d631ad7>"plot_doy"]:::uptodate --> x4571a9b7d2c4f70f(["doy_plot_2500<br>2500"]):::uptodate
    xb88b325298077171>"calc_gdd_doy"]:::uptodate --> x5d124cd085114def["gdd_doy_2500<br>2500"]:::uptodate
    xe5ad1b541da28dc0(["casc_ne"]):::uptodate --> x5d124cd085114def["gdd_doy_2500<br>2500"]:::uptodate
    xe4ea051685a102ce["prism_tmean"]:::uptodate --> x5d124cd085114def["gdd_doy_2500<br>2500"]:::uptodate
    x09ece08de4b3110b(["casc_ne_file"]):::uptodate --> xe5ad1b541da28dc0(["casc_ne"]):::uptodate
    x2e865c2cb7f7f0bd>"read_casc_ne"]:::uptodate --> xe5ad1b541da28dc0(["casc_ne"]):::uptodate
    x5a7177ac72d59179(["doy_trend_1000<br>1000"]):::uptodate --> x56ad0a64704ce37e(["trend_plot_1000<br>1000"]):::uptodate
    x298e720a0d38fbab>"plot_slopes"]:::uptodate --> x56ad0a64704ce37e(["trend_plot_1000<br>1000"]):::uptodate
    x067ed113746ada91(["doy_trend_50<br>50"]):::uptodate --> xb10cda98be740603(["trend_plot_50<br>50"]):::uptodate
    x298e720a0d38fbab>"plot_slopes"]:::uptodate --> xb10cda98be740603(["trend_plot_50<br>50"]):::uptodate
    xdcf6fe500c4f6c47(["normals_summary_50<br>50"]):::uptodate --> xe0edcdcfe499bd71(["normals_mean_plot_50<br>50"]):::uptodate
    xa917b7eaa4a3ab69>"plot_normals_mean"]:::uptodate --> xe0edcdcfe499bd71(["normals_mean_plot_50<br>50"]):::uptodate
    xef0f3bd95aeea8a1(["gdd_doy_stack_50<br>50"]):::uptodate --> xa4e7d2ec2b26ed98(["doy_plot_50<br>50"]):::uptodate
    x13c8ccaa5d631ad7>"plot_doy"]:::uptodate --> xa4e7d2ec2b26ed98(["doy_plot_50<br>50"]):::uptodate
    xef0f3bd95aeea8a1(["gdd_doy_stack_50<br>50"]):::uptodate --> xdcf6fe500c4f6c47(["normals_summary_50<br>50"]):::uptodate
    x5057cf71ad61ffba>"summarize_normals"]:::uptodate --> xdcf6fe500c4f6c47(["normals_summary_50<br>50"]):::uptodate
    x40c2e72d4bfe48c6(["gdd_doy_stack_1000<br>1000"]):::uptodate --> x8b570043a37c4f3f(["normals_summary_1000<br>1000"]):::uptodate
    x5057cf71ad61ffba>"summarize_normals"]:::uptodate --> x8b570043a37c4f3f(["normals_summary_1000<br>1000"]):::uptodate
    x40c2e72d4bfe48c6(["gdd_doy_stack_1000<br>1000"]):::uptodate --> x5a7177ac72d59179(["doy_trend_1000<br>1000"]):::uptodate
    xbfe90ebeeb7a071e>"get_lm_slope"]:::uptodate --> x5a7177ac72d59179(["doy_trend_1000<br>1000"]):::uptodate
    x40c2e72d4bfe48c6(["gdd_doy_stack_1000<br>1000"]):::uptodate --> x1198f75c36e06a6d(["doy_plot_1000<br>1000"]):::uptodate
    x13c8ccaa5d631ad7>"plot_doy"]:::uptodate --> x1198f75c36e06a6d(["doy_plot_1000<br>1000"]):::uptodate
    x5d124cd085114def["gdd_doy_2500<br>2500"]:::uptodate --> x03a837447b8e1f85(["gdd_doy_stack_2500<br>2500"]):::uptodate
    x4e641563f83bc893["gdd_doy_50<br>50"]:::uptodate --> xef0f3bd95aeea8a1(["gdd_doy_stack_50<br>50"]):::uptodate
    x067ed113746ada91(["doy_trend_50<br>50"]):::uptodate --> x9dd6eb88f0f020eb(["spatial_report"]):::uptodate
    xef0f3bd95aeea8a1(["gdd_doy_stack_50<br>50"]):::uptodate --> x9dd6eb88f0f020eb(["spatial_report"]):::uptodate
    x45979941e033c65c(["normals_summary_2500<br>2500"]):::uptodate --> x2f5625350a1b19db(["normals_mean_plot_2500<br>2500"]):::uptodate
    xa917b7eaa4a3ab69>"plot_normals_mean"]:::uptodate --> x2f5625350a1b19db(["normals_mean_plot_2500<br>2500"]):::uptodate
    x4796032f25dfd47a>"get_prism_tmean"]:::uptodate --> xe4ea051685a102ce["prism_tmean"]:::uptodate
    x25dbf37c6e783c25(["years"]):::uptodate --> xe4ea051685a102ce["prism_tmean"]:::uptodate
    xb88b325298077171>"calc_gdd_doy"]:::uptodate --> x143c225a85b6f8ef["gdd_doy_1000<br>1000"]:::uptodate
    xe5ad1b541da28dc0(["casc_ne"]):::uptodate --> x143c225a85b6f8ef["gdd_doy_1000<br>1000"]:::uptodate
    xe4ea051685a102ce["prism_tmean"]:::uptodate --> x143c225a85b6f8ef["gdd_doy_1000<br>1000"]:::uptodate
    xef0f3bd95aeea8a1(["gdd_doy_stack_50<br>50"]):::uptodate --> x067ed113746ada91(["doy_trend_50<br>50"]):::uptodate
    xbfe90ebeeb7a071e>"get_lm_slope"]:::uptodate --> x067ed113746ada91(["doy_trend_50<br>50"]):::uptodate
    xf560c6147541e200(["doy_trend_2500<br>2500"]):::uptodate --> xb9525cb3d2f5752d(["trend_plot_2500<br>2500"]):::uptodate
    x298e720a0d38fbab>"plot_slopes"]:::uptodate --> xb9525cb3d2f5752d(["trend_plot_2500<br>2500"]):::uptodate
    xb88b325298077171>"calc_gdd_doy"]:::uptodate --> x4e641563f83bc893["gdd_doy_50<br>50"]:::uptodate
    xe5ad1b541da28dc0(["casc_ne"]):::uptodate --> x4e641563f83bc893["gdd_doy_50<br>50"]:::uptodate
    xe4ea051685a102ce["prism_tmean"]:::uptodate --> x4e641563f83bc893["gdd_doy_50<br>50"]:::uptodate
    x6e52cb0f1668cc22(["readme"]):::dispatched --> x6e52cb0f1668cc22(["readme"]):::dispatched
    x3831a3d6946cd453>"plot_normals_sd"]:::uptodate --> x3831a3d6946cd453>"plot_normals_sd"]:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef dispatched stroke:#000000,color:#000000,fill:#DC863B;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 52 stroke-width:0px;
  linkStyle 53 stroke-width:0px;
```

------------------------------------------------------------------------

Developed in collaboration with the University of Arizona [CCT Data
Science](https://datascience.cct.arizona.edu/) group.
