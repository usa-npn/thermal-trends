

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
    x2db1ec7a48f65a9b([""Outdated""]):::outdated --- xb6630624a7b3aa0f([""Dispatched""]):::dispatched
    xb6630624a7b3aa0f([""Dispatched""]):::dispatched --- xf1522833a4d242c5([""Up to date""]):::uptodate
    xf1522833a4d242c5([""Up to date""]):::uptodate --- xd03d7c7dd2ddda2b([""Stem""]):::none
    xd03d7c7dd2ddda2b([""Stem""]):::none --- x6f7e04ea3427f824[""Pattern""]:::none
    x6f7e04ea3427f824[""Pattern""]:::none --- xeb2d7cac8a1ce544>""Function""]:::none
  end
  subgraph Graph
    direction LR
    xab9f05120e038f63>"check_zip_file"]:::uptodate --> x66b13d5a9d20761a>"get_prism_tmean"]:::uptodate
    xe29a7570fd64b783(["doy_trend_2500<br>2500"]):::outdated --> x4a7371f634a1c6ee(["trend_plot_2500<br>2500"]):::outdated
    x9c6eebcf51a630b0>"plot_slopes"]:::uptodate --> x4a7371f634a1c6ee(["trend_plot_2500<br>2500"]):::outdated
    xff529209e87def7b["gdd_doy_1000<br>1000"]:::outdated --> x46cc5bc3b6c68c1a(["gdd_doy_stack_1000<br>1000"]):::outdated
    x47d67438bee47c7b(["normals_summary_1000<br>1000"]):::outdated --> xd1093b48fdaa3b26(["normals_mean_plot_1000<br>1000"]):::outdated
    xdd6e5783f4aa3d91>"plot_normals_mean"]:::uptodate --> xd1093b48fdaa3b26(["normals_mean_plot_1000<br>1000"]):::outdated
    xcff06c9512a11109>"calc_gdd_doy"]:::uptodate --> x28c62ae9542e7849["gdd_doy_2500<br>2500"]:::outdated
    x6976cced396df4c9(["casc_ne"]):::outdated --> x28c62ae9542e7849["gdd_doy_2500<br>2500"]:::outdated
    xf1e1014b1abe0030["prism_tmean"]:::outdated --> x28c62ae9542e7849["gdd_doy_2500<br>2500"]:::outdated
    xb106621904434716(["casc_ne_file"]):::dispatched --> x6976cced396df4c9(["casc_ne"]):::outdated
    x78206bf5e8c258ec>"read_casc_ne"]:::uptodate --> x6976cced396df4c9(["casc_ne"]):::outdated
    xcff06c9512a11109>"calc_gdd_doy"]:::uptodate --> x786a1a0a06ddc553["gdd_doy_50<br>50"]:::outdated
    x6976cced396df4c9(["casc_ne"]):::outdated --> x786a1a0a06ddc553["gdd_doy_50<br>50"]:::outdated
    xf1e1014b1abe0030["prism_tmean"]:::outdated --> x786a1a0a06ddc553["gdd_doy_50<br>50"]:::outdated
    xd87e155a2058b73d(["normals_summary_50<br>50"]):::outdated --> xb6b5b21811b62e8e(["normals_mean_plot_50<br>50"]):::outdated
    xdd6e5783f4aa3d91>"plot_normals_mean"]:::uptodate --> xb6b5b21811b62e8e(["normals_mean_plot_50<br>50"]):::outdated
    x05f2370eca178222(["doy_trend_1000<br>1000"]):::outdated --> x31a3593b535e23c4(["trend_plot_1000<br>1000"]):::outdated
    x9c6eebcf51a630b0>"plot_slopes"]:::uptodate --> x31a3593b535e23c4(["trend_plot_1000<br>1000"]):::outdated
    x21326ed6e10cd0d0(["gdd_doy_stack_2500<br>2500"]):::outdated --> xe29a7570fd64b783(["doy_trend_2500<br>2500"]):::outdated
    x5d601d40e571c532>"get_lm_slope"]:::uptodate --> xe29a7570fd64b783(["doy_trend_2500<br>2500"]):::outdated
    x46cc5bc3b6c68c1a(["gdd_doy_stack_1000<br>1000"]):::outdated --> x2c8ecb326142bdff(["doy_plot_1000<br>1000"]):::outdated
    x2d2070bf4c44e867>"plot_doy"]:::uptodate --> x2c8ecb326142bdff(["doy_plot_1000<br>1000"]):::outdated
    x08bdbd4f78dad638(["doy_trend_50<br>50"]):::outdated --> x5a26c52d2d28f1dc(["trend_plot_50<br>50"]):::outdated
    x9c6eebcf51a630b0>"plot_slopes"]:::uptodate --> x5a26c52d2d28f1dc(["trend_plot_50<br>50"]):::outdated
    x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::outdated --> x08bdbd4f78dad638(["doy_trend_50<br>50"]):::outdated
    x5d601d40e571c532>"get_lm_slope"]:::uptodate --> x08bdbd4f78dad638(["doy_trend_50<br>50"]):::outdated
    x46cc5bc3b6c68c1a(["gdd_doy_stack_1000<br>1000"]):::outdated --> x47d67438bee47c7b(["normals_summary_1000<br>1000"]):::outdated
    xf91ccb269c3645a7>"summarize_normals"]:::uptodate --> x47d67438bee47c7b(["normals_summary_1000<br>1000"]):::outdated
    x28c62ae9542e7849["gdd_doy_2500<br>2500"]:::outdated --> x21326ed6e10cd0d0(["gdd_doy_stack_2500<br>2500"]):::outdated
    x46cc5bc3b6c68c1a(["gdd_doy_stack_1000<br>1000"]):::outdated --> x05f2370eca178222(["doy_trend_1000<br>1000"]):::outdated
    x5d601d40e571c532>"get_lm_slope"]:::uptodate --> x05f2370eca178222(["doy_trend_1000<br>1000"]):::outdated
    xfdc192d56cd8f9ef(["normals_summary_2500<br>2500"]):::outdated --> xa1c9e5079d21856f(["normals_mean_plot_2500<br>2500"]):::outdated
    xdd6e5783f4aa3d91>"plot_normals_mean"]:::uptodate --> xa1c9e5079d21856f(["normals_mean_plot_2500<br>2500"]):::outdated
    x08bdbd4f78dad638(["doy_trend_50<br>50"]):::outdated --> xe6f43699e6499b95(["spatial_report"]):::outdated
    x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::outdated --> xe6f43699e6499b95(["spatial_report"]):::outdated
    x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::outdated --> x233d6af147d6e9d1(["doy_plot_50<br>50"]):::outdated
    x2d2070bf4c44e867>"plot_doy"]:::uptodate --> x233d6af147d6e9d1(["doy_plot_50<br>50"]):::outdated
    xcff06c9512a11109>"calc_gdd_doy"]:::uptodate --> xff529209e87def7b["gdd_doy_1000<br>1000"]:::outdated
    x6976cced396df4c9(["casc_ne"]):::outdated --> xff529209e87def7b["gdd_doy_1000<br>1000"]:::outdated
    xf1e1014b1abe0030["prism_tmean"]:::outdated --> xff529209e87def7b["gdd_doy_1000<br>1000"]:::outdated
    x21326ed6e10cd0d0(["gdd_doy_stack_2500<br>2500"]):::outdated --> x07c639dff4c1c0c9(["doy_plot_2500<br>2500"]):::outdated
    x2d2070bf4c44e867>"plot_doy"]:::uptodate --> x07c639dff4c1c0c9(["doy_plot_2500<br>2500"]):::outdated
    x66b13d5a9d20761a>"get_prism_tmean"]:::uptodate --> xf1e1014b1abe0030["prism_tmean"]:::outdated
    xf9ac23fbc741da6f(["years"]):::dispatched --> xf1e1014b1abe0030["prism_tmean"]:::outdated
    x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::outdated --> xd87e155a2058b73d(["normals_summary_50<br>50"]):::outdated
    xf91ccb269c3645a7>"summarize_normals"]:::uptodate --> xd87e155a2058b73d(["normals_summary_50<br>50"]):::outdated
    x21326ed6e10cd0d0(["gdd_doy_stack_2500<br>2500"]):::outdated --> xfdc192d56cd8f9ef(["normals_summary_2500<br>2500"]):::outdated
    xf91ccb269c3645a7>"summarize_normals"]:::uptodate --> xfdc192d56cd8f9ef(["normals_summary_2500<br>2500"]):::outdated
    x786a1a0a06ddc553["gdd_doy_50<br>50"]:::outdated --> x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::outdated
    xc11069275cfeb620(["readme"]):::dispatched --> xc11069275cfeb620(["readme"]):::dispatched
    x7913874ff1a7ce23>"plot_normals_sd"]:::uptodate --> x7913874ff1a7ce23>"plot_normals_sd"]:::uptodate
  end
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef dispatched stroke:#000000,color:#000000,fill:#DC863B;
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 4 stroke-width:0px;
  linkStyle 54 stroke-width:0px;
  linkStyle 55 stroke-width:0px;
```

------------------------------------------------------------------------

Developed in collaboration with the University of Arizona [CCT Data
Science](https://datascience.cct.arizona.edu/) group.
