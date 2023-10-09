get_filter_statement <- function(filter_statements, argument_sequence, introduction_table){

  for (i in seq_along(argument_sequence)){
    # first concatenate the or arguments to one
    concatenated_args = vector(mode = "list", length = length(unique(argument_sequence)))

    for (j in seq_along(concatenated_args)){
      original_indeces = which(argument_sequence == j)
      concatenated_args[[j]] = paste0(
        filter_statements[original_indeces],
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

  no_where = base::gsub("WHERE ", "", final_add)
  filter_statement = paste("WHERE", no_where)

  # and need to add table-prefixes to id variables
  split_statement = strsplit(filter_statement, " ")[[1]]

  for (iword in seq_along(split_statement)){
    if (grepl("_id$", split_statement[iword])){
      no_id = base::sub("[a-z]+_id$", "", split_statement[iword])
      id = base::regmatches(split_statement[iword], base::gregexpr("[a-z]+_id$", split_statement[iword]))[[1]]
      split_statement[iword] = paste0(
        no_id,
        introduction_table[introduction_table$newly_discovered_ids == id, "join_table"],
        ".",
        id
      )
    }
  }

  filter_statement = paste(split_statement, collapse = " ")
  return(filter_statement)

}
