#' Align NEXRAD Moments
#'
#' @param nc_file NetCDF File  
#' @param csv_out File path to save output
#' 
#' @importFrom dplyr filter full_join mutate select
#' @importFrom ncmeta nc_grids
#' @importFrom purrr map
#' @importFrom tidync activate hyper_tibble tidync
#' @importFrom tidyr unnest
#' @importFrom readr write_csv
#' @importFrom rlang .data
#' @importFrom stringr str_detect
#' @return
#' @export
#'

align_moments <- function(nc_file, csv_out = NULL) {
  nc <- tidync::tidync(nc_file)
  grids_HI <- ncmeta::nc_grids(nc_file) %>% 
    tidyr::unnest(cols = ('variables')) %>% 
    filter(stringr::str_detect(.data$variable, '_HI')) %>% 
    dplyr::mutate(data = purrr::map(grid,
                                    ~nc %>% 
                                      tidync::activate(.x) %>% 
                                      tidync::hyper_tibble()
                                    )
                  )
  
  aligned_moments <- grids_HI$data[[1]] %>% 
    dplyr::full_join(grids_HI$data[[2]], 
                     by = c('gateD_HI' = 'gateC_HI', 
                            'radialD_HI' = 'radialC_HI' , 
                            'scanD_HI' = 'scanC_HI'
                            ) 
                     ) %>% 
    dplyr::full_join(grids_HI$data[[3]],
                     by = c('gateD_HI' = 'gateP_HI', 
                            'radialD_HI' = 'radialP_HI' , 
                            'scanD_HI' = 'scanP_HI'
                            )
                     ) %>%
    dplyr::full_join(grids_HI$data[[4]],
                     by = c('gateD_HI' = 'gateR_HI', 
                            'radialD_HI' = 'radialR_HI' , 
                            'scanD_HI' = 'scanR_HI'
                            )
                     ) %>%
    dplyr::full_join(grids_HI$data[[5]],
                     by = c('gateD_HI' = 'gateV_HI', 
                            'radialD_HI' = 'radialV_HI' , 
                            'scanD_HI' = 'scanV_HI'
                            )
                     ) %>% 
    dplyr::select(gateD_HI, radialD_HI, scanD_HI, Reflectivity_HI, RadialVelocity_HI, SpectrumWidth_HI, DifferentialReflectivity_HI, CorrelationCoefficient_HI, DifferentialPhase_HI)
  
  if(!is.null(csv_out)) {
    aligned_moments %>% 
      readr::write_csv(file = csv_out)
    }
  return(aligned_moments)
  }
