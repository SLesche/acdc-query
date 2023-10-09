#' Add a filter argument to a list
#'
#' This function adds an argument to a list containing filter arguments later used to query databases. 
#' The user can either specify the variable on which to filter on and the operator and value used in the filter or specify an SQL query manually.
#' When supplying only variable, operator and value, a SQL query will be constructed for the user and added as the next object to a list.
#'
#' @param list The list to which the argument will be added.
#' @param conn The connection object or database connection string.
#' @param variable The variable name to be used in the argument.
#' @param operator The operator to be used in the argument (e.g., "greater", "between", "equal", "less").
#' @param values The values to be used in the argument.
#' @param statement The manual argument select statement to be used.
#'
#' @return The updated list with the added argument.
#' @export
#' @examples 
#' conn <- connect_to_db(":memory:")
#'
#' DBI::dbWriteTable(conn, "mtcars", mtcars)
#' 
#' arguments = list()
#' arguments = add_argument(
#'  list = arguments,
#'  conn = conn,
#'  variable = "cyl",
#'  operator = "equal",
#'  values = c(4, 6)
#' )
#' 
#' manual_arguments = add_argument(
#'  list = arguments,
#'  conn = conn,
#'  statement = "SELECT carb FROM mtcars WHERE cyl = 4 OR cyl = 6)"
#' )

add_argument <- function(list, conn, variable, operator, values, statement = NULL) {
  if (is.null(statement)) {
    list[[length(list) + 1]] = make_valid_sql(conn, variable, operator, values)
  } else {
    list[[length(list) + 1]] = statement
  }
  return(list)
}
