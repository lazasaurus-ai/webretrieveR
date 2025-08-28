#' @keywords internal
`%||%` <- function(a, b) if (!is.null(a) && length(a) > 0 && !is.na(a) && nzchar(a)) a else b

#' @keywords internal
.build_sources_block <- function(hits) {
  if (is.null(hits) || nrow(hits) == 0) return("SOURCES:\n(none)\n\n")
  lines <- paste0("[", seq_len(nrow(hits)), "] ", hits$title, " — ", hits$url)
  paste0("SOURCES:\n", paste(lines, collapse = "\n"), "\n\n")
}
