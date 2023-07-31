#' Download the database file
#'
#' This function downloads the database file from a specified URL and saves it to the local path.
#'
#' @param local_path The local path where the downloaded file will be saved.
#'
#' @return NULL (no explicit return value).
#' @export
#'
#' @examples
#' # Download the database file to the current working directory
#' download_db("initial_db.db")
#'
download_db <- function(local_path){
  # TODO: Have this updated
  # TODO: Return a "last updated" file somewhere.
  db_url = "https://raw.githubusercontent.com/jstbcs/inhibitiontasks/inhibitiontaks_db2023/initial_db.db"
  utils::download.file(
    url = db_url,
    destfile = local_path,
    quiet = TRUE
  )
}
