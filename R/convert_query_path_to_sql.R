#' Convert Query Path to SQL
#'
#' This function converts a table-specific filtering argument specified in 'argument'
#' to a more general SQL query that returns entries from the target table that was
#' used to generate the path list. It uses the query to determine at which table the argument
#' is set and then constructs a SQL query by utilizing the table pathway to the target table.
#'
#' @param argument The table-specific filtering argument.
#' @param path_list A list representing the join path. Each element of the list should be a data frame
#'   describing a step in the join path with columns: "waypoint_tables", "walk_approaches", and "target_table".
#' @param requested_vars A character vector specifying the variables to be selected from the final query result.
#'   If \code{NULL}, all variables are selected.
#'
#' @return A SQL query string that represents the desired filtering and joins on the target table.
convert_query_path_to_sql <- function(argument, path_list, requested_vars = NULL){
  # This function aims to convert a table-specific filtering argument specified
  # in 'argument' to a more general SQL query that returns entries from the
  # target table that was used to generate the path list,
  # to do this, we use the SQL query to figure out at which table the argument is set
  # and then use this tables pathway to the target table to build the SQL-Query

  base_argument = argument
  starting_table = base::regmatches(base_argument, base::gregexpr("[a-z]+_table", base_argument))[[1]]
  filter_statement = base::regmatches(base_argument, base::gregexpr( "WHERE .*$", base_argument))[[1]]
  starting_table_index = c()

  for (i in seq_along(path_list)){
    if (path_list[[i]]$table == starting_table){
      starting_table_index = i

      break
    }
  }

  path_dataframe = path_list[[starting_table_index]]$path
  target_table = path_list[[starting_table_index]]$target_table


  if (target_table == starting_table){
    argument_request_vars = base::sub(
      return_id_name_from_table(target_table),
      " * ",
      argument
    )

    argument_request_vars = base::sub(
      target_table,
      paste(target_table, "AS tab"),
      argument_request_vars
    )

    return(argument_request_vars)
  }

  if (is.null(requested_vars)){
    selected_vars = " * "
  } else {
    selected_vars = paste(
      requested_vars,
      collapse = ", "
    )
  }

  sql_base_query = paste0(
    "SELECT ",
    selected_vars,
    " FROM ",
    target_table,
    " AS tab"
  )

  sql_query = sql_base_query

  added_sql = c()

  for (i in nrow(path_dataframe):1){
    # Notice that i runs from the back of path-dataframe to front
    # this is because the last entry is closest to the target table

    if (i == nrow(path_dataframe)){
      i_following_table = target_table
    } else {
      i_following_table = path_dataframe$waypoint_tables[i + 1]
    }
    i_following_id = return_id_name_from_table(i_following_table)

    i_walk_approach = path_dataframe$walk_approaches[i]
    i_waypoint_table = path_dataframe$waypoint_tables[i]
    i_waypoint_id = return_id_name_from_table(i_waypoint_table)

    # this is in here to make joins work. Adds tab. to the selected table if its
    # the first in query queue
    as_tab_name = c()
    if (i == nrow(path_dataframe)){
      as_tab_name = "tab."
    }

    # go backwards in path dataframe to build the query
    if (i_walk_approach == "backward"){
      current_add = paste0(
        " WHERE ",
        as_tab_name, i_waypoint_id,
        " IN (",
        "SELECT ",
        i_waypoint_id,
        " FROM ",
        i_waypoint_table
      )
      added_sql = paste0(added_sql, current_add)
    } else if (i_walk_approach == "forward"){
      current_add = paste0(
        " WHERE ",
        as_tab_name, i_following_id,
        " IN (",
        "SELECT ",
        i_following_id,
        " FROM ",
        i_waypoint_table
      )
      added_sql = paste0(added_sql, current_add)
    }
  }
  final_step = paste0(
    " WHERE ",
    return_id_name_from_table(starting_table),
    " IN (",
    argument,
    paste0(rep(")", nrow(path_dataframe) + 1), collapse = "")
  )

  final_query = paste0(
    sql_query,
    added_sql,
    final_step
  )

  return(final_query)
}

