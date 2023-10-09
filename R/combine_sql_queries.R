#' Combine SQL Queries
#'
#' This function combines multiple SQL queries into a single query using logical OR and AND operations.
#' It takes a list of SQL query arguments, an argument sequence indicating the order of arguments,
#' and a path list for query conversion. The queries are combined using OR operations within each group and
#' AND operations between different groups of queries.
#'
#' @param arguments A list of SQL query arguments.
#' @param argument_sequence A numeric vector indicating the order of query arguments. Each number corresponds
#'   to the index of the query argument in the \code{arguments} list.
#' @param path_list A list representing the join path. Each element of the list should be a data frame
#'   describing a step in the join path with columns: "table_to_join", "method", and "common_var".
#' @param requested_vars A character vector specifying the variables to be selected from the final query result.
#'   If \code{NULL}, all variables are selected.
#'
#' @return A combined SQL query string that integrates the specified queries using logical OR and AND operations.
combine_sql_queries <- function(arguments, argument_sequence, path_list, requested_vars = NULL){
  sql_queries = vector(mode = "list", length = length(arguments))

  for (i in seq_along(arguments)){
    sql_queries[[i]] = convert_query_path_to_sql(arguments[[i]], path_list, requested_vars)
  }

  sql_base = paste0(base::gsub("WHERE .*", "", sql_queries[[1]]), "WHERE ")

  sql_base_remove = base::sub(" \\* ", ".*", sql_base)

  for (i in seq_along(sql_queries)){
    sql_queries[[i]] = base::gsub(sql_base_remove, "", sql_queries[[i]])
  }


  for (i in seq_along(argument_sequence)){
    # first concatenate the or arguments to one
    concatenated_args = vector(mode = "list", length = length(unique(argument_sequence)))

    for (j in seq_along(concatenated_args)){
      original_indeces = which(argument_sequence == j)
      concatenated_args[[j]] = paste0(
        sql_queries[original_indeces],
        collapse = " OR "
      )
      concatenated_args[[j]] = paste0(
        "(",
        concatenated_args[[j]],
        ")"
      )
    }
  }

  # now I just have "AND" relations left
  final_add = paste(concatenated_args, collapse = " AND ")

  if (is.null(requested_vars)){
    selected_vars = " * "
  } else {
    selected_vars = paste(requested_vars, collapse = ", ")
  }

  sql_base = base::sub(" \\* ", selected_vars, sql_base)

  final_query = paste0(sql_base, final_add)

  return(final_query)
}
