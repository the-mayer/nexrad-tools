#' Create NetCDF
#'
#' @param in_file_path Path to NEXRAD Data file
#' @param out_file_path Path to output file
#'
#' @return
#' @export
#'
#' @importFrom rJava .jaddClassPath .jcall .jnew 
create_netCDF <- function(in_file_path, out_file_path) {
  .jaddClassPath('inst/java/BlockBunzipper.jar')
  .jaddClassPath('inst/java/commons-compress-1.20.jar')
  ncdf_writer <- .jnew('BlockBunzipper')
  .jcall(ncdf_writer, returnSig="V", method="main", c(in_file_path, out_file_path) )
}
