#' Get column names from database tables
#'
#' This function retrieves the column names from all tables in the specified database connection.
#'
#' @param conn The connection object or database connection string.
#'
#' @return A data frame containing the column names and corresponding table names.
#' @examples
#' # Get column names from tables
#' my_conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#' DBI::dbExecute(my_conn, "CREATE TABLE table1 (id INTEGER PRIMARY KEY, name TEXT)")
#' DBI::dbExecute(my_conn, "CREATE TABLE table2 (id INTEGER PRIMARY KEY, age INTEGER)")
#' column_names <- get_column_names(conn = my_conn)
#' column_names
get_column_names <- function(conn) {
  tables = DBI::dbListTables(conn)
  tables = tables[tables != "sqlite_sequence"]
  column_names = data.frame(
    column = c(),
    table = c()
  )
  for (table in tables) {
    columns = DBI::dbListFields(conn, table)
    for (column in columns) {
      add = data.frame(
        column = column,
        table = table
      )
      column_names = rbind(column_names, add)
    }
  }
  return(column_names)
}
