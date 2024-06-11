#a wrapper that returns the file path
tar_write_csv <- function(data, path) {
  readr::write_csv(data, path)
  return(path)
}