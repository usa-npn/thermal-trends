summarize_slope_diffs_state <- function(slope_differences, roi_sf) {
  states <- tibble(
    state = state.abb,
    state_name = state.name,
    ID = tolower(state.name)
  )
  extract <- exactextractr::exact_extract(
    slope_differences,
    roi_sf,
    fun = "mean",
    append_cols = TRUE
  )

  table <- left_join(extract, states, by = "ID") |>
    as_tibble() |>
    select(state, state_name, everything(), -ID) |>
    arrange(state)
  fs::dir_create("output", "tables")
  readr::write_csv(table, "output/tables/slope_diff_state_summary.csv")
  return("output/tables/slope_diff_state_summary.csv")
}
