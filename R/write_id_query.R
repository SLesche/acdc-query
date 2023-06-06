#' Generate SQL query for filtering IDs in a table
#'
#' This function generates an SQL query to filter rows in a table based on a
#' vector of IDs. It constructs a query that selects all columns from the given
#' table where the specified variable name matches any of the IDs in the vector.
#'
#' @param table_name The name of the table to query.
#' @param variable_name The name of the variable/column to filter on.
#' @param id_vector A vector of IDs to match against the variable.
#'
#' @return The generated SQL query.
#'
#' @examples
#' # Generate an SQL query to filter IDs in a table
#' write_id_query("my_table", "id_column", c(1, 2, 3))
#'
write_id_query <- function(table_name, variable_name, id_vector) {
  # Convert the ID vector to a comma-separated string
  id_str = paste0(id_vector, collapse = ",")

  # Construct the SQL query
  sql_query = sprintf("SELECT * FROM %s WHERE %s IN (%s)", table_name, variable_name, id_str)

  # Return the results
  return(sql_query)
}
