

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
threshold GDD are reached for this region. It then uses DOY as a
response variable in a series of generalized additive models to estimate
spatio-temporal trends.

Report of work in progress:
<https://usa-npn.github.io/thermal-trends/spatial-trends-report.html>

## Reproducibility

This workflow requires a lot of computational power and disk space.
Currently it runs on a Jetstream2 instance with 16 cores and 60GB of ram
on a 500GB disk. Even then, the disk occasionally fills up and the temp
directory needs to be manually cleared out as intermediate tiff files
accumulate. I’ve used a `.Renviron` file to set the `TMPDIR` variable to
make sure `tmpdir()` is on a large enough attached volume rather than
the root disk, which for Jetstream2 is only 50GB.

### `renv`

This project uses
[`renv`](https://rstudio.github.io/renv/articles/renv.html) for package
management. When opening this repo as an RStudio Project for the first
time, `renv` should automatically install itself and prompt you to run
`renv::restore()` to install all package dependencies.

### `targets`

This project uses the [`targets`
package](https://docs.ropensci.org/targets/) for workflow management.
Run `targets::tar_make()` from the console or from the HPC run
`sbatch run.sh` to run the workflow and reproduce all results. The graph
below shows the workflow:

- The project is out-of-sync – use `renv::status()` for details. qs2
  0.1.3

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    xf1522833a4d242c5([""Up to date""]):::uptodate --- x2db1ec7a48f65a9b([""Outdated""]):::outdated
    x2db1ec7a48f65a9b([""Outdated""]):::outdated --- xb6630624a7b3aa0f([""Dispatched""]):::dispatched
    xb6630624a7b3aa0f([""Dispatched""]):::dispatched --- xd03d7c7dd2ddda2b([""Stem""]):::none
    xd03d7c7dd2ddda2b([""Stem""]):::none --- x6f7e04ea3427f824[""Pattern""]:::none
  end
  subgraph Graph
    direction LR
    x0b494d9bc4b357f4(["gdd_doy_stack_50"]):::uptodate --> xdb2d4cf2f7118b3e(["gdd_doy_mean_50"]):::uptodate
    x6190f8a1d165fd4b(["gdd_doy_stack_1250"]):::uptodate --> xe030e5e376cbeec4(["gam_df_1250"]):::uptodate
    x6672cfab7f0558ba["gdd_doy_650"]:::uptodate --> xb9f0ee932663ed1f(["gdd_doy_stack_650"]):::uptodate
    x0b494d9bc4b357f4(["gdd_doy_stack_50"]):::uptodate --> x2421bacfa5192d5e(["gam_df_50"]):::uptodate
    xd1924c2b6947d923["slopes_gam_1950"]:::dispatched --> xaa0486ce9606c790["slope_range_gam_1950"]:::dispatched
    x786a1a0a06ddc553["gdd_doy_50"]:::uptodate --> x0b494d9bc4b357f4(["gdd_doy_stack_50"]):::uptodate
    x6190f8a1d165fd4b(["gdd_doy_stack_1250"]):::uptodate --> x64fb5b155a04c501(["gdd_doy_max_1250"]):::uptodate
    xb76c0bbea0c751b0["prism_tmax"]:::uptodate --> xc8e128aab3cd4a9e["gdd_doy_1250"]:::uptodate
    xcaf68fce9acaa5b6["prism_tmin"]:::uptodate --> xc8e128aab3cd4a9e["gdd_doy_1250"]:::uptodate
    x73ccc223e5bb7e64(["roi"]):::uptodate --> xc8e128aab3cd4a9e["gdd_doy_1250"]:::uptodate
    x4653a794c063cafa(["gam_df_2500"]):::uptodate --> x505a93e9b4cc77fa(["gam_2500"]):::uptodate
    xd2c5001f86d780d8(["gdd_doy_stack_1950"]):::uptodate --> x8f907661d2ac9568(["gdd_doy_min_1950"]):::uptodate
    x21326ed6e10cd0d0(["gdd_doy_stack_2500"]):::uptodate --> x54b7c2e690c8d9ab(["gdd_doy_max_2500"]):::uptodate
    x9f390473f862e874(["gam_50"]):::uptodate --> xe388cae0099ca599(["appraisal_50"]):::uptodate
    x9f390473f862e874(["gam_50"]):::uptodate --> x47d0b54a3cd242c1["slopes_gam_50"]:::uptodate
    x2315814e27faae1c(["slope_newdata"]):::uptodate --> x47d0b54a3cd242c1["slopes_gam_50"]:::uptodate
    x733b67494e902db6(["gam_1250"]):::uptodate --> xc86358416deb93b5(["smooths_1250"]):::uptodate
    x73ccc223e5bb7e64(["roi"]):::uptodate --> xc86358416deb93b5(["smooths_1250"]):::uptodate
    x6190f8a1d165fd4b(["gdd_doy_stack_1250"]):::uptodate --> x05339bb428e93d35(["gdd_doy_mean_1250"]):::uptodate
    xee85424733695318["slope_range_gam_1250"]:::uptodate --> xe6f074eed19231c1(["slope_range"]):::outdated
    xaa0486ce9606c790["slope_range_gam_1950"]:::dispatched --> xe6f074eed19231c1(["slope_range"]):::outdated
    x9ac242e81637a82f["slope_range_gam_2500"]:::uptodate --> xe6f074eed19231c1(["slope_range"]):::outdated
    xf7a4a2c91e301efc["slope_range_gam_50"]:::uptodate --> xe6f074eed19231c1(["slope_range"]):::outdated
    x807b446f7c1cfb0d["slope_range_gam_650"]:::uptodate --> xe6f074eed19231c1(["slope_range"]):::outdated
    xb76c0bbea0c751b0["prism_tmax"]:::uptodate --> x786a1a0a06ddc553["gdd_doy_50"]:::uptodate
    xcaf68fce9acaa5b6["prism_tmin"]:::uptodate --> x786a1a0a06ddc553["gdd_doy_50"]:::uptodate
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x786a1a0a06ddc553["gdd_doy_50"]:::uptodate
    x47d0b54a3cd242c1["slopes_gam_50"]:::uptodate --> xf7a4a2c91e301efc["slope_range_gam_50"]:::uptodate
    xd4ed10d8000b5d13(["gam_df_1950"]):::uptodate --> xf00bec52b4c06ab1(["gam_1950"]):::uptodate
    xb9f0ee932663ed1f(["gdd_doy_stack_650"]):::uptodate --> xcbcdbe4c5a587e73(["doy_range_650"]):::uptodate
    x73ccc223e5bb7e64(["roi"]):::uptodate --> xe1610651e71037f4(["slopes_plot_slopes_gam_50"]):::outdated
    xe6f074eed19231c1(["slope_range"]):::outdated --> xe1610651e71037f4(["slopes_plot_slopes_gam_50"]):::outdated
    x47d0b54a3cd242c1["slopes_gam_50"]:::uptodate --> xe1610651e71037f4(["slopes_plot_slopes_gam_50"]):::outdated
    x3a4b99e62ddf3528(["gdd_doy_sd_50"]):::uptodate --> x7b3a719ceba86523(["sd_plot_50"]):::uptodate
    xd2c5001f86d780d8(["gdd_doy_stack_1950"]):::uptodate --> xdd7d50d2e5f7bc21(["doy_range_1950"]):::uptodate
    x0b494d9bc4b357f4(["gdd_doy_stack_50"]):::uptodate --> x3a4b99e62ddf3528(["gdd_doy_sd_50"]):::uptodate
    xe874b36c37c8fddc(["gam_650"]):::uptodate --> x0be891253a341f97(["smooths_650"]):::uptodate
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x0be891253a341f97(["smooths_650"]):::uptodate
    xb9f0ee932663ed1f(["gdd_doy_stack_650"]):::uptodate --> xd2df24c3402964bf(["gam_df_650"]):::uptodate
    xd2c5001f86d780d8(["gdd_doy_stack_1950"]):::uptodate --> xb93aacb9a51bc6d2(["gdd_doy_sd_1950"]):::uptodate
    xb76c0bbea0c751b0["prism_tmax"]:::uptodate --> x28c62ae9542e7849["gdd_doy_2500"]:::uptodate
    xcaf68fce9acaa5b6["prism_tmin"]:::uptodate --> x28c62ae9542e7849["gdd_doy_2500"]:::uptodate
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x28c62ae9542e7849["gdd_doy_2500"]:::uptodate
    x0b494d9bc4b357f4(["gdd_doy_stack_50"]):::uptodate --> x01c3ae4c10fdd4d6(["doy_range_50"]):::uptodate
    xb9f0ee932663ed1f(["gdd_doy_stack_650"]):::uptodate --> x1427b2f9dd8fc8e2(["gdd_doy_sd_650"]):::uptodate
    xdd7d50d2e5f7bc21(["doy_range_1950"]):::uptodate --> x618957bc968e9084(["summary_plot_1950"]):::uptodate
    xbfc158b2f5767148(["gdd_doy_max_1950"]):::uptodate --> x618957bc968e9084(["summary_plot_1950"]):::uptodate
    x984369f89f19179c(["gdd_doy_mean_1950"]):::uptodate --> x618957bc968e9084(["summary_plot_1950"]):::uptodate
    x8f907661d2ac9568(["gdd_doy_min_1950"]):::uptodate --> x618957bc968e9084(["summary_plot_1950"]):::uptodate
    x9f390473f862e874(["gam_50"]):::uptodate --> x897648e65d20ff57(["k_check_50"]):::uptodate
    x2421bacfa5192d5e(["gam_df_50"]):::uptodate --> x9f390473f862e874(["gam_50"]):::uptodate
    xfb7bfc7274c6b2af["slopes_gam_2500"]:::uptodate --> x9ac242e81637a82f["slope_range_gam_2500"]:::uptodate
    x876ba53f0425363a(["doy_range_1250"]):::uptodate --> xdebd1975895667c3(["summary_plot_1250"]):::uptodate
    x64fb5b155a04c501(["gdd_doy_max_1250"]):::uptodate --> xdebd1975895667c3(["summary_plot_1250"]):::uptodate
    x05339bb428e93d35(["gdd_doy_mean_1250"]):::uptodate --> xdebd1975895667c3(["summary_plot_1250"]):::uptodate
    x14b193e33831e0fd(["gdd_doy_min_1250"]):::uptodate --> xdebd1975895667c3(["summary_plot_1250"]):::uptodate
    xe874b36c37c8fddc(["gam_650"]):::uptodate --> x4a7f475c95f396bf(["k_check_650"]):::uptodate
    xd2c5001f86d780d8(["gdd_doy_stack_1950"]):::uptodate --> xbfc158b2f5767148(["gdd_doy_max_1950"]):::uptodate
    xf00bec52b4c06ab1(["gam_1950"]):::uptodate --> xd1924c2b6947d923["slopes_gam_1950"]:::dispatched
    x2315814e27faae1c(["slope_newdata"]):::uptodate --> xd1924c2b6947d923["slopes_gam_1950"]:::dispatched
    x73ccc223e5bb7e64(["roi"]):::uptodate --> xbffb8bea489906eb(["slopes_plot_slopes_gam_1950"]):::outdated
    xe6f074eed19231c1(["slope_range"]):::outdated --> xbffb8bea489906eb(["slopes_plot_slopes_gam_1950"]):::outdated
    xd1924c2b6947d923["slopes_gam_1950"]:::dispatched --> xbffb8bea489906eb(["slopes_plot_slopes_gam_1950"]):::outdated
    x21326ed6e10cd0d0(["gdd_doy_stack_2500"]):::uptodate --> x1c0e03eef0403772(["gdd_doy_sd_2500"]):::uptodate
    xb9f0ee932663ed1f(["gdd_doy_stack_650"]):::uptodate --> x2315814e27faae1c(["slope_newdata"]):::uptodate
    xf00bec52b4c06ab1(["gam_1950"]):::uptodate --> x33184cb170bb2f7e(["smooths_1950"]):::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x33184cb170bb2f7e(["smooths_1950"]):::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> xf5f0232f6335d66b(["slopes_plot_slopes_gam_2500"]):::outdated
    xe6f074eed19231c1(["slope_range"]):::outdated --> xf5f0232f6335d66b(["slopes_plot_slopes_gam_2500"]):::outdated
    xfb7bfc7274c6b2af["slopes_gam_2500"]:::uptodate --> xf5f0232f6335d66b(["slopes_plot_slopes_gam_2500"]):::outdated
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x4ab7119c33125021(["slopes_plot_slopes_gam_1250"]):::outdated
    xe6f074eed19231c1(["slope_range"]):::outdated --> x4ab7119c33125021(["slopes_plot_slopes_gam_1250"]):::outdated
    x59655877c673f294["slopes_gam_1250"]:::uptodate --> x4ab7119c33125021(["slopes_plot_slopes_gam_1250"]):::outdated
    x2fee061101c79ea2["gdd_doy_1950"]:::uptodate --> xd2c5001f86d780d8(["gdd_doy_stack_1950"]):::uptodate
    xe874b36c37c8fddc(["gam_650"]):::uptodate --> xb9c227710b304f59["slopes_gam_650"]:::uptodate
    x2315814e27faae1c(["slope_newdata"]):::uptodate --> xb9c227710b304f59["slopes_gam_650"]:::uptodate
    x505a93e9b4cc77fa(["gam_2500"]):::uptodate --> xb6c6f6549c1e20c8(["appraisal_2500"]):::uptodate
    xb76c0bbea0c751b0["prism_tmax"]:::uptodate --> x6672cfab7f0558ba["gdd_doy_650"]:::uptodate
    xcaf68fce9acaa5b6["prism_tmin"]:::uptodate --> x6672cfab7f0558ba["gdd_doy_650"]:::uptodate
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x6672cfab7f0558ba["gdd_doy_650"]:::uptodate
    xb9f0ee932663ed1f(["gdd_doy_stack_650"]):::uptodate --> xc7dae8b3aae0a83b(["gdd_doy_min_650"]):::uptodate
    x1c0e03eef0403772(["gdd_doy_sd_2500"]):::uptodate --> xf2afd81d3c4b5757(["sd_plot_2500"]):::uptodate
    xb9f0ee932663ed1f(["gdd_doy_stack_650"]):::uptodate --> x740f6b7a90b6ef16(["gdd_doy_mean_650"]):::uptodate
    xf9ac23fbc741da6f(["years"]):::uptodate --> xb76c0bbea0c751b0["prism_tmax"]:::uptodate
    xb93aacb9a51bc6d2(["gdd_doy_sd_1950"]):::uptodate --> x20f6ae3612b278e1(["sd_plot_1950"]):::uptodate
    x28c62ae9542e7849["gdd_doy_2500"]:::uptodate --> x21326ed6e10cd0d0(["gdd_doy_stack_2500"]):::uptodate
    x8884c919cd6ce83e(["gdd_doy_sd_1250"]):::uptodate --> x757283642f0f5874(["sd_plot_1250"]):::uptodate
    x505a93e9b4cc77fa(["gam_2500"]):::uptodate --> x4252f936f6cf4c89(["k_check_2500"]):::uptodate
    x733b67494e902db6(["gam_1250"]):::uptodate --> x59655877c673f294["slopes_gam_1250"]:::uptodate
    x2315814e27faae1c(["slope_newdata"]):::uptodate --> x59655877c673f294["slopes_gam_1250"]:::uptodate
    xf9ac23fbc741da6f(["years"]):::uptodate --> xcaf68fce9acaa5b6["prism_tmin"]:::uptodate
    x733b67494e902db6(["gam_1250"]):::uptodate --> x3f96da81ec909de5(["appraisal_1250"]):::uptodate
    x1427b2f9dd8fc8e2(["gdd_doy_sd_650"]):::uptodate --> xf830eed042a91a44(["sd_plot_650"]):::uptodate
    x59655877c673f294["slopes_gam_1250"]:::uptodate --> xee85424733695318["slope_range_gam_1250"]:::uptodate
    xc8e128aab3cd4a9e["gdd_doy_1250"]:::uptodate --> x6190f8a1d165fd4b(["gdd_doy_stack_1250"]):::uptodate
    xd2df24c3402964bf(["gam_df_650"]):::uptodate --> xe874b36c37c8fddc(["gam_650"]):::uptodate
    x6190f8a1d165fd4b(["gdd_doy_stack_1250"]):::uptodate --> x14b193e33831e0fd(["gdd_doy_min_1250"]):::uptodate
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x3492f272f613898d(["slopes_plot_slopes_gam_650"]):::outdated
    xe6f074eed19231c1(["slope_range"]):::outdated --> x3492f272f613898d(["slopes_plot_slopes_gam_650"]):::outdated
    xb9c227710b304f59["slopes_gam_650"]:::uptodate --> x3492f272f613898d(["slopes_plot_slopes_gam_650"]):::outdated
    x733b67494e902db6(["gam_1250"]):::uptodate --> x10b2f90a62d7dae9(["k_check_1250"]):::uptodate
    x21326ed6e10cd0d0(["gdd_doy_stack_2500"]):::uptodate --> x231c7be094fefc7f(["gdd_doy_mean_2500"]):::uptodate
    x21326ed6e10cd0d0(["gdd_doy_stack_2500"]):::uptodate --> x64e573c83090b300(["gdd_doy_min_2500"]):::uptodate
    xf00bec52b4c06ab1(["gam_1950"]):::uptodate --> x571ee1cbcc0c287a(["k_check_1950"]):::outdated
    xd2c5001f86d780d8(["gdd_doy_stack_1950"]):::uptodate --> x984369f89f19179c(["gdd_doy_mean_1950"]):::uptodate
    xe874b36c37c8fddc(["gam_650"]):::uptodate --> x1af2bdc6213d6994(["appraisal_650"]):::uptodate
    x21326ed6e10cd0d0(["gdd_doy_stack_2500"]):::uptodate --> x4653a794c063cafa(["gam_df_2500"]):::uptodate
    x0b494d9bc4b357f4(["gdd_doy_stack_50"]):::uptodate --> x6b695a435a5ef3e0(["gdd_doy_min_50"]):::uptodate
    x01c3ae4c10fdd4d6(["doy_range_50"]):::uptodate --> xafc839d1cc5064c0(["summary_plot_50"]):::uptodate
    xdaaf7a015d302884(["gdd_doy_max_50"]):::uptodate --> xafc839d1cc5064c0(["summary_plot_50"]):::uptodate
    xdb2d4cf2f7118b3e(["gdd_doy_mean_50"]):::uptodate --> xafc839d1cc5064c0(["summary_plot_50"]):::uptodate
    x6b695a435a5ef3e0(["gdd_doy_min_50"]):::uptodate --> xafc839d1cc5064c0(["summary_plot_50"]):::uptodate
    x6c953909fe7b8fce(["doy_range_2500"]):::uptodate --> xb2de9693a473eb79(["summary_plot_2500"]):::uptodate
    x54b7c2e690c8d9ab(["gdd_doy_max_2500"]):::uptodate --> xb2de9693a473eb79(["summary_plot_2500"]):::uptodate
    x231c7be094fefc7f(["gdd_doy_mean_2500"]):::uptodate --> xb2de9693a473eb79(["summary_plot_2500"]):::uptodate
    x64e573c83090b300(["gdd_doy_min_2500"]):::uptodate --> xb2de9693a473eb79(["summary_plot_2500"]):::uptodate
    x21326ed6e10cd0d0(["gdd_doy_stack_2500"]):::uptodate --> x6c953909fe7b8fce(["doy_range_2500"]):::uptodate
    xcbcdbe4c5a587e73(["doy_range_650"]):::uptodate --> xa93f83461407d05c(["summary_plot_650"]):::uptodate
    xfac0fe8f7b7ae32a(["gdd_doy_max_650"]):::uptodate --> xa93f83461407d05c(["summary_plot_650"]):::uptodate
    x740f6b7a90b6ef16(["gdd_doy_mean_650"]):::uptodate --> xa93f83461407d05c(["summary_plot_650"]):::uptodate
    xc7dae8b3aae0a83b(["gdd_doy_min_650"]):::uptodate --> xa93f83461407d05c(["summary_plot_650"]):::uptodate
    xe030e5e376cbeec4(["gam_df_1250"]):::uptodate --> x733b67494e902db6(["gam_1250"]):::uptodate
    x505a93e9b4cc77fa(["gam_2500"]):::uptodate --> xfb7bfc7274c6b2af["slopes_gam_2500"]:::uptodate
    x2315814e27faae1c(["slope_newdata"]):::uptodate --> xfb7bfc7274c6b2af["slopes_gam_2500"]:::uptodate
    x9f390473f862e874(["gam_50"]):::uptodate --> x88dd041ff32b3238(["smooths_50"]):::uptodate
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x88dd041ff32b3238(["smooths_50"]):::uptodate
    x6190f8a1d165fd4b(["gdd_doy_stack_1250"]):::uptodate --> x876ba53f0425363a(["doy_range_1250"]):::uptodate
    x6190f8a1d165fd4b(["gdd_doy_stack_1250"]):::uptodate --> x8884c919cd6ce83e(["gdd_doy_sd_1250"]):::uptodate
    xd2c5001f86d780d8(["gdd_doy_stack_1950"]):::uptodate --> xd4ed10d8000b5d13(["gam_df_1950"]):::uptodate
    x0b494d9bc4b357f4(["gdd_doy_stack_50"]):::uptodate --> xdaaf7a015d302884(["gdd_doy_max_50"]):::uptodate
    xf00bec52b4c06ab1(["gam_1950"]):::uptodate --> x8dbe7e86078fcdc8(["appraisal_1950"]):::outdated
    xb9c227710b304f59["slopes_gam_650"]:::uptodate --> x807b446f7c1cfb0d["slope_range_gam_650"]:::uptodate
    xb9f0ee932663ed1f(["gdd_doy_stack_650"]):::uptodate --> xfac0fe8f7b7ae32a(["gdd_doy_max_650"]):::uptodate
    xb76c0bbea0c751b0["prism_tmax"]:::uptodate --> x2fee061101c79ea2["gdd_doy_1950"]:::uptodate
    xcaf68fce9acaa5b6["prism_tmin"]:::uptodate --> x2fee061101c79ea2["gdd_doy_1950"]:::uptodate
    x73ccc223e5bb7e64(["roi"]):::uptodate --> x2fee061101c79ea2["gdd_doy_1950"]:::uptodate
    x505a93e9b4cc77fa(["gam_2500"]):::uptodate --> xdf2eb319be33483b(["smooths_2500"]):::uptodate
    x73ccc223e5bb7e64(["roi"]):::uptodate --> xdf2eb319be33483b(["smooths_2500"]):::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef dispatched stroke:#000000,color:#000000,fill:#DC863B;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
```

------------------------------------------------------------------------

Developed in collaboration with the University of Arizona [CCT Data
Science](https://datascience.cct.arizona.edu/) group.
