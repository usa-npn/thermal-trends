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
  
  #TODO check for provisional versions of files and prompt to replace or not with stable versions
  
  #check if path exists and create if not
  year_dir <- fs::dir_create(path(prism_dir, year))
  
  #make sequence of dates
  date_start <- make_date(year = year)
  date_end <- make_date(year = year, month = 12, day = 31)
  dates <- seq(date_start, date_end, "day")
  
  #make list of requests
  #api documentation: https://prism.oregonstate.edu/documents/PRISM_downloads_web_service.pdf
  
  base_url <- "https://services.nacse.org/prism/data/public/4km"
  req_tmean <- 
    request(base_url) |> 
    req_url_path_append("tmean") |> 
    req_retry(max_tries = 10)
  
  reqs <- purrr::map(dates, \(x) req_tmean |> req_url_path_append(format(x, "%Y%m%d")))
  
  # retrieve filenames
  head_reqs <- purrr::map(reqs, \(x) req_method(x, "HEAD"))
  head_resps <- req_perform_sequential(head_reqs, progress = "Retrieving filenames")
  filenames <- head_resps |> 
    purrr::map_chr(\(x) {
      x$headers$`Content-Disposition` |> 
        str_remove("filename=") |>
        str_remove_all('\\"') |> 
        path()})
  
  files_exist <- fs::file_exists(path(year_dir, filenames))
  
  reqs_to_perform <- reqs[!files_exist]
  filenames_to_download <- filenames[!files_exist]
  
  message(length(reqs_to_perform), " files to download")
  
  if (length(reqs_to_perform) > 0) {
    resp <- 
      req_perform_sequential(
        reqs_to_perform,
        paths = path(year_dir, filenames_to_download),
        progress = "Downloading"
      )
    #check that they are actually zip files and if not change extension to .txt
    
    walk(path(year_dir, filenames_to_download), \(x) {
      is_zip <- check_zip_file(x)
      if (!isTRUE(is_zip)) {
        warning(is_zip)
        file.rename(x, fs::path_ext_set(x, "txt"))
      }
    })
  } else {
    message("Skipping downloading.")
  }
  
  #return all the file paths
  invisible(path(year_dir, filenames))
}


#from https://github.com/ropensci/prism/blob/master/R/prism_webservice.R
check_zip_file <- function(x) {
  zfile <- readLines(x, warn = FALSE)
  
  # zip files have "PK\....." in their first line
  is_zip <- grepl("^PK\003\004", zfile[1])
  
  if (is_zip) {
    return(is_zip)
  } else{
    return(zfile)
  }
}