# library(targets)
# tar_load_globals()
# tar_load(gdd_doy_stack_50)

summarize_normals <- function(stack, years = 1991:2020) {
  
  if(!(all(as.character(1991:2020)  %in% names(stack)))) {
    message("stack does not contain all years from 1991:2020")
  }
  
  years <- as.character(years)
  years <- years[ which(years %in% names(stack))]
  
  stack[[years]] |> 
    terra::app(function(x) c(mean = mean(x, na.rm = TRUE), sd = sd(x, na.rm = TRUE)))
}

# gdd_doy_stack_50[[as.character(1991:2020)]] |> app(function(x) c(mean = mean(x), sd = sd(x))) 
