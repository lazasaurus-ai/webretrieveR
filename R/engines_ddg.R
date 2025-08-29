#' DuckDuckGo Instant Answer retriever with web fallback
#' @keywords internal
wr_engine_ddg <- function(q, max_chars = 1500, include_urls = TRUE,
                          app_id = "webretrieveR/0.1", timeout_sec = 6) {
  res <- httr::GET(
    "https://api.duckduckgo.com/",
    query = list(q = q, format = "json", no_redirect = 1, no_html = 1, t = app_id),
    httr::user_agent(app_id),
    httr::timeout(timeout_sec)
  )
  httr::stop_for_status(res)
  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  p <- jsonlite::fromJSON(txt, simplifyVector = FALSE)
  
  bullets <- character()
  add <- function(txt, url = NULL) {
    if (is.null(txt) || !nzchar(txt)) return()
    if (include_urls && !is.null(url) && nzchar(url)) {
      bullets <<- c(bullets, paste0(txt, " (", url, ")"))
    } else {
      bullets <<- c(bullets, txt)
    }
  }
  
  # ── IA results
  if (!is.null(p$Answer) && nzchar(p$Answer)) add(paste0("Direct answer: ", p$Answer))
  if (!is.null(p$AbstractText) && nzchar(p$AbstractText)) add(p$AbstractText, p$AbstractURL %||% "")
  if (!is.null(p$Results) && length(p$Results)) {
    for (r in p$Results) add(r$Text %||% "", r$FirstURL %||% "")
  }
  .flatten_related <- function(rt) {
    out <- list()
    for (item in rt) {
      if (!is.null(item$Topics)) out <- c(out, .flatten_related(item$Topics))
      else out <- c(out, list(list(text = item$Text %||% "", url = item$FirstURL %||% "")))
    }
    out
  }
  if (!is.null(p$RelatedTopics) && length(p$RelatedTopics)) {
    for (rt in .flatten_related(p$RelatedTopics)) add(rt$text, rt$url)
  }
  
  # ── Fallback to DuckDuckGo HTML if no bullets
  if (length(bullets) == 0) {
    message("DuckDuckGo IA returned no results, falling back to web search…")
    url <- paste0("https://duckduckgo.com/html/?q=", URLencode(q, reserved = TRUE))
    res2 <- httr::GET(url, httr::user_agent(app_id), httr::timeout(timeout_sec))
    txt2 <- httr::content(res2, as = "text", encoding = "UTF-8")
    
    # Very simple regex scrape for titles/snippets (could be improved with xml2/rvest)
    titles <- stringr::str_match_all(txt2, "<a[^>]+class=\"result__a\"[^>]*>(.*?)</a>")[[1]][,2]
    snippets <- stringr::str_match_all(txt2, "<a[^>]+class=\"result__snippet\"[^>]*>(.*?)</a>")[[1]][,2]
    links <- stringr::str_match_all(txt2, "<a[^>]+class=\"result__a\" href=\"([^\"]+)\"")[[1]][,2]
    
    n <- min(length(titles), length(links))
    for (i in seq_len(n)) {
      txt_snip <- if (i <= length(snippets)) snippets[i] else ""
      add(paste0(titles[i], " – ", txt_snip), links[i])
    }
  }
  
  wr_build_context("DuckDuckGo", q, bullets, max_chars = max_chars)
}
