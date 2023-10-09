#' Get column names from database tables
#'
#' This function retrieves the column names from all tables in the specified database connection.
#'
#' @param conn The connection object or database connection string.
#'
#' @return A data frame containing the column names and corresponding table names.
#' @import DBI
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
