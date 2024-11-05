
<!-- README.md is generated from README.Qmd. Please edit that file -->

# Estimating trends in phenology

<!-- badges: start -->

<div>

[![](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

Project Status: WIP – Initial development is in progress, but there has
not yet been a stable, usable release suitable for the public.

</div>

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

- The project is out-of-sync – use
  `]8;;ide:run:renv::status()renv::status()]8;;` for details. qs 0.27.2.
  Announcement: https://github.com/qsbase/qs/issues/103

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    xf1522833a4d242c5([""Up to date""]):::uptodate --- xb6630624a7b3aa0f([""Dispatched""]):::dispatched
    xb6630624a7b3aa0f([""Dispatched""]):::dispatched --- xd03d7c7dd2ddda2b([""Stem""]):::none
    xd03d7c7dd2ddda2b([""Stem""]):::none --- x6f7e04ea3427f824[""Pattern""]:::none
  end
  subgraph Graph
    direction LR
    xfdc192d56cd8f9ef(["normals_summary_2500<br>2500"]):::uptodate --> x57ccbb18d53b398f(["normals_mean_gtiff_2500<br>2500"]):::uptodate
    xc8e128aab3cd4a9e["gdd_doy_1250<br>calc DOY to reach threshold..."]:::uptodate --> x6190f8a1d165fd4b(["gdd_doy_stack_1250<br>1250"]):::uptodate
    x2f4c106bb92a3f7f(["gam_df_50gdd"]):::uptodate --> x270191fc54049f46(["gam_50gdd"]):::uptodate
    x270191fc54049f46(["gam_50gdd"]):::uptodate --> xb1f1af046ce0f5f4(["k_check_50gdd"]):::uptodate
    xfdc192d56cd8f9ef(["normals_summary_2500<br>2500"]):::uptodate --> x387144ee5a388fce(["normals_sd_plot_2500<br>2500"]):::uptodate
    x21326ed6e10cd0d0(["gdd_doy_stack_2500<br>2500"]):::uptodate --> x4a4c5b117a150179(["gam_df_2500gdd"]):::uptodate
    xd87e155a2058b73d(["normals_summary_50<br>50"]):::uptodate --> xc7a535d2781491db(["normals_mean_gtiff_50<br>50"]):::uptodate
    x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::uptodate --> x2315814e27faae1c(["slope_newdata"]):::uptodate
    x01722e698f2e7985(["cities_sf<br>Example cities for plotting..."]):::uptodate --> xfc3b6bdcddc13624(["slopes_plot_slopes_gam_50gdd_city_plot_gam_50gdd<br>slopes_gam_50gdd city_plot_..."]):::uptodate
    xc95f5b57457f5bc5(["city_plot_gam_50gdd<br>timeseries plot for example..."]):::uptodate --> xfc3b6bdcddc13624(["slopes_plot_slopes_gam_50gdd_city_plot_gam_50gdd<br>slopes_gam_50gdd city_plot_..."]):::uptodate
    x73ccc223e5bb7e64(["roi<br>vector for North East"]):::uptodate --> xfc3b6bdcddc13624(["slopes_plot_slopes_gam_50gdd_city_plot_gam_50gdd<br>slopes_gam_50gdd city_plot_..."]):::uptodate
    xe6f074eed19231c1(["slope_range<br>range across all thresholds..."]):::uptodate --> xfc3b6bdcddc13624(["slopes_plot_slopes_gam_50gdd_city_plot_gam_50gdd<br>slopes_gam_50gdd city_plot_..."]):::uptodate
    xf31f386f0c8bf37c["slopes_gam_50gdd<br>gam_50gdd"]:::uptodate --> xfc3b6bdcddc13624(["slopes_plot_slopes_gam_50gdd_city_plot_gam_50gdd<br>slopes_gam_50gdd city_plot_..."]):::uptodate
    xad066c3293ce714c(["gam_df_1250gdd"]):::uptodate --> x2c39659f61437218(["gam_1250gdd"]):::uptodate
    x3d3a34fc9d50fc8b(["normals_summary_1250<br>1250"]):::uptodate --> x0d02102f0fd46b6e(["normals_mean_gtiff_1250<br>1250"]):::uptodate
    x3d3a34fc9d50fc8b(["normals_summary_1250<br>1250"]):::uptodate --> x5bd215076381efc6(["normals_mean_plot_1250<br>1250"]):::uptodate
    x01722e698f2e7985(["cities_sf<br>Example cities for plotting..."]):::uptodate --> x786b02bcc3d103ac(["slopes_plot_slopes_gam_2500gdd_city_plot_gam_2500gdd<br>slopes_gam_2500gdd city_plo..."]):::uptodate
    xda24f67f6edd1cdb(["city_plot_gam_2500gdd<br>timeseries plot for example..."]):::uptodate --> x786b02bcc3d103ac(["slopes_plot_slopes_gam_2500gdd_city_plot_gam_2500gdd<br>slopes_gam_2500gdd city_plo..."]):::uptodate
    x73ccc223e5bb7e64(["roi<br>vector for North East"]):::uptodate --> x786b02bcc3d103ac(["slopes_plot_slopes_gam_2500gdd_city_plot_gam_2500gdd<br>slopes_gam_2500gdd city_plo..."]):::uptodate
    xe6f074eed19231c1(["slope_range<br>range across all thresholds..."]):::uptodate --> x786b02bcc3d103ac(["slopes_plot_slopes_gam_2500gdd_city_plot_gam_2500gdd<br>slopes_gam_2500gdd city_plo..."]):::uptodate
    x37340903c56c0aa4["slopes_gam_2500gdd<br>gam_2500gdd"]:::uptodate --> x786b02bcc3d103ac(["slopes_plot_slopes_gam_2500gdd_city_plot_gam_2500gdd<br>slopes_gam_2500gdd city_plo..."]):::uptodate
    xfdc192d56cd8f9ef(["normals_summary_2500<br>2500"]):::uptodate --> x76a0d248ffe930fc(["normals_sd_gtiff_2500<br>2500"]):::uptodate
    x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::uptodate --> xb72891f20a5b8df1(["report"]):::uptodate
    x73ccc223e5bb7e64(["roi<br>vector for North East"]):::uptodate --> xb72891f20a5b8df1(["report"]):::uptodate
    x2c39659f61437218(["gam_1250gdd"]):::uptodate --> x94b5b91a7dfdd388["slopes_gam_1250gdd<br>gam_1250gdd"]:::uptodate
    x2315814e27faae1c(["slope_newdata"]):::uptodate --> x94b5b91a7dfdd388["slopes_gam_1250gdd<br>gam_1250gdd"]:::uptodate
    x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::uptodate --> xd87e155a2058b73d(["normals_summary_50<br>50"]):::uptodate
    x01722e698f2e7985(["cities_sf<br>Example cities for plotting..."]):::uptodate --> xc95f5b57457f5bc5(["city_plot_gam_50gdd<br>timeseries plot for example..."]):::uptodate
    x270191fc54049f46(["gam_50gdd"]):::uptodate --> xc95f5b57457f5bc5(["city_plot_gam_50gdd<br>timeseries plot for example..."]):::uptodate
    x21326ed6e10cd0d0(["gdd_doy_stack_2500<br>2500"]):::uptodate --> xfdc192d56cd8f9ef(["normals_summary_2500<br>2500"]):::uptodate
    x01722e698f2e7985(["cities_sf<br>Example cities for plotting..."]):::uptodate --> xb95f4280bc225cb6(["slopes_plot_slopes_gam_1250gdd_city_plot_gam_1250gdd<br>slopes_gam_1250gdd city_plo..."]):::uptodate
    x79affb5734531b9e(["city_plot_gam_1250gdd<br>timeseries plot for example..."]):::uptodate --> xb95f4280bc225cb6(["slopes_plot_slopes_gam_1250gdd_city_plot_gam_1250gdd<br>slopes_gam_1250gdd city_plo..."]):::uptodate
    x73ccc223e5bb7e64(["roi<br>vector for North East"]):::uptodate --> xb95f4280bc225cb6(["slopes_plot_slopes_gam_1250gdd_city_plot_gam_1250gdd<br>slopes_gam_1250gdd city_plo..."]):::uptodate
    xe6f074eed19231c1(["slope_range<br>range across all thresholds..."]):::uptodate --> xb95f4280bc225cb6(["slopes_plot_slopes_gam_1250gdd_city_plot_gam_1250gdd<br>slopes_gam_1250gdd city_plo..."]):::uptodate
    x94b5b91a7dfdd388["slopes_gam_1250gdd<br>gam_1250gdd"]:::uptodate --> xb95f4280bc225cb6(["slopes_plot_slopes_gam_1250gdd_city_plot_gam_1250gdd<br>slopes_gam_1250gdd city_plo..."]):::uptodate
    xf9ac23fbc741da6f(["years"]):::uptodate --> xf1e1014b1abe0030["prism_tmean<br>download PRISM data"]:::uptodate
    xd87e155a2058b73d(["normals_summary_50<br>50"]):::uptodate --> xb6b5b21811b62e8e(["normals_mean_plot_50<br>50"]):::uptodate
    xd87e155a2058b73d(["normals_summary_50<br>50"]):::uptodate --> xd07aca72e6461b3b(["normals_sd_plot_50<br>50"]):::uptodate
    x270191fc54049f46(["gam_50gdd"]):::uptodate --> xf837d70f2f7feef5(["smooths_50gdd"]):::uptodate
    x73ccc223e5bb7e64(["roi<br>vector for North East"]):::uptodate --> xf837d70f2f7feef5(["smooths_50gdd"]):::uptodate
    x01722e698f2e7985(["cities_sf<br>Example cities for plotting..."]):::uptodate --> xda24f67f6edd1cdb(["city_plot_gam_2500gdd<br>timeseries plot for example..."]):::uptodate
    xa0831ffe9c612a85(["gam_2500gdd"]):::uptodate --> xda24f67f6edd1cdb(["city_plot_gam_2500gdd<br>timeseries plot for example..."]):::uptodate
    x37340903c56c0aa4["slopes_gam_2500gdd<br>gam_2500gdd"]:::uptodate --> xc85fbf33cef0954b["slope_range_gam_2500gdd<br>gam_2500gdd"]:::uptodate
    x01722e698f2e7985(["cities_sf<br>Example cities for plotting..."]):::uptodate --> x79affb5734531b9e(["city_plot_gam_1250gdd<br>timeseries plot for example..."]):::uptodate
    x2c39659f61437218(["gam_1250gdd"]):::uptodate --> x79affb5734531b9e(["city_plot_gam_1250gdd<br>timeseries plot for example..."]):::uptodate
    xa0831ffe9c612a85(["gam_2500gdd"]):::uptodate --> xe9853415eb8396c2(["smooths_2500gdd"]):::uptodate
    x73ccc223e5bb7e64(["roi<br>vector for North East"]):::uptodate --> xe9853415eb8396c2(["smooths_2500gdd"]):::uptodate
    xa0831ffe9c612a85(["gam_2500gdd"]):::uptodate --> xf3d5d15e350d5eab(["k_check_2500gdd"]):::uptodate
    x3d3a34fc9d50fc8b(["normals_summary_1250<br>1250"]):::uptodate --> x52d1c684028d6d97(["normals_sd_plot_1250<br>1250"]):::uptodate
    x6190f8a1d165fd4b(["gdd_doy_stack_1250<br>1250"]):::uptodate --> xad066c3293ce714c(["gam_df_1250gdd"]):::uptodate
    x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::uptodate --> x2f4c106bb92a3f7f(["gam_df_50gdd"]):::uptodate
    x4a4c5b117a150179(["gam_df_2500gdd"]):::uptodate --> xa0831ffe9c612a85(["gam_2500gdd"]):::uptodate
    xbb97ce3cab68ba80(["k_check_1250gdd"]):::uptodate --> x2fbab7231f35281f(["k_check_df<br>Collect results from k_chec..."]):::uptodate
    xf3d5d15e350d5eab(["k_check_2500gdd"]):::uptodate --> x2fbab7231f35281f(["k_check_df<br>Collect results from k_chec..."]):::uptodate
    xb1f1af046ce0f5f4(["k_check_50gdd"]):::uptodate --> x2fbab7231f35281f(["k_check_df<br>Collect results from k_chec..."]):::uptodate
    x786a1a0a06ddc553["gdd_doy_50<br>calc DOY to reach threshold..."]:::uptodate --> x0b494d9bc4b357f4(["gdd_doy_stack_50<br>50"]):::uptodate
    x94b5b91a7dfdd388["slopes_gam_1250gdd<br>gam_1250gdd"]:::uptodate --> xcf52529221f59757["slope_range_gam_1250gdd<br>gam_1250gdd"]:::uptodate
    x270191fc54049f46(["gam_50gdd"]):::uptodate --> xf31f386f0c8bf37c["slopes_gam_50gdd<br>gam_50gdd"]:::uptodate
    x2315814e27faae1c(["slope_newdata"]):::uptodate --> xf31f386f0c8bf37c["slopes_gam_50gdd<br>gam_50gdd"]:::uptodate
    xf31f386f0c8bf37c["slopes_gam_50gdd<br>gam_50gdd"]:::uptodate --> x4b457197d87408a3["slope_range_gam_50gdd<br>gam_50gdd"]:::uptodate
    xf1e1014b1abe0030["prism_tmean<br>download PRISM data"]:::uptodate --> x786a1a0a06ddc553["gdd_doy_50<br>calc DOY to reach threshold..."]:::uptodate
    x73ccc223e5bb7e64(["roi<br>vector for North East"]):::uptodate --> x786a1a0a06ddc553["gdd_doy_50<br>calc DOY to reach threshold..."]:::uptodate
    xfdc192d56cd8f9ef(["normals_summary_2500<br>2500"]):::uptodate --> xa1c9e5079d21856f(["normals_mean_plot_2500<br>2500"]):::uptodate
    x3d3a34fc9d50fc8b(["normals_summary_1250<br>1250"]):::uptodate --> xc70a663eb2f5555a(["normals_sd_gtiff_1250<br>1250"]):::uptodate
    xf1e1014b1abe0030["prism_tmean<br>download PRISM data"]:::uptodate --> xc8e128aab3cd4a9e["gdd_doy_1250<br>calc DOY to reach threshold..."]:::uptodate
    x73ccc223e5bb7e64(["roi<br>vector for North East"]):::uptodate --> xc8e128aab3cd4a9e["gdd_doy_1250<br>calc DOY to reach threshold..."]:::uptodate
    x28c62ae9542e7849["gdd_doy_2500<br>calc DOY to reach threshold..."]:::uptodate --> x21326ed6e10cd0d0(["gdd_doy_stack_2500<br>2500"]):::uptodate
    xcf52529221f59757["slope_range_gam_1250gdd<br>gam_1250gdd"]:::uptodate --> xe6f074eed19231c1(["slope_range<br>range across all thresholds..."]):::uptodate
    xc85fbf33cef0954b["slope_range_gam_2500gdd<br>gam_2500gdd"]:::uptodate --> xe6f074eed19231c1(["slope_range<br>range across all thresholds..."]):::uptodate
    x4b457197d87408a3["slope_range_gam_50gdd<br>gam_50gdd"]:::uptodate --> xe6f074eed19231c1(["slope_range<br>range across all thresholds..."]):::uptodate
    x2fbab7231f35281f(["k_check_df<br>Collect results from k_chec..."]):::uptodate --> x34bbb91993920f80(["k_check_df_csv"]):::uptodate
    x2c39659f61437218(["gam_1250gdd"]):::uptodate --> x8830e3e0882599a2(["smooths_1250gdd"]):::uptodate
    x73ccc223e5bb7e64(["roi<br>vector for North East"]):::uptodate --> x8830e3e0882599a2(["smooths_1250gdd"]):::uptodate
    x2c39659f61437218(["gam_1250gdd"]):::uptodate --> xbb97ce3cab68ba80(["k_check_1250gdd"]):::uptodate
    x6190f8a1d165fd4b(["gdd_doy_stack_1250<br>1250"]):::uptodate --> x3d3a34fc9d50fc8b(["normals_summary_1250<br>1250"]):::uptodate
    xd87e155a2058b73d(["normals_summary_50<br>50"]):::uptodate --> xeec74c9f0c9fa06a(["normals_sd_gtiff_50<br>50"]):::uptodate
    xf1e1014b1abe0030["prism_tmean<br>download PRISM data"]:::uptodate --> x28c62ae9542e7849["gdd_doy_2500<br>calc DOY to reach threshold..."]:::uptodate
    x73ccc223e5bb7e64(["roi<br>vector for North East"]):::uptodate --> x28c62ae9542e7849["gdd_doy_2500<br>calc DOY to reach threshold..."]:::uptodate
    xa0831ffe9c612a85(["gam_2500gdd"]):::uptodate --> x37340903c56c0aa4["slopes_gam_2500gdd<br>gam_2500gdd"]:::uptodate
    x2315814e27faae1c(["slope_newdata"]):::uptodate --> x37340903c56c0aa4["slopes_gam_2500gdd<br>gam_2500gdd"]:::uptodate
    xc11069275cfeb620(["readme"]):::dispatched --> xc11069275cfeb620(["readme"]):::dispatched
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef dispatched stroke:#000000,color:#000000,fill:#DC863B;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 83 stroke-width:0px;
```

------------------------------------------------------------------------

Developed in collaboration with the University of Arizona [CCT Data
Science](https://datascience.cct.arizona.edu/) group.
