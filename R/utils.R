#' Create a base URL for a http request.
#'
#' @param api_type Type of API architecture. Must be one of c("rest", "soap").
#' @param file_format File format. Must be one of c("json", "xml", "ttl", "jsonld").
#' @param method RESTful method. Check the Marineregions gazetteer at https://marineregions.org/gazetteer.php?p=webservices for available methods.
#'
#' @return A base URL to append queries to.
#' @export
#'
#' @examples
#' api <- "rest"
#' file <- "json"
#' method <- "getGazetteerRecordsByName"
#' mr_req_URL(api_type = api, file_format = file, method = method)
#' # https://marineregions.org//rest/getGazetteerRecordsByName.json/

mr_req_URL <- function(api_type, file_format, method){
  URL <- "https://marineregions.org/"
  base_url <- glue::glue("{URL}/{api_type}/{method}.{file_format}/")

  # write function mr_gaz_methods() where you can see the available methods & search for strings
  methods <- c("getGazetteerRecordByMRGID", "getGazetteerGeometry" , "getGazetteerTypes", "getGazetteerGeometries", "getGazetteerRecordsByName", "getGazetteerRecordsByType", "getGazetteerWMSes", "getGazetteerRecordsByLatLong", "getGazetteerRecordsByNames", "getGazetteerSources", "getGazetteerNamesByMRGID", "getGazetteerRecordsBySource", "getFeed", "getGazetteerRelationsByMRGID")

  checkmate::assert_choice(api_type, c("rest", "soap"))
  checkmate::assert_choice(file_format, c("json", "xml", "ttl", "jsonld"))
  checkmate::assert_choice(method, methods)

  return(base_url)
}

#' Get user agent and package version
#'
#' @param . A http request.
#'
#' @return A character string that unites the user agent of the http request and the package version.
#' @export
#'
#' @examples \dontrun{
#' httr2::request("http://example.com") %>% req_mr_user_agent() %>% httr2::req_dry_run()
#' }
req_mr_user_agent <- function(.){
  httr2::req_user_agent(. , glue::glue("mregions2 {packageVersion('mregions')}"))
}

#' Transform httr2 response into tibble
#'
#' @param resp response from httr2 request.
#' @param unpack Set `TRUE` when `mr_gaz_records_by_names()` is run. This webservice nests the result once more.
#'
#' @return A tibble containing the json response body from the httr2 response.
#' @export
#'
#' @examples
#' name <- "High Sea"
#' count <- 5
#' url <- "https://marineregions.org//rest/getGazetteerRecordsByName.json/"
#'
#' req <- httr2::request(url) %>%
#'  httr2::req_url_path_append(utils::URLencode(name)) %>%
#'  httr2::req_url_path_append("/")
#'
#' resp <- req %>%
#'  httr2::req_url_query(
#'   `like` = TRUE,
#'   `fuzzy` = FALSE,
#'   `offset` = 0,
#'   `count` = count) %>%
#'  httr2::req_perform()
#'
#' res <- mr_resp_to_tibble(resp)
mr_resp_to_tibble <- function(resp, unpack = FALSE){

  res_json <- resp %>%
    httr2::resp_body_json()

  if(unpack){
    entries <- list()
    for (i in 1:length(res_json)) {
      entry <- res_json[[i]]
      entries <- append(entries, entry)
      }
    res_json <- entries
  }

  res <- do.call(rbind, res_json) %>%
    tibble::as_tibble(res_json)

  col_names <- colnames(res)
  res <- res %>%
    tidyr::unnest(col_names)

  return(res)
}

#' Replace NULL values with NA in list
#'
#' @description useful when running `tibble::as_tibble()` which does not accept NULL.
#' @param list_with_NULL list element passed to be changed to NA if NULL.
#'
#' @return elements in e.g. a list with NA instead of NULL.
#' @export
#'
#' @examples
#' y <- list(
#' one = c(month.abb, 5),
#' two = c(NULL, 5, NA),
#' three = NULL,
#' four = list(NULL) # does not change nested NULL for now
#' )
#' str(y)
#' z <- mr_null_to_na(y)
#' str(z)
mr_null_to_na <- function(list_with_NULL){

  checkmate::check_list(list_with_NULL)

  null_to_na <- function(x){
    if(is.null(x))
    {x <- NA} else{x}
    return(x)
  }

  list_with_NA <- lapply(list_with_NULL, null_to_na)
  return(list_with_NA)
}
