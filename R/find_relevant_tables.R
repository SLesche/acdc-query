#' Find relevant tables based on column name
#'
#' This function finds the relevant database tables that contain a specified column.
#'
#' @param conn The connection object or database connection string.
#' @param column_name The name of the column to search for in the database tables.
#' @param info Optional. The information data frame obtained from `get_column_names()` function.
#'   If not provided, it will be obtained within the function.
#'
#' @return A character vector containing the names of the relevant tables.
#' @examples
#' # Find relevant tables
#' my_conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#' DBI::dbExecute(my_conn, "CREATE TABLE table1 (id INTEGER PRIMARY KEY, name TEXT)")
#' DBI::dbExecute(my_conn, "CREATE TABLE table2 (id INTEGER PRIMARY KEY, age INTEGER)")
#' tables <- find_relevant_tables(conn = my_conn, column_name = "id")
#' tables
find_relevant_tables <- function(conn, column_name, info = NULL) {
  # TODO: maybe save an info-data and use that, check speed of get_column_names
  if (is.null(info)) {
    info <- get_column_names(conn)
  }

  tables <- info[info$column == column_name, "table"]

  if (length(tables) == 0) {
    stop("This column does not exist in any table in this database")
  }

  return(tables)
}
