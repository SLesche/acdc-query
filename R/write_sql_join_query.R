write_sql_join_query <- function(conn, argument, join_path_list = NULL){
# Could also compute the join_path_list
  if (is.null(join_path_list)){
    join_path_list = precompute_table_join_paths(conn)
  }

  # join the paths selectively on the argument
  add_join_paths_to_query(argument, join_path_list)

}
