#' Connect to a SQLite database
#'
#' This function establishes a connection to a SQLite database file located at the specified path using the DBI and RSQLite packages.
#'
#' @param path_to_db The path to the SQLite database file.
#'
#' @return A database connection object.
#' @export
#'
#' @examples
#' # Connect to a SQLite database file in memory
#' conn <- connect_to_db(":memory:")
#' 
#' # When connecting to a specific file, like the downloaded ACDC-Database just use the path to the database
#' 
#' # conn <- connect_to_db("path/to/database.db")
#'
#' @import DBI
#' @import RSQLite
connect_to_db <- function(path_to_db){
  conn = DBI::dbConnect(RSQLite::SQLite(), path_to_db)
  return(conn)
}
