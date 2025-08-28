#' WebClient: Minimal client for DuckDuckGo + LLM chat
#'
#' Wraps DuckDuckGo Instant Answer search and a user-supplied chat client
#' (e.g., \code{ellmer::chat_aws_bedrock()}), then exposes \code{$ask()}.
#'
#' @export
WebClient <- R6::R6Class(
  "WebClient",
  public = list(
    k_web        = NULL,
    chat_client  = NULL,   # function(prompt) -> character
    system_rules = NULL,
    initialize = function(k_web = getOption("webretrieveR.k_web", 5),
                          chat_client = getOption("webretrieveR.chat_client"),
                          system_rules = getOption("webretrieveR.system_rules")) {
      self$k_web        <- k_web
      if (!is.null(chat_client)) stopifnot(is.function(chat_client))
      self$chat_client  <- chat_client
      self$system_rules <- system_rules
    },
    #' Replace the chat client (e.g., ellmer::chat_aws_bedrock())
    set_chat = function(chat_client) {
      stopifnot(is.function(chat_client))
      self$chat_client <- chat_client; invisible(self)
    },
    #' Retrieve sources via DDG IA
    search = function(question) {
      search_web(question) |> utils::head(self$k_web)
    },
    #' Build SOURCES + QUESTION prompt
    context = function(question, hits = NULL) {
      if (is.null(hits)) hits <- self$search(question)
      paste0(
        self$system_rules, "\n\n",
        .build_sources_block(hits),
        "QUESTION: ", question, "\n"
      )
    },
    #' Ask the chat client with assembled context
    ask = function(question) {
      if (is.null(self$chat_client)) {
        stop("No chat_client set. Use set_chat() or options(webretrieveR.chat_client=...).", call. = FALSE)
      }
      hits   <- self$search(question)
      prompt <- self$context(question, hits)
      ans    <- self$chat_client(prompt)
      list(answer = ans, citations = hits, prompt_used = prompt)
    }
  )
)
