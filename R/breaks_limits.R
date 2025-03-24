breaks_limits <- function (n = 5, tol = 0.1, min = TRUE, max = TRUE, digits = 1, ...) 
{
  n_default <- n
  scales:::force_all(n, tol, min, max, ...)
  function(x, n = n_default) {
    breaks <- pretty(x, n, ...)
    
    #force limits to be included and remove breaks outside of limits
    if (isTRUE(min)) {
      breaks <- c(x[1], breaks)
    }
    if (isTRUE(max)) {
      breaks <- c(x[2], breaks)
    }
    breaks <- unique(sort(breaks))
    breaks <- breaks[breaks>=x[1] & breaks<=x[2]]
    
    #remove breaks too close to limits that they are likely to overlap
    scl_br <- (breaks - min(breaks)) / diff(range(breaks)) #or diff(x)
    if (isTRUE(min) & abs(scl_br[1] - scl_br[2]) < tol) {
      breaks <- breaks[-2]
    }
    if (isTRUE(max) & abs(scl_br[length(scl_br)] - scl_br[length(scl_br) - 1]) < tol) {
      breaks <- breaks[-(length(breaks)-1)]
    }
    labels <- as.character(round(breaks, digits = digits))
    if (isTRUE(min)) {
      labels[1] <- paste0("≤ ", labels[1])
    }
    if (isTRUE(max)) {
      labels[length(labels)] <- paste0("≥ ", labels[length(labels)])
    }
    names(breaks) <- labels
    breaks
  }
}