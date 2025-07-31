#' Query Database
#'
#' This function performs targeted queries on an SQLite database using specified filtering arguments and returns the query results.
#' It extracts information about which tables of the database are relevant for the query and then joins these relevant tables to the target table.
#' The function constructs an SQL query which incorporates both the joining and filtering target variables. This SQL statement is then applied to the database and the resulting dataframe is returned to the user.
#'
#' @param conn The connection object to an SQLite database.
#' @param arguments A list of filtering arguments for the query. The list must have only one filter argument per list-entry.
#' @param target_vars A character vector specifying the variables to be included in the query results.
#   If "default" is included as an element in the vector, it will be replaced by all variables present in the target_table.
#' @param target_table The target table in the database for querying.
#' @param argument_relation A character string specifying the relation between filtering arguments ("and" or "or" or a numerical vector with the same length as the number of arguments). Arguments with equal numbers in their index are joined using the OR operator, others using AND. To represent (A OR B) AND C AND D use the vector c(1, 1, 2, 3).
#' @return A data frame containing the query results.
#' @import DBI
#' @export
#'
#' @examples
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
#' arguments = add_argument(
#'  list = arguments,
#'  conn = conn,
#'  variable = "cyl",
#'  operator = "equal",
#'  values = c(4, 6)
#' )
#'
#' arguments = add_argument(
#'  list = arguments,
#'  conn = conn,
#'  variable = "example_value",
#'  operator = "greater",
#'  values = 0.4
#' )
#'
#' # Return specified variables
#' target_vars = c("mtcars_id", "example_id", "cyl")
#'
#' query_results = query_db(
#'  conn = conn,
#'  arguments = arguments,
#'  target_vars = target_vars,
#'  target_table = "example_table",
#'  argument_relation = "and"
#' )
#'
#' # Return all variables in mtcars_table and example_value from example_table
#' query_results = query_db(
#'  conn = conn,
#'  arguments = arguments,
#'  target_vars = c("default", "example_value"),
#'  target_table = "mtcars_table",
#'  argument_relation = "and"
#' )
#'
query_db <- function(conn, arguments, target_vars = "default", target_table = "observation_table", argument_relation = "and"){
  # Convert argument_relation into proper numerical vector
  argument_sequence = get_argument_sequence(arguments, argument_relation)

  # Get info about the db structure
  col_names = get_column_names(conn)

  # replace "default" in target_vars with all variables of the target table
  target_table_vars = col_names[col_names$table == target_table, "column"]

  used_default_vars = FALSE
  if ("default" %in% target_vars){
    used_default_vars = TRUE
    target_vars = unique(c(target_vars, target_table_vars))
    target_vars = target_vars[target_vars != "default"]
  }

  # Extract filter variables from arguments
  filter_variables = c()
  filter_statements = vector(mode = "list", length = length(arguments))
  for (i in seq_along(arguments)){
    filter_variables = c(
      filter_variables,
      base::sub(
        "WHERE ",
        "",
        base::regmatches(
          arguments[[i]],
          base::gregexpr("WHERE [a-z_\\.A-Z]+", arguments[[i]])
        )
      )
    )
    filter_statements[[i]] = base::regmatches(arguments[[i]], base::gregexpr("WHERE .*", arguments[[i]]))[[1]]
  }

  # Figure out which tables of the database are used
  relevant_tables = c()
  for (var in filter_variables){
    relevant_tables = c(relevant_tables, find_relevant_tables(conn, var, col_names, TRUE))
  }

  for (target_var in target_vars){
    table = find_relevant_tables(conn, target_var, col_names, TRUE)
    relevant_tables = c(relevant_tables, table)
  }

  relevant_tables = unique(relevant_tables)

  # Construct SQL query
  sql_query = add_join_paths_to_query(
    conn,
    filter_statements = filter_statements,
    join_path_list = precompute_table_join_paths(
      conn = conn,
      input_table = target_table,
      relevant_tables = relevant_tables
    ),
    argument_sequence = argument_sequence,
    requested_vars = target_vars
  )

  if (grepl("observation_table", sql_query)){
    print("Querying through observation table. Query times may be longer.")
  }

  # Send to db
  data = DBI::dbGetQuery(
    conn,
    sql_query
  )


  return(data)
}
