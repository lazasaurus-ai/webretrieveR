.onLoad <- function(libname, pkgname) {
  wr_register_engine("ddg", wr_engine_ddg)
  wr_register_engine("wikipedia", wr_engine_wikipedia)
}
