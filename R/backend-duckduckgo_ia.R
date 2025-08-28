#' Search DuckDuckGo Instant Answer
#'
#' Thin wrapper around \code{duckduckr::duckduck_answer()} that normalizes to a
#' common tibble schema used by this package.
#'
#' @param q Query string.
#' @param no_html Remove HTML from results (default TRUE).
#' @param skip_disambig Skip disambiguation pages (default FALSE).
#' @return A tibble with columns: title, url, snippet, score, published_at, source.
#' @export
search_duckduckgo_ia <- function(q, no_html = TRUE, skip_disambig = FALSE) {
  if (!requireNamespace("duckduckr", quietly = TRUE)) {
    stop("Package 'duckduckr' is required. Install it with install.packages('duckduckr').", call. = FALSE)
  }
  j <- duckduckr::duckduck_answer(
    q,
    no_html = no_html,
    skip_disambig = skip_disambig,
    app_name = "webretrieveR"
  )
  tibble::tibble(
    title        = j$Heading %||% q,
    url          = j$AbstractURL %||% NA_character_,
    snippet      = j$AbstractText %||% NA_character_,
    score        = 0.5,               # fixed weight; IA has no ranking
    published_at = NA_character_,
    source       = "duckduckgo_ia"
  )
}
