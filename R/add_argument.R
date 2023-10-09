#' Add an argument to a list
#'
#' This function adds an argument to a list based on specified conditions.
#'
#' @param list The list to which the argument will be added.
#' @param conn The connection object or database connection string.
#' @param variable The variable name to be used in the argument.
#' @param operator The operator to be used in the argument (e.g., "greater", "between", "equal", "less").
#' @param values The values to be used in the argument.
#' @param statement The manual argument select statement to be used..
#'
#' @return The updated list with the added argument.
#' @export

add_argument <- function(list, conn, variable, operator, values, statement = NULL) {
  if (is.null(statement)) {
    list[[length(list) + 1]] = make_valid_sql(conn, variable, operator, values)
  } else {
    list[[length(list) + 1]] = statement
  }
  return(list)
}
