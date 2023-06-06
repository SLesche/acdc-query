#' Identify the table queried in SQL argument
#'
#' This function takes an SQL argument and extracts the table name that is being
#' queried in the "FROM" clause. It uses regular expressions to locate the table
#' name after the "FROM" keyword.
#'
#' @param sql_argument The SQL argument to analyze.
#'
#' @return The table name that is being queried.
#'
#' @examples
#' # Extract the table name from an SQL argument
#' which_table_is_queried(sql_argument)
#'
which_table_is_queried <- function(sql_argument){
  table = stringr::str_extract(sql_argument, "(?<=FROM\\s)\\w+")
  return(table)
}
