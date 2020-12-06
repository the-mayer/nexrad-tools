#' Create NetCDF
#'
#' @param in_file Path to NEXRAD Data file
#' @param out_path Path to output directory
#'
#' @return
#' @export
#'
#' @importFrom glue glue
#' @importFrom rJava .jaddClassPath .jcall J
create_netCDF <- function(in_file, out_file_path) {
  .jaddClassPath('inst/java/toolsUI-5.3.2.jar')
  ncdf_writer <- J('ucar.nc2.FileWriter2')
  out_file <- glue::glue('{out_path}/{basename(in_file)}.ncdf')
  .jcall(ncdf_writer, returnSig="V", method="main", c('-in', in_file, '-out', out_file) )
  try(file.remove(glue::glue('{in_file}.uncompress')), silent = T)
}
