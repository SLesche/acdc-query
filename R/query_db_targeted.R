#' Query Database Targeted
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
query_db_targeted <- function(conn, arguments, target_vars = NULL, argument_relation = "and", target_table = "observation_table", full_db = TRUE){
  if (full_db == TRUE & target_table != "observation_table"){
    warning("Requesting return of full database only works with the observation_table as the target table. (This is due to poor implementation of the backward join logic)")
  }

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

  path_list = compute_fastest_way_to_table(conn, target_table = target_table)
  target_table_id = return_id_name_from_table(target_table)

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
        combine_sql_queries(
          arguments,
          argument_sequence,
          path_list,
          target_vars
        ),
        precompute_table_join_paths(conn),
        target_vars
      )
    )
  }

  return(data)
}
