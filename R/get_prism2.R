#' Download data from PRISM
#'
#' Downloads an entire year of daily data from PRISM and returns the download
#' path so it works with `format = 'file'` in `targets`.
#'
#' NOTE: this works with the latest version of the PRISM API as of Sep. 30,
#' 2025. https://prism.oregonstate.edu/documents/PRISM_downloads_web_service.pdf
#'
#' @param year year of data to be downloaded
#' @param variable variable to get
#' @param prism_dir base directory for PRISM data.  Subfolders will be created
#'   for the variable and year
#' @param format File format to download from PRISM. Options include `"nc"` for
#'   netCDF, `"asc"` for ASCII Grid format, `"bil"` for BIL format, and `"tif"`
#'   for cloud optimized geotiff. The default of `"bil"` is for compatibility
#'   with the targets pipeline.  Previous version of the PRISM API did not have
#'   cloud optimized geotiffs available.
#'
#' @return path to folder for that year of data
get_prism2 <- function(
  year,
  variable = c("tmin", "tmax", "tmean"),
  prism_dir = "data/prism",
  format = c("bil", "tif", "nc", "asc")
) {
  variable <- match.arg(variable)
  format <- match.arg(format)

  # no format query = tif
  if (format == "tif") {
    format <- NULL
  }

  base_req <-
    httr2::request("https://services.nacse.org/prism/data/get") |>
    httr2::req_user_agent(
      "University of Arizona CCT Data Science (https://datascience.cct.arizona.edu/)"
    ) |>
    httr2::req_retry(max_tries = 10) |>
    httr2::req_url_path_append("us", "4km")

  cli::cli_alert("Downloading PRISM {variable} data for {year}")

  #check if path exists and create if not
  year_dir <- fs::dir_create(fs::path(prism_dir, variable, year))

  #make sequence of dates
  date_start <- lubridate::make_date(year = year)
  date_end <- lubridate::make_date(year = year, month = 12, day = 31)
  dates <- seq(date_start, date_end, "day")

  req <- base_req |>
    httr2::req_url_path_append(variable) |>
    httr2::req_url_query(format = format)

  reqs <- purrr::map(dates, \(x) {
    req |> httr2::req_url_path_append(format(x, "%Y%m%d"))
  })

  # retrieve filenames
  head_reqs <- purrr::map(reqs, \(x) httr2::req_method(x, "HEAD"))
  head_resps <- httr2::req_perform_sequential(
    head_reqs,
    progress = "Retrieving filenames"
  )
  filenames <- head_resps |>
    purrr::map_chr(\(x) {
      x$headers$`Content-Disposition` |>
        stringr::str_remove("filename=") |>
        stringr::str_remove_all('\\"') |>
        fs::path()
    })

  filepaths <- fs::path(year_dir, filenames)
  # Figure out which ones need to be downloaded
  files_exist <- fs::file_exists(filepaths)

  reqs_to_perform <- reqs[!files_exist]
  files_to_dl <- filepaths[!files_exist]

  # TODO: there is a release date web service that could be used to determine if
  # any files need updating.  Files released 6 months ago are considered
  # "stable".
  # https://prism.oregonstate.edu/documents/PRISM_downloads_web_service.pdf
  # E.g. https://services.nacse.org/prism/data/get/releaseDate/us/4km/{variable}/{format(date_start, "%Y%m%d")}/{format(date_end, "%Y%m%d")}?json=true

  cli::cli_alert_info("{length(reqs_to_perform)} files to download")

  if (length(reqs_to_perform) > 0) {
    resp <-
      httr2::req_perform_sequential(
        reqs_to_perform |>
          purrr::map(\(req) {
            req |>
              httr2::req_throttle(capacity = 1, fill_time_s = 2)
          }),
        paths = files_to_dl,
        progress = "Downloading"
      )
    #check that they are actually zip files and if not change extension to .txt

    purrr::walk(files_to_dl, \(x) {
      is_zip <- check_zip_file(x)
      if (!isTRUE(is_zip)) {
        warning(is_zip)
        file.rename(x, fs::path_ext_set(x, "txt"))
      }
    })
  } else {
    cli::cli_alert_info("Skipping downloading.")
  }

  #return the path to the folder so targets tracks the whole dang thing
  invisible(year_dir)
}
