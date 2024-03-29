#' Discover ID Introduction Steps
#'
#' This function identifies the steps in a join path where new IDs are introduced, allowing you to
#' determine at which join steps each ID variable is added to the query. It returns a data frame with
#' information about newly discovered IDs and the corresponding join step in the path.
#'
#' @param conn The connection object or database connection string.
#' @param full_path_dataframe A data frame representing the full join path, including columns: "table_to_join",
#'   "method", and "common_var".
#'
#' @return A data frame with information about newly discovered IDs and the corresponding join step.
discover_id_introduction_steps <- function(conn, full_path_dataframe){
  column_names = get_column_names(conn)
  column_names = column_names[which(base::grepl("_id$", column_names$column)), ]

  discovered_ids = data.frame()

  for (i in 1:nrow(full_path_dataframe)){
    current_table = full_path_dataframe$table_to_join[i]

    contained_ids = column_names[which(column_names$table == current_table), "column"]

    if (i > 1){
      newly_discovered_ids = contained_ids[which(!contained_ids %in% discovered_ids$newly_discovered_ids)]
    } else {
      newly_discovered_ids = contained_ids
    }

    discovery_id = i

    if (length(newly_discovered_ids) > 0){
      discovered_ids = rbind(discovered_ids, data.frame(newly_discovered_ids, discovery_id))
    }

    if (nrow(discovered_ids) >= length(unique(column_names$column))){
      break
    }
  }

  for (i in 1:nrow(discovered_ids)){
    if (discovered_ids$discovery_id[i] == 1){
      discovered_ids$join_table[i] = "tab"
    } else {
      discovered_ids$join_table[i] = paste0("dtjoin", discovered_ids$discovery_id[i] - 1)
    }
  }
  return(discovered_ids)
}
