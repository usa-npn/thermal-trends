library(targets)
library(tictoc)
library(gratia)
library(mgcv)
tar_load_globals()
tar_load(gdd_doy_stack_50)

# Convert to meters so x and y are in same units
gdd_rast_m <- gdd_doy_stack_50 |> project(crs("EPSG:32618"))

# Aggregate a TON to make this faster to iterate on
model_df <- make_model_df(gdd_rast_m, agg_factor = 15)
dim(model_df)
ggplot(model_df, aes(x = x, y = y)) +
  geom_raster(aes(fill = doy)) +
  scale_fill_viridis_c()

# Create `nei` object with poorly written slow custom function
nei <- make_nei(model_df, buffer = 100000)
#TODO currently this nei only does NCV spatially, not spatio-temporally. I think the spatio-temporal version would extend this to think of time as a third dimension and each "neighborhood" would be a rectangular prism (±x, ±y, ±time) around a central pixel where the distance (in "pixels") in space could be different than the distance in time.

#check that this is doing what I think it's doing
pl <- list()
for(pli in sample(1:nrow(model_df), 9)){
  # for(pli in c(10:18)) {
  pl[[paste0(pli)]] <- ggplot(model_df, aes(x=x, y=y, fill=doy)) +
    geom_raster() +
    geom_point(aes(x=x, y=y), size=2,
               data=model_df[nei$k[(nei$m[pli-1]+1):nei$m[pli]], ]) +
    scale_fill_viridis_c() +
    coord_equal() +
    theme_minimal()
}

patchwork::wrap_plots(pl, ncol=3, nrow=3) + patchwork::plot_layout(guides = "collect", axes = "collect")

# Fit some GAMs.
# Could use `bam()` for the REML version, but it doesn't work with "NCV", so using gam() for both to even the playing field

tic()
doy_reml <- mgcv::gam(
  doy ~ ti(y, x, bs = "cr", d = 2, k = 40) +
    ti(year_scaled, bs = "cr") +
    ti(y, x, year_scaled, d = c(2,1), bs = c("cr", "cr"), k = c(40, 5)),
  data = model_df,
  method = "REML"
)
toc() #9.2 sec with default knots
k.check(doy_reml) #not enough knots

#NCV
tic()
doy_ncv <- mgcv::gam(
  doy ~ ti(y, x, bs = "cr", d = 2, k = 40) +
    ti(year_scaled, bs = "cr") +
    ti(y, x, year_scaled, d = c(2,1), bs = c("cr", "cr"), k = c(40, 5)),
  data = model_df,
  method = "NCV",
  nei = nei
)
toc() #56.254 sec with default knots
k.check(doy_ncv) #maybe enough knots?

summary(doy_ncv)
summary(doy_reml)
gratia::draw(doy_ncv)
gratia::draw(doy_reml)
