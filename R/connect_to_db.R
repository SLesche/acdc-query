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
#' # Connect to a SQLite database file
#' db_file <- base::system.file("extdata", "acdc.db", package = "acdcquery")
#' conn <- connect_to_db(db_file)
#'
#' # When connecting to a specific file, like the downloaded ACDC-Database
#' # just use the path to the database
#' \dontrun{conn <- connect_to_db("path/to/database.db")}
#'
#' # Want the most recent version of the database?
#' # Download it at https://github.com/jstbcs/acdc-database/blob/main/acdc.db
#'
#' @import DBI
#' @import RSQLite
connect_to_db <- function(path_to_db){
  conn = DBI::dbConnect(RSQLite::SQLite(), path_to_db)
  return(conn)
}
