#' Query Database
#'
#' This function performs targeted queries on a database using specified filtering arguments and returns the query results.
#'
#' @param conn The connection object or database connection string.
#' @param arguments A list of filtering arguments for the query.
#' @param target_vars A character vector specifying the variables to be included in the query results.
#' @param argument_relation A character string specifying the relation between filtering arguments ("and" or "or" or a numerical vector with the same length as the number of arguments).
#' @param target_table The target table in the database for querying.
#' @param full_db A logical value indicating whether target variables are located only in one table, or distributed among multiple tables in the database.
#'
#' @return The query results as a data frame.
#' @import DBI
#' @export
#'
#' @examples
#' conn <- connect_to_db(":memory:")
#'
#' mtcars$mtcars_id = 1:nrow(mtcars)
#' PlantGrowth$plant_id = 1:nrow(PlantGrowth)
#' PlantGrowth$mtcars_id = 30:1
#'
#' DBI::dbWriteTable(conn, "mtcars_table", mtcars)
#' DBI::dbWriteTable(conn, "plant_table", PlantGrowth)
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
#' arguments = add_argument(
#'  list = arguments,
#'  conn = conn,
#'  variable = "weight",
#'  operator = "greater",
#'  values = 5
#' )
#'
#' query_results = query_db(
#'  conn = conn,
#'  arguments = arguments,
#'  target_vars = c("mtcars_id", "plant_id", "cyl", "weight"),
#'  argument_relation = "and",
#'  target_table = "plant_table",
#'  full_db = TRUE
#' )
query_db <- function(conn, arguments, target_vars = NULL, argument_relation = "and", target_table = "observation_table", full_db = TRUE){
  # When only requesting a specific table, make sure that target vars are present in that table
  if (full_db == FALSE){
    table_fields = DBI::dbListFields(conn, target_table)
    target_vars = target_vars[target_vars %in% table_fields]
    if (length(target_vars) == 0){
      warning("None of the variables you specified are present in the target table. Returning all variables from the target table.")
      target_vars = NULL
    }
  }

  argument_matches = vector(mode = "list", length = length(arguments))

  argument_sequence = get_argument_sequence(arguments, argument_relation)

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

  col_names = get_column_names(conn)

  relevant_tables = c()
  for (var in filter_variables){
    relevant_tables = c(relevant_tables, find_relevant_tables(conn, var, col_names, TRUE))
  }

  # Make sure that people dont filter
  if (("observation_table" %in% relevant_tables) & (target_table != "observation_table")){
    warning_message = "You are attempting to filter based on variables of the observation-level data. This can be very slow. Are you sure you want to continue?"
  }

  path_list = compute_fastest_way_to_table(conn, target_table = target_table)
  target_table_id = return_id_name_from_table(target_table)

  for (target_var in target_vars){
    table = find_relevant_tables(conn, target_var, col_names, TRUE)
    relevant_tables = c(relevant_tables, table)
  }
  relevant_tables = unique(relevant_tables)

  # protection against a full db query just taking variables from one table
  # this will break the join function because the path dataframe only has one row in that case
  if (all(relevant_tables == target_table)){
    full_db = FALSE
  }

  if (full_db == FALSE){
    data = DBI::dbGetQuery(
      conn,
      combine_sql_queries(
        arguments,
        argument_sequence,
        path_list,
        target_vars
      )
    )
  } else {
    data = DBI::dbGetQuery(
      conn,
      add_join_paths_to_query(
        conn,
        argument = combine_sql_queries(
          arguments,
          argument_sequence,
          path_list,
          target_vars
        ),
        filter_statements = filter_statements,
        join_path_list = precompute_table_join_paths(
          conn = conn,
          input_table = target_table,
          relevant_tables = relevant_tables
        ),
        argument_sequence = argument_sequence,
        requested_vars = target_vars
      )
    )
  }

  return(data)
}
