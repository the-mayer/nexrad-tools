#' Create NetCDF
#'
#' @param in_file Path to NEXRAD Data file
#' @param out_path Path to output directory
#'
#' @return
#' @export
#'
#' @importFrom glue glue
#' @importFrom rJava .jaddClassPath .jcall .jnew 
create_netCDF <- function(in_file, out_file_path) {
  .jaddClassPath('inst/java/BlockBunzipper.jar')
  .jaddClassPath('inst/java/commons-compress-1.20.jar')
  ncdf_writer <- .jnew('BlockBunzipper')
  out_file <- glue::glue('{out_path}/{basename(in_file)}.ncdf')
  .jcall(ncdf_writer, returnSig="V", method="main", c(in_file, out_file) )
}
