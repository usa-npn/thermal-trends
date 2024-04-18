write_tiff <- function(raster, filename, out_dir = "output/rasters") {
  out_path <- fs::path(out_dir, filename)
  fs::dir_create(out_dir)
  terra::writeRaster(raster, filename = out_path, filetype = "COG", overwrite = TRUE)
  
  #return:
  out_path
}