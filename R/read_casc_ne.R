read_casc_ne <- function(casc_ne_file) {
  shp_file <- fs::path_file(casc_ne_file) |> fs::path_ext_set(".shp")
  path <- fs::path("/vsizip/", casc_ne_file, shp_file)
  terra::vect(path)
}
