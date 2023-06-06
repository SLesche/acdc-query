#' Add an argument to a list
#'
#' This function adds an argument to a list based on specified conditions.
#'
#' @param list The list to which the argument will be added.
#' @param conn The connection object or database connection string.
#' @param variable The variable or column name to be used in the argument.
#' @param operator The operator to be used in the argument (e.g., "greater", "between", "equal", "less").
#' @param values The values to be used in the argument.
#' @param manual A logical value indicating whether the argument should be created automatically or manually.
#'   If `FALSE`, the argument is created automatically using the provided parameters.
#'   If `TRUE`, the `statement` parameter must be specified.
#' @param statement The manual argument select statement to be used. Required if `manual = TRUE`.
#'
#' @return The updated list with the added argument.

add_argument <- function(list, conn, variable, operator, values, manual = FALSE, statement = NULL) {
  if (manual == FALSE) {
    list[[length(list) + 1]] = make_valid_sql(conn, variable, operator, values)
  } else {
    if (is.null(statement)) {
      stop("When using manual argument select, specify a statement variable")
    } else {
      list[[length(list) + 1]] = statement
    }
  }
  return(list)
}
