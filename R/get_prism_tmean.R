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
  
  #removed un-zipped folders (we don't need them and I can't stop get_prism_dailys() from unzipping!)
  dir_ls(path(prism_dir, year), type = "directory") |> dir_delete()
  
  #return:
  path(prism_dir, year)
}