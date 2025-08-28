#' Unified Web Search (DuckDuckGo IA only, minimal build)
#'
#' For this minimal package, \code{search_web()} delegates to
#' \code{search_duckduckgo_ia()} and returns a normalized tibble.
#'
#' @param q Query string.
#' @param ... Passed to \code{search_duckduckgo_ia()}.
#' @return A tibble: title, url, snippet, score, published_at, source.
#' @export
search_web <- function(q, ...) {
  stopifnot(is.character(q), length(q) == 1, nzchar(q))
  search_duckduckgo_ia(q, ...)
}
