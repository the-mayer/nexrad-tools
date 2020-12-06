#' Title
#'
#' @param in_file_path 
#' @param out_file_path 
#'
#' @return
#' @export
#'
#' @examples
#' @importFrom rJava .jaddLibrary .jaddClassPath .jnew
create_netCDF <- function(in_file_path, out_file_path) {
  .jaddClassPath('inst/java/BlockBunzipper.jar')
  .jaddClassPath('inst/java/commons-compress-1.20.jar')
  ncdf_writer <- .jnew('BlockBunzipper')
  .jcall(ncdf_writer, returnSig="V", method="main", c(in_file_path, out_file_path) )
}
