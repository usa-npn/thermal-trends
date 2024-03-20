#' Download mean temp from PRISM
#'
#' Downloads an entire year of tmean data from PRISM using `get_prism_dailys()`
#' and returns the download path so it works with `format = 'file'` in `targets`
#'
#' @param year year of data to be downloaded
#' @param prism_dir base directory for PRISM data.  A subfolder will be created for the year
#'
#' @return path to folder for that year of data
get_prism_tmean <- function(year, prism_dir = "data/prism") {
  prism_set_dl_dir(path(prism_dir, year), create = TRUE)
  get_prism_dailys(type = "tmean", minDate = make_date(year, 1, 1), maxDate = make_date(year, 12, 31))
  
  #return:
  path(prism_dir, year)
}