#' Check validity of operator and values
#'
#' This function checks the validity of the operator and values used in a condition.
#'
#' @param operator The operator to be checked.
#' @param values The values to be checked.
#'
#' @return NULL (no explicit return value).
#' @export

check_operator <- function(operator, values) {
  valid_operators = c("less", "greater", "between", "equal")

  if (!operator %in% valid_operators) {
    msg = paste0("Operator can only take the following values: ", paste(valid_operators, collapse = ", "))
    stop(msg)
  }

  if (operator == "between" & length(values) != 2) {
    msg = "When using the 'between' operator, please provide two values"
    stop(msg)
  }

  if (operator != "between" & operator != "equal" & length(values) != 1) {
    msg = "When using 'less', 'greater', or 'equal', provide only one value"
    stop(msg)
  }
}
