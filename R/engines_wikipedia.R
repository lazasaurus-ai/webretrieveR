#' Wikipedia retriever (search top hit -> summary)
#' @keywords internal
wr_engine_wikipedia <- function(q, max_chars = 1500, include_urls = TRUE,
                                lang = "en", timeout_sec = 6) {
  ua <- "webretrieveR/0.1"
  
  # 1) Title search
  search_res <- httr::GET(
    sprintf("https://%s.wikipedia.org/w/rest.php/v1/search/title", lang),
    query = list(q = q, limit = 1),
    httr::user_agent(ua),
    httr::timeout(timeout_sec)
  )
  httr::stop_for_status(search_res)
  s_txt  <- httr::content(search_res, as = "text", encoding = "UTF-8")
  # Use simplifyDataFrame to get a clean data.frame if possible
  s_json <- jsonlite::fromJSON(s_txt, simplifyDataFrame = TRUE)
  
  pages <- tryCatch(s_json$pages, error = function(e) NULL)
  if (is.null(pages) || NROW(pages) == 0) {
    return(wr_build_context("Wikipedia", q, bullets = "No results.", max_chars = max_chars))
  }
  
  # title extraction that works for both data.frame and list shapes
  title <- NA_character_
  if (!is.null(pages$title)) {
    title <- pages$title[1]
  } else if (is.list(pages) && length(pages) >= 1 && !is.null(pages[[1]]$title)) {
    title <- pages[[1]]$title
  }
  if (!nzchar(title)) {
    return(wr_build_context("Wikipedia", q, bullets = "No results.", max_chars = max_chars))
  }
  
  # 2) Summary
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
    if (include_urls && nzchar(url)) bullets <- c(bullets, paste0(p$extract, " (", url, ")"))
    else bullets <- c(bullets, p$extract)
  }
  
  if (!length(bullets)) bullets <- "No summary available."
  wr_build_context("Wikipedia", q, bullets, max_chars = max_chars)
}
