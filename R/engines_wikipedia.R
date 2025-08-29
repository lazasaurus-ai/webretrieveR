#' Wikipedia retriever (search top hit -> summary, with alias fallback)
#' @keywords internal
wr_engine_wikipedia <- function(q, max_chars = 1500, include_urls = TRUE,
                                lang = "en", timeout_sec = 8) {
  ua <- "webretrieveR/0.1"
  
  # candidate queries: original + aliases (see wr_alias_candidates in utils)
  candidates <- unique(c(q, wr_alias_candidates(q)))
  
  pick <- NULL
  title <- NULL
  
  for (qq in candidates) {
    # Use search/page for broader matching
    res <- httr::GET(
      sprintf("https://%s.wikipedia.org/w/rest.php/v1/search/page", lang),
      query = list(q = qq, limit = 1),
      httr::user_agent(ua),
      httr::timeout(timeout_sec)
    )
    if (httr::http_error(res)) next
    txt   <- httr::content(res, as = "text", encoding = "UTF-8")
    js    <- jsonlite::fromJSON(txt, simplifyDataFrame = TRUE)
    pages <- tryCatch(js$pages, error = function(e) NULL)
    
    if (!is.null(pages) && NROW(pages) > 0) {
      # prefer 'key' if present, else 'title'
      title <- pages$key[1]
      if (is.null(title) || !nzchar(title)) title <- pages$title[1]
      pick  <- qq
      break
    }
  }
  
  if (is.null(title) || !nzchar(title)) {
    return(wr_build_context("Wikipedia", q, bullets = "No results.", max_chars = max_chars))
  }
  
  # Summary for the chosen page
  sum_res <- httr::GET(
    sprintf("https://%s.wikipedia.org/api/rest_v1/page/summary/%s",
            lang, utils::URLencode(title, reserved = TRUE)),
    httr::user_agent(ua),
    httr::timeout(timeout_sec)
  )
  httr::stop_for_status(sum_res)
  sum_txt <- httr::content(sum_res, as = "text", encoding = "UTF-8")
  p <- jsonlite::fromJSON(sum_txt, simplifyDataFrame = TRUE)
  
  bullets <- character(0)
  if (!is.null(p$description) && nzchar(p$description)) {
    bullets <- c(bullets, paste0("Description: ", p$description))
  }
  if (!is.null(p$extract) && nzchar(p$extract)) {
    url <- (p$content_urls$desktop$page %||% p$content_urls$mobile$page) %||% ""
    bullets <- c(
      bullets,
      if (include_urls && nzchar(url)) paste0(p$extract, " (", url, ")") else p$extract
    )
  }
  if (!length(bullets)) bullets <- "No summary available."
  
  wr_build_context("Wikipedia", q, bullets, max_chars = max_chars)
}
