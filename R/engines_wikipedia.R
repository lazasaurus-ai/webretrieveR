#' Wikipedia retriever (search top hit -> summary, with alias fallback)
#' @keywords internal
wr_engine_wikipedia <- function(q, max_chars = 1500, include_urls = TRUE,
                                lang = "en", timeout_sec = 8) {
  ua <- "webretrieveR/0.1"
  
  # use alias helper if available, else none
  aliases <- if (exists("wr_alias_candidates", mode = "function", inherits = TRUE)) {
    tryCatch(wr_alias_candidates(q), error = function(e) character(0))
  } else character(0)
  
  candidates <- unique(c(q, aliases))
  pick_title <- NULL
  
  # broader endpoint: search/page
  for (qq in candidates) {
    res <- httr::GET(
      sprintf("https://%s.wikipedia.org/w/rest.php/v1/search/page", lang),
      query = list(q = qq, limit = 1),
      httr::user_agent(ua),
      httr::timeout(timeout_sec)
    )
    if (httr::http_error(res)) next
    js  <- jsonlite::fromJSON(httr::content(res, as = "text", encoding = "UTF-8"),
                              simplifyDataFrame = TRUE)
    pages <- tryCatch(js$pages, error = function(e) NULL)
    if (!is.null(pages) && NROW(pages) > 0) {
      pick_title <- pages$key[1]
      if (is.null(pick_title) || !nzchar(pick_title)) pick_title <- pages$title[1]
      if (nzchar(pick_title)) break
    }
  }
  
  if (!nzchar(pick_title)) {
    return(wr_build_context("Wikipedia", q, bullets = "No results.", max_chars = max_chars))
  }
  
  # summary
  res2 <- httr::GET(
    sprintf("https://%s.wikipedia.org/api/rest_v1/page/summary/%s",
            lang, utils::URLencode(pick_title, reserved = TRUE)),
    httr::user_agent(ua),
    httr::timeout(timeout_sec)
  )
  httr::stop_for_status(res2)
  p <- jsonlite::fromJSON(httr::content(res2, as = "text", encoding = "UTF-8"),
                          simplifyDataFrame = TRUE)
  
  bullets <- character(0)
  if (!is.null(p$description) && nzchar(p$description))
    bullets <- c(bullets, paste0("Description: ", p$description))
  if (!is.null(p$extract) && nzchar(p$extract)) {
    url <- (p$content_urls$desktop$page %||% p$content_urls$mobile$page) %||% ""
    bullets <- c(bullets, if (include_urls && nzchar(url)) paste0(p$extract, " (", url, ")") else p$extract)
  }
  if (!length(bullets)) bullets <- "No summary available."
  
  wr_build_context("Wikipedia", q, bullets, max_chars = max_chars)
}
