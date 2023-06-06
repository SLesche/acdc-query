#' Extract IDs from a database table
#'
#' This function extracts the IDs from a specified database table.
#'
#' @param conn The connection object or database connection string.
#' @param table The name of the database table from which to extract IDs.
#' @param variable Optional. Works in conjunction with id_vector to return a filtered version
#' @param id_vector Optional. Only return entries that contain these ids
#'
#' @return A data frame or tibble containing the extracted IDs.
#' @examples
#' # Extract IDs from a table
#' my_conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#' DBI::dbExecute(my_conn, "CREATE TABLE my_table (id INTEGER PRIMARY KEY, name TEXT)")
#' DBI::dbExecute(my_conn, "INSERT INTO my_table (name) VALUES ('John'), ('Jane')")
#' ids <- extract_table_ids(conn = my_conn, table = "my_table")
#' ids
extract_table_ids <- function(conn, table, variable = NULL, id_vector = NULL) {
  which_columns_exist_query = paste0("PRAGMA table_info(", table, ")")
  table_columns = DBI::dbGetQuery(conn, which_columns_exist_query)
  ends_in_id = table_columns$name[grep("_id$", table_columns$name)]
  ends_in_id_sql = paste(ends_in_id, collapse = ", ")
  id_str = paste0(id_vector, collapse = ",")

  if (is.null(variable) & is.null(id_vector)){
    sql_statement = paste0("SELECT ", ends_in_id_sql, " FROM ", table)
    ids = DBI::dbGetQuery(conn, sql_statement)
  } else if (!is.null(variable) & !is.null(id_vector)){
    sql_statement = sprintf("SELECT %s FROM %s WHERE %s IN (%s)", ends_in_id_sql, table, variable, id_str)
    ids = DBI::dbGetQuery(conn, sql_statement)
  } else {
    stop("When using this function, specify either both 'variable' and 'ids' or none of the two!")
  }

  return(ids)
}
