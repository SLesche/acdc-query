#' Create a valid SQL statement based on variable, operator, and values
#'
#' This function creates a valid SQL statement based on the specified variable, operator, and values.
#' It handles different operators such as "greater", "less", "equal", and "between".
#'
#' @param conn The connection object or database connection string.
#' @param variable The variable for which the SQL statement is created.
#' @param operator The operator to be used in the SQL statement.
#' @param values The values to be used in the SQL statement.
#'
#' @return A character string representing the valid SQL statement.
#' @examples
#' # Create a valid SQL statement
#' my_conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#' DBI::dbExecute(my_conn, "CREATE TABLE my_table (id INTEGER PRIMARY KEY, name TEXT)")
#' statement <- make_valid_sql(conn = my_conn, variable = "name", operator = "equal", values = c("John", "Jane"))
#' statement
make_valid_sql <- function(conn, variable, operator, values) {
  # if the variable is an id-name, it should be filtered in its table
  is_table = return_table_name_from_id(variable)
  if (is_table %in% dbListTables(conn)){
    id_name = variable
    table = is_table
  } else {
    # First find out which table the variable is from
    table = find_relevant_tables(conn, variable)
    id_name = return_id_name_from_table(table)
  }

  # Then turn this into a statement
  # Check validity of operator
  check_operator(operator, values)

  # if values is a char, surround with ''
  if (all(is.character(values))) {
    values = paste0("'", values, "'")
  }

  if (operator == "greater") {
    sql_statement = paste(
      "SELECT",
      id_name,
      "FROM",
      table,
      "WHERE",
      variable,
      ">",
      values[1]
    )
  }

  if (operator == "less") {
    sql_statement = paste(
      "SELECT",
      id_name,
      "FROM",
      table,
      "WHERE",
      variable,
      "<",
      values[1]
    )
  }

  if (operator == "equal") {
    equal_statement = ""
    for (i in seq_along(values)) {
      added_statement = paste(
        variable,
        "=",
        values[i]
      )
      if (i == 1) {
        equal_statement = added_statement
      } else {
        equal_statement = paste(equal_statement, "OR", added_statement)
      }
    }
    sql_statement = paste(
      "SELECT",
      id_name,
      "FROM",
      table,
      "WHERE",
      equal_statement
    )
  }

  if (operator == "between") {
    sql_statement = paste(
      "SELECT",
      id_name,
      "FROM",
      table,
      "WHERE",
      variable,
      ">",
      values[1],
      "AND",
      variable,
      "<",
      values[2]
    )
  }
  return(sql_statement)
}
