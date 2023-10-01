#' Query Database
#'
#' This function performs targeted queries on a database using specified filtering arguments and returns the query results.
#'
#' @param conn The connection object or database connection string.
#' @param arguments A list of filtering arguments for the query.
#' @param target_vars A character vector specifying the variables to be included in the query results.
#' @param argument_relation A character string specifying the relation between filtering arguments ("and" or "or").
#' @param target_table The target table in the database for querying.
#' @param full_db A logical value indicating whether to return the entire database. Only works when the target table is "observation_table".
#'
#' @return The query results as a data frame.
#' @export
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
      stringr::str_remove(
        stringr::str_extract_all(
          arguments[[i]], "WHERE [a-z_A-Z]+"
        ),
        "WHERE "
      )
    )

    filter_statements[[i]] = stringr::str_extract(arguments[[i]], "WHERE .*")
  }

  col_names = get_column_names(conn)

  relevant_tables = c()
  for (var in filter_variables){
    relevant_tables = c(relevant_tables, find_relevant_tables(conn, var, col_names, TRUE))
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
    data = dbGetQuery(
      conn,
      combine_sql_queries(
        arguments,
        argument_sequence,
        path_list,
        target_vars
      )
    )
  } else {
    data = dbGetQuery(
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
