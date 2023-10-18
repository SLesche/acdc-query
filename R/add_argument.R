#' Add a filter argument to a list
#'
#' This function adds an argument to a list containing filter arguments later used to select data from the database.
#' When supplying the variable used for filtering, the operator and the value, an SQL query will be constructed for the user and added as the next object to the list of arguments.#' When supplying only variable, operator and value, a SQL query will be constructed for the user and added as the next object to a list.
#' Alternatively, the user may specify an SQL query manually.
#'
#' @param list The list to which the argument will be added.
#' @param conn The connection object or database connection string.
#' @param variable The variable name to be used in the argument.
#' @param operator The operator to be used in the argument (i.e., "greater", "between", "equal", "less").
#' @param values The values to be used in the argument.
#' @param statement The manual SQL query to be used.
#'
#' @return A list object with the new argument (SQL query) added.
#' @export
#' @examples
#'
#' conn <- connect_to_db(":memory:")
#'
#' mtcars$mtcars_id = 1:nrow(mtcars)
#'
#' example_data = data.frame(
#'   example_id = 1:150,
#'   mtcars_id = rep(1:30, each = 5),
#'   example_value = runif(150, 0, 1)
#' )
#'
#' DBI::dbWriteTable(conn, "mtcars_table", mtcars)
#' DBI::dbWriteTable(conn, "example_table", example_data)
#'
#' # Initializing argument list
#' arguments = list()
#'
#' # Using "equal" operator
#' arguments = add_argument(
#'  list = arguments,
#'  conn = conn,
#'  variable = "cyl",
#'  operator = "equal",
#'  values = c(4, 6)
#' )
#'
#' # Using "greater" operator
#' arguments = add_argument(
#'  list = arguments,
#'  conn = conn,
#'  variable = "cyl",
#'  operator = "greater",
#'  values = 2
#' )
#'
#' # Using "between" operator
#' arguments = add_argument(
#'  list = arguments,
#'  conn = conn,
#'  variable = "cyl",
#'  operator = "between",
#'  values = c(2, 8)
#' )
#'
#' # Manully constructing a filter statement
#' manual_arguments = add_argument(
#'  list = arguments,
#'  conn = conn,
#'  statement = "SELECT mtcars_id FROM mtcars WHERE cyl = 4 OR cyl = 6)"
#' )

add_argument <- function(list, conn, variable, operator, values, statement = NULL) {
  if (is.null(statement)) {
    list[[length(list) + 1]] = make_valid_sql(conn, variable, operator, values)
  } else {
    list[[length(list) + 1]] = statement
  }
  return(list)
}
