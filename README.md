
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

Loading required namespace: terra Warning message: package ‘geotargets’
was built under R version 4.3.3

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
    x09e654e88f35baa2(["gdd_doy_stack_300<br>300"]):::uptodate --> xc5a47be3eb6c999f(["doy_trend_300<br>300"]):::uptodate
    xbfe90ebeeb7a071e>"get_lm_slope"]:::uptodate --> xc5a47be3eb6c999f(["doy_trend_300<br>300"]):::uptodate
    xe29acbe10e4acf5e["gdd_doy_200<br>200"]:::uptodate --> x99fb079e151e8aaa(["gdd_doy_stack_200<br>200"]):::uptodate
    xc5a47be3eb6c999f(["doy_trend_300<br>300"]):::uptodate --> x04dfda02c5bc958a(["trend_plot_300<br>300"]):::uptodate
    x298e720a0d38fbab>"plot_slopes"]:::uptodate --> x04dfda02c5bc958a(["trend_plot_300<br>300"]):::uptodate
    x251a9bbe1f58f2ec(["doy_trend_200<br>200"]):::uptodate --> x371459079f39f627(["trend_plot_200<br>200"]):::uptodate
    x298e720a0d38fbab>"plot_slopes"]:::uptodate --> x371459079f39f627(["trend_plot_200<br>200"]):::uptodate
    x99fb079e151e8aaa(["gdd_doy_stack_200<br>200"]):::uptodate --> x251a9bbe1f58f2ec(["doy_trend_200<br>200"]):::uptodate
    xbfe90ebeeb7a071e>"get_lm_slope"]:::uptodate --> x251a9bbe1f58f2ec(["doy_trend_200<br>200"]):::uptodate
    x388a2f32d8679472["gdd_doy_300<br>300"]:::uptodate --> x09e654e88f35baa2(["gdd_doy_stack_300<br>300"]):::uptodate
    x99fb079e151e8aaa(["gdd_doy_stack_200<br>200"]):::uptodate --> xee77e2ccce9f82c4(["doy_plot_200<br>200"]):::uptodate
    x13c8ccaa5d631ad7>"plot_doy"]:::uptodate --> xee77e2ccce9f82c4(["doy_plot_200<br>200"]):::uptodate
    x09e654e88f35baa2(["gdd_doy_stack_300<br>300"]):::uptodate --> x029e34683ca15036(["doy_plot_300<br>300"]):::uptodate
    x13c8ccaa5d631ad7>"plot_doy"]:::uptodate --> x029e34683ca15036(["doy_plot_300<br>300"]):::uptodate
    xb88b325298077171>"calc_gdd_doy"]:::uptodate --> xe29acbe10e4acf5e["gdd_doy_200<br>200"]:::uptodate
    xd097f7e15f521741(["ne_vect_file"]):::uptodate --> xe29acbe10e4acf5e["gdd_doy_200<br>200"]:::uptodate
    xe4ea051685a102ce["prism_tmean"]:::uptodate --> xe29acbe10e4acf5e["gdd_doy_200<br>200"]:::uptodate
    xb88b325298077171>"calc_gdd_doy"]:::uptodate --> x388a2f32d8679472["gdd_doy_300<br>300"]:::uptodate
    xd097f7e15f521741(["ne_vect_file"]):::uptodate --> x388a2f32d8679472["gdd_doy_300<br>300"]:::uptodate
    xe4ea051685a102ce["prism_tmean"]:::uptodate --> x388a2f32d8679472["gdd_doy_300<br>300"]:::uptodate
    x4796032f25dfd47a>"get_prism_tmean"]:::uptodate --> xe4ea051685a102ce["prism_tmean"]:::uptodate
    x25dbf37c6e783c25(["years"]):::uptodate --> xe4ea051685a102ce["prism_tmean"]:::uptodate
    x548139ace4ace77c(["thresholds"]):::uptodate --> x548139ace4ace77c(["thresholds"]):::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 25 stroke-width:0px;
```

------------------------------------------------------------------------

Developed in collaboration with [CCT Data
Science](https://datascience.cct.arizona.edu/).
