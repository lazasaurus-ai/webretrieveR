#' Retrieve compact context from one or more engines
#'
#' @param q Query string.
#' @param engines Character vector of engine names to run (default c("ddg","wikipedia")).
#' @param max_chars_each Max characters per engine block.
#' @param include_urls Include URLs inline when provided by the engine.
#' @param as One of "string" (single concatenated block) or "list" (named list by engine).
#' @param ... Passed to engine functions.
#' @return Character (as="string") or named list (as="list").
#' @examples
#' \dontrun{
#' wr_retrieve("R programming language", engines = c("ddg","wikipedia"))
#' }
#' @export
wr_retrieve <- function(q,
                        engines = c("ddg","wikipedia"),
                        max_chars_each = 1200,
                        include_urls = TRUE,
                        as = c("string","list"),
                        ...) {
  as <- match.arg(as)
  out <- list()
  for (e in engines) {
    fun <- get0(e, envir = .wr_registry, inherits = FALSE)
    if (!is.function(fun)) stop("Engine not registered: ", e)
    out[[e]] <- fun(q, max_chars = max_chars_each, include_urls = include_urls, ...)
  }
  if (as == "list") return(out)
  paste(out, collapse = "\n\n")
}

#' Build an ellmer-ready prompt from engines + question
#'
#' @param question The question you’ll ask the LLM.
#' @inheritParams wr_retrieve
#' @return Character prompt string suitable for ellmer::chat_aws_bedrock()$chat()
#' @examples
#' \dontrun{
#' prompt <- wr_ellmer_prompt("What is R used for?",
#'                            engines = c("ddg","wikipedia"))
#' ch <- ellmer::chat_aws_bedrock("anthropic.claude-3-5-sonnet-20240620-v1:0")
#' ch$chat(prompt)
#' }
#' @export
wr_ellmer_prompt <- function(question,
                             engines = c("ddg","wikipedia"),
                             max_chars_each = 1200,
                             include_urls = TRUE,
                             ...) {
  ctx <- wr_retrieve(question, engines = engines,
                     max_chars_each = max_chars_each,
                     include_urls = include_urls, as = "string", ...)
  paste0(
    ctx,
    "\n\nUsing only the context above when possible, answer clearly. ",
    "Cite URLs inline if present.\nQuestion: ", question
  )
}
