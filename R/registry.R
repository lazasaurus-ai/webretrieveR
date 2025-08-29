#' Internal registry for retrievers
#' @keywords internal
.wr_registry <- new.env(parent = emptyenv())

#' Register a retriever engine
#'
#' A retriever is a function of the form:
#'   function(q, max_chars = 1500, include_urls = TRUE, ...) -> character
#' returning a single compact context string.
#'
#' @param name Engine name (e.g., "ddg", "wikipedia").
#' @param fun  Function implementing the retriever signature.
#' @export
wr_register_engine <- function(name, fun) {
  stopifnot(is.character(name), length(name) == 1, nzchar(name))
  stopifnot(is.function(fun))
  assign(name, fun, envir = .wr_registry)
  invisible(name)
}

#' List registered engines
#' @return character vector of engine names
#' @export
wr_list_engines <- function() sort(ls(.wr_registry))
