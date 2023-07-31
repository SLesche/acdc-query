#' @export
combine_sql_queries <- function(arguments, argument_sequence, path_list, requested_vars = NULL){
  sql_queries = vector(mode = "list", length = length(arguments))

  for (i in seq_along(arguments)){
    sql_queries[[i]] = convert_query_path_to_sql(arguments[[i]], path_list, requested_vars)
  }

  sql_base = paste0(stringr::str_remove_all(sql_queries[[1]], "WHERE .*"), "WHERE ")

  sql_base_remove = stringr::str_replace(sql_base, " \\* ", ".*")

  for (i in seq_along(sql_queries)){
    sql_queries[[i]] = stringr::str_remove_all(sql_queries[[i]], sql_base_remove)
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

  sql_base = stringr::str_replace(sql_base, " \\* ", selected_vars)

  final_query = paste0(sql_base, final_add)

  return(final_query)
}
