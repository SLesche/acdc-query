#' @export
query_db_targeted <- function(conn, arguments, target_vars = NULL, argument_relation = "and", target_table = "observation_table", full_db = TRUE){
  # copy some stuff off the query db function
  # but instead of return_connected_ids, use convert_query_path_to_sql in conjunction with compute_fastest_way_to_table

  # Querying starts
  if (full_db == TRUE & target_table != "observation_table"){
    warning("Requesting return of full database only works with the observation_table as the target table. (This is due to poor implementation of the backward join logic)")
  }

  # When only requesting a specific table, make sure that target vars are present in that table
  if (full_db == FALSE){
    table_fields = DBI::dbListFields(conn, target_table)
    target_vars = target_vars[target_vars %in% table_fields]
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
