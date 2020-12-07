#' Create NetCDF
#'
#' @param in_file Path to NEXRAD Data file
#'
#' @return
#' @export
#'
#' @importFrom glue glue
#' @importFrom rJava .jaddClassPath .jcall J
create_netCDF <- function(in_file) {
  .jaddClassPath('inst/java/toolsUI-5.3.2.jar')
  ncdf_writer <- J('ucar.nc2.FileWriter2')
  out_file <- glue::glue('{in_file}.nc')
  tryCatch({
    if(!file.exists(out_file) ) {
      ncdf_writer$main(c('-in', in_file, '-out', out_file))
      if(file.exists(glue::glue('{in_file}.uncompress')) ) {
        file.remove(glue::glue('{in_file}.uncompress'))
        }
      }
    }, 
    IOException = function(e){
      e$message
      })
  }
