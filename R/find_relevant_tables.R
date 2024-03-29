#' Find relevant tables based on column name
#'
#' This function finds the relevant database tables that contain a specified column.
#'
#' @param conn The connection object or database connection string.
#' @param column_name The name of the column to search for in the database tables.
#' @param info Optional. The information data frame obtained from `get_column_names()` function.
#'   If not provided, it will be obtained within the function.
#' @param strict Should only one table be returned? Relevant for id variables
#'
#' @return A character vector containing the names of the relevant tables.
find_relevant_tables <- function(conn, column_name, info = NULL, strict = FALSE) {
  # TODO: maybe save an info-data and use that, check speed of get_column_names
  if (strict == TRUE & grepl("_id$", column_name)){
    tables = return_table_name_from_id(column_name)
    return(tables)
  }
  if (is.null(info)) {
    info = get_column_names(conn)
  }

  tables = info[info$column == column_name, "table"]

  if (length(tables) == 0) {
    msg = paste("The column:", column_name, "does not exist in any table in this database")
    stop(msg)
  }

  return(tables)
}
