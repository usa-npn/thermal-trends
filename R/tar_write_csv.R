#a wrapper that returns the file path
tar_write_csv <- function(data, path) {
  fs::dir_create(fs::path_dir(path))
  readr::write_csv(data, path)
  return(path)
}