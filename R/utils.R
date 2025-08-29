#' @keywords internal
`%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x

#' Build a compact context block from bullets
#' @keywords internal
wr_build_context <- function(source, query, bullets, max_chars = 1500) {
  bullets <- unique(bullets[nzchar(bullets)])
  if (!length(bullets)) {
    return(paste0("Source: ", source, "\nQuery: ", query, "\n- No results."))
  }
  keep <- 0
  for (i in seq_along(bullets)) {
    trial <- paste0(
      "Source: ", source, "\nQuery: ", query, "\n",
      paste(paste0("- ", bullets[seq_len(i)]), collapse = "\n")
    )
    if (nchar(trial) <= max_chars) keep <- i else break
  }
  if (keep == 0) keep <- 1
  paste0(
    "Source: ", source, "\nQuery: ", query, "\n",
    paste(paste0("- ", bullets[seq_len(keep)]), collapse = "\n")
  )
}
