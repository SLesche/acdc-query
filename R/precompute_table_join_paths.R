#' Precompute Table Join Paths
#'
#' This function precomputes join paths for all tables in a given database using a combination of forward and backward joins.
#' It generates a list of data frames representing the join paths for each table, including information about tables to join,
#' walk approaches (forward or backward), and common variables used for joining.
#'
#' @param conn The connection object or database connection string.
#'
#' @return A list of join paths for each table in the database.
#' @export
precompute_table_join_paths <- function(conn){
  all_tables = DBI::dbListTables(conn)
  tables = all_tables[stringr::str_detect(all_tables, "sqlite", negate = TRUE)]

  n_tables = length(tables)

  table_info = vector(mode = "list", length = n_tables)

  for (i in seq_along(tables)){
    table_info[[i]]$table = tables[i]
    table_info[[i]]$fields = DBI::dbListFields(conn, tables[i])
    table_info[[i]]$ids = table_info[[i]]$fields[stringr::str_detect(table_info[[i]]$fields, "id$")]
  }

  for (i in seq_along(table_info)){
    # Check forward mentions
      # so which table ids are mentioned in this table
    table_info[[i]]$forward = data.frame(
      table = return_table_name_from_id(table_info[[i]]$ids),
      id = table_info[[i]]$ids
    )

    # remove the table ifself in the forward mentions
    bad_rows = which(table_info[[i]]$forward$table == table_info[[i]]$table)

    table_info[[i]]$forward = table_info[[i]]$forward[-bad_rows, ]
  }

  for (i in seq_along(table_info)){
    other_ids = subset(seq_along(table_info), seq_along(table_info) != i)
    backward_mention_in = c()
    table_name = table_info[[i]]$table

    for (j in other_ids){
      forward_mentions = table_info[[j]]$forward$table
      other_table_name = table_info[[j]]$table
      if (table_name %in% forward_mentions){
        backward_mention_in = c(backward_mention_in, other_table_name)
      }
    }
    table_info[[i]]$backward = data.frame(table = backward_mention_in)
    table_info[[i]]$backward$ids = return_id_name_from_table(table_info[[i]]$backward$table)
  }

  for (i in seq_along(table_info)){
    table_info[[i]]$path = data.frame(
      position = 1:n_tables,
      table_to_join = "replace",
      method = "replace",
      common_var = "replace"
    )

    explored_tables = c(table_info[[i]]$table)
    methods = c("base")
    common_var = c("base")

    while (!all(tables %in% explored_tables)){
      # For all explored tables, find the one with the most forward links to
      # non-explored tables. If all are zero, then do a backward step.

      number_of_forward_unexplored_tables = rep(0, length(explored_tables))

      for (j in seq_along(explored_tables)){
        last_explored_table = explored_tables[j]

        index_last_explored_table = c()
        for (k in seq_along(table_info)){
          if (table_info[[k]]$table == last_explored_table){
            index_last_explored_table = k
          }
        }

        forward_tables = table_info[[index_last_explored_table]]$forward$table
        non_explored_forward = forward_tables[!forward_tables %in% explored_tables]

        n_unexplored_forward = length(non_explored_forward)

        number_of_forward_unexplored_tables[j] = n_unexplored_forward
      }

      max_unexplored = max(number_of_forward_unexplored_tables)

      best_forward_explorer = explored_tables[number_of_forward_unexplored_tables == max_unexplored][1]

      index_best_explored_table = c()
      for (j in seq_along(table_info)){
        if (table_info[[j]]$table == best_forward_explorer){
          index_best_explored_table = j
        }
      }

      forward_tables = table_info[[index_best_explored_table]]$forward$table
      non_explored_forward = forward_tables[!forward_tables %in% explored_tables]

      if (length(non_explored_forward) > 0){
        for (table in non_explored_forward){
          explored_tables = c(explored_tables, table)
          methods = c(methods, "forward")
          common_var = c(common_var, return_id_name_from_table(table))
        }
      } else {
        found_backward = 0
        backward_counter = 1
        while (found_backward == 0){
          # try each of the recent tables to backward join on something

          last_explored_table = utils::tail(explored_tables, backward_counter)[1]

          for (j in seq_along(table_info)){
            if (table_info[[j]]$table == last_explored_table){
              index_last_explored_table = j
            }
          }

          backward_tables = table_info[[index_last_explored_table]]$backward$table
          non_explored_backward = backward_tables[!backward_tables %in% explored_tables]

          if (length(non_explored_backward) > 0){
            backward_table = non_explored_backward[1]
            found_backward = 1
          } else {
            backward_counter = backward_counter + 1
          }
        }
        explored_tables = c(explored_tables, backward_table)
        methods = c(methods, "backward")
        common_var = c(common_var, return_id_name_from_table(last_explored_table))
      }
    }
    table_info[[i]]$path$table_to_join = explored_tables
    table_info[[i]]$path$method = methods
    table_info[[i]]$path$common_var = common_var
  }

  list_join_paths = table_info
  return(list_join_paths)
}
