check_k <- function(gam) {
  name <- deparse(substitute(gam))
  mgcv::k.check(gam) |> 
    as_tibble(rownames = "term") |> 
    mutate(gam = name, .before = 1) |> 
    separate(gam, into = c("trash", "res_m", "k")) |> 
    select(-trash)
}
# check_k(gam_50000_100)
