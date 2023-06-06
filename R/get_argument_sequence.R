#' Get argument sequence based on argument relation
#'
#' This function returns the sequence of arguments based on the specified argument relation.
#' The argument relation determines the logical relationship between the arguments (e.g., "and", "or").
#'
#' @param arguments The list of arguments.
#' @param argument_relation The specified argument relation. If "and", the sequence will be 1:length(arguments).
#'   If "or", the sequence will be rep(1, length(arguments)).
#'   If a vector is provided, it should have the same length as the number of arguments.
#'
#' @return A numeric vector representing the sequence of arguments.
#' @examples
#' # Get argument sequence with "and" relation
#' arguments <- list("arg1", "arg2", "arg3")
#' argument_sequence <- get_argument_sequence(arguments, argument_relation = "and")
#' argument_sequence
#'
#' # Get argument sequence with "or" relation
#' arguments <- list("arg1", "arg2", "arg3")
#' argument_sequence <- get_argument_sequence(arguments, argument_relation = "or")
#' argument_sequence
#'
#' # Get argument sequence with custom relation
#' arguments <- list("arg1", "arg2", "arg3")
#' argument_relation <- c("or", "and", "or")
#' argument_sequence <- get_argument_sequence(arguments, argument_relation)
#' argument_sequence
get_argument_sequence <- function(arguments, argument_relation) {
  if (length(argument_relation) == 1) {
    if (argument_relation == "and") {
      argument_sequence = 1:length(arguments)
    } else if (argument_relation == "or") {
      argument_sequence = rep(1, length(arguments))
    }
  } else if (length(arguments) != length(argument_relation)) {
    stop("When specifying custom argument relations, make sure that you have a vector of the same length as the number of arguments")
  } else {
    argument_sequence = argument_relation
  }
  return(argument_sequence)
}
