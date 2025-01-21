appraise_gam <- function(gam) {
  if (!inherits(gam, "gam")) { #if target doesn't exist...
    return(NULL)
  }
  gam_name <- deparse(substitute(gam))
  p <- gratia::appraise(gam) + patchwork::plot_annotation(title = gam_name)
  ggsave(
    filename = paste0("appraisal_", gam_name, ".png"),
    plot = p, 
    path = "output/gams/",
    width = 12, 
    height = 10, 
    bg = "white"
  )
  
}