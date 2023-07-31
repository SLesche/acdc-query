#' @export
add_join_paths_to_query <- function(conn, argument, join_path_list, requested_vars = NULL){
  base_argument = argument
  starting_table = stringr::str_extract(base_argument, "[a-z]+_table")
  filter_statement = stringr::str_extract(base_argument, "WHERE .*$")

  if (is.null(requested_vars)){
    selected_vars = " * "
  } else {
    selected_vars = paste(requested_vars, collapse = ", ")
  }
  sql_base_query = paste0(
    "SELECT ", selected_vars, " FROM ", starting_table, " AS tab"
  )
  starting_table_id = c()

  for (i in seq_along(join_path_list)){
    if (join_path_list[[i]]$table == starting_table){
      starting_table_id = i

      break
    }
  }

  path_dataframe = join_path_list[[starting_table_id]]$path[-1, ]
  sql_query = sql_base_query

  # Figure out in which join step which id variable is added
  introduction_table = discover_id_introduction_steps(conn, join_path_list[[starting_table_id]]$path)

  for (i in 1:nrow(path_dataframe)){
    current_table_to_join = path_dataframe$table_to_join[i]
    current_method = path_dataframe$method[i]
    current_common_var = path_dataframe$common_var[i]

    # I only want to add new id variables to the joins, not any that are in there currently
    upcoming_important_ids = return_id_name_from_table(path_dataframe$table_to_join[i:nrow(path_dataframe)])
    already_introduced_ids = introduction_table[which(introduction_table$discovery_id < (i + 1)), "newly_discovered_ids"]
    upcoming_important_ids = upcoming_important_ids[!upcoming_important_ids %in% already_introduced_ids]

    relevant_field_names = DBI::dbListFields(conn, current_table_to_join)
    relevant_field_names = relevant_field_names[which(stringr::str_detect(relevant_field_names, "_id$", negate = TRUE) | relevant_field_names %in% upcoming_important_ids)]
    relevant_field_names = unique(c(relevant_field_names, return_id_name_from_table(current_table_to_join)))
    relevant_field_names = paste(relevant_field_names, collapse = ", ")

    if (current_method == "forward"){
      join_var_statement = paste0(
        introduction_table$join_table[i + 1], # here I want to figure out where the relevant id is introduced (by which join step)
        ".",
        current_common_var,
        " = ",
        paste0("dtjoin", i),
        ".",
        current_common_var
      )

      sql_query = paste0(
        sql_query,
        " LEFT JOIN ",
        "(SELECT ",
        relevant_field_names,
        " FROM ",
        current_table_to_join,
        ")",
        " AS ", paste0("dtjoin", i),
        " ON ",
        join_var_statement
      )
    } else {
      join_var_statement = paste0(
        "dtout",
        ".",
        current_common_var,
        " = ",
        "tab",
        ".",
        current_common_var
      )

      sql_query = paste0(
        "SELECT * FROM ",
        current_table_to_join,
        " AS dtout ",
        " LEFT JOIN (",
        sql_query,
        " ",
        filter_statement,
        ") AS tab ",
        join_var_statement
      )
    }
  }

  # if only forward joins, you need to add the filter statement
  used_modes = unique(path_dataframe$method)
  if (length(used_modes) == 1 & used_modes[1] == "forward"){
    sql_query = paste0(
      sql_query,
      " ",
      filter_statement
    )
  }
  return(sql_query)
}
