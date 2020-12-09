#' Download NEXRAD
#' 
#' This function will download NEXRAD data for a specific NEXRAD station from Amazon Web Services when a start datetime and endtime are provided.
#'
#' @param station_id The 4 letter NEXRAD station code
#' @param start_datetime A character vector representing the UTC start time of the data request. Format: 'YYYY-mm-dd HH:MM:SS'
#' @param end_datetime A character vector representing the UTC end time of the data request. Format: 'YYYY-mm-dd HH:MM:SS'
#'
#' @return The file name and location of downloaded NEXRAD files
#' @export
#' 
#' @importFrom magrittr %>% 
#' @importFrom lubridate as_datetime date 
#' @importFrom tibble as_tibble enframe
#' @importFrom dplyr mutate filter select
#' @importFrom purrr map_chr
#' @importFrom aws.s3 get_bucket_df save_object
#' @importFrom rlang .data
#' @importFrom glue glue
#' @importFrom stringr str_remove str_extract
#' @importFrom here here
#' @importFrom R.utils gunzip
#'
#' @examples 
#' \dontrun{
#' download_nexrad(station_id = 'KFWS', 
#'                 start_datetime = '2020-01-01 04:00:00', 
#'                 end_datetime = '2020-01-01 05:00:00')
#' }
download_nexrad <- function(station_id, start_datetime, end_datetime = NULL){
  
  # Turn user input into date object
  start_datetime <- lubridate::as_datetime(start_datetime)
  end_datetime <- if(is.null(end_datetime) ) {
    start_datetime
  } else { lubridate::as_datetime(end_datetime) }
  
  # Create a date sequence
  date_seq <- seq.Date(from = lubridate::date(start_datetime), 
                       to = lubridate::date(end_datetime), 
                       by = "day"
                       )
  # Download AWS data for each day in the sequence
  prefix <- glue::glue('{format(date_seq, "%Y")}/{format(date_seq, "%m")}/{format(date_seq, "%d")}/{station_id}')
  bucket <- aws.s3::get_bucket_df(bucket = "noaa-nexrad-level2", 
                                  key = "", 
                                  secret = "", 
                                  region = "us-east-1", 
                                  prefix = prefix) %>% 
    tibble::as_tibble() %>% 
    dplyr::mutate(temp = basename(.data$Key),
                  temp = stringr::str_remove(.data$temp, station_id),
                  temp = as.character(strptime(x = .data$temp, format = '%Y%m%d_%H%M%S')),
                  datetime = lubridate::as_datetime(.data$temp)
                  ) %>% 
    dplyr::select(.data$Key, .data$datetime)
  filtered_bucket <- if(start_datetime == end_datetime) {
    bucket %>% 
      dplyr::filter(.data$datetime >= start_datetime)
  } else {
    bucket %>% 
      dplyr::filter(.data$datetime >= start_datetime & .data$datetime <= end_datetime)
  }
  saved_data <- purrr::map_chr(.x = filtered_bucket$Key, ~ aws.s3::save_object(object = .x, 
                                                                               bucket = 'noaa-nexrad-level2', 
                                                                               key= '', 
                                                                               secret = '', 
                                                                               region = "us-east-1",
                                                                               file = here::here(glue::glue('nexrad_data/{basename(.x)}'))
                                                                               ) 
                               ) %>% 
    tibble::enframe(name = NULL, value = 'filename')
  zip_data <- saved_data %>% 
    dplyr::mutate(zip_file = stringr::str_extract(.data$filename, '.gz$')) %>% 
    dplyr::filter(!is.na(.data$zip_file))
  if(nrow(zip_data) > 0) {
    purrr::map_chr(.x = zip_data$filename, ~ R.utils::gunzip(.x, overwrite = T) ) %>% 
      tibble::enframe(name = NULL, value = 'filename')
  } else { return(saved_data) }
}
