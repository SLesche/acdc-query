#' Add Join Paths to Query
#'
#' This function generates an SQL query based on a specified connection, argument, and join path list.
#' It constructs a query that performs joins on multiple tables according to the provided join path,
#' incorporating requested variables and filter conditions as needed.
#'
#' @param conn The connection object or database connection string.
#' @param filter_statements The SQL-Filter statements extracted from the filter arguments list via 'get_filter_statement()'.
#' @param join_path_list A list representing the join path. Each element of the list should be a data frame
#'   describing a step in the join path with columns: "table_to_join", "method", and "common_var".
#' @param argument_sequence A numeric vector representing the AND/OR sequence of arguments.
#' @param requested_vars A character vector specifying the variables to be selected from the final query result.
#'   If `NULL`, all variables are selected.
#'
#' @return A SQL query string that represents the joined tables and requested variables.
#' @import DBI
add_join_paths_to_query <- function(conn, filter_statements, join_path_list, argument_sequence, requested_vars = NULL){
  starting_table = join_path_list[[1]]$table[1]

  starting_table_id = c()

  for (i in seq_along(join_path_list)){
    if (join_path_list[[i]]$table == starting_table){
      starting_table_id = i

      break
    }
  }
  # protection against queries located entirely within a table

  path_dataframe = join_path_list[[starting_table_id]]$path

  single_row_only = ifelse(nrow(path_dataframe) == 1, 1, 0)
  if (!single_row_only){
    path_dataframe = path_dataframe[-1, ]
  }

  # Figure out in which join step which id variable is added
  introduction_table = discover_id_introduction_steps(conn, join_path_list[[starting_table_id]]$path)


  # if you want to select id vars from different tables, need to add the join-prefixes
  if (any(base::grepl("id$", requested_vars))){
    for (i_var in seq_along(requested_vars)){
      if (base::grepl("_id$", requested_vars[i_var])){
        join_prefix = introduction_table[which(introduction_table$newly_discovered_ids == requested_vars[i_var]), "join_table"]
        requested_vars[i_var] = paste0(join_prefix, ".", requested_vars[i_var])
      }
    }
  }

  if (is.null(requested_vars)){
    selected_vars = " * "
  } else {
    selected_vars = paste(requested_vars, collapse = ", ")
  }

  if (starting_table == "observation_table") {
    sql_base_query = paste0(
      "SELECT ", selected_vars, " FROM ", starting_table, " AS tab"
    )
  } else {
    sql_base_query = paste0(
      "SELECT DISTINCT ", selected_vars, " FROM ", starting_table, " AS tab"
    )
  }

  sql_query = sql_base_query

  if (!single_row_only){
    for (i in 1:nrow(path_dataframe)){
      current_table_to_join = path_dataframe$table_to_join[i]
      current_method = path_dataframe$method[i]
      current_common_var = path_dataframe$common_var[i]

      # I only want to add new id variables to the joins, not any that are in there currently
      upcoming_important_ids = path_dataframe$common_var[i:nrow(path_dataframe)]
      already_introduced_ids = introduction_table[which(introduction_table$discovery_id < (i + 1)), "newly_discovered_ids"]
      upcoming_important_ids = upcoming_important_ids[(!upcoming_important_ids %in% already_introduced_ids) | (upcoming_important_ids %in% current_common_var)]

      table_field_names = DBI::dbListFields(conn, current_table_to_join)

      relevant_field_names = table_field_names[grepl(pattern = "_id$", table_field_names) | table_field_names %in% requested_vars]
      relevant_field_names = paste(relevant_field_names, collapse = ", ")

      common_vars = strsplit(path_dataframe$all_common_vars[i], ",")[[1]]
      join_var_statement = character()
      for (icommon in seq_along(common_vars)){
        current_common_var = common_vars[icommon]
        new_join_statement = paste0(
          # "((",
          introduction_table$join_table[introduction_table$newly_discovered_ids == current_common_var], # here I want to figure out where the relevant id is introduced (by which join step)
          ".",
          current_common_var,
          " = ",
          paste0("dtjoin", i),
          ".",
          current_common_var
          # ") OR (",
          # introduction_table$join_table[introduction_table$newly_discovered_ids == current_common_var], # here I want to figure out where the relevant id is introduced (by which join step)
          # ".",
          # current_common_var,
          # " IS NULL ",
          # " AND ",
          # paste0("dtjoin", i),
          # ".",
          # current_common_var,
          # " IS NULL ",
          # "))"
        )
        if (icommon == 1){
          join_var_statement = new_join_statement
        } else {
          join_var_statement = paste0(
            join_var_statement,
            " AND ",
            new_join_statement
          )
        }
      }

      if (current_method == "forward"){
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
        sql_query = paste0(
          sql_query,
          " FULL JOIN ",
          "(SELECT ",
          relevant_field_names,
          " FROM ",
          current_table_to_join,
          ")",
          " AS ", paste0("dtjoin", i),
          " ON ",
          join_var_statement
        )
      }
    }
  }

  combined_filter_statement = get_filter_statement(filter_statements, argument_sequence, introduction_table)
  sql_query = paste0(
    sql_query,
    " ",
    combined_filter_statement
  )
  return(sql_query)
}
