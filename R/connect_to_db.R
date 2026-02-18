#' Connect to an SQLite database
#'
#' This function establishes a connection to an SQLite database file located at the specified path using the DBI and RSQLite packages.
#'
#' @param path_to_db The path to the SQLite database file.
#'
#' @return A database connection object.
#' @export
#'
#' @examples
#' # When connecting to a specific file, like the downloaded ACDC-Database
#' # just use the path to the database
#' # If the specified database file does not exist, an error will be thrown.
#' # Consider downloading the database using `download_acdc()` or `download_ted()`.
#' \dontrun{conn <- connect_to_db("path/to/database.db")}
#'
#' @import DBI
#' @import RSQLite
connect_to_db <- function(path_to_db){
  if (!file.exists(path_to_db)) {
    stop(
      "Database file does not exist at the specified path.
      Consider downloading the database using download_acdc() or download_ted().",
      call. = FALSE)
  }
  conn = DBI::dbConnect(RSQLite::SQLite(), path_to_db)
  return(conn)
}
