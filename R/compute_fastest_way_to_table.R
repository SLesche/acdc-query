#' Compute Fastest Way to Table
#'
#' This function computes the fastest way to reach a target table from given input table(s) in a database using a combination
#' of forward and backward joins. It returns a list of join paths along with waypoint tables and walk approaches (forward or backward)
#' that enable efficient traversal from the input table(s) to the target table.
#'
#' @param conn The connection object or database connection string.
#' @param input_table The input table(s) from which the traversal begins. If \code{NULL}, all tables are considered as inputs.
#' @param target_table The target table that you want to reach through joins.
#'
#' @return A list of join paths with waypoint tables and walk approaches.
#' @export
compute_fastest_way_to_table <- function(conn, input_table = NULL, target_table = "observation_table"){
  all_tables = DBI::dbListTables(conn)
  tables = all_tables[stringr::str_detect(all_tables, "sqlite", negate = TRUE)]

  n_tables = length(tables)

  table_info = vector(mode = "list", length = n_tables)


  for (i in seq_along(tables)){
    table_info[[i]]$table = tables[i]
    table_info[[i]]$fields = DBI::dbListFields(conn, tables[i])
    table_info[[i]]$ids = table_info[[i]]$fields[stringr::str_detect(table_info[[i]]$fields, "id$")]
  }

  target_table_index = c()
  input_table_index = c()
  for (i in seq_along(table_info)){
    if (table_info[[i]]$table == target_table){
      target_table_index = i
    }

    if (!is.null(input_table)){
      if (table_info[[i]]$table == input_table){
        input_table_index = i
      }
    }
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

  # Only discovers paths for input table if that is specified
  if (is.null(input_table)){
    indexes_to_compute = seq_along(table_info)
  } else {
    indexes_to_compute = input_table_index
  }

  for (i in indexes_to_compute){
    starting_table = table_info[[i]]$table
    explored_tables = c(starting_table)
    methods = c("base")
    common_var = c("base")

    if (starting_table == target_table){
      waypoint_tables = starting_table
      walk_approaches = "none"
    } else {
      target_table_connectors_forward = table_info[[target_table_index]]$forward
      target_table_connectors_backward = table_info[[target_table_index]]$backward

      target_table_connectors = c(target_table_connectors_forward$table, target_table_connectors_backward$table)

      starting_table_connectors_forward = table_info[[i]]$forward
      starting_table_connectors_backward = table_info[[i]]$backward

      starting_table_connectors = c(starting_table_connectors_forward$table, starting_table_connectors_backward$table)


      if (starting_table %in% target_table_connectors){
        if (starting_table %in% target_table_connectors_forward$table){
          waypoint_tables = starting_table
          walk_approaches = "backward"
        } else if (starting_table %in% target_table_connectors_backward$table){
          waypoint_tables = starting_table
          walk_approaches = "forward"
        }
      } else {
        connector_ids = which(starting_table_connectors %in% target_table_connectors)

        if (any(connector_ids > 0)){
          connector_tables = starting_table_connectors[connector_ids]
          if (length(connector_tables) > 1){
            connector_tables = connector_tables[which(connector_tables != "observation_table")]
          }

          waypoint_tables = c(starting_table, connector_tables[1])

          to_connector_table = c()
          walk_approaches = c()
          if (connector_tables[1] %in% starting_table_connectors_forward$table){
            walk_approaches = c(walk_approaches, "forward")
          } else if (connector_tables[1] %in% starting_table_connectors_backward$table){
            walk_approaches = c(walk_approaches, "backward")
          }

          # same for target tables, but now the walk order needs to be reversed
          if (connector_tables[1] %in% target_table_connectors_forward$table){
            walk_approaches = c(walk_approaches, "backward")
          } else if (connector_tables[1] %in% target_table_connectors_backward$table){
            walk_approaches = c(walk_approaches, "forward")
          }

        } else {
          # have observation tables be the last table in starting table connectors
          # dont want to make a connection via observation table if possible
          if ("observation_table" %in% starting_table_connectors){
            starting_table_connectors = starting_table_connectors[-which(starting_table_connectors == "observation_table")]
            starting_table_connectors = c(starting_table_connectors, "observation_table")
          }

          for (first_level_table in starting_table_connectors){
            first_level_table_id = c()
            for (itable_info in seq_along(table_info)){
              if (table_info[[itable_info]]$table == first_level_table){
                first_level_table_id = itable_info
                break
              }
            }

            first_level_table_connectors = c(
              table_info[[first_level_table_id]]$forward$table,
              table_info[[first_level_table_id]]$backward$table
            )

            connector_ids = which(first_level_table_connectors %in% target_table_connectors)
            if (any(connector_ids > 0)){
              path_found = 1
              connector_tables = first_level_table_connectors[connector_ids]
              if (length(connector_tables > 1)){
                connector_tables = connector_tables[which(connector_tables != "observation_table")]
              }

              waypoint_tables = c(starting_table, first_level_table, connector_tables[1])

              to_connector_table = c()
              walk_approaches = c()
              if (first_level_table %in% starting_table_connectors_forward$table){
                walk_approaches = c(walk_approaches, "forward")
              } else if (first_level_table %in% starting_table_connectors_backward$table){
                walk_approaches = c(walk_approaches, "backward")
              }

              if (connector_tables[1] %in% table_info[[first_level_table_id]]$forward$table){
                walk_approaches = c(walk_approaches, "forward")
              } else if (connector_tables[1] %in% table_info[[first_level_table_id]]$backward$table){
                walk_approaches = c(walk_approaches, "backward")
              }

              # same for target tables, but now the walk order needs to be reversed
              if (connector_tables[1] %in% target_table_connectors_forward$table){
                walk_approaches = c(walk_approaches, "backward")
              } else if (connector_tables[1] %in% target_table_connectors_backward$table){
                walk_approaches = c(walk_approaches, "forward")
              }
              break
            }
          }
        }
      }
    }
    table_info[[i]]$path = data.frame(
      waypoint_tables,
      walk_approaches
    )
  }

  useable_table_info_ids = c()
  if (is.null(input_table)){
    useable_table_info_ids = seq_along(table_info)
  } else {
    useable_table_info_ids = input_table_index
  }

  list_join_paths = vector(mode = "list", length = length(useable_table_info_ids))
  for (iinfo in seq_along(useable_table_info_ids)){
    list_join_paths[[iinfo]]$path = table_info[[useable_table_info_ids[iinfo]]]$path
    list_join_paths[[iinfo]]$table = table_info[[useable_table_info_ids[iinfo]]]$table
    list_join_paths[[iinfo]]$target_table = target_table
  }
  return(list_join_paths)
}
