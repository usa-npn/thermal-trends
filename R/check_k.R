check_k <- function(gam) {
  name <- deparse(substitute(gam))
  safe_k_check <- purrr::possibly(mgcv::k.check, tibble::tibble())
  safe_k_check(gam) |> 
    tibble::as_tibble(rownames = "term") |> 
    dplyr::mutate(gam = name, .before = 1)
}
# check_k(gam_50000_100)
